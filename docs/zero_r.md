# ZeroR Classifier

ZeroR picks the most frequent class in the training data and predicts that value for every new example. It is a sanity check often used to compare more elaborate algorithms against a trivial baseline.

## Parameters

* `default_class` – value returned when the dataset is empty.
* `tie_break` – how to choose among classes with equal frequency. Options are `:first` or `:random`.
* `random_seed` – seed for reproducible tie resolution.

## Example

```ruby
require 'ai4r/classifiers/zero_r'
require 'ai4r/data/data_set'

set = Ai4r::Data::DataSet.new.load_csv_with_labels('examples/classifiers/zero_one_r_data.csv')
classifier = Ai4r::Classifiers::ZeroR.new.build(set)
puts classifier.eval(set.data_items.first)
```

See `examples/classifiers/zero_and_one_r_example.rb` for a longer walkthrough.
