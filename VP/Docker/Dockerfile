FROM ruby:3.2.2-alpine3.17
USER root
RUN apk update && apk upgrade && apk add --update alpine-sdk && \
    apk add --no-cache bash make cmake

COPY ./start.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/start.sh

RUN apk add lighttpd
#RUN mkdir /etc/lighttpd/
COPY ./lighttpd.conf /etc/lighttpd/
COPY ./mod_cgi.conf /etc/lighttpd/

RUN mkdir /var/www/html
RUN mkdir /var/www/html/run
RUN echo "hello world" > /var/www/html/index.html
RUN echo "puts \"Content-type: text/plain\n\nI'm Alive\"" > /var/www/html/run/alive

RUN gem install linkeddata csv 

ENTRYPOINT ["/usr/local/bin/start.sh"]

# / # apk add lighttpd
# fetch https://dl-cdn.alpinelinux.org/alpine/v3.17/main/x86_64/APKINDEX.tar.gz
# fetch https://dl-cdn.alpinelinux.org/alpine/v3.17/community/x86_64/APKINDEX.tar.gz
# (1/9) Installing brotli-libs (1.0.9-r9)
# (2/9) Installing libdbi (0.9.0-r2)
# (3/9) Installing gdbm (1.23-r0)
# (4/9) Installing libsasl (2.1.28-r3)
# (5/9) Installing libldap (2.6.3-r6)
# (6/9) Installing lua5.4-libs (5.4.6-r0)
# (7/9) Installing pcre2 (10.42-r0)
# (8/9) Installing zstd-libs (1.5.5-r0)
# (9/9) Installing lighttpd (1.4.67-r0)
# Executing lighttpd-1.4.67-r0.pre-install
# Executing busybox-1.35.0-r29.trigger
# OK: 27 MiB in 45 packages
# / # ls /etc/lighttpd/
# lighttpd.conf         mime-types.conf       mod_cgi.conf          mod_fastcgi.conf      mod_fastcgi_fpm.conf
# / # curl
# sh: curl: not found
# / # wget
# BusyBox v1.35.0 (2022-11-19 10:13:10 UTC) multi-call binary.

# Usage: wget [-cqS] [--spider] [-O FILE] [-o LOGFILE] [--header STR]
# 	[--post-data STR | --post-file FILE] [-Y on/off]
# 	[-P DIR] [-U AGENT] [-T SEC] URL...

# Retrieve files via HTTP or FTP

# 	--spider	Only check URL existence: $? is 0 if exists
# 	--header STR	Add STR (of form 'header: value') to headers
# 	--post-data STR	Send STR using POST method
# 	--post-file FILE	Send FILE using POST method
# 	-c		Continue retrieval of aborted transfer
# 	-q		Quiet
# 	-P DIR		Save to DIR (default .)
# 	-S    		Show server response
# 	-T SEC		Network read timeout is SEC seconds
# 	-O FILE		Save to FILE ('-' for stdout)
# 	-o LOGFILE	Log messages to FILE
# 	-U STR		Use STR for User-Agent header
# 	-Y on/off	Use proxy
# / # wget localhost
# Connecting to localhost (127.0.0.1:80)
# wget: can't connect to remote host (127.0.0.1): Connection refused
# / # ps
#     PID TTY          TIME CMD
#      13 pts/1    00:00:00 sh
#      33 pts/1    00:00:00 ps
# / # ps -a
#     PID TTY          TIME CMD
#      34 pts/1    00:00:00 ps
# / # ps -aux
# USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root           1  0.1  0.1  99608 22532 pts/0    Ss+  01:36   0:00 irb
# root          13  0.0  0.0   1692  1160 pts/1    Ss   01:37   0:00 sh
# root          35  0.0  0.0   1712   884 pts/1    R+   01:39   0:00 ps -aux
# / # service lighttpd configtest
# sh: service: not found
# / # lighttpd
# lighttpd        lighttpd-angel
# / # lighttpd
# lighttpd        lighttpd-angel
# / # lighttpd
# lighttpd        lighttpd-angel
# / # lighttpd --help
# lighttpd: unrecognized option: -
# lighttpd/1.4.67 (ssl) - a light and fast webserver
# usage:
#  -f <name>  filename of the config-file
#  -m <name>  module directory (default: /usr/lib/lighttpd)
#  -i <secs>  graceful shutdown after <secs> of inactivity
#  -1         process single (one) request on stdin socket, then exit
#  -p         print the parsed config-file in internal form, and exit
#  -t         test config-file syntax, then exit
#  -tt        test config-file syntax, load and init modules, then exit
#  -D         don't go to background (default: go to background)
#  -v         show version
#  -V         show compile-time features
#  -h         show this help

# / # lighttpd -tt
# 2023-07-25 01:41:16: (server.c.1162) No configuration available. Try using -f option.
# / # gem
# RubyGems is a package manager for Ruby.
