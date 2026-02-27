#!/bin/bash

set -e

gem build -o db_config.gem
gem push ./db_config.gem
rm db_config.gem
