
# Naive Bayes Classifier

Naive Bayes uses probability theory to predict the most likely class for a data point. Each attribute is assumed to be independent given the class. During training the algorithm records how often each attribute value occurs with every class and converts these counts into probabilities. When evaluating new data the class with the highest posterior probability is returned.

## Parameters

`Ai4r::Classifiers::NaiveBayes` exposes parameters via `set_parameters`:

* `m` – equivalent sample size for the m‑estimate used when computing conditional probabilities. The default is `0`. Increase it when the training set is small to avoid zero probabilities.

## Example

```ruby
require 'ai4r/classifiers/naive_bayes'
require 'ai4r/data/data_set'

set = Ai4r::Data::DataSet.new
set.load_csv_with_labels 'examples/classifiers/naive_bayes_data.csv'

classifier = Ai4r::Classifiers::NaiveBayes.new
classifier.set_parameters(m: 3).build(set)

puts classifier.eval(['Red', 'SUV', 'Domestic'])
puts classifier.get_probability_map(['Red', 'SUV', 'Domestic'])
```

The last line prints a hash with the probability for each class.

# Naive Bayes

`Ai4r::Classifiers::NaiveBayes` computes several probability tables when built. These attributes are exposed as read-only accessors:

* `class_prob` – Probability of each class in the training set.
* `pcc` – Count of occurrences for every attribute value and class. Layout is `[attribute][value][class]`.
* `pcp` – Conditional probability of an attribute value given a class. Shares the same layout as `pcc` and is derived from it using the `:m` parameter.

Inspecting these arrays helps you understand the learned model.


