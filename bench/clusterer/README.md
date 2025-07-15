# Clusterer Bench

A small benchmarking harness to compare clustering algorithms. All code lives
under `bench/clusterer` while shared helpers are in `bench/common`.

## Quick-start

```
$ ruby bench/clusterer/cluster_bench.rb \
    --dataset bench/clusterer/datasets/blobs.csv \
    --k 3 \
    --algos kmeans,single_linkage,average_linkage,diana \
    --export out/cluster_results.csv
```

This prints an ASCII table of metrics and saves a CSV with the same data.

## Understanding the numbers

* `silhouette` – average silhouette coefficient (-1..1), higher is better.
* `sse` – sum of squared errors to cluster centroids when available.
* `duration_ms` – wall clock time to build the model.
* `notes` – algorithm-specific remarks (iterations, memory ▲, divisive…).

## What to discuss in class

* Why do linkage methods show the `memory▲` note?
* Why does DIANA not require guessing `k` beforehand?
* What happens when k-means runs for many iterations?

## Extending

1. Create a runner under `bench/clusterer/runners/` (e.g., `dbscan_runner.rb`).
2. Add it to `RUNNERS` in `cluster_bench.rb`.
3. Drop a new CSV file under `bench/clusterer/datasets/` if needed.

## FAQ

* Ensure datasets contain only numeric columns when not using ground truth.
* `k` must be less than or equal to the number of data points.
* Large datasets may slow down hierarchical algorithms significantly.
