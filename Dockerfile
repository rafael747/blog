# syntax=docker/dockerfile:1
FROM ruby:2.5
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

EXPOSE 4000

