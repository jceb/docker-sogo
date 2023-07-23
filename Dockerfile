# Base image: https://hub.docker.com/r/phusion/baseimage/tags
# FROM phusion/baseimage:jammy-1.0.1
FROM phusion/baseimage:focal-1.2.0

# SOGo supported distributions: https://packages.sogo.nu/nightly/5/ubuntu/dists/
RUN curl -L https://keys.openpgp.org/vks/v1/by-fingerprint/74FFC6D72B925A34B5D356BDF8A27B36A6E2EAE9 | gpg --dearmor > /usr/share/keyrings/sogo-archive-keyring.gpg
# RUN echo "deb [signed-by=/usr/share/keyrings/sogo-archive-keyring.gpg] http://packages.inverse.ca/SOGo/nightly/5/ubuntu jammy jammy" > /etc/apt/sources.list.d/sogo.list
RUN echo "deb [signed-by=/usr/share/keyrings/sogo-archive-keyring.gpg] http://packages.inverse.ca/SOGo/nightly/5/ubuntu focal focal" > /etc/apt/sources.list.d/sogo.list

# Install Apache, SOGo from repository
RUN apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes && \
    apt-get install -y --no-install-recommends apache2 sogo sogo-activesync memcached mariadb-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Activate required Apache modules
RUN a2enmod headers proxy proxy_http rewrite ssl

# Move SOGo's data directory to /srv
RUN usermod --home /srv/lib/sogo sogo

# FIXME: somehow this confiugration causes a startup error
# ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libssl.so
ENV USEWATCHDOG=YES

# SOGo daemons
RUN mkdir -p /etc/service/sogod/log /etc/service/apache2/log /etc/service/memcached/log
ADD sogod.sh /etc/service/sogod/run
ADD sogod-log.sh /etc/service/sogod/log/run
ADD apache2.sh /etc/service/apache2/run
ADD apache2-log.sh /etc/service/apache2/log/run
RUN echo 'LogFormat "%h %A %l %u %t \"%r\" %>s %p %b" syslog' > /etc/apache2/httpd.conf && \
    cat /etc/apache2/apache2.conf >> /etc/apache2/httpd.conf && \
    mv /etc/apache2/httpd.conf /etc/apache2/apache2.conf && \
    sed -i -e 's|CustomLog \${APACHE_LOG_DIR}/access.log combined|CustomLog "\|/usr/bin/logger -t httpd -p local0.info" syslog|' -e 's|ErrorLog \${APACHE_LOG_DIR}/error.log|ErrorLog /dev/stdout|' /etc/apache2/sites-available/*.conf
ADD memcached.sh /etc/service/memcached/run
ADD memcached-log.sh /etc/service/memcached/log/run

# Make GATEWAY host available, control memcached startup
RUN mkdir -p /etc/my_init.d
ADD memcached-control.sh /etc/my_init.d/

# Interface the environment
VOLUME /srv
EXPOSE 80 443 8800

# Baseimage init process
ENTRYPOINT ["/sbin/my_init"]
CMD []
