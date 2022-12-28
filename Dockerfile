# Base image: https://hub.docker.com/r/phusion/baseimage/tags
FROM phusion/baseimage:focal-1.2.0

# SOGo supported distributions: https://packages.sogo.nu/nightly/5/ubuntu/dists/
RUN echo "deb http://packages.inverse.ca/SOGo/nightly/5/ubuntu focal focal" > /etc/apt/sources.list.d/sogo.conf

# Install Apache, SOGo from repository
RUN apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes && \
    apt-get install -y --no-install-recommends apache2 sogo memcached && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Activate required Apache modules
RUN a2enmod headers proxy proxy_http rewrite ssl

# Move SOGo's data directory to /srv
RUN usermod --home /srv/lib/sogo sogo

# FIXME: somehow this confiugration causes a startup error
# ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libssl.so
ENV USEWATCHDOG=YES

# SOGo daemons
RUN mkdir -p /etc/service/sogod /etc/service/apache2 /etc/service/memcached
ADD sogod.sh /etc/service/sogod/run
ADD apache2.sh /etc/service/apache2/run
ADD memcached.sh /etc/service/memcached/run

# Make GATEWAY host available, control memcached startup
RUN mkdir -p /etc/my_init.d
ADD memcached-control.sh /etc/my_init.d/

# Interface the environment
VOLUME /srv
EXPOSE 80 443 8800

# Baseimage init process
ENTRYPOINT ["/sbin/my_init"]
CMD []
