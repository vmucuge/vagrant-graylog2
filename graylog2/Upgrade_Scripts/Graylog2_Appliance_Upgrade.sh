#!/bin/bash
#Provided by @mrlesmithjr
#EveryThingShouldBeVirtual.com

# Graylog2 upgrade script for appliance

set -e
# Setup logging
# Logs stderr and stdout to separate files.
exec 2> >(tee "./graylog2/upgrade_graylog2.err")
exec > >(tee "./graylog2/upgrade_graylog2.log")

# Setup Pause function
function pause(){
   read -p "$*"
}

echo "Detecting IP Address"
IPADDY="$(ifconfig | grep -A 1 'eth1' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
echo "Detected IP Address is $IPADDY"

SERVERNAME=$IPADDY
SERVERALIAS=$IPADDY

# Stop Graylog2 Services
service graylog2-server stop
service graylog2-web-interface stop

# Remove graylog2 symlinks
rm /opt/graylog2-server
rm /opt/graylog2-web-interface

# Remove previous graylog2 server and web-interface
rm -rf /opt/graylog2-server*
cp /etc/graylog2.conf /etc/graylog2.conf.orig
rm -rf /opt/graylog2-web-interface*

# Download Graylog2-Server and Graylog2-Web-Interface
echo "Downloading Graylog2-Server and Graylog2-Web-Interface to /opt"
cd /opt
wget https://github.com/Graylog2/graylog2-server/releases/download/0.20.3/graylog2-server-0.20.3.tgz
wget https://github.com/Graylog2/graylog2-web-interface/releases/download/0.20.3/graylog2-web-interface-0.20.3.tgz

# Extract files
echo "Extracting Graylog2-Server and Graylog2-Web-Interface to /opt"
  for f in *.*gz
do
tar zxf "$f"
done

# Reconfigure graylog2-server startup
update-rc.d -f graylog2-server remove
update-rc.d graylog2-server defaults 96 04

# Create Symbolic Links
echo "Creating SymLink Graylog2-server"
ln -s graylog2-server-0.2*/ graylog2-server

# Install graylog2-server
echo "Installing graylog2-server"
echo -n "Enter a password to use for the admin account to login to the Graylog2 webUI: "
read adminpass
echo "You entered $adminpass (MAKE SURE TO NOT FORGET THIS PASSWORD!)"
pause 'Press [Enter] key to continue...'
cd graylog2-server/
cp /etc/graylog2.conf /etc/graylog2.conf.pre-upgrade
cp /opt/graylog2-server/graylog2.conf{.example,}
mv graylog2.conf /etc/
pass_secret=$(pwgen -s 96)
admin_pass_hash=$(echo -n $adminpass|sha256sum|awk '{print $1}')
sed -i -e 's|password_secret =|password_secret = '$pass_secret'|' /etc/graylog2.conf
sed -i -e "s|root_password_sha2 =|root_password_sha2 = $admin_pass_hash|" /etc/graylog2.conf
sed -i -e 's|elasticsearch_shards = 4|elasticsearch_shards = 1|' /etc/graylog2.conf
sed -i -e 's|mongodb_useauth = true|mongodb_useauth = false|' /etc/graylog2.conf
sed -i -e 's|#elasticsearch_discovery_zen_ping_multicast_enabled = false|elasticsearch_discovery_zen_ping_multicast_enabled = false|' /etc/graylog2.conf
sed -i -e 's|#elasticsearch_discovery_zen_ping_unicast_hosts = 192.168.1.203:9300|elasticsearch_discovery_zen_ping_unicast_hosts = 127.0.0.1:9300|' /etc/graylog2.conf

# Setting new retention policy setting or Graylog2 Server will not start
sed -i 's|retention_strategy = delete|retention_strategy = close|' /etc/graylog2.conf

# This setting is required as of v0.20.2 in /etc/graylog2.conf
sed -i -e 's|#rest_transport_uri = http://192.168.1.1:12900/|rest_transport_uri = http://127.0.0.1:12900/|' /etc/graylog2.conf

# Install graylog2 web interface
echo "Installing graylog2-web-interface"
cd /opt/
ln -s graylog2-web-interface-0.2*/ graylog2-web-interface

# Setting up graylog2 web interface
sed -i -e 's|graylog2-server.uris=""|graylog2-server.uris="http://127.0.0.1:12900/"|' /opt/graylog2-web-interface/conf/graylog2-web-interface.conf
app_secret=$(pwgen -s 96)
sed -i -e 's|application.secret=""|application.secret="'$app_secret'"|' /opt/graylog2-web-interface/conf/graylog2-web-interface.conf

# Fixing /opt/graylog2-web-interface Permissions
echo "Fixing Graylog2 Web Interface Permissions"
chown -R root:root /opt/graylog2*

# Cleaning up /opt
echo "Cleaning up"
rm /opt/graylog2-server*.*gz
rm /opt/graylog2-web-interface*.*gz

# Restart Services
service graylog2-server restart
service graylog2-web-interface restart

# All Done
echo "Installation has completed!!"
echo "Browse to IP address of this Graylog2 Server Used for Installation"
echo "IP Address detected from system is $IPADDY"
echo "Browse to http://$IPADDY:9000"
echo "Login with username: admin"
echo "Login with password: $adminpass"
echo "You Entered $SERVERNAME During Install"
echo "Browse to http://$SERVERNAME:9000 If Different"
echo "EveryThingShouldBeVirtual.com"
echo "@mrlesmithjr"
