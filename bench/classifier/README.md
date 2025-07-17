# Classifier Bench

A lightweight harness to compare basic classifiers on small CSV datasets.
Everything lives in `bench/classifier` while shared helpers reside in
`bench/common`.

## Quick start

```bash
ruby bench/classifier/classifier_bench.rb \
    --dataset bench/classifier/datasets/iris.csv \
    --split 0.3 \
    --algos id3,naive_bayes,ib1,hyperpipes \
    --export out/results_classifier.csv
```

### Example: iris flowers

Compare four algorithms on the classic iris dataset:

```bash
ruby bench/classifier/classifier_bench.rb \
    --dataset bench/classifier/datasets/iris.csv \
    --split 0.3 \
    --algos id3,naive_bayes,ib1,hyperpipes
```

You'll see accuracy, F1 score and timing for each model. For a full walkthrough visit [../../docs/classifier_bench.md](../../docs/classifier_bench.md).

## Dataset format

CSV files require a header row. The last column is treated as the label and all
preceding columns are features.

## Metrics explained

* `accuracy` – overall correctness on the test split.
* `precision` / `recall` – macro averaged across labels.
* `f1` – harmonic mean of precision and recall.
* `training_ms` – wall-clock time to build the model.
* `predict_ms` – average milliseconds per 100 predictions.
* `model_size_kb` – size of the serialized model.

Badges mark algorithms as **accurate**, **fast-train**, **fast-predict**,
**tiny model** or **interpretable** when conditions are met.

## Typical classroom questions

* Why does IB1 need almost no training phase?
* Which algorithms output human-readable rules?
* How do precision and recall behave with imbalanced classes?

## Extending

1. Add a runner under `bench/classifier/runners/`.
2. Register it in `RUNNERS` inside `classifier_bench.rb`.
3. Drop a new CSV file under `bench/classifier/datasets/` if needed.

## Troubleshooting

* Ensure CSVs include a header line.
* Non-numeric features are supported.
* A mismatch in column count will raise parsing errors.
