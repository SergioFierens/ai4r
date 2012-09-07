require 'rake'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.title = "ar4r - Artificial Intelligence For Ruby - API DOC"
end

