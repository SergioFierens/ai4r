# A* Search

`Ai4r::Search::AStar` performs best-first search using heuristics to guide
expansion. Provide a starting node, a goal predicate, a neighbor function that
returns reachable nodes and their costs, and a heuristic estimating remaining
cost.

```ruby
require 'ai4r/search'

start = 'A'
goal_test = ->(n) { n == 'G' }
neighbor_fn = ->(n) { { 'G' => 1 } }
heuristic = ->(n) { 0 }

path = Ai4r::Search::AStar.new(start, goal_test, neighbor_fn, heuristic).search
```

The call returns the path as an array of nodes or `nil` when the goal cannot be
reached.
