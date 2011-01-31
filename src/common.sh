# pdi : plowdown high level script
#       common part
# Copyright (C) 2011 César DE OLIVEIRA
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

DEBUG="OFF"

logDir="/tmp/plowdown"
downRemaining=$logDir"/remaining"
downDone=$logDir"/done"
downFailed=$logDir"/failed"
plowdownStatus=$logDir"/status"
userConfigFile=/home/$USER/.plowdownHLrc

if [ -e $userConfigFile ] ; then
  downDir=$(sed -n 's:downloadDirectory=\(.*\):\1:p' $userConfigFile)
  #tmpDir=$downDir"/.plowdownTmp"
  tmpDir=$(sed -n 's:tmpDownloadDirectory=\(.*\):\1:p' $userConfigFile)
  [ "$tmpDir" == "" ] && tmpDir=$downDir
fi

# Define some colors first:
RED='\e[1;31m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color

function echoInfo
{
  echo -e "[$(date +"%Y-%m-%d %H:%M")] INFO: $@"
}

function usage()
{
  echo -e "${BLUE}************** Plowdown high level script usage **************${NC}"
  echo -e "${CYAN}Download: ${RED}pdg${NC} <URLs or/and files>"
  echo -e "${CYAN}Dowload state ${NC}(done, failed, remaining): ${RED}pdi${NC} [OPTIONS: -v for verbose mode -d for detailled mode]"
  echo -e "${CYAN}Download rate: ${RED}pdr${NC}"
  echo -e "${CYAN}Clean up: ${RED}pdc${NC}"
  echo -e "${BLUE}**************************************************************${NC}"
}

