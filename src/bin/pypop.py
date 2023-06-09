#!/usr/bin/env python

# This file is part of PyPop

# Copyright (C) 2003-2007. The Regents of the University of California (Regents)
# All Rights Reserved.

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

# IN NO EVENT SHALL REGENTS BE LIABLE TO ANY PARTY FOR DIRECT,
# INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
# LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
# DOCUMENTATION, EVEN IF REGENTS HAS BEEN ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.

# REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING
# DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS
# IS". REGENTS HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
# UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

"""Python population genetics statistics.
"""

import sys, os, time

DIR = os.path.abspath(os.path.dirname(__file__))
sys.path.insert(0, os.path.join(DIR, '..'))
sys.path.insert(0, os.path.join(DIR, '../src'))

import PyPop

######################################################################
# BEGIN: CHECK PATHS and FILEs
######################################################################

# create system-level defaults relative to where python is
# installed, e.g. if python is installed in sys.prefix='/usr'
# we look in /usr/share/pypop, /usr/bin/pypop etc.
# FIXME: this should be removed
datapath = os.path.join(sys.prefix, 'share', 'pypop')
binpath = os.path.join(sys.prefix, 'bin')
altpath = os.path.join(datapath, 'config.ini')

# find our exactly where the current pypop is being run from
pypopbinpath = os.path.dirname(os.path.realpath(sys.argv[0]))

version = PyPop.__version__
pkgname = PyPop.__pkgname__
  
######################################################################
# END: CHECK PATHS and FILEs
######################################################################

######################################################################
# BEGIN: generate message texts
######################################################################

copyright_message = """Copyright (C) 2003-2006 Regents of the University of California.
Copyright (C) 2007-2023 PyPop team.
This is free software.  There is NO warranty; not even for
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."""

interactive_message = """PyPop: Python for Population Genomics (%s)
%s

You may redistribute copies of PyPop under the terms of the
GNU General Public License.  For more information about these
matters, see the file named COPYING.

To accept the default in brackets for each filename, simply press
return for each prompt.
""" % (version, copyright_message)

######################################################################
# END: generate message texts
######################################################################

######################################################################
# BEGIN: parse command line options
######################################################################

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter, FileType
from pathlib import Path
from glob import glob
from configparser import ConfigParser
from PyPop.Main import getUserFilenameInput, checkXSLFile


parser = ArgumentParser(prog="pypop.py", description="""Process and run population genetics statistics on one or more INPUTFILEs.\n
Expects to find a configuration file called 'config.ini' in the\n
current directory""", epilog=copyright_message, formatter_class=ArgumentDefaultsHelpFormatter)

parser.add_argument("-c", "--config", help="select config file",
                    required=False, default='config.ini')
parser.add_argument("-m", "--testmode", help="run PyPop in test mode for unit testing", action='store_true', required=False, default=False)
parser.add_argument("-d", "--debug", help="enable debugging output (overrides config file setting)",
                    action='store_true', required=False, default=False)
parser.add_argument("-t", "--generate-tsv", help="generate TSV output files (aka run 'popmeta')",
                    action='store_true', required=False, default=False)
parser.add_argument("--enable-ihwg", help="enable 13th IWHG workshop populationdata default headers",
                    action='store_true', required=False, default=False)
parser.add_argument("-x", "--xsl", help="override the default XSLT translation with XSLFILE", 
                    metavar="XSLFILE", required=False, default=None)
parser.add_argument("-o", "--outputdir", help="put output in directory DIR",
                    required=False, type=Path, default=None)
parser.add_argument("-V", "--version", action='version', version="%(prog)s {version} {copyright}".format(version=version, copyright=copyright_message))

gp = parser.add_argument_group('Mutually exclusive input options')
gpm = gp.add_mutually_exclusive_group(required=True)
gpm.add_argument("-i", "--interactive", help="run in interactive mode, prompting user for file names",
                 action='store_true', default=False)
gpm.add_argument("-f", "--filelist", help="file containing list of files (one per line) to process\n(mutually exclusive with supplying POPFILEs)",
                 type=FileType('r'), default=None)
gpm.add_argument("popfiles", metavar="POPFILE", help="input population ('.pop') file(s)", nargs='*', default=[])

args = parser.parse_args()
                    
configFilename = args.config
xslFilename = args.xsl
debugFlag = args.debug
interactiveFlag = args.interactive
generateTSV = args.generate_tsv
testMode = args.testmode
fileList = args.filelist
outputDir = args.outputdir
popFilenames = args.popfiles      
ihwg_output = args.enable_ihwg

if outputDir:
    if not outputDir.is_dir():
      sys.exit("'%s' is not a directory, please supply a valid output directory" % outputDir)
    
# heuristics for default 'text.xsl' XML -> text file

if xslFilename:
  # first, check the command supplied filename first, return canonical
  # location and abort if it is not found immediately
  xslFilename = checkXSLFile(xslFilename, abort=True, debug=debugFlag)
  xslFilenameDefault = None

