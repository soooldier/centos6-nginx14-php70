FROM centos:centos6
MAINTAINER Tang Yi<soooldier@live.com>

# Install base tool
RUN yum -y install vim wget tar


# Install develop tool
RUN yum -y groupinstall development


# Install php rpm
RUN rpm --import http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6 && \
    rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm


# Install crontab service
RUN yum -y install vixie-cron crontabs


# Install Git need package
RUN yum -y install curl-devel expat-devel gettext-devel devel zlib-devel perl-devel


# Install php-fpm (https://webtatic.com/packages/php70/
RUN yum -y install php70w php70w-fpm php70w-mbstring php70w-xml php70w-mysql php70w-pdo php70w-gd php70w-pecl-imagick php70w-opcache php70w-bcmath php70w-pecl-redis


# Install php-mssql,mcrypt
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN yum -y install php70w-mcrypt


# Install nginx
RUN rpm --import http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6 && \
    rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
    yum -y update nginx-release-centos && \
    cp -p /etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo.backup && \
    sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/nginx.repo
RUN yum -y --enablerepo=nginx install nginx


# Install supervisor
RUN yum -y install python-setuptools && \
    easy_install supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf


# Install Git Laster Version
RUN cd ~/ && \
    wget https://www.kernel.org/pub/software/scm/git/git-2.6.3.tar.gz && \
    tar zxf ./git-2.6.3.tar.gz && \
    cd ./git-2.6.3 && \
    ./configure && make && make install && \
    rm -rf ~/git-2.6.3*


# Copy files for setting
ADD . /opt/


# Create Base Enter Cont Command
RUN chmod 755 /opt/docker/bash/init-bashrc.sh && echo "/opt/docker/bash/init-bashrc.sh" >> /root/.bashrc


# Setting lnmp(php,lnmp)
RUN chmod 755 /opt/docker/bash/setting-lnmp.sh && bash /opt/docker/bash/setting-lnmp.sh


# Setting DateTime Zone
RUN cp -p /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


# Setup default path
WORKDIR /home


# Private expose
EXPOSE 22 80 8080


# Volume for web server install
VOLUME ["/home/website","/home/config","/home/logs"]


# Start run shell
CMD ["bash"]
