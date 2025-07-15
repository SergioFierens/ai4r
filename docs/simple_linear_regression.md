# Simple Linear Regression

`Ai4r::Classifiers::SimpleLinearRegression` fits a straight line to predict a numeric output from a single attribute. When multiple attributes are present, the algorithm chooses the one that minimises mean squared error.

## Parameters

* `selected_attribute` – force the attribute index used for regression; otherwise the best attribute is selected automatically.

## Example

```ruby
require 'ai4r/classifiers/simple_linear_regression'
require 'ai4r/data/data_set'

set = Ai4r::Data::DataSet.new.parse_csv_with_labels('examples/classifiers/simple_linear_regression_example.csv')
model = Ai4r::Classifiers::SimpleLinearRegression.new.build(set)
puts "Slope: #{model.slope}, Intercept: #{model.intercept}"
```

See `examples/classifiers/simple_linear_regression_example.rb` for a full script.
