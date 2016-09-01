namespace :load do
  task :defaults do
    set :logrotate_default_hooks, -> { true }
    set :logrotate_role, :app
    set :logrotate_conf, "/etc/logrotate.d/#{application}"
  end
end

namespace :deploy do
  before :starting, :check_logrotate_hooks do
    invoke 'rails:logrotate:add_default_hooks' if fetch(:logrotate_default_hooks)
  end
end

namespace :rails do
  namespace :logrotate do
    desc 'Install logrotate'
    task :install do
      on roles(fetch(:logrotate_role)) do |role|
        @role = role
        template_puma 'logrotate', "#{fetch(:tmp_dir)}/logrotate", role
        execute "chown root #{fetch(:tmp_dir)}/logrotate"
        execute "chmod 600 #{fetch(:tmp_dir)}/logrotate"
        sudo "mv #{fetch(:tmp_dir)}/logrotate #{fetch(:logrotate_conf)}"
      end
    end

    task :add_default_hooks do
      after 'deploy:check', 'rails:logrotate:install'
    end
  end
end
