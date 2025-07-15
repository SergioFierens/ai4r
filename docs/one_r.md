# OneR Classifier

OneR selects the single attribute that yields the fewest classification errors and creates a rule for each of its values. Numeric attributes are discretized into a given number of bins (default: 10).

## Parameters

* `selected_attribute` – index of the attribute to force, otherwise the best attribute is chosen.
* `tie_break` – strategy when two attributes have the same error rate, `:first` or `:last`.
* `bin_count` – number of bins for numeric attributes.

## Example

```ruby
require 'ai4r/classifiers/one_r'
require 'ai4r/data/data_set'

set = Ai4r::Data::DataSet.new.load_csv_with_labels('examples/classifiers/zero_one_r_data.csv')
classifier = Ai4r::Classifiers::OneR.new.build(set)
puts classifier.get_rules
```

See `examples/classifiers/zero_and_one_r_example.rb` for an interactive demo.
