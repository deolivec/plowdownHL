# pdi : plowdown high level script
#       information part
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

function extractStatus()
{
  [ "$#" -lt "3" ] && return
  local inputFile=$1
  local userMsg=$2
  local filter=$3
  local optionalFilter=$4
  local optionalDeleteFirstLine=$5

  local tmp=$logDir"/tmp"
  local server=""
  local header=0
  local nbLine=0

  local files=$(ls "$inputFile"_* 2> /dev/null)

  for file in $files ; do
    server=$(echo $file |sed "s:$inputFile.::")

    if [ -e $file ] && [ "$(wc -l < $file)" -ne "0" ]; then
      sed -n "s:$filter:\1:p" $file > $tmp
      #delete first line for the remaining downloads because it appears on the ongoing section
      [ "$optionalDeleteFirstLine" == "TRUE" ] && sed -i '1d' $tmp
    fi
    [ "$optionalFilter" != "" ] && [ -e "$downRemaining"_"$server" ] \
      &&  sed -n "s:$optionalFilter:\1:p" "$downRemaining"_"$server" >> $tmp

    if [ -e  $tmp ] ; then
      nbLine=$(wc -l < $tmp 2>/dev/null)
      if [ "$nbLine" -ne "0" ] ; then
        if [ "$header" == "0" ]; then
          header=1
          echo -e "${BLUE}----------------------"
          echo -e "Download(s) $userMsg:"
          echo -e "----------------------${NC}"
        fi
        echo -e "${CYAN}On $server: ${RED}$nbLine${NC}" 

        if [ "$detailed" == "TRUE" ] ; then
          if [ "$userMsg" == "succed" ] ; then
            while read line ; do
              link=$(echo $line |cut -d'|' -f1)
              file=$(echo $line |cut -d'|' -f2)
              echo -e "${CYAN}$file${NC} - $link"
            done < $tmp
          else
            cat $tmp
          fi
        fi
        if [ "$userMsg" == "succed" ] ; then
          local size=$(cut -d'|' -f2 < $tmp |xargs -d"\n" du -hc 2> /dev/null \
                | awk 'END {print $1}')
          echo -e "${CYAN}Total: ${RED}$size${NC}"
        fi
      fi
      \rm -f $tmp
    fi
  done
}

#
# Main
#

. /usr/local/share/plowdownHL/common.sh
[ "$downDir" == "" ] && echo -e "${RED}ERROR : download directory not correctly set in user config file.${NC}" && exit
[ ! -d "$downDir" ] && echo -e "${RED}ERROR : download directory doesn't exist.${NC}" && exit
[ ! -d "$logDir" ] && echo -e "${CYAN}*** No more plowdown process running ***${NC}" && exit

verbose="FALSE"
detailed="FALSE"

for arg in $@ ; do
  case $arg in
    -h)
      usage
      exit
    ;;
    -v)
      verbose="TRUE"
    ;;
    -d)
      detailed="TRUE"
    ;;
  esac
done

extractStatus $downRemaining "remaining" "^\([^#].*\)" "" "TRUE"
extractStatus $downDone "succed" "\(.*\)" "^# \(.*\)"
extractStatus $downFailed "failed" "\(.*\)" "^#NOTFOUND \(.*\)"

if [ "$( ls "$plowdownStatus"_* 2>/dev/null)" != "" ] ; then
  echo -e "${BLUE}---------------------"
  echo -e "Download(s) ongoing: "
  echo -e "---------------------${NC}"
  for file in $(ls "$plowdownStatus"_*) ; do
  fileName=$(sed -n 's/Filename: \(.*\)/\1/p' $file|tail -1)
  server=$(echo $file|sed "s:$plowdownStatus.::")
  if [ "$fileName" == "" ] ; then
    echo -e "${RED}Download doesn't start on ${CYAN}$server${NC}"
  else
      downloadStatusLine=$(tr  "\015" "\n" < $file|tail -1)

      fileDownloadPercentage=$(echo $downloadStatusLine |awk '{ print $1}')
      fileSize=$(echo $downloadStatusLine|awk '{ print $2}')
      fileDownloaded=$(echo $downloadStatusLine |awk '{ print $4}')
      timeSpent=$(echo $downloadStatusLine |awk 'END  { print $10}')
      timeRemaining=$(echo $downloadStatusLine |awk 'END  { print $11}')

      if [ "$(echo $fileDownloadPercentage|egrep '[0-9\.]+[kMG]')" == "" ] &&
           [ "$(echo $fileSize|egrep '[0-9\.]+[kMG]')" == "" ] &&
           [ "$(echo $fileDownloaded|egrep '[0-9\.]+[kMG]')" == "" ] &&
           [ "$(echo $timeSpent|egrep '[0-9\:]+')" == "" ] &&
           [ "$(echo $timeRemaining|egrep '[0-9\:]+')" == "" ] ; then
        echo -e "${RED}Download doesn't start for ${CYAN}$fileName${NC}"
      else
        echo -e "${RED}On $server${NC}"
        echo -e "${CYAN}Filename: ${NC}$fileName"
        echo -e "${CYAN}Downloaded: ${RED}$fileDownloadPercentage%${NC} ($fileDownloaded/$fileSize)."
        echo -e "${CYAN}Time spent: ${RED}$timeSpent. ${CYAN}Time remaining: ${RED}$timeRemaining.${NC}"
        echo
      fi
  fi
  done
fi

if [ "$verbose" == "TRUE" ] && [ -e $plowdownStatus ] ; then
  echo -e "${BLUE}----------------"
  echo -e "Plowdown status:"
  echo -e "----------------${NC}"
  cat $plowdownStatus
fi

if [ "$(ps -C plowdown| sed '1d')" == "" ] ; then
  if [ "$(ls "$plowdownStatus"_* 2> /dev/null)" != "" ] ; then
    echo
    echo -e "${RED}*** Plowdown crashed ***${NC}"
    echo
  else
    echo
    echo -e "${CYAN}*** No more plowdown process running ***${NC}"
    echo
  fi
fi
