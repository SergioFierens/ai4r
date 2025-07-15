# Gradient Boosting

`Ai4r::Classifiers::GradientBoosting` performs regression by fitting many simple linear models to the residuals of previous ones. The predictions of all learners are combined using a learning rate.

## Parameters

* `n_estimators` – number of boosting iterations. Default is `10`.
* `learning_rate` – shrinkage factor applied to each learner. Default is `0.1`.

## Example

```ruby
require 'ai4r/classifiers/gradient_boosting'
require 'ai4r/data/data_set'

set = Ai4r::Data::DataSet.new.parse_csv_with_labels('examples/classifiers/simple_linear_regression_example.csv')
boost = Ai4r::Classifiers::GradientBoosting.new.build(set)
puts boost.eval(set.data_items.first[0...-1])
```

This algorithm does not produce interpretable rules.
