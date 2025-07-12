# Naive Bayes

`Ai4r::Classifiers::NaiveBayes` computes several probability tables when built. These attributes are exposed as read-only accessors:

* `class_prob` – Probability of each class in the training set.
* `pcc` – Count of occurrences for every attribute value and class. Layout is `[attribute][value][class]`.
* `pcp` – Conditional probability of an attribute value given a class. Shares the same layout as `pcc` and is derived from it using the `:m` parameter.

Inspecting these arrays helps you understand the learned model.

