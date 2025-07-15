# KMeans Clustering

`Ai4r::Clusterers::KMeans` partitions data into K clusters by minimizing the
within-cluster variance. Points are assigned to the nearest centroid and the
centroids move to the mean of their assigned points until convergence.

## Example

```ruby
require 'ai4r'
include Ai4r::Clusterers
include Ai4r::Data

points = [[1,1],[1,2],[9,8],[9,9]]
set = DataSet.new(data_items: points)
clusterer = KMeans.new
clusterer.build(set, 2)
pp clusterer.clusters.map(&:data_items)
```

`build` returns the clusterer itself so you can inspect `clusters`,
`iterations`, and the sum of squared errors via `sse`.

See `examples/clusterers/kmeans_custom_example.rb` for a variant using
Manhattan distance.
