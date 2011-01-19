# plowdownHL.sh : plowdown high level script
#                 cron part
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

. /usr/local/share/plowdownHL/common.sh
[ "$downDir" == "" ] && echo -e "${RED}ERROR : download directory not correctly set in user config file.${NC}" && exit
[ ! -d "$downDir" ] && echo -e "${RED}ERROR : download directory doesn't exist ($downDir).${NC}" && exit
[ ! -d "$logDir" ] && exit

listRemaining=$(ls "$downRemaining"_* 2>/dev/null)

for file in $listRemaining ; do
  server=$(echo $file | sed "s:$downRemaining.::")
  if [ -e "$plowdownStatus"_"$server" ] && [ "$(ps aux|grep plowdown|grep $server)" == "" ] ; then
    echoInfo "- CRON TASK - ${RED}Crash detected on ${CYAN}$server.${NC}" >> "$plowdownStatus"
    /usr/local/bin/pdg "--restart" $server
  else
    echoInfo "- CRON TASK - ${RED}$server running correctly...${NC}" >> "$plowdownStatus"
  fi
done

