FROM ubuntu:18.04
LABEL Maintainer="Yuri L Chuk"

#
# Create user and group for utorrent.
#

RUN groupadd -r -g 666 utorrent \
    && useradd -r -u 666 -g 666 -d /utorrent -m utorrent

#
# Add utorrent init script.
#

ADD utorrent.sh /utorrent.sh
RUN chown utorrent: /utorrent.sh \
    && chmod 755 /utorrent.sh

#
# Create settings folder.
#

RUN mkdir /settings \
    && chown utorrent: /settings  \
    && chmod 755 /settings

#
# Install utorrent and all required dependencies.
#

RUN apt-get -q update \
    && apt-get install -qy curl libssl1.0.0 libssl-dev vim \
    && curl -s http://download-new.utorrent.com/endpoint/utserver/os/linux-x64-ubuntu-13-04/track/beta/ | tar xzf - --strip-components 1 -C utorrent \
    && chown -R utorrent: utorrent \
    && apt-get -y remove curl \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

#
# Define container settings.
#

VOLUME ["/settings", "/utorrent/media/done", "/utorrent/media/downloading", "/utorrent/media/torrents"]

EXPOSE 8080 6881

#
# Start utorrent.
#

WORKDIR /utorrent

CMD ["/utorrent.sh"]