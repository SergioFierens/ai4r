# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
#
# Toy example showing how to use the minimal Transformer encoder
# together with logistic regression for text classification.

require_relative '../../lib/ai4r/neural_network/transformer'
require_relative '../../lib/ai4r/classifiers/logistic_regression'
require_relative '../../lib/ai4r/data/data_set'

# Small set of short sentences labeled as greeting (1) or farewell (0)
sentences = {
  'hello' => 1,
  'hi' => 1,
  'good morning' => 1,
  'good day' => 1,
  'bye' => 0,
  'goodbye' => 0,
  'see you' => 0,
  'farewell' => 0
}

# Build a vocabulary from the words used in the sentences
vocab = {}
sentences.keys.each do |text|
  text.split.each { |tok| vocab[tok] = vocab.length unless vocab.key?(tok) }
end
unk_id = vocab.length
max_len = sentences.keys.map { |s| s.split.length }.max

# Transformer encoder
encoder = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: vocab.length + 1,
  max_len: max_len,
  architecture: :encoder
)

# Convert each sentence into averaged encoder outputs
items = sentences.map do |text, label|
  ids = text.split.map { |tok| vocab.fetch(tok, unk_id) }
  vectors = encoder.eval(ids)
  mean = Array.new(encoder.embed_dim, 0.0)
  vectors.each do |vec|
    vec.each_index { |i| mean[i] += vec[i] }
  end
  mean.map! { |v| v / ids.length.to_f }
  mean << label
end

data_set = Ai4r::Data::DataSet.new(data_items: items)

# Train logistic regression on the averaged transformer features
classifier = Ai4r::Classifiers::LogisticRegression.new
classifier.set_parameters(lr: 0.5, iterations: 500).build(data_set)

puts 'Prediction results:'
sentences.each_key do |text|
  ids = text.split.map { |tok| vocab.fetch(tok, unk_id) }
  vectors = encoder.eval(ids)
  mean = Array.new(encoder.embed_dim, 0.0)
  vectors.each { |vec| vec.each_index { |i| mean[i] += vec[i] } }
  mean.map! { |v| v / ids.length.to_f }
  pred = classifier.eval(mean)
  puts "#{text.ljust(12)} -> #{pred}"
end

