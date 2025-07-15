# Clusterer Bench

The clusterer bench compares algorithms such as KMeans, hierarchical linkages,
DIANA and DBSCAN. It loads points from a CSV file and prints basic metrics
for each run.

```bash
ruby bench/clusterer/cluster_bench.rb \
    --dataset bench/clusterer/datasets/blobs.csv \
    --k 3 --epsilon 4 --min-points 3 \
    --algos kmeans,dbscan
```

`--epsilon` and `--min-points` only apply to DBSCAN. Results are shown in an
ASCII table and can be exported to CSV.
