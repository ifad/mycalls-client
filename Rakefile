require "bundler"
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'

# Run rspec by default.
task :default => :rspec

RSpec::Core::RakeTask.new(:rspec)

require 'yard'
require 'yard/rake/yardoc_task'

# Use YARD to generate documentation
YARD::Rake::YardocTask.new

desc "Validate the gemspec"
task :gemspec do
  eval(File.read('mycalls-client.gemspec'), binding, '.gemspec').validate
end

begin
  require "rcov/rcovtask"

  desc "Create a code coverage report"
  Rcov::RcovTask.new do |t|
    t.test_files = FileList["test/**/*_test.rb"]
    t.ruby_opts << "-Itest -x mocha,rcov,Rakefile"
    t.verbose = true
  end
rescue LoadError
  task :clobber_rcov
  # puts "RCov is not available"
end
