#!/bin/bash
set -e

bundle exec rake ranking:update_ranking
# bundke exec rake ranking:update_star_ranking