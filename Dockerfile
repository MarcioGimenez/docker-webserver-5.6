FROM ubuntu:trusty
MAINTAINER Marcio Gimenez <marciogimenez1093@gmail.com>
LABEL Description="Imagem com Apache e PHP, baseada no Ubuntu. Inclui os mais populares recursos do PHP5.6." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST WWW PORT NUMBER]:443 -v [HOST WWW DOCUMENT ROOT]:/var/www/html marciogimenez/webserver-5.6" \
	Version="1.1"

    RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y python-software-properties software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
	LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get install -y libapache2-mod-php5.6 php5.6-bcmath php5.6-bz2 php5.6-cli php5.6-common php5.6-phpdbg php5.6-curl php5.6-dba php5.6-gd php5.6-gmp php5.6-imap php5.6-intl php5.6-ldap php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-dev php5.6-odbc php5.6-pgsql php5.6-pspell php5.6-recode php5.6-snmp php5.6-soap php5.6-sqlite php5.6-tidy php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-zip  php5.6-json php5.6-gettext \
    apache2 git wget zip unzip vim supervisor && \
    apt-get remove -y python-software-properties software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    chmod 777 -R /var/www  && \
    apache2ctl -t && \
    mkdir -p /run /var/lib/apache2 /var/lib/php && \
    chmod -R 777 /run /var/lib/apache2 /var/lib/php /etc/php/5.6/apache2/php.ini
	
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_SERVERNAME localhost
ENV APACHE_DOCUMENTROOT /var/www/html
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN a2enmod rewrite  && a2enmod php5.6 && chown -R www-data:www-data /var/www/html
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf


RUN sed -i "s/memory_limit = 128M/memory_limit = 1024M/g" /etc/php/5.6/apache2/php.ini \
 && sed -i "s/display_errors = Off/display_errors = On/g" /etc/php/5.6/apache2/php.ini \
 && sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php/5.6/apache2/php.ini \
 && sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/g" /etc/php/5.6/apache2/php.ini \
 && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 99M/g" /etc/php/5.6/apache2/php.ini \
 && sed -i "s/post_max_size = 8M/post_max_size = 100M/g" /etc/php/5.6/apache2/php.ini \
 && sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php/5.6/apache2/php.ini

RUN service apache2 stop \
 && a2enmod rewrite \
 && a2enmod headers \
 && a2enmod expires \
 && a2enmod remoteip \
 && a2dissite 000-default \
 && update-rc.d apache2 disable

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

VOLUME /var/www/html
VOLUME /var/log/httpd

EXPOSE 80
EXPOSE 443

ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

#WORKDIR /var/www/html

# Supervised Apache
CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
