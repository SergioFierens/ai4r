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
