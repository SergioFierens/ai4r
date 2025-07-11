require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/id3'

# Load the training data
file = "#{File.dirname(__FILE__)}/id3_data.csv"
data_set = Ai4r::Data::DataSet.new.load_csv_with_labels(file)

# Build the tree
id3 = Ai4r::Classifiers::ID3.new.build(data_set)

# Export DOT representation
File.open('id3_tree.dot', 'w') { |f| f.puts id3.to_graphviz }
puts 'Decision tree saved to id3_tree.dot'

# You can also inspect the tree as nested hashes
p id3.to_h

