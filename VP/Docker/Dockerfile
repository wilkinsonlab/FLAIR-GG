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
COPY ./mime-types.conf /etc/lighttpd/

RUN mkdir /var/www/html
RUN mkdir /var/www/html/run
#RUN echo "hello world" > /var/www/html/index.html
#RUN echo "puts \"Content-type: text/plain\n\nI'm Alive\"" > /var/www/html/run/alive

RUN gem install linkeddata csv 

ENTRYPOINT ["/usr/local/bin/start.sh"]

