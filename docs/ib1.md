# IB1 Classifier

IB1 performs nearest neighbour classification while automatically normalizing numeric attributes. It stores every training instance and compares them to new data when evaluating.

```ruby
require 'ai4r/classifiers/ib1'
require 'ai4r/data/data_set'

labels = %w[city age gender marketing_target]
items = [
  ['New York', 25, 'M', 'Y'],
  ['Chicago', 43, 'M', 'Y']
]

set = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)
classifier = Ai4r::Classifiers::IB1.new.build(set)
```

## Incremental learning

New training instances can be added at any time using `add_instance`:

```ruby
classifier.add_instance(['Chicago', 55, 'M', 'N'])
```

`add_instance` appends the item to the internal dataset and updates the
stored minimum and maximum values so that distance calculations remain
normalized.
