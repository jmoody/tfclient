require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'bundler/audit/task'

Bundler::Audit::Task.new

RSpec::Core::RakeTask.new(:spec) do |task|
  Rake::Task["bundle:audit"].invoke
  task.pattern = "spec/lib/**{,/*/**}/*_spec.rb"
end

RSpec::Core::RakeTask.new(:unit) do |task|
  Rake::Task["bundle:audit"].invoke
  task.pattern = "spec/lib/**{,/*/**}/*_spec.rb"
end

RSpec::Core::RakeTask.new(:integration) do |task|
  Rake::Task["bundle:audit"].invoke
  task.pattern = "spec/integration/**{,/*/**}/*_spec.rb"
end

task :server do
  sh "docker-compose up --build --remove-orphans --detach"
end

task :socat do
  sh "socat readline ssl:localhost:10000,verify=0"
end

