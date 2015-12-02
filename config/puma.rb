#!/usr/bin/env puma

# start puma with:
# RAILS_ENV=production bundle exec puma -C ./config/puma.rb

application_path = '/var/www/url-shortner/current'
# railsenv = 'production'
directory application_path
environment railsenv
daemonize true
pidfile "#{application_path}/tmp/pids/puma.pid"
state_path "#{application_path}/tmp/pids/puma.state"
stdout_redirect "#{application_path}/log/puma-stdout.log", "#{application_path}/log/puma-stderr.log"
threads 0, 16
bind "unix:///var/run/puma.sock"