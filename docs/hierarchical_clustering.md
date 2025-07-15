# Hierarchical Clustering

AI4R includes several agglomerative algorithms such as SingleLinkage,
CompleteLinkage and WardLinkage.  All hierarchical clusterers expose a
`cluster_tree` array storing the clusters at each merge step when the
clusterer is built.

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

The first element of the array contains the final cluster and the last
captures the initial individual points. You can limit the depth by
passing a value to the constructor.

Hierarchical clusterers only build a dendrogram and do not support
evaluating new items afterwards. `supports_eval?` will return `false`
for these classes.

## Plotting a dendrogram

The example `examples/clusterers/dendrogram_example.rb` shows how to
plot the recorded tree using the `dendrogram` gem.

You can benchmark hierarchical clustering against other methods in the
[Clusterer Bench](clusterer_bench.md).
