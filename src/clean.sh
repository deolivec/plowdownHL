# plowdownHL.sh : plowdown high level script
#                 clean part
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

echo "Do you really want to clean all the process and data ? (y/n)"
read choice

if [ "$choice" == "y" ] ; then
  for pid in $(ps aux|grep plowdown |awk '{print $2}'); do kill $pid 2>/dev/null; done
  for pid in $(ps aux|grep curl |awk '{print $2}'); do kill $pid 2>/dev/null; done
  #delete plowshare traces and plowdownHL traces
  \rm -fr /tmp/plowdown*
  [ "$tmpDir" != "" ] && [ "$downDir" != "$tmpDir" ] && \rm -f $tmpDir/*
  echo -e "${RED}Clean done."
else
  echo -e "${RED}Nothing done."
fi
echo -e "${NC}"

