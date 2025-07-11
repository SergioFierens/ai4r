# Hyperpipes Classifier

Hyperpipes builds one "pipe" per class describing the observed attribute ranges. When classifying a new example each pipe receives a vote for every attribute that matches the stored range or value. The class with the most votes wins.

```ruby
require 'ai4r'
include Ai4r::Classifiers
include Ai4r::Data

# Load training data from the repository
file = 'examples/classifiers/hyperpipes_data.csv'
data = DataSet.new.parse_csv_with_labels(file)

classifier = Hyperpipes.new
classifier.set_parameters(:tie_strategy => :random).build(data)

pp classifier.pipes    # inspect pipes_summary
puts classifier.eval(['Chicago', 85, 'F'])
```

See `examples/classifiers/hyperpipes_example.rb` for a runnable sample.
