#!/usr/bin/env python

# This file is part of PyPop

# Copyright (C) 2023
# PyPop contributors

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# IN NO EVENT SHALL CONTRIBUTORS BE LIABLE TO ANY PARTY FOR DIRECT,
# INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
# LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
# DOCUMENTATION, EVEN IF CONTRIBUTORS HAVE BEEN ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.

# REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING
# DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS
# IS". CONTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
# UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

import os, sys
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter, RawDescriptionHelpFormatter, FileType
from pathlib import Path

"""Command-line interface for PyPop scripts
"""

# combine both kinds of formats
class PyPopFormatter(ArgumentDefaultsHelpFormatter, RawDescriptionHelpFormatter):
    pass

def get_parent_cli(version="", copyright_message=""):
    # options common to both scripts
    parent_parser = ArgumentParser(add_help=False)
    parent_parser.add_argument("-o", "--outputdir", help="put output in directory OUTPUTDIR",
                               required=False, type=Path, default=None)
    parent_parser.add_argument("-V", "--version", action='version', version="%(prog)s {version}\n{copyright}".format(version=version, copyright=copyright_message))

    # define function arguments as signatures - need to be added in child parser as part of the selection logic
    ihwg_args = ("--enable-ihwg", {'help':"enable 13th IWHG workshop populationdata default headers",
                                   'action':'store_true', 'required':False, 'default':False})
    phylip_args = ("--enable-phylip", {'help':"enable generation of PHYLIP ``.phy`` files",
                                       'action':'store_true', 'required':False, 'default':False})
    return parent_parser, ihwg_args, phylip_args

def get_pypop_cli(version="", copyright_message=""):

    parent_parser, ihwg_args, phylip_args = get_parent_cli(version=version, copyright_message=copyright_message)
    pypop_parser = ArgumentParser(prog="pypop", parents=[parent_parser],
                            description="""Process and run population genetics statistics on one or more POPFILEs.
Expects to find a configuration file called 'config.ini' in the
current directory""", epilog=copyright_message, formatter_class=PyPopFormatter)

    pypop_parser.add_argument("-c", "--config", help="select config file",
                        required=False, default='config.ini')
    pypop_parser.add_argument("-m", "--testmode", help="run PyPop in test mode for unit testing", action='store_true', required=False, default=False)
    pypop_parser.add_argument("-d", "--debug", help="enable debugging output (overrides config file setting)",
                        action='store_true', required=False, default=False)
    pypop_parser.add_argument("-x", "--xsl", help="override the default XSLT translation with XSLFILE", 
                        metavar="XSLFILE", required=False, default=None)

    gp_tsv = pypop_parser.add_argument_group('Generate TSV output options', 'Note that --enable- flags only valid if --enable-tsv/-t selected')
    gp_tsv.add_argument("-t", "--enable-tsv", help="generate TSV output files (aka run 'popmeta')",
                        action='store_true', required=False, default=False)
    gp_tsv.add_argument(ihwg_args[0], **ihwg_args[1])
    gp_tsv.add_argument(phylip_args[0], **phylip_args[1])
    
    
    gp_input = pypop_parser.add_argument_group('Mutually exclusive input options')
    gpm = gp_input.add_mutually_exclusive_group(required=True)
    gpm.add_argument("-i", "--interactive", help="run in interactive mode, prompting user for file names",
                     action='store_true', default=False)
    gpm.add_argument("-f", "--filelist", help="file containing list of files (one per line) to process\n(mutually exclusive with supplying POPFILEs)",
                     type=FileType('r'), default=None)
    gpm.add_argument("popfiles", metavar="POPFILE", help="input population (``.pop``) file(s)", nargs='*', default=[])

    return pypop_parser

def get_popmeta_cli(version="", copyright_message=""):

    parent_parser, ihwg_args, phylip_args = get_parent_cli(version=version, copyright_message=copyright_message)
    popmeta_parser = ArgumentParser(prog="popmeta", parents=[parent_parser],
                                    epilog=copyright_message, description="""Processes XMLFILEs and generates 'meta'-analyses. XMLFILE are
expected to be the XML output files taken from runs of 'pypop'.  Will
skip any XML files that are not well-formed XML.""", formatter_class=PyPopFormatter)

    popmeta_parser.add_argument("--disable-tsv", help="disable generation of ``.dat`` TSV files",
                        action='store_false', dest="generate_dat", required=False, default=True)
    popmeta_parser.add_argument("--output-meta", help="dump the meta output file to stdout, ignore xslt file",
                        action='store_true', required=False, default=False)
    popmeta_parser.add_argument("-x", "--xsldir", help="use specified directory to find meta XSLT", 
                        metavar="XSLDIR", required=False, default=None)
    popmeta_parser.add_argument(ihwg_args[0], **ihwg_args[1])
    group = popmeta_parser.add_mutually_exclusive_group(required=False)
    group.add_argument(phylip_args[0], **phylip_args[1])
    group.add_argument("-b", "--batchsize", help="process in batches of size total/FACTOR rather than all at once, by default do separately (batchsize=0)",
                        type=int, metavar="FACTOR", required=False, default=0)

    popmeta_parser.add_argument("xmlfiles", metavar="XMLFILE", help="XML (``.xml``) file(s) generated by pypop runs", nargs='+', default=[])

    return popmeta_parser
