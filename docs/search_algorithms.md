# Search Algorithms

The `Ai4r::Search` module provides minimal implementations of
breadth-first search (BFS) and depth-first search (DFS). Both algorithms
traverse a state space defined by a successor function until a goal is
reached.

```ruby
require 'ai4r/search'

bfs = Ai4r::Search::BFS.new(goal_test, neighbor_fn)
path = bfs.search(start)

dfs = Ai4r::Search::DFS.new(goal_test, neighbor_fn)
path = dfs.search(start)
```

Both methods return the path from the start node to the first goal or
`nil` when no goal is reachable.
