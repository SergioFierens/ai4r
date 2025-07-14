# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# Toy example of using the minimal Transformer encoder for
# text classification. We build random sentence embeddings
# with the Transformer and train a logistic regression
# classifier on a tiny sentiment dataset.

require_relative '../../lib/ai4r/neural_network/transformer'
require_relative '../../lib/ai4r/classifiers/logistic_regression'
require_relative '../../lib/ai4r/data/data_set'

# Vocabulary for our miniature dataset
VOCAB = {
  'good' => 0,
  'great' => 1,
  'bad' => 2,
  'awful' => 3,
  'movie' => 4,
  'film' => 5,
  '<pad>' => 6
}.freeze

MAX_LEN = 2

# Helper that converts space separated text into an array of token ids
# and pads it to MAX_LEN tokens.
def encode(text)
  tokens = text.split.map { |w| VOCAB[w] }
  tokens.fill(VOCAB['<pad>'], tokens.length...MAX_LEN)
end

# Build encoder only Transformer
model = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: VOCAB.size,
  max_len: MAX_LEN
)

train_texts = ['good movie', 'great film', 'bad movie', 'awful film']
labels = [1, 1, 0, 0]

# Obtain sentence embeddings by averaging token representations
train_features = train_texts.map do |text|
  tokens = encode(text)
  enc = model.eval(tokens)
  mean = Array.new(model.embed_dim, 0.0)
  enc.each do |vec|
    vec.each_with_index { |v, i| mean[i] += v }
  end
  mean.map { |v| v / enc.length }
end

data_items = train_features.each_with_index.map { |feat, i| feat + [labels[i]] }
labels_names = (0...model.embed_dim).map { |i| "f#{i}" } + ['class']

dataset = Ai4r::Data::DataSet.new(
  data_items: data_items,
  data_labels: labels_names
)

classifier = Ai4r::Classifiers::LogisticRegression.new
classifier.set_parameters(lr: 0.5, iterations: 2000).build(dataset)

puts 'Predictions:'
['good film', 'awful movie'].each do |text|
  tokens = encode(text)
  enc = model.eval(tokens)
  mean = Array.new(model.embed_dim, 0.0)
  enc.each do |vec|
    vec.each_with_index { |v, i| mean[i] += v }
  end
  mean.map! { |v| v / enc.length }
  puts "#{text} => #{classifier.eval(mean)}"
end
