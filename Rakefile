require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.pattern = "spec/**/*_spec.rb"
end

# "Alias" the spec task by depending on the test task
task :spec => :test

task :default => [:test]
