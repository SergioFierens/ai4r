require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.title = "ar4r - Artificial Intelligence For Ruby - API DOC"
end

spec = Gem::Specification.new do |s| 
  s.name = "ai4r"
  s.version = "1.4"
  s.author = "Sergio Fierens"
  s.homepage = "http://ai4r.rubyforge.org"
  s.rubyforge_project = "ai4r"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby implementations of algorithms covering several Artificial intelligence fields, including Genetic algorithms, Neural Networks, machine learning, and clustering."
  s.files = FileList["{examples,lib,site}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "ai4r"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  #s.add_dependency("dependency", ">= 0.x.x")
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end 

