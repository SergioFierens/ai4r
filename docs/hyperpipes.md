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
classifier.set_parameters(:tie_break => :random).build(data)

pp classifier.pipes    # inspect pipes_summary
puts classifier.eval(['Chicago', 85, 'F'])
```

See `examples/classifiers/hyperpipes_example.rb` for a runnable sample.

## Parameters

`tie_break` – determines how to break ties when several classes receive the
same number of votes. Options are `:first`, `:last` or `:random`.

`margin` – expands numeric boundaries by this amount when building the pipes.
A larger margin makes the classifier more tolerant to unseen values.

```ruby
require 'ai4r/classifiers/hyperpipes'
require 'ai4r/data/data_set'

labels = %w[city age gender marketing_target]
items = [
  ['New York', 25, 'M', 'Y'],
  ['Chicago', 43, 'M', 'Y'],
  ['Chicago', 55, 'M', 'N']
]

set = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)
classifier = Ai4r::Classifiers::Hyperpipes.new
classifier.set_parameters(tie_break: :last, margin: 0.5)
classifier.build(set)
classifier.eval(['New York', 30, 'M'])
```

Compare results in the [Classifier Bench](classifier_bench.md).
