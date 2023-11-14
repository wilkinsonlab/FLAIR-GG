FROM ruby:3.0.0

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:UTF-8" LC_ALL="C.UTF-8"
RUN chmod a+r /etc/resolv.conf

RUN mkdir /indexer
WORKDIR /indexer
RUN gem update --system
RUN gem install bundler:2.2.19
COPY . /indexer/
RUN bundle install
CMD ["ruby", "shacl-indexer-server.rb", "-o", "0.0.0.0"]

