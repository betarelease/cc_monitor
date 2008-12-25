namespace :db do
  namespace :migrate do
    task :reset do
      require 'migrations/project'
      Project.down
      Project.up
    end
  end
end