#!/bin/bash
setupDir="$(dirname "$(readlink -f "$0")")"

bash "$setupDir/installs.sh"
bash "$setupDir/bash.sh"
bash "$setupDir/private.sh"
bash "$setupDir/ssh.sh"
bash "$setupDir/git.sh"
bash "$setupDir/sudo.sh"

echo
read -p "Setup firmware? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/firmware.sh"

echo
read -p "Setup firewall? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/firewall.sh"

echo
read -p "Setup mailing? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/mail.sh"

echo
read -p "Setup SSH Server? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/sshd.sh"

echo
read -p "Setup jobs? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/jobs.sh"

echo
read -p "Setup S.M.A.R.T.? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/smart.sh"

echo
read -p "Setup dynamic motd? (y/N) " && [[ $REPLY =~ ^[Yy]$ ]] \
 && bash "$setupDir/motd.sh"

echo
read -p "Setup desktop (y/N)? "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$setupDir/desktop-installs.sh"
  bash "$setupDir/desktop-setup.sh"
  bash "$setupDir/git-msladek.sh"
  read -p "Setup XFCE (y/N)?" && [[ $REPLY =~ ^[Yy]$ ]] \
    && bash "$setupDir/desktop-xfce.sh"
fi

echo -e "\n... all done!"
