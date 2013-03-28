require 'capistrano/ext/multistage'

set :application, "reciprosody"
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :repository,  "andrew@jaguar.cs.qc.cuny.edu:/home/data/repos/reciprosody2.git"
set :user, "andrew"

default_run_options[:pty] = true  ## Prevents sudo: no tty present and no askpass program specified


set :stages, ["staging", "production"]
set :default_stage, "production"

role :web, "jaguar.cs.qc.cuny.edu"                          # Your HTTP server, Apache/etc
role :app, "jaguar.cs.qc.cuny.edu"                          # This may be the same as your `Web` server
role :db,  "jaguar.cs.qc.cuny.edu", :primary => true # This is where Rails migrations will run
role :db,  "jaguar.cs.qc.cuny.edu"

## make sure that all necessary gems are installed.  (before restarting)
namespace :bundle do
  desc "run bundle install and ensure all gem requirements are met"
  task :install do
    run "cd #{current_path} && bundle install  --without=development,test"
  end

  desc "run asset precompile"
  task :assets_precompile do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end

end
before "deploy:restart", "bundle:install", "bundle:assets_precompile"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end