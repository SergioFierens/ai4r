require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

namespace :test do
  desc 'Run neural network unit and integration tests'
  task :nn do
    files = Dir['test/unit/neural_network/**/*_test.rb'] +
            Dir['test/integration/**/*_test.rb']
    script = 'ARGV.each { |f| require File.expand_path(f) }'
    ruby '-Ilib:test', '-e', script, *files
  end
end

task :e2e do
  files = Dir['test/e2e/**/*_test.rb']
  script = 'ARGV.each { |f| require File.expand_path(f) }'
  ruby '-Ilib:test', '-e', script, *files
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.title = "ar4r - Artificial Intelligence For Ruby - API DOC"
end

RuboCop::RakeTask.new(:rubocop)

