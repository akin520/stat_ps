#!/bin/bash
#rpm -Uhv http://rpmforge.sw.be/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
#rpm -Uhv http://mirrors.ustc.edu.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm

rpm -Uhv http://10.0.1.30/kysd_repo/shell/files/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
rpm -Uhv http://10.0.1.30/kysd_repo/shell/files/epel-release-6-8.noarch.rpm


yum -y install wget unzip cmake bison bison-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
yum -y install cmake libmcrypt libmcrypt-devel libmhash libmhash-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers




echo "add kysd repo!!!"
wget http://10.0.1.30/kysd_repo/kysd-cn.repo -O /etc/yum.repos.d/kysd.repo
