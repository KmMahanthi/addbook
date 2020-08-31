FROM packages.netstratum.com/ubuntu:20.04

ARG version

# ARG uid

# ARG gid

ENV source=_build/default/rel/addbook/addbook-${version}.tar.gz

# ENV addbookuid=${uid}

# ENV addbookgid=${gid}

# RUN groupadd -r -g $addbookgid addbook && useradd -r -u $addbookuid -g $addbookgid addbook

ADD $source /opt/addbook

RUN mkdir /opt/addbook/var

# RUN chown -R addbook.addbook /opt/addbook

ENV SHELL /bin/bash

# USER addbook:addbook

VOLUME /opt/addbook/var

CMD ["/opt/addbook/bin/addbook", "foreground"]
