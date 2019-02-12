FROM centos:7
RUN echo "export LC_ALL=C" >> /root/.bashrc
RUN yum install -y epel-release
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
RUN yum install -y python-pip php56w php56w-fpm php56w-devel
RUN yum -y groupinstall "Development tools"
ADD mongodb-org-3.6.repo /etc/yum.repos.d/
RUN yum install -y mongodb-org git
RUN yum install -y php-pear gcc gcc-c++ make openssl-devel
WORKDIR /usr/share/
RUN git clone https://github.com/william9527/mongo-php-driver.git
WORKDIR /usr/share/mongo-php-driver
RUN git checkout 1.3.0
RUN git submodule init
RUN git submodule update
RUN phpize
RUN ./configure --enable-mongodb
RUN make && make install
RUN echo 'extension=mongodb.so' >> /etc/php.d/json.ini
RUN pecl channel-update pecl.php.net
RUN yum install -y GeoIP-devel java-1.8.0-openjdk-devel sshpass sendmail sudo
RUN pecl install geoip
RUN curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
RUN yum -y install monit
RUN pip install stix docker pymongo pyyaml
COPY config/php-fpm.d/* /etc/php-fpm.d/
COPY config/php.ini /etc/
COPY phpunit-5.7.phar /usr/bin/phpunit
RUN chmod a+x /usr/bin/phpunit
RUN yum install -y mod_security mod_ssl crontabs
RUN yum install -y httpd-devel libxml2-devel yajl yajl-devel python-pip git
RUN mkdir -p /tmp/upload_file
RUN chmod 755 /tmp/upload_file
RUN chmod 766 /etc/httpd
RUN touch /etc/httpd/virtualhosts.conf
RUN chmod 777 /etc/httpd/virtualhosts.conf
RUN mkdir -p /var/log/rule
WORKDIR /usr/share
RUN git clone https://github.com/william9527/ModSecurity.git
WORKDIR /usr/share/ModSecurity
RUN git checkout mxs; sh autogen.sh;sh configure;make;make install
RUN rm /etc/httpd/conf.d/ssl.conf
RUN yum install -y nginx
RUN openssl req -subj '/CN=cloudcoffer.com/C=US' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout /etc/nginx/server.key -out /etc/nginx/server.crt
COPY nginx.conf /etc/nginx/
RUN chmod -R 777 /var/lib/php/session
RUN yum install -y clamav
RUN freshclam

EXPOSE 9995
