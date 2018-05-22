FROM centos:7
RUN echo "export LC_ALL=C" >> /root/.bashrc
RUN yum install -y epel-release
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
RUN yum install -y python-pip php56w php56w-fpm php56w-devel
RUN yum -y groupinstall "Development tools"
ADD mongodb-org-3.6.repo /etc/yum.repos.d/
RUN yum install -y mongodb-org
RUN yum install -y php-pear gcc gcc-c++ make openssl-devel
COPY mongodb-1.3.0.tgz /usr/lib/mongodb-1.3.0.tgz
RUN cd /usr/lib; tar -xvf mongodb-1.3.0.tgz
RUN cd /usr/lib/mongodb-1.3.0 && phpize
RUN cd /usr/lib/mongodb-1.3.0 && ./configure --enable-mongodb
RUN cd /usr/lib/mongodb-1.3.0 && make && make install
RUN echo 'extension=mongodb.so' >> /etc/php.d/json.ini
RUN pecl channel-update pecl.php.net
RUN yum install -y GeoIP-devel java-1.8.0-openjdk-devel sshpass sendmail
RUN pecl install geoip
RUN curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
RUN yum -y install monit
RUN pip install stix
COPY config/php-fpm.d/* /etc/php-fpm.d/
COPY config/php.ini /etc/
COPY phpunit-5.7.phar /usr/bin/phpunit
RUN chmod a+x /usr/bin/phpunit
RUN yum install -y nginx
RUN openssl req -subj '/CN=cloudcoffer.com/C=US' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout /etc/nginx/server.key -out /etc/nginx/server.crt
COPY nginx.conf /etc/nginx/
RUN chmod -R 777 /var/lib/php/session
EXPOSE 9995