require 'rake'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList["test/**/*_test.rb"]
end

RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.title = "ai4r - Artificial Intelligence For Ruby - API DOC"
end

