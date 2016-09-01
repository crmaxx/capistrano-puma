namespace :load do
  task :defaults do
    set :logrotate_role, :app
    set :logrotate_conf, "/etc/logrotate.d/#{application}"
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

    after 'deploy:check', 'rails:logrotate:install'
  end
end
