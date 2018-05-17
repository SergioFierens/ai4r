require 'rubygems'
require 'rake'

SPEC = Gem::Specification.new do |s|
  s.name = "ai4r"
  s.version = "1.13"
  s.author = "Sergio Fierens"
  s.homepage = "https://github.com/SergioFierens/ai4r"
  s.platform = Gem::Platform::RUBY
  s.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    Ruby algorithm implementations covering several
    Artificial intelligence fields, including Genetic
    algorithms, Neural Networks, machine learning, and clustering.
  DESC
  s.files = FileList["{examples,lib}/**/*"].to_a
  s.require_path = "lib"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
end
