# Clusterer Bench

A tiny benchmarking lab for basic clustering algorithms. All code lives under
this folder while shared helpers are kept in `bench/common`.

## Quick-start

```
$ ruby bench/clusterer/cluster_bench.rb \
    --dataset datasets/blobs.csv \
    --k 3 \
    --algos kmeans,single_linkage,average_linkage,diana \
    --export out/cluster_results.csv
```

Console output prints a table of metrics and the same numbers are exported to a
CSV file for later analysis.

## Understanding the numbers

* `silhouette` – average silhouette coefficient (-1..1)
* `sse` – sum of squared errors (only for k-means)
* `duration_ms` – wall clock time in milliseconds
* `iterations` – number of k-means iterations

## What to discuss in class

* Why do hierarchical methods consume more memory?
* Why does DIANA not require guessing `k` beforehand?
* How does SSE compare with the silhouette score?

## Extending

1. Implement a new runner under `bench/clusterer/runners/` inheriting from
   `Bench::Common::BaseRunner`.
2. Append its name to `RUNNERS` in `cluster_bench.rb`.
3. Add a CSV dataset under `bench/clusterer/datasets/`.

## FAQ

* Ensure all columns are numeric or parsing will fail.
* `k` must be smaller than the number of rows.
* Pass `--with-ground-truth` if the last column contains labels.
