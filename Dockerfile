FROM ruby:3.2.2-alpine AS base

CMD ["/bin/sh", "-c", "-set", "-uex"]

RUN apk update \
    && apk add --no-cache \
    autoconf \
    bash \
    build-base \
    ca-certificates \
    curl \
    dpkg-dev dpkg \
    glib-dev \
    git \
    libpq-dev \
    libc-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    nodejs \
    openssl \
    openssl-dev \
    postgresql-client \
    tzdata \
    nano

FROM base AS release

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/Gemfile 
COPY Gemfile.lock /usr/src/app/Gemfile.lock

RUN gem install bundler -v 2.5.6 --no-document && \
    bundle install --jobs=3 --retry=3

COPY . /usr/src/app

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

EXPOSE 3000

CMD [ "rails", "server", "-b", "0.0.0.0" ]