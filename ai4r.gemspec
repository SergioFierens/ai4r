# frozen_string_literal: true

require_relative 'lib/ai4r/version'
require 'rake'

SPEC = Gem::Specification.new do |s|
  s.name = 'ai4r'
  s.version = Ai4r::VERSION
  s.author = 'Sergio Fierens'
  s.homepage = 'https://github.com/SergioFierens/ai4r'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Minimalist Ruby library for learning a broad range of ML and AI algorithms.'
  s.description = <<~DESC
    AI4R is a lightweight, educational Ruby library featuring clean implementations of core machine learning and AI algorithms—such as decision trees, neural networks, k-means, genetic algorithms, and even a bit size Transformers architecture covering encoder, decoder, and seq2seq variations. Designed with simplicity and clarity in mind, this library is ideal for students, educators, and developers who want to understand these algorithms line by line.

    With no external dependencies, no GPU support, and no production overhead, AI4R serves as a practical and transparent way to explore the foundations of AI in Ruby. It is a long-maintained open-source effort to bring accessible, hands-on machine learning to the Ruby community.
  DESC
  s.required_ruby_version = '>= 3.1'
  s.license = 'Unlicense'
  s.files = FileList['{examples,lib}/**/*'].to_a
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']
  s.metadata = {
    'source_code_uri' => 'https://github.com/SergioFierens/ai4r',
    'rubygems_mfa_required' => 'true'
  }
end
