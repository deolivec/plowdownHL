# pdi : plowdown high level script
#       rate part
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
[ "$downDir" == "" ] && echo -e "${RED}ERROR : user config file not set correctly.${NC}" && exit
[ ! -d "$logDir" ] && exit
[  "$( ls "$plowdownStatus"_* 2>/dev/null)" == "" ] && echo -e "${CYAN}*** No more plowdown process running ***${NC}" && exit

loop="run"
choice=0
files=0
nbFiles=0

while [ "$loop" == "run" ] ; do
  files=$(ls "$plowdownStatus"_*)
  nbFiles=$(echo $files|wc -w)
  if [ "$nbFiles" -eq "1" ] ; then
    choice=1
    loop="exit"
  else
    echo "-----------------------------------"
    echo "Download status. Choose the server."
    echo "-----------------------------------"
    local count=1
    for file in $files ; do
      echo "$count: $(echo $file | sed "s:$plowdownStatus.::")"
      count=$((count+1))
    done
    echo "0: Quit"
    read choice
    [ "$choice" -ge 0 ] 2>/dev/null && [ "$choice" -le "$nbFiles" ]  && loop="exit"
  fi
done

if [ "$choice" -gt 0 ] && [ "$choice" -le "$nbFiles" ] ; then
  tail -f $(echo $files | cut -d' ' -f$choice)
fi

