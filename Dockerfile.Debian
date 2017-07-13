# Build Debian Package in Docker
#
# Needs docker 17.05!
# https://docs.docker.com/engine/userguide/eng-image/multistage-build/#use-multi-stage-builds
#
# Build with "./build.sh docker_deb [‹distro›:‹codename› [‹build-opts›…]]"
#
# The ruby1.9 handling in 'package' is only needed for 'precise'.
# Trusty does not provide 'rubygems'.

ARG DISTRO=ubuntu
ARG CODENAME=xenial

FROM ${DISTRO}:${CODENAME} AS build
WORKDIR /build
ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::http::Timeout "90";' >/etc/apt/apt.conf.d/90docker.conf \
    && apt-get update -qq && apt-get install -qy \
        locales lsb-release build-essential pkg-config \
        subversion git time tmux curl wget ruby-dev \
        libssl-dev zlib1g-dev libncurses-dev libncursesw5-dev \
        libreadline-dev libcppunit-dev autoconf automake libtool \
    && rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" >/etc/locale.gen \
    && locale-gen --lang en_US.UTF-8
COPY patches/ ./patches
COPY build.sh tmp-docker/ ./
RUN ./build.sh install

FROM ${DISTRO}:${CODENAME} AS package
ENV DEBFULLNAME=pyroscope
ENV DEBEMAIL=pyroscope.project@gmail.com
WORKDIR /package
ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::http::Timeout "90";' >/etc/apt/apt.conf.d/90docker.conf \
    && apt-get update -qq && apt-get install -qy \
        lsb-release build-essential ruby ruby-dev \
    && ( test "$(lsb_release -cs)" = 'trusty' || apt-get install -qy rubygems ) \
    && ( test $(printf "%d%02d" $(ruby --version | tr . ' ' | cut -f2-3 -d' ')) -ge 109 \
         || ( apt-get install -qy ruby1.9.3 \
              && update-alternatives --set gem /usr/bin/gem1.9.1 ) ) \
    && rm -rf /var/lib/apt/lists/*
RUN gem install --no-rdoc --no-ri fpm -v 1.8.1
COPY --from=build /opt/rtorrent /opt/rtorrent/
COPY build.sh tmp-docker/ ./
RUN ./build.sh pkg2deb
