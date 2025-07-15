# Random Forest

`Ai4r::Classifiers::RandomForest` builds an ensemble of ID3 decision trees from random samples of the data and feature set. Predictions are made by majority vote across all trees.

## Parameters

* `n_trees` – number of trees to build. Default is `10`.
* `sample_size` – number of data items sampled for each tree.
* `feature_fraction` – fraction of attributes sampled for each tree.
* `random_seed` – seed to make the randomness reproducible.

## Example

```ruby
require 'ai4r/classifiers/random_forest'
require 'ai4r/data/data_set'

set = Ai4r::Data::DataSet.new.load_csv_with_labels('examples/classifiers/id3_data.csv')
forest = Ai4r::Classifiers::RandomForest.new.set_parameters(n_trees: 5).build(set)
puts forest.eval(set.data_items.first[0...-1])
```

Random forests do not currently export human‑readable rules.
