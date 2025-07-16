# frozen_string_literal: true

require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rspec/core/rake_task'

# Default task
task default: :spec

# RSpec task
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --color'
end

# Test coverage task
desc 'Run tests with coverage report'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
end

# Legacy test suite (for backward compatibility)
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# Documentation generation
RDoc::Task.new do |rd|
  rd.main = 'README.md'
  rd.rdoc_dir = 'rdoc'
  rd.rdoc_files.include('README.md', 'lib/**/*.rb')
  rd.title = 'AI4R - Artificial Intelligence For Ruby - API Documentation'
  rd.options << '--line-numbers'
  rd.options << '--all'
end

# Rubocop tasks
desc 'Run Rubocop'
task :rubocop do
  sh 'bundle exec rubocop'
end

desc 'Run Rubocop with auto-correct'
task :rubocop_fix do
  sh 'bundle exec rubocop -a'
end

desc 'Run Rubocop with unsafe auto-correct'
task :rubocop_fix_unsafe do
  sh 'bundle exec rubocop -A'
end

# Quality check task
desc 'Run all quality checks (tests, coverage, rubocop)'
task quality: %i[coverage rubocop]

# CI task
desc 'Run continuous integration checks'
task ci: %i[spec rubocop]

# Console task for interactive testing
desc 'Open an interactive console with AI4R loaded'
task :console do
  require 'pry'
  require_relative 'lib/ai4r'
  Pry.start
end

# Benchmarking tasks
namespace :benchmark do
  desc 'Run classifier benchmarks'
  task :classifiers do
    ruby 'examples/experiment/classifier_bench_example.rb'
  end

  desc 'Run clusterer benchmarks'
  task :clusterers do
    ruby 'examples/experiment/clusterer_bench_example.rb'
  end

  desc 'Run search algorithm benchmarks'
  task :search do
    ruby 'examples/experiment/search_bench_example.rb'
  end

  desc 'Run all benchmarks'
  task all: %i[classifiers clusterers search]
end

# Educational examples
namespace :examples do
  desc 'Run beginner tutorial examples'
  task :beginner do
    puts 'Running beginner tutorial examples...'
    Dir['examples/beginner/*.rb'].each do |file|
      puts "\n📚 Running: #{file}"
      ruby file
    end
  end

  desc 'Run intermediate tutorial examples'
  task :intermediate do
    puts 'Running intermediate tutorial examples...'
    Dir['examples/intermediate/*.rb'].each do |file|
      puts "\n📚 Running: #{file}"
      ruby file
    end
  end

  desc 'Run advanced tutorial examples'
  task :advanced do
    puts 'Running advanced tutorial examples...'
    Dir['examples/advanced/*.rb'].each do |file|
      puts "\n📚 Running: #{file}"
      ruby file
    end
  end
end

# Version task
desc 'Display the current version'
task :version do
  require_relative 'lib/ai4r/version'
  puts "AI4R version: #{Ai4r::VERSION}"
end