FROM ruby:3.3.0

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:UTF-8" LC_ALL="C.UTF-8"
ENV RACK_ENV=production
RUN apt-get update -q
RUN apt-get -y dist-upgrade --fix-missing -q
RUN apt-get -y install git
RUN apt-get clean
RUN mkdir /app
WORKDIR /app
RUN gem update --system
RUN gem install bundler:2.3.12
COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN git clone https://github.com/wilkinsonlab/FLAIR-GG.git
COPY . .



ENTRYPOINT ["sh", "entrypoint.sh"]
