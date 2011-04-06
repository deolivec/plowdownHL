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

if [[ $EUID -ne 0 ]] ; then
   echo "This script must be run as root" 1>&2
   echo "use sudo for example..."
   exit 1
fi

case $1 in
  install)
    \mkdir /usr/local/share/plowdownHL
    \cp src/* /usr/local/share/plowdownHL/
    \cp scripts/pdg /usr/local/bin/
    \cp scripts/pdi /usr/local/bin/
    \cp scripts/plowdownHL.cron /etc/cron.hourly/
    \ln -s /usr/local/share/plowdownHL/rate.sh /usr/local/bin/pdr
    \ln -s /usr/local/share/plowdownHL/clean.sh /usr/local/bin/pdc
    \chmod +x /usr/local/share/plowdownHL/*
    \chmod +x /etc/cron.hourly/plowdownHL.cron /usr/local/bin/pd[gi]
    if [ "$SUDO_USER" != "" ] ; then
      user=$SUDO_USER
    else
      echo "type user name account to configure"
      read user
    fi
    if [ ! -e /home/$user/.plowdownHLrc ] ; then
      cp plowdownHLrc /home/$user/.plowdownHLrc
      chown $user /home/$user/.plowdownHLrc
      echo "Don't forget to adapt your configuration file: /home/$user/.plowdownHLrc"
    else
      echo "Configuration file already exist : /home/$user/.plowdownHLrc" 
    fi
    sed -i "s:USER_NAME:$user:" /home/$user/.plowdownHLrc
    sed -i "s:USER_NAME:$user:" /etc/cron.hourly/plowdownHL.cron
    echo "install done."
  ;;
  uninstall)
    \rm -fr /usr/local/share/plowdownHL
    \rm -f /usr/local/bin/{pdi,pdg,pdc,pdr}
    \rm -f /etc/cron.hourly/plowdownHL.cron
    echo "uninstall done."
  ;;
  *)
    echo "Usage : install/uninstall"
  ;;
esac

