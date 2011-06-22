# pdi : plowdown high level script
#       setup part
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

#!/bin/bash

# Define some colors first:
RED='\e[1;31m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color


if [[ $EUID -ne 0 ]] 2>/dev/null; then
   echo -e "\n${RED}This script must be run as root${NC}" 1>&2
   echo -e "${BLUE}use sudo for example...${NC}\n"
   exit 1
fi

alias echo='/bin/echo -e'

case $1 in
  install)
    [ ! -e /usr/local/share/plowdownHL ] &&  \mkdir /usr/local/share/plowdownHL
    \cp src/* /usr/local/share/plowdownHL/
    \cp scripts/pdg /usr/local/bin/
    \cp scripts/pdi /usr/local/bin/
    \cp scripts/plowdownHL.cron /etc/cron.hourly/
    \rm -f /usr/local/bin/pd[rc] 2>/dev/null
    \ln -s /usr/local/share/plowdownHL/rate.sh /usr/local/bin/pdr
    \ln -s /usr/local/share/plowdownHL/clean.sh /usr/local/bin/pdc
    \chmod +x /usr/local/share/plowdownHL/*
    \chmod +x /etc/cron.hourly/plowdownHL.cron /usr/local/bin/pd[gi]
    if [ "$SUDO_USER" != "" ] ; then
      user=$SUDO_USER
    else
      echo "${BLUE}type user name account to configure${NC}"
      read user
    fi
    if [ ! -e /home/$user/.plowdownHLrc ] ; then
      \cp plowdownHLrc /home/$user/.plowdownHLrc
      \chown $user /home/$user/.plowdownHLrc
      echo "\n${RED}Don't forget to adapt your configuration file: ${CYAN}/home/$user/.plowdownHLrc${NC}"
    else
      echo "\n${BLUE}Configuration file already exist: ${CYAN}/home/$user/.plowdownHLrc${NC}" 
    fi
    \sed -i "s:USER_NAME:$user:" /home/$user/.plowdownHLrc
    \sed -i "s:USER_NAME:$user:" /etc/cron.hourly/plowdownHL.cron
    echo "${RED}To get help about this tool, type: ${CYAN}pdg -h${NC}"
    echo "${BLUE}install done.${NC}\n"
  ;;
  uninstall)
    \rm -fr /usr/local/share/plowdownHL
    \rm -f /usr/local/bin/{pdi,pdg,pdc,pdr}
    \rm -f /etc/cron.hourly/plowdownHL.cron
    echo "\n${RED}uninstall done.${NC}\n"
  ;;
  *)
    echo "\n${RED}Usage : install/uninstall${NC}\n"
  ;;
esac

