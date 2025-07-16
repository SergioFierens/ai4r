# Clusterer Bench

The clusterer bench compares algorithms such as [KMeans](kmeans.md),
[hierarchical clustering](hierarchical_clustering.md), DIANA and
[DBSCAN](dbscan.md). It loads points from a CSV file and prints basic metrics
for each run.

```bash
ruby bench/clusterer/cluster_bench.rb \
    --dataset bench/clusterer/datasets/blobs.csv \
    --k 3 --epsilon 4 --min-points 3 \
    --algos kmeans,dbscan
```

`--epsilon` and `--min-points` only apply to DBSCAN. Results are shown in an
ASCII table and can be exported to CSV.

## Walk through the blobs example

1. Execute the command above from the project root. Use `-Ilib` if the gem isn't installed.
2. `bench/clusterer/datasets/blobs.csv` contains 300 two‑dimensional points plus a label column used only for evaluation.
3. The bench builds three clusters with each selected algorithm.
4. Metrics such as silhouette coefficient and SSE are printed to the terminal.
5. A second table highlights algorithms that are fast or memory intensive.
6. Passing `--export` writes all metrics to a CSV file.

Example output:

```text
algorithm | silhouette         | sse               | duration_ms | notes
--------------------------------------------------------------------------
kmeans    | 0.9120608842715905 | 607.6781788299999 | 15.41       | iter=5
dbscan    | 0.9120608842715913 |                   | 161.88      | eps=4.0
```
