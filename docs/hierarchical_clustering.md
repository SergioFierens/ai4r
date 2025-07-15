# Hierarchical Clustering

AI4R provides several algorithms to build dendrograms from your data. Most are
**agglomerative** – they start with individual points and merge the closest
clusters. `Diana` implements a **divisive** strategy by repeatedly splitting a
cluster.

Available linkage methods include:

* `SingleLinkage`
* `CompleteLinkage`
* `AverageLinkage`
* `WeightedAverageLinkage`
* `CentroidLinkage`
* `MedianLinkage`
* `WardLinkage` and `WardLinkageHierarchical`
* `Diana` (divisive)

Every hierarchical clusterer records the merge tree in a `cluster_tree` array.
The first element contains the final cluster, while the last holds the original
points.

```ruby
require 'ai4r'
include Ai4r::Clusterers
include Ai4r::Data

points = [[0,0],[0,1],[1,0],[1,1]]
set = DataSet.new(data_items: points)
clusterer = SingleLinkage.new.build(set, 1)
puts clusterer.cluster_tree.size       # => 4
puts clusterer.cluster_tree.last.size  # => 4
```

These algorithms only build the dendrogram. `supports_eval?` therefore returns
`false` except for the divisive `Diana` class, which can classify unseen points.

## Example Scripts

* `examples/clusterers/dendrogram_example.rb` – save a dendrogram image using
  `WardLinkage`.
* `examples/clusterers/hierarchical_dendrogram_example.rb` – print the levels
  stored by `WardLinkageHierarchical`.
* `examples/clusterers/clusterer_example.rb` – try different algorithms (e.g.,
  `Diana`, `KMeans`) on survey data.

## Benchmarks

Compare linkage methods with k-means using the clusterer bench:

```bash
ruby bench/clusterer/cluster_bench.rb --algos kmeans,single_linkage,diana \
    --dataset bench/clusterer/datasets/blobs.csv --k 3
```

The resulting table shows silhouette scores, SSE when available and runtime.
See `bench/clusterer/README.md` for more information.
