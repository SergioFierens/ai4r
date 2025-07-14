# DBSCAN Clustering

DBSCAN groups together densely packed points and labels isolated points as noise. The implementation operates on numeric attributes and uses squared Euclidean distance by default. Squaring the distance avoids an expensive square root for every comparison.

## Parameters

`Ai4r::Clusterers::DBSCAN` exposes parameters via `set_parameters`:

* `epsilon` – squared radius for the neighbourhood. The squared distance between two points must be `<= epsilon` to be considered neighbours. If you want a real radius `r`, pass `epsilon: r**2`.
* `min_points` – minimum number of neighbouring points **excluding the point itself** required to create or expand a cluster.
* `distance_function` – optional custom distance measure. Provide a closure receiving two items and returning a distance. When omitted, squared Euclidean distance is used.

For example, a radius of `3` units corresponds to `epsilon: 9`.

## Example

```ruby
require 'ai4r'
include Ai4r::Clusterers
include Ai4r::Data

points = [[1,1], [1,2], [8,8], [9,8]]
set = DataSet.new(data_items: points)
clusterer = DBSCAN.new
clusterer.set_parameters(epsilon: 4, min_points: 1).build(set)
pp clusterer.clusters
```
