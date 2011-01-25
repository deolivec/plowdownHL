# pdi : plowdown high level script 
#       get part
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

function getPremiumAccount()
{
  local serverConfigFile=0
  local user=""
  local pwd=""
  while read line ; do
    [[ $line == *$server* ]] && serverConfigFile=1

    if [ "$serverConfigFile" -eq "1" ] && [[ $line == *account=* ]] ; then
      user=$(echo $line|sed -n 's:account=\(.*\):\1:p')
      serverConfigFile=2
    fi
    if [ "$serverConfigFile" -eq "2" ] && [[ $line == *password=* ]] ; then
      pwd=$(echo $line|sed -n 's:password=\(.*\):\1:p')
      serverConfigFile=3
    fi
  done < $userConfigFile

  if [ "$user" != "" ] && [ "$pwd" != "" ] ; then
    case $server in
#      megaupload)
#        accountParameter="-a $user:$pwd"
#      ;;
#      fileserve)
#        accountParameter="-a $user:$pwd"
#      ;;
#      rapidshare)
#        accountParameter="-a $user:$pwd"
#      ;;
      x7_to)
        accountParameter="-b $user:$pwd"
      ;;
      *)
        accountParameter="-a $user:$pwd"
      ;;
    esac
  else
    accountParameter=""
  fi
}

function launchServerDownload()
{
  echoInfo "${RED}Starting download for ${CYAN}$server...${NC}"

  if [ "$restart" != "TRUE" ] ; then
    #cat /dev/null > "$downDone"_"$server"
    #cat /dev/null > "$downFailed"_"$server"
    cat /dev/null > "$plowdownStatus"_"$server"
  fi

  getPremiumAccount

  local count=1
  while [ "$count" -ne "-1" ] ; do

    #update FAILED list
    sed -n 's:^#NOTFOUND \(.*\):\1:p' "$downRemaining"_"$server" >> "$downFailed"_"$server"

    #update DONE list
    sed -n 's:^# \(.*\):\1:p' "$downRemaining"_"$server" >> "$downDone"_"$server"

    #update remaining list by removing FAILED and DONE links
    sed -i '/^\#.*/d' "$downRemaining"_"$server"

    count=$(wc -l < "$downRemaining"_"$server")
    if [ "$count" -eq "0" ] ; then
      count=-1
    else
      echoInfo "Downloads remaining on $server: $count"
      if [ "$DEBUG" == "OFF" ] ; then
        # -m : comment a link when downloaded sucessfully
        # -x : Do not overwrite existing files
        plowdown $accountParameter -m -x --temp-directory $tmpDir -o $downDir "$downRemaining"_"$server" &> "$plowdownStatus"_"$server"
        cat /dev/null > "$plowdownStatus"_"$server"
      else
        sleep 5
        echo DEBUG 2>/dev/null >>  "$plowdownStatus"_"$server"
      fi
      echoInfo "Check if download list was updated for $server"
    fi
  done

  echoInfo "${RED}Download on ${CYAN}$server ${RED}finished. Bye Bye...${NC}"
  \rm -f "$downRemaining"_"$server"
  \rm -f "$plowdownStatus"_"$server"
}

function addLink()
{
  [ "$#" -eq "0" ] && return

  local link=$(echo $@ | sed -n 's:.*\(http[^ ]*\).*:\1:p')
  local server=$(echo $link| sed -n 's#.*http://w*\.*\([^\.]*\).*#\1#p')
  local linkType
  local tmp=$logDir/tmp
  local err=0

  case $server in
    megaupload)
      if [ $(echo $link| sed -n 's:.*\.com/?\(.\)=.*:\1:p') == "f" ] ; then
        linkType="folder"
      else
        linkType="link"
      fi
    ;;
    "")
      linkType="none"
    ;;
    *)
      linkType="link"
    ;;
  esac

  case $linkType in
    folder)
      echoInfo "Adding the folder links: ${CYAN}$link${NC}"
      plowlist $link > $tmp
    ;;
    link)
      echo $link > $tmp
    ;;
    *)
      touch $tmp
      echoInfo "${RED}Invalid link: $@${NC}"
      err=1
    ;;
  esac

  while read link ; do
    if [ "$(grep $link "$downRemaining"_"$server" 2>/dev/null)" == "" ] ; then
      echoInfo "Adding the link: ${CYAN}$link${NC}"
      echo $link >> "$downRemaining"_"$server" 2>/dev/null
    else
      echoInfo "${RED}Link not added ${CYAN}$link${NC} (already in remaining list)"
      err=2
    fi
  done < $tmp
  \rm -f $tmp 2>/dev/null
  return $err
}

#
# Main
#

. /usr/local/share/plowdownHL/common.sh
[ "$downDir" == "" ] && echo -e "${RED}ERROR : download directory not correctly set in user config file.${NC}" && exit
[ ! -d "$downDir" ] && echo -e "${RED}ERROR : download directory doesn't exist.${NC}" && exit
[ ! -d "$logDir" ] && mkdir $logDir

[ "$#" -eq "0" ] && exit 1
[ "$1" == "-h" ] && exit 1

#update list download
input=""
list=""
restart=""
server=""
err=0

if [ "$1" == "--restart" ] ; then
  restart="TRUE"
  server=$2
  list=""
else
  restart="FALSE"
  list=$@
fi

for input in $list ; do
  if [ ! -e "$input" ] ; then
    addLink $input
    [ "$?" -ne "0" ] && err=2
  else
    echoInfo "Adding the file content: ${CYAN}$input${NC}"
    while read line ; do
      addLink $line
      [ "$?" -ne "0" ] && err=2
    done < $input
  fi
done

echoInfo "${BLUE}Download lists updated${NC}"

if [ "$restart" == "TRUE" ] ; then
  #launch a new thread
  echoInfo "${RED}Plowdown restart for ${CYAN}$server.${NC}"
  launchServerDownload &
else
  for file in $(ls "$downRemaining"_* 2>/dev/null) ; do
    server=$(echo $file | sed -n 's:.*_\(.*\):\1:p')
    if [ "$server" != "" ] ; then
      if [ ! -e "$plowdownStatus"_"$server" ]; then
        #launch a new thread
        launchServerDownload &
        [ "$err" == "2" ] && err=3
        [ "$err" != "3" ] && [ "$err" != "2" ] && err=4
      else
        echoInfo "${RED}plowdown already running for ${CYAN}$server.${NC}"
      fi
    fi
  done
fi
exit $err

