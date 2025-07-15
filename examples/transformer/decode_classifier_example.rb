# frozen_string_literal: true

require_relative '../../lib/ai4r/neural_network/transformer'
require_relative '../../lib/ai4r/classifiers/logistic_regression'
require_relative '../../lib/ai4r/data/data_set'

# Tiny dataset of greetings (label 0) and farewells (label 1)
sentences = [
  %w[hello there],
  %w[how are you],
  %w[good morning],
  %w[nice to meet you],
  %w[goodbye],
  %w[see you later],
  %w[have a nice day],
  %w[take care]
]
labels = [0, 0, 0, 0, 1, 1, 1, 1]

# Build vocabulary
vocab = {}
next_id = 0
sentences.each do |tokens|
  tokens.each do |t|
    unless vocab.key?(t)
      vocab[t] = next_id
      next_id += 1
    end
  end
end

vocab_size = vocab.length
max_len = sentences.map(&:length).max

transformer = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: vocab_size,
  max_len: max_len,
  architecture: :decoder
)
embed_dim = transformer.embed_dim

# Encode each sentence and average embeddings
items = []
sentences.each_with_index do |tokens, idx|
  ids = tokens.map { |t| vocab[t] }
  vecs = transformer.eval(ids)
  avg = Array.new(embed_dim, 0.0)
  vecs.each do |v|
    v.each_index { |i| avg[i] += v[i] }
  end
  avg.map! { |v| v / vecs.length }
  items << (avg + [labels[idx]])
end

labels_names = (0...embed_dim).map { |i| "x#{i}" } + ['class']
set = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels_names)

classifier = Ai4r::Classifiers::LogisticRegression.new
classifier.set_parameters(lr: 0.5, iterations: 500).build(set)

# Classify a short greeting
sample = %w[hello]
ids = sample.map { |t| vocab[t] }
vecs = transformer.eval(ids)
avg = Array.new(embed_dim, 0.0)
vecs.each { |v| v.each_index { |i| avg[i] += v[i] } }
avg.map! { |v| v / vecs.length }
puts "Prediction: #{classifier.eval(avg)} (0=greeting, 1=farewell)"
