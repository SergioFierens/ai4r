
# IB1 Instance-Based Classifier

IB1 is the simplest instance-based learning algorithm. It predicts the class of a new item using the single nearest neighbour from the training set. Numeric attributes are normalised when computing distances while nominal attributes are compared for equality. Missing values are tolerated by assigning a maximum penalty.

## Parameters

`Ai4r::Classifiers::IB1` exposes no tunable parameters. Build the classifier with a dataset where the last attribute represents the class label.

## Example

```ruby
require 'ai4r'
include Ai4r::Classifiers
include Ai4r::Data

file = 'examples/classifiers/hyperpipes_data.csv'
data = DataSet.new.parse_csv_with_labels(file)

classifier = IB1.new.build(data)

sample = ['Chicago', 55, 'M']
puts "Prediction for #{sample.inspect}: #{classifier.eval(sample)}"
```

The classifier automatically updates attribute ranges as new examples are seen and returns the class of the closest training instance.

See [Classifier Bench](classifier_bench.md) for a comparison with other classifiers.


