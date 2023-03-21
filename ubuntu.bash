#!/bin/bash
cd ~/

current_hostname=$(hostname)
ssh_port=$(cat /etc/ssh/sshd_config | grep "^#\?Port" | awk ' { print $2}  ')

read -p "Введите новый hostname, либо нажмите Enter чтоб оставить текущий [$current_hostname]: " hostname
read -p "Введите номер ssh порта, либо нажмите Enter чтоб оставить текущий [$ssh_port]: " ssh_port
read -p "Вставьте свой публичный ключ, либо нажмите Enter чтоб продолжить: " ssh_key

if [[ "$hostname" != "" ]]; then
  hostnamectl set-hostname $hostname
  arrIN=(${hostname//./ })
  sed -i "s/127.0.1.1 .*/127.0.1.1 ${arrIN[0]} $hostname/" /etc/hosts
fi

re="^[1-5]{1}[0-9]{1,4}$"
if [[ "$ssh_port" != "" ]] && [[ $ssh_port =~ $re ]] ; then
  sed -i "s/^#\?Port .*/Port $ssh_port/" /etc/ssh/sshd_config
  sed -i "s/^ssh.*/ssh\t\t$ssh_port\/tcp/" /etc/services
fi

if [[ "$ssh_key" != "" ]]; then
  echo $ssh_key >> ~/.ssh/authorized_keys
fi

sed -i 's/.AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/.DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
sed -i 's/.DNS=.*/#DNS=8.8.8.8 1.1.1.1/' /etc/systemd/resolved.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved.service

apt-get install --assume-yes traceroute vim ipset build-essential libpq-dev libxml2 libxml2-dev libxslt-dev bash-completion nmon atop iotop htop net-tools bridge-utils iptraf-ng rar unrar zip unzip pigz fail2ban
update-alternatives --set editor /usr/bin/vim.basic
systemctl restart sshd;
ufw disable;apt remove --purge --assume-yes ufw
systemctl stop snapd;apt remove --purge --assume-yes snapd;rm -rf ~/snap/;rm -rf /var/cache/snapd/ 
timedatectl set-timezone Asia/Tashkent

chmod 400 /etc/update-motd.d/88-esm-announce
chmod 400 /etc/update-motd.d/91-contract-ua-esm-status
chmod 400 /etc/update-motd.d/50-motd-news
chmod 400 /etc/update-motd.d/10-help-text

echo 'export HISTTIMEFORMAT="%h %d %H:%M:%S "' >> ~/.bashrc
sed -i 's/HISTSIZE=.*/HISTSIZE=5000/' ~/.bashrc
sed -i 's/HISTFILESIZE=.*/HISTFILESIZE=5000/' ~/.bashrc
sed -i 's/HISTCONTROL.*//' ~/.bashrc
echo "PROMPT_COMMAND='history -a'" >> ~/.bashrc
source ~/.bashrc

echo "===================================="
echo "Reboot required!"
echo "Press enter to exit"
read end
