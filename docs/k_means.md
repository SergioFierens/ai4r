# K-Means Clustering

The `Ai4r::Clusterers::KMeans` class implements the classic k-means algorithm.
It partitions numeric data points into `k` clusters by iteratively assigning
points to the nearest centroid and then updating the centroids.

## Basic Usage

```ruby
require 'ai4r'
include Ai4r::Clusterers
include Ai4r::Data

points = [[1, 1], [1, 2], [2, 1], [2, 2], [8, 8], [9, 8]]
set = DataSet.new(data_items: points)
clusterer = KMeans.new.build(set, 2)

clusterer.clusters.each_with_index do |cluster, i|
  puts "Cluster #{i}: #{cluster.data_items.inspect}"
end
```

Centroids are picked at random by default. Provide `random_seed` in
`set_parameters` for deterministic results or `init_centroids` to choose your
own starting points.

To change the distance measure supply a lambda via `distance_function`.
See `examples/clusterers/kmeans_custom_example.rb` for a full script.

## After Building

* `clusters` returns an array of `DataSet` clusters.
* `sse` gives the sum of squared errors for the current centroids.
* `iterations` reports how many refinement steps were required.

K-means supports evaluating new items:

```ruby
index = clusterer.eval([1.5, 1.5])
```

## Benchmarks

The project ships with a small benchmarking harness under
`bench/clusterer`. Run it to compare k-means against hierarchical
approaches:

```bash
ruby bench/clusterer/cluster_bench.rb --algos kmeans,single_linkage \
    --dataset bench/clusterer/datasets/blobs.csv --k 3
```

The resulting table reports silhouette score, SSE, runtime and other
useful notes. Consult `bench/clusterer/README.md` for details.
