#!/bin/sh

# if [ ! -f /etc/ocserv/server-key.pem ] || [ ! -f /etc/ocserv/server-cert.pem ]; then

# 	# Check environment variables
# 	[ -z "$CA_CN" ] && CA_CN="VPN CA"
# 	[ -z "$CA_ORG" ] && CA_ORG="My Organization"
# 	[ -z "$CA_DAYS" ] && CA_DAYS=9999
# 	[ -z "$SRV_CN" ] &&	SRV_CN="www.example.com"
# 	[ -z "$SRV_ORG" ] && SRV_ORG="My Company"
# 	[ -z "$SRV_DAYS" ] && SRV_DAYS=9999

# 	# If no certificate found, generate one
# 	cd /etc/ocserv
# 	certtool --generate-privkey --outfile ca-key.pem
# 	cat > ca.tmpl <<-EOCA
# 	cn = "$CA_CN"
# 	organization = "$CA_ORG"
# 	serial = 1
# 	expiration_days = $CA_DAYS
# 	ca
# 	signing_key
# 	cert_signing_key
# 	crl_signing_key
# 	EOCA
# 	certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca.pem
# 	certtool --generate-privkey --outfile server-key.pem 
# 	cat > server.tmpl <<-EOSRV
# 	cn = "$SRV_CN"
# 	organization = "$SRV_ORG"
# 	expiration_days = $SRV_DAYS
# 	signing_key
# 	encryption_key
# 	tls_www_server
# 	EOSRV
# 	certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem

# 	# Create a test user
# 	if [ -z "$NO_TEST_USER" ] && [ ! -f /etc/ocserv/data/ocpasswd ]; then
# 		echo "Creating test user 'test' with password 'test'"
# 		echo 'test:*:$5$DktJBFKobxCFd7wN$sn.bVw8ytyAaNamO.CvgBvkzDiFR6DaHdUzcif52KK7' > /etc/ocserv/data/ocpasswd
# 	fi
# fi

# Open ipv4 ip forward
sysctl -w net.ipv4.ip_forward=1

# Enable NAT forwarding
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A INPUT -p tcp --dport 4444 -j ACCEPT
# iptables -A INPUT -p udp --dport 4444 -j ACCEPT

iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Enable TUN device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# Run OpennConnect Server
exec "$@";

