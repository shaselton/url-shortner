
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :user, 'root'
set :domain, 'hase.io'
set :deploy_to, '/var/www/url-shortner'
set :repository, 'git@github.com:shaselton/url-shortner.git'
set :branch, 'master'
set :app_name, 'url_shortner'

target =  ENV['target'] || ENV['to'] || 'development'

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'
    invoke :'whenever:update'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/pids"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
      queue "mkdir -p #{deploy_to}/#{current_path}/log"
    end
  end
end

task :start => :environment do
  queue! %[cd #{deploy_to}/current && RAILS_ENV=#{target} bundle exec puma -C ./config/puma.rb]
end

task :stop => :environment do
  queue! %[cd #{deploy_to}/current && bundle exec pumactl -F ./config/puma.rb stop && rm -rf /var/run/puma.sock]
end

task :restart => :environment do
  queue! %[cd #{deploy_to}/current && bundle exec pumactl -F ./config/puma.rb restart]
end

namespace :whenever do
  task :update => :environment do
    queue! %[cd #{deploy_to}/current && bundle exec whenever --set 'environment=#{rails_env}&current_path=#{deploy_to}/current&shared_path=#{deploy_to}/shared' --update-crontab #{app_name}]
  end
end