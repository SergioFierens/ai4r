# Classifier Bench

A lightweight harness to compare basic classifiers on small CSV datasets.

## Quick-start

```bash
ruby bench/classifier/classifier_bench.rb \
    --dataset bench/classifier/datasets/logreg.csv \
    --algos logistic_regression,naive_bayes
```

The script shuffles the data, splits it using a 70/30 ratio and reports
accuracy and duration for each algorithm. Use `--train-ratio` to change
the split or `--export` to save results as CSV.
