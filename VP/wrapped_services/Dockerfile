FROM ruby:3.3.0

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:UTF-8" LC_ALL="C.UTF-8"

USER root
RUN apt-get -y update && apt-get -y upgrade 
RUN apt-get -y update
RUN apt-get install -y libraptor2-0 

RUN mkdir /server
WORKDIR /server
RUN gem update --system
RUN gem install bundler:2.3.12
COPY ./ /server
WORKDIR /server
RUN bundle install
WORKDIR /server/wrapped_services
