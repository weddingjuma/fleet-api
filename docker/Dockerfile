FROM mapotempo/nginx-passenger:2.0.1

LABEL maintainer="Mapotempo <contact@mapotempo.com>"

ENV RAILS_ENV production
ENV REDIS_HOST redis-cache

ADD . /srv/app

# Install app
RUN apt-get update && apt-get install -y apt-transport-https curl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN apt-get update && \
    apt-get install -y git build-essential zlib1g zlib1g-dev \
        cmake libevent-dev python-minimal && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs && \
    cd /srv/app && \
    bundle install --full-index --without test development && \
    \
    cd ./SyncFunction && \
    npm install && \
    cd .. && \
# Fix permissions
    chown -R www-data:www-data . && \
    \
# Cleanup Debian packages
    apt-get remove -y git build-essential cmake libevent-dev apt-transport-https curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ADD docker/env.d/* /etc/nginx/env.d/

VOLUME /srv/app/poly

WORKDIR /srv/app
