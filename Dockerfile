FROM debian:jessie

# Update the package repository
RUN set -x \
 && DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        locales \
        build-essential \
        bzip2 \
        libssl-dev \
        libxml2 \
        libxml2-dev \
        libpcre3 \
        libpcre3-dev \
        tcl \
        tcl-dev \
        libboost-dev \
    # Configure locale
 && export LANGUAGE=en_US.UTF-8 \
 && export LANG=en_US.UTF-8 \
 && export LC_ALL=en_US.UTF-8 \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    # Install TrafficServer
    # https://trafficserver.apache.org/downloads
 && mkdir /tmp/trafficserver \
 && cd /tmp/trafficserver \
 && curl -L http://www-eu.apache.org/dist/trafficserver/trafficserver-7.0.0.tar.bz2 | tar -xj --strip-components 1 \
 && ./configure \
 && make install \
 && cd / \
    # Install dumb-init
    # https://github.com/Yelp/dumb-init
 && DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")') \
 && curl -Lo /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI" \
 && chmod +x /usr/local/bin/dumb-init \
    # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
        build-essential \
        bzip2 \
        libssl-dev \
        libxml2-dev \
        libpcre3-dev \
        tcl-dev \
        libboost-dev \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/*

EXPOSE 8080

ENTRYPOINT ["dumb-init"]
CMD ["traffic_cop", "--stdout"]
