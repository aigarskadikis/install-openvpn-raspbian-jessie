#!/bin/sh

#this code is tested un fresh 2016-05-27-raspbian-jessie-lite.img image

#sudo su
#apt-get update -y
#apt-get upgrade -y
#apt-get install git -y
#cd
#git clone https://github.com/catonrug/install-openvpn-raspbian-jessie.git && cd install-openvpn-raspbian-jessie && chmod +x install-openvpn.sh && ./install-openvpn.sh

apt-get update -y
apt-get upgrade -y

#install openvpn
apt-get install openvpn easy-rsa -y

#extract default configuration file
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf

#set some configuration
sed "s/^.*dh dh1024\.pem$/dh dh2048/" /etc/openvpn/server.conf | grep "dh dh2048"
sed -i "s/^.*dh dh1024\.pem$/dh dh2048/" /etc/openvpn/server.conf

sed "s/^.*push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf | grep "redirect-gateway def1 bypass-dhcp"
sed -i "s/^.*push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf

sed "s/^.*push \"dhcp-option DNS 208\.67\.222\.222\"/push \"dhcp-option DNS 208\.67\.222\.222\"/" /etc/openvpn/server.conf | grep "dhcp-option DNS 208\.67\.222\.222"
sed -i "s/^.*push \"dhcp-option DNS 208\.67\.222\.222\"/push \"dhcp-option DNS 208\.67\.222\.222\"/" /etc/openvpn/server.conf

sed "s/^.*push \"dhcp-option DNS 208\.67\.220\.220\"/push \"dhcp-option DNS 208\.67\.220\.220\"/" /etc/openvpn/server.conf | grep "dhcp-option DNS 208\.67\.220\.220"
sed -i "s/^.*push \"dhcp-option DNS 208\.67\.220\.220\"/push \"dhcp-option DNS 208\.67\.220\.220\"/" /etc/openvpn/server.conf

sed "s/^.*user nobody$/user nobody/" /etc/openvpn/server.conf | grep "user nobody"
sed -i "s/^.*user nobody$/user nobody/" /etc/openvpn/server.conf

sed "s/^.*group nogroup$/group nogroup/" /etc/openvpn/server.conf | grep "group nogroup"
sed -i "s/^.*group nogroup$/group nogroup/" /etc/openvpn/server.conf

#enable packed forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

#set packet forwarding after reboot
sed "s/^.*net\.ipv4\.ip_forward=1$/net\.ipv4\.ip_forward=1/" /etc/sysctl.conf | grep "net\.ipv4\.ip_forward=1"
sed -i "s/^.*net\.ipv4\.ip_forward=1$/net\.ipv4\.ip_forward=1/" /etc/sysctl.conf

#install and configure firewall
apt-get install ufw -y

#allow ssh connection throught firewall
ufw allow ssh

#allow udp connection for port 1194
ufw allow 1194/udp

DEFAULT_FORWARD_POLICY="DROP"


sed "s/^.*DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/" /etc/default/ufw | grep "DEFAULT_FORWARD_POLICY=\"ACCEPT\""
sed -i "s/^.*DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/" /etc/default/ufw

#insert some content before "Don't delete these required lines, otherwise there will be errors"
sed -i "0,/^.*Don.*delete these required lines.*otherwise there will be errors$/s/^.*Don.*delete these required lines.*otherwise there will be errors$/# START OPENVPN RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n# Allow traffic from OpenVPN client to eth0\n-A POSTROUTING -s 10\.8\.0\.0\/8 -o eth0 -j MASQUERADE\nCOMMIT\n# END OPENVPN RULES\n\n# Don\'t delete these required lines, otherwise there will be errors\n/" /etc/ufw/before.rules
cat /etc/ufw/before.rules

#enable firewall
echo y | ufw enable

#check firewall status
ufw status

cp -r /usr/share/easy-rsa/ /etc/openvpn

mkdir /etc/openvpn/easy-rsa/keys

sed -i "s/^export KEY_COUNTRY=\"US\"/^export KEY_COUNTRY=\"US\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/^export KEY_PROVINCE=\"TX\"/export KEY_PROVINCE=\"TX\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/^export KEY_CITY=\"Dallas\"/export KEY_CITY=\"Dallas\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/^export KEY_ORG=\"My Company Name\"/export KEY_ORG=\"My Company Name\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/^export KEY_EMAIL=\"sammy@example.com\"/export KEY_EMAIL=\"sammy@example.com\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/^export KEY_OU=\"MYOrganizationalUnit\"/export KEY_OU=\"MYOrganizationalUnit\"/" /etc/openvpn/easy-rsa/vars
sed -i "s/^export KEY_NAME=\"EasyRSA\"/export KEY_NAME=\"server\"/" /etc/openvpn/easy-rsa/vars

#time openssl dhparam -out /etc/openvpn/dh2048.pem 2048
