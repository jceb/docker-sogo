# Base image: https://hub.docker.com/r/phusion/baseimage/tags
FROM phusion/baseimage:focal-1.2.0

# SOGo supported distributions: https://packages.sogo.nu/nightly/5/ubuntu/dists/
RUN curl -L https://keys.openpgp.org/vks/v1/by-fingerprint/74FFC6D72B925A34B5D356BDF8A27B36A6E2EAE9 | gpg --dearmor > /usr/share/keyrings/sogo-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/sogo-archive-keyring.gpg] http://packages.inverse.ca/SOGo/nightly/5/ubuntu focal focal" > /etc/apt/sources.list.d/sogo.list

# Install Apache, SOGo from repository
# Workaround for sogo installation issue
RUN mkdir -p /usr/share/doc/sogo && touch /usr/share/doc/sogo/bugfix.sh
RUN apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes && \
    apt-get install -y --no-install-recommends apache2 sogo sogo-activesync memcached && \
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
