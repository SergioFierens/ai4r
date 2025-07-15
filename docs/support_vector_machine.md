# Support Vector Machine

`Ai4r::Classifiers::SupportVectorMachine` is a minimal linear SVM trained with stochastic gradient descent. Only numeric attributes and two classes are supported.

## Parameters

* `learning_rate` – gradient descent step size. Default is `0.01`.
* `iterations` – number of training iterations. Default is `1000`.
* `c` – regularisation strength. Default is `1.0`.

## Example

```ruby
require 'ai4r/classifiers/support_vector_machine'
require 'ai4r/data/data_set'

items = [[0,0,'N'], [1,0,'N'], [0,1,'Y'], [1,1,'Y']]
labels = %w[x1 x2 class]
set = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)
svm = Ai4r::Classifiers::SupportVectorMachine.new.build(set)
puts svm.eval([1,0])
```

SVM models do not generate human-readable rules.
