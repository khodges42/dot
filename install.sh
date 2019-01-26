#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Permission denied"
   exit 1
fi

if [ -z "$SUDO_USERS" ]
then
      echo "\$SUDO_USERS is empty. Using $(ls /home)"
      SUDO_USERS=$(ls /home)
fi

if [ -z "$USER_FOLDERS" ]
then
   USER_FOLDERS="Code Mnt Junk"
fi

if [ -z "$USER_SOFTWARE" ]
then
   USER_SOFTWARE="python3 thunar curl feh nitrogen rsync terminator screen emacs zsh git wget python-pip python-dev build-essential software-properties-common"
fi

#Turn those space separated lists into bash arrays, except for the software (which we pass directly).
SUDO_USERS=($SUDO_USERS)
USER_FOLDERS=($USER_FOLDERS)

DEBIAN_FRONTEND=noninteractive apt -y install sudo
for user in $SUDO_USERS; do
   adduser $user sudo
done

#to look up other xfce4-panel plugins: apt-cache search panel plugin | less
apt install -y menu obmenu obsession openbox xorg network-manager xfce4-panel xfce4-cpugraph-plugin 
for user in $SUDO_USERS; do
   mkdir -p /home/$user/.config/openbox/
   cp /var/lib/openbox/debian-menu.xml /home/$user/.config/openbox/debian-menu.xml
   cp /etc/xdg/openbox/menu.xml /home/$user/.config/openbox/menu.xml
   cp /etc/xdg/openbox/rm.xml /home/$user/.config/openbox/rc.xml
   cp /home/$user/.bashrc /tmp/.bashrc && \awk '/force_color_prompt=/ { gsub(/#force/, "force") }; { print }' /tmp/.bashrc > /home/$user/.bashrc
   chown -R $user:$user /home/$user/
   echo "xset b off" >> /home/$user/.config/openbox/autostart
   echo "(sleep 1s && xfce4-panel) &" >> /home/$user/.config/openbox/autostart
   echo "(sleep 1s && nitrogen --restore) &" >> /home/$user/.config/openbox/autostart
   #after using nitrogen manually, the above command will restore the last used wallpaper on reboot/login.
done

openbox --reconfigure
apt install -y $USER_SOFTWARE

for user in $SUDO_USERS; do
   cp /home/$user/.Xresources /home/$user/.Xdefaults
   mkdir /home/$user/Audio /home/$user/Drawer /home/$user/Mnt /home/$user/Scripts /home/$user/Shred
   chown -R $user:$user /home/$user/
done
