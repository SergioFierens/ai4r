# A* Search

`Ai4r::Search::AStar` performs best-first search using heuristics to guide
expansion. You provide a starting node, a goal predicate, a neighbor
function returning adjacent nodes with their transition costs, and a
heuristic estimating the remaining distance. A good heuristic dramatically
reduces the number of explored states.

See [Search Algorithms](search_algorithms.md) for BFS and DFS.

```ruby
require 'ai4r/search'

start = 'A'
goal_test = ->(n) { n == 'G' }
neighbor_fn = ->(n) { { 'G' => 1 } }
heuristic_fn = ->(n) { 0 }

path = Ai4r::Search::AStar.new(start, goal_test, neighbor_fn, heuristic_fn).search
```

The call returns the path as an array of nodes or `nil` when the goal cannot be
reached.

### Trying it out

Use the grid problem from the search bench to see A* in action. The
heuristic already provided in the problem estimates the Manhattan
distance to the goal.

```bash
$ ruby bench/search/search_bench.rb \
    --problem grid --map bench/search/maps/small.txt \
    --algos a_star
```

Observe how `nodes_expanded` drops compared to BFS or DFS while the
solution path remains the same. Encourage students to tweak the heuristic
or design their own problems. For probabilistic search consider
[Monte Carlo Tree Search](monte_carlo_tree_search.md).
