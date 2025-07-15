# DBSCAN Clustering

`DBSCAN` groups together densely packed points and labels sparse points as noise.
The implementation in AI4R works on numeric attributes and uses a squared
Euclidean distance by default (avoiding a square root per comparison).

## Parameters

Set parameters with `set_parameters`:

* `epsilon` – squared neighbourhood radius. For a real radius `r`, pass
  `epsilon: r**2`.
* `min_points` – number of neighbours **excluding the point itself** required to
  create or expand a cluster.
* `distance_function` – optional lambda to override the distance metric.

Unlike `KMeans`, DBSCAN does not support `eval` once built. Calling
`supports_eval?` returns `false`.

## Minimal Example

```ruby
require 'ai4r'
include Ai4r::Clusterers
include Ai4r::Data

set = DataSet.new(data_items: [[1,1], [1,2], [8,8], [9,8]])
clusterer = DBSCAN.new
clusterer.set_parameters(epsilon: 4, min_points: 1).build(set)
pp clusterer.clusters.map(&:data_items)
```

## Parameter Exploration

To see how `epsilon` and `min_points` influence the results, run the script in
the "Illustrative Example" section or adapt it to your own datasets.

## Benchmarks

DBSCAN can also be benchmarked using the clusterer bench just like other
algorithms. Simply add `dbscan` to the `--algos` list:

```bash
ruby bench/clusterer/cluster_bench.rb --algos dbscan,kmeans \
    --dataset bench/clusterer/datasets/blobs.csv --k 3
```

Check `bench/clusterer/README.md` for the available metrics and usage tips.
