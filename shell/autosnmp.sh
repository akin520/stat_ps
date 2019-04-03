#!/bin/bash
#
#
#


cat /etc/redhat-release |grep CentOS 2>&1 >/dev/null
if [ $? -ne 0 ];then
echo "OS no CentOS!"
exit 1
fi

yum install net-snmp* -y

if [ -f /etc/snmp/snmpd.conf ];then
rm -rf /etc/snmp/snmpd.conf
wget http://10.0.1.30/kysd_repo/shell/files/snmpd.conf -O /etc/snmp/snmpd.conf
fi

if [ -f /etc/sysconfig/snmpd.options ];then
rm -rf /etc/sysconfig/snmpd.options
wget http://10.0.1.30/kysd_repo/shell/files/snmpd -O /etc/sysconfig/snmpd.options
fi

if [ -f /etc/sysconfig/snmpd ];then
rm -rf /etc/sysconfig/snmpd
wget http://10.0.1.30/kysd_repo/shell/files/snmpd -O /etc/sysconfig/snmpd
fi

chkconfig snmpd on
service snmpd restart

clear
echo "====================================="
echo "installed"
echo "SNMP Community:kysd"
echo "====================================="
