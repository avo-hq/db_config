#!/bin/bash

set -e

gem build -o db_config.gem
gem push --key github --host https://rubygems.pkg.github.com/avo-hq ./db_config.gem
rm db_config.gem
