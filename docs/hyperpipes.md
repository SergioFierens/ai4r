# Hyperpipes Classifier

Hyperpipes is a fast baseline algorithm that creates one "pipe" per class.
A pipe records value ranges for numeric attributes and sets of observed values
for nominal attributes. New records are classified by counting how many
attributes match each pipe.

## Parameters

`tie_strategy` – determines how to break ties when several classes receive the
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
classifier.set_parameters(tie_strategy: :last, margin: 0.5)
classifier.build(set)
classifier.eval(['New York', 30, 'M'])
```
