FROM ubuntu:trusty
MAINTAINER Marcio Gimenez <marciogimenez1093@gmail.com>
LABEL Description="Imagem com Apache e PHP, baseada no Ubuntu. Inclui os mais populares recursos do PHP5.6." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST WWW PORT NUMBER]:443 -v [HOST WWW DOCUMENT ROOT]:/var/www/html marciogimenez/webserver-5.6" \
	Version="1.0"

	ADD run.sh /run.sh
	
    RUN DEBIAN_FRONTEND=noninteractive && \
    chmod +x /*.sh && \
    apt-get update && \
    apt-get install -y python-software-properties software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
	LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get install -y libapache2-mod-php5.6 php5.6-bcmath php5.6-bz2 php5.6-cli php5.6-common php5.6-phpdbg php5.6-curl php5.6-dba php5.6-gd php5.6-gmp php5.6-imap php5.6-intl php5.6-ldap php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-dev php5.6-odbc php5.6-pgsql php5.6-pspell php5.6-recode php5.6-snmp php5.6-soap php5.6-sqlite php5.6-tidy php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-zip  php5.6-json php5.6-gettext \
    apache2 git wget zip unzip vim && \
    apt-get remove -y python-software-properties software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    chmod 777 -R /var/www  && \
    apache2ctl -t && \
    mkdir -p /run /var/lib/apache2 /var/lib/php && \
    chmod -R 777 /run /var/lib/apache2 /var/lib/php /etc/php/5.6/apache2/php.ini
	

ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_SERVERNAME localhost
ENV APACHE_DOCUMENTROOT /var/www
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN a2enmod rewrite  && a2enmod php5.6 && chown -R www-data:www-data /var/www/html
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

VOLUME /var/www/html
VOLUME /var/log/httpd

EXPOSE 80
EXPOSE 443

ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www/html

ENTRYPOINT ["/run.sh"]