else:
  # if not supplied, use heuristics to set a default, heuristics may
  # return a valid path or None (but the value found here is always
  # overriden by options in the .ini file)

  if debugFlag:
    print("pypopbinpath", pypopbinpath)
    print("binpath", binpath)
    print("datapath", datapath)

  
  try:
    from importlib.resources import files
    mypath = files('PyPop.xslt')
  except (ModuleNotFoundError, ImportError):  # fallback to using backport if not found
    from importlib_resources import files
    mypath = files('PyPop.xslt').joinpath('')

  xslFilenameDefault = checkXSLFile('text.xsl', mypath, \
                                    abort=False, debug=debugFlag)

  if xslFilenameDefault == None:
    # otherwise use heuristics for XSLT transformation file 'text.xsl'
    # check child directory 'xslt/' first
    xslFilenameDefault = checkXSLFile('text.xsl', pypopbinpath, \
                                      'xslt', debug=debugFlag)
    # if not found  check sibling directory '../PyPop/xslt/'
    if xslFilenameDefault == None:
      xslFilenameDefault = checkXSLFile('text.xsl', pypopbinpath, \
                                        '../PyPop/xslt', debug=debugFlag)

######################################################################
# END: parse command line options
######################################################################

# call as a command-line application

# start by assuming an empty list of filenames
fileNames = []

if interactiveFlag:
  # run in interactive mode, requesting input from user

  # Choices made in previous runs of PyPop will be stored in a file
  # called '.pypoprc', stored the user's home directory
  # (i.e. $HOME/.pypoprc) so that in subsequent invocations of the
  # script it will use the previous choices as defaults.

  # For systems without a concept of a $HOME directory (i.e.
  # Windows), it will look for .pypoprc in the current directory.

  # The '.pypoprc' file will be created if it does not previously
  # exist.  The format of this file is identical to the ConfigParser
  # format (i.e. the .ini file format).
  
  if os.environ['HOME']:
    pypoprcFilename = os.path.join(os.environ['HOME'],'.pypoprc')
  else:
    pypoprcFilename = '.pypoprc'

  pypoprc = ConfigParser()
    
  if os.path.isfile(pypoprcFilename):
    pypoprc.read(pypoprcFilename)
    configFilename = pypoprc.get('Files', 'config')
    fileName = pypoprc.get('Files', 'pop')
  else:
    configFilename = 'config.ini'
    fileName = 'no default'

  print(interactive_message)
  
  # read user input for both filenames
  configFilename = getUserFilenameInput("config", configFilename)
  fileNames.append(getUserFilenameInput("population", fileName))

  print("PyPop is processing %s ..." % fileNames[0])
  
else:   
  # non-interactive mode: run in 'batch' mode

  if fileList:
    # if we are providing the filelist
    # use list from file as list to check
    #li = [f.strip('\n') for f in open(fileList).readlines()]
    li = [f.strip('\n') for f in fileList.readlines()]
    fileList.close() # make sure we close it
  elif popFilenames:
    # check number of arguments, must be at least one, but can be more
    # use args as list to check
    #li = args
    li = popFilenames
  # otherwise bail out with error
  #else:

  # loop through all arguments in li, appending to list of files to
  # process, ensuring we expand any Unix-shell globbing-style
  # arguments
  for fileName in li:
    globbedFiles = glob(fileName)
    if len(globbedFiles) == 0:
      # if no files were found for that glob, please exit and warn
      # the user
      sys.exit("Couldn't find file(s): %s" % fileName)
    else:
      fileNames.extend(globbedFiles)

# parse config file
from PyPop.Main import Main, getConfigInstance
config = getConfigInstance(configFilename, altpath)

xmlOutPaths = []
txtOutPaths = []
# loop through list of filenames passed, processing each in turn
for fileName in fileNames:

  # parse out the parts of the filename
  #baseFileName = os.path.basename(fileName)

  application = Main(config=config,
                     debugFlag=debugFlag,
                     fileName=fileName,
                     datapath=datapath,
                     xslFilename=xslFilename,
                     xslFilenameDefault=xslFilenameDefault,
                     outputDir=outputDir,
                     version=version,
                     testMode=testMode)

  xmlOutPaths.append(application.getXmlOutPath())
  txtOutPaths.append(application.getTxtOutPath())

if generateTSV:
  from PyPop.Meta import Meta
  
  print("Generating TSV (.dat) files...")
  Meta(popmetabinpath=pypopbinpath,
       datapath=datapath,
       metaXSLTDirectory=None,
       dump_meta=False,
       R_output=True,
       PHYLIP_output=False,
       ihwg_output=ihwg_output,
       batchsize=len(xmlOutPaths),
       outputDir=outputDir,
       xml_files=xmlOutPaths)

if interactiveFlag:

  print("PyPop run complete!")
  print("XML output(s) can be found in: ",  xmlOutPaths)
  print("Plain text output(s) can be found in: ",  txtOutPaths)

  # update .pypoprc file

  if pypoprc.has_section('Files') != 1:
    pypoprc.add_section('Files')
    
  pypoprc.set('Files', 'config', os.path.abspath(configFilename))
  pypoprc.set('Files', 'pop', os.path.abspath(fileNames[0]))
  pypoprc.write(open(pypoprcFilename, 'w'))

