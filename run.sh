#!/bin/bash
set -x
gem install bundler --version 1.17.3 --no-doc --no-ri
bundle install
bundle exec ruby ffi_test.rb
