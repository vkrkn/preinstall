#!/bin/bash
cd ~/

echo "Введите hostname:"
read hostname
echo "Введите ssh порт:"
read ssh_port
echo "Вставьте свой публичный ключ:"
read ssh_key

if [[ "$hostname" != "" ]]; then
  hostnamectl set-hostname $hostname
  arrIN=(${hostname//./ })
  sed -i "s/127.0.1.1 .*/127.0.1.1 ${arrIN[0]} $hostname/" /etc/hosts
fi

if [[ "$ssh_port" != "" ]]; then
  sed -i "s/#Port .*/Port $ssh_port/" /etc/ssh/sshd_config
fi

if [[ "$ssh_key" != "" ]]; then
  echo $ssh_key >> ~/.ssh/authorized_keys
fi

sed -i 's/.AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
sed -i 's/.PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/.DNSStubListener=yes/DNSStubListener=no' /etc/systemd/resolved.conf
sed -i 's/.DNS=.*/DNS=8.8.8.8 1.1.1.1/' /etc/systemd/resolved.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

apt-get install --assume-yes ipset build-essential libpq-dev libxml2 libxml2-dev libxslt-dev bash-completion nmon atop iotop htop net-tools bridge-utils iptraf-ng rar unrar zip unzip pigz fail2ban
sed -i '285a\enabled\t= true' /etc/fail2ban/jail.conf
systemctl restart sshd; systemctl restart fail2ban
ufw disble;apt remove --purge --assume-yes ufw
systemctl stop snapd;apt remove --purge --assume-yes snapd;rm -rf ~/snap/;rm -rf /var/cache/snapd/ 
timedatectl set-timezone Asia/Tashkent

echo "Reboot required!"
echo "Press enter to exit"
read end