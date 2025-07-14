# Logistic Regression

`Ai4r::Classifiers::LogisticRegression` implements binary logistic regression using gradient descent. Training data must contain numeric attributes with the last column representing the class label `0` or `1`.

## Parameters

* `learning_rate` – Learning rate used during gradient descent. Default is `0.1`.
* `iterations` – Number of training iterations. Default is `1000`.

## Example

```ruby
require 'ai4r/classifiers/logistic_regression'
require 'ai4r/data/data_set'

items = [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]
labels = %w(x1 x2 class)
set = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)

reg = Ai4r::Classifiers::LogisticRegression.new
reg.set_parameters(learning_rate: 0.5, iterations: 2000).build(set)

reg.eval([1, 0]) # => 1
```
