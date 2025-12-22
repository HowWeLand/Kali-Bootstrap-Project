# apt aliases - Aptitude package management with tagging
alias retag='sudo aptitude add-user-tag'
alias untag='sudo aptitude remove-user-tag'
alias tag-orphans='aptitude search "?user-tag(?not(~g~i))"'
alias apt-update='sudo apt update'
alias apt-preview='apt list --upgradable'
alias apt-upgrade='sudo apt full-upgrade'
alias apt-clean='sudo apt-get autopurge'
alias apt-sizes='dpkg-query -W --showformat='"'"'${Installed-Size}\t${Package}\n'"'"' | sort -rn | head -20'
