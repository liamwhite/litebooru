# litebooru [![Build Status](https://travis-ci.org/liamwhite/litebooru.svg?branch=master)](https://travis-ci.org/liamwhite/litebooru) [![Code Climate](https://codeclimate.com/github/liamwhite/litebooru/badges/gpa.svg)](https://codeclimate.com/github/liamwhite/litebooru) [![Test Coverage](https://codeclimate.com/github/liamwhite/litebooru/badges/coverage.svg)](https://codeclimate.com/github/liamwhite/litebooru/coverage)
open booru-on-rails clone

## Setup
1. Install PostgreSQL and libpq-dev (9.4 recommended, may not work with older versions)
2. Install Elasticsearch (1.7 recommended, should work with versions >= 1.4)
3. Install MRI dependencies `libxml2-dev libxslt-dev zlib1g-dev libssl-dev`
4. Install `rbenv` and ruby-build, and use it to `rbenv install` a recent Ruby version (currently >=2.2.2)
5. Clone this repo.
6. Install nginx and a webserver of your choice. Season to taste.
7. Load the schema:
  1. `sudo -u postgres -s`
  2. `psql`
  3. `create role litebooru with createdb login password 'password';`
  4. exit psql and go back to your user
  5. `bundle exec rake db:setup`
8. Have fun.

## License
AGPL v3
