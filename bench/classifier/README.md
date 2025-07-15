# Classifier Bench

A small harness to compare basic classification algorithms. All code lives under `bench/classifier` while shared helpers are kept in `bench/common`.

## Quick start

```
$ ruby bench/classifier/classifier_bench.rb \
    --dataset bench/classifier/datasets/iris.csv \
    --split 0.3 \
    --algos id3,naive_bayes,ib1,hyperpipes \
    --export out/results_classifier.csv
```

An ASCII table is printed and a CSV with the same metrics is saved to the path passed to `--export`.

## Dataset format

CSV files must include a header row. The last column is treated as the label. Both numeric and nominal attributes are supported.

## Metrics explained

* `accuracy` – overall correctness on the test split.
* `f1` – macro averaged harmonic mean of precision and recall.
* `training_ms` – wall clock time to build the model.
* `predict_ms` – average time per 100 predictions.
* `model_size_kb` – approximate model size via `Marshal` dump.

Badges are derived automatically:

* **Accurate** – `accuracy` ≥ 0.95
* **Fast-train** – training time ≤ median
* **Fast-predict** – prediction time ≤ median
* **Tiny model** – model size ≤ half the median
* **Interpretable** – algorithm is ID3 or Hyperpipes

## Typical classroom questions

* Why does IB1 have no real training phase?
* When would Naive Bayes break down despite high speed?

## Extending

1. Add a runner under `bench/classifier/runners/` (e.g. `logreg_runner.rb`).
2. Append it to `RUNNERS` in `classifier_bench.rb`.
3. Drop a new CSV file under `bench/classifier/datasets/` if needed.

## Troubleshooting

* Ensure the CSV has a header row.
* Convert non-numeric features to strings.
