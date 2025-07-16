# Classifier Bench

The classifier bench compares several simple algorithms on CSV datasets. It uses
the shared helpers in `bench/common` so the command-line interface matches the
other labs.

```bash
ruby bench/classifier/classifier_bench.rb \
    --dataset bench/classifier/datasets/iris.csv \
    --split 0.3 \
    --algos id3,naive_bayes,ib1,hyperpipes
```

Results appear in an ASCII table and can be exported to CSV with `--export`.
Metrics include accuracy, F1 score, training time, prediction speed and model
size. An additional table highlights advantages such as interpretability or
speed.

The bench is a quick way to compare [ID3](machine_learning.md),
[Naive Bayes](naive_bayes.md), [IB1](ib1.md) and
[Hyperpipes](hyperpipes.md) on the same dataset.

## Walk through the iris example

1. Navigate to the project root and run the command above. Add `-Ilib` if you haven't installed the gem locally.
2. The script loads `bench/classifier/datasets/iris.csv` which holds 150 flower measurements with a `species` label.
3. Records are shuffled and split 70/30 into training and test sets.
4. Each selected algorithm builds a model from the training data and predicts the holdout set.
5. The console prints a table of metrics for every classifier. An extra table marks which algorithms are accurate, fast or interpretable.
6. The `--export` option writes the same information to a CSV file for later review.

Example output:

```text
algorithm  | accuracy | f1   | training_ms | predict_ms | model_size_kb
-----------------------------------------------------------------------
id3        | 0.93     | 0.94 | 8.54        | 0.07       | 3.4
ib1        | 0.96     | 0.96 | 0.14        | 41.02      | 3.12
hyperpipes | 0.91     | 0.92 | 0.34        | 2.3        | 3.31
```
