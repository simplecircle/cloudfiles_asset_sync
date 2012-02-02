require "rubygems"
require "rake"
require "rake/testtask"

task :default do |t|
  begin
    Rake::Task["test:units"].invoke
  rescue
    abort "Errors running tests"
  end
end

Rake::TestTask.new(:test) do |task|
 task.test_files = FileList["test/**/*_test.rb"]
 task.verbose = true
end
