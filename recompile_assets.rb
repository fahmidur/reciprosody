#!/usr/bin/env bash

rm -rf ./public/assets/*

bundle exec rake assets:precompile
