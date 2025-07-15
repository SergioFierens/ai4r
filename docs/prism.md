# PRISM Rule Induction

PRISM builds modular if–then rules for classification. For each class it selects
attribute/value pairs that maximize the probability of the target class and
continues adding conditions until the rule becomes perfect. The process repeats
until all training instances are covered.

## Parameters

The implementation exposes no tunable parameters. Provide a dataset where the
last attribute is the class label. All attributes are treated as discrete values.

## Examples

### Nominal data

The script `examples/classifiers/prism_nominal_example.rb` loads a CSV with
categorical attributes:

```ruby
require 'ai4r'
data = Ai4r::Data::DataSet.new.load_csv_with_labels(
  'examples/classifiers/zero_one_r_data.csv'
)
classifier = Ai4r::Classifiers::Prism.new.build(data)
puts classifier.get_rules
```

### Numeric data

`examples/classifiers/prism_numeric_example.rb` shows that numeric values work in
the same way:

```ruby
require 'ai4r'
items = [
  [20, 70, 'N'],
  [25, 80, 'N'],
  [30, 60, 'Y'],
  [35, 65, 'Y']
]
labels = ['temperature', 'humidity', 'play']
data = Ai4r::Data::DataSet.new(:data_items => items, :data_labels => labels)
classifier = Ai4r::Classifiers::Prism.new.build(data)
puts classifier.eval([30, 70])
```

Compare PRISM with other models in the [Classifier Bench](classifier_bench.md).

