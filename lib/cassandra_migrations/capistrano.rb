# encoding : utf-8

Capistrano::Configuration.instance(:must_exist).load do
  after 'bundle:install', 'cassandra:migrate'

  namespace :cassandra do
    task :migrate, :roles => :cassandra do
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")
      directory = latest_release
      
      run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} cassandra:create"
      run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} cassandra:migrate"
    end
  end
end
