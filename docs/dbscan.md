# DBSCAN Clustering

DBSCAN groups together densely packed points and labels isolated points as noise. The implementation operates on numeric attributes and uses squared Euclidean distance by default.

## Parameters

`Ai4r::Clusterers::DBSCAN` exposes parameters via `set_parameters`:

* `epsilon` – squared radius for the neighbourhood. The squared distance between two points must be `<= epsilon` to be considered neighbours.
* `min_points` – minimum number of neighbouring points **excluding the point itself** required to create or expand a cluster.
* `distance_function` – optional custom distance measure. Provide a closure receiving two items and returning a distance. When omitted, squared Euclidean distance is used.

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
