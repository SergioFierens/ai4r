# Search Algorithms

`Ai4r::Search` collects a handful of classical techniques for exploring
state spaces. The goal predicates and successor functions are tiny Ruby
procs so you can prototype ideas in a few lines of code. Breadth-first
search (BFS) expands the frontier level by level, whereas depth-first
search (DFS) follows one branch as deep as it can. They both expect a
`goal_test` and a `neighbor_fn` describing your problem space. For large
graphs you can also try iterative deepening search (IDDFS) which mixes the
two approaches.

```ruby
require 'ai4r/search'

bfs = Ai4r::Search::BFS.new(goal_test, neighbor_fn)
path = bfs.search(start)

dfs = Ai4r::Search::DFS.new(goal_test, neighbor_fn)
path = dfs.search(start)
```

Both methods return the path from the start node to the first goal or
`nil` when no goal is reachable.

## A tiny grid example

Assume we have a `5x5` grid with walls marked by `#` and a start `S` and
goal `G`. The [bench/search](../bench/search) folder contains sample
maps. We can load one and run BFS on it:

```ruby
require 'ai4r/search'
require_relative '../bench/search/problems/grid'

problem = Bench::Search::Problems::Grid.from_file('bench/search/maps/small.txt')
bfs = Ai4r::Search::BFS.new(problem.method(:goal?), problem.method(:neighbors))
path = bfs.search(problem.start_state)
```

`path` will hold the list of coordinates from `S` to `G`.

To compare algorithms head-to-head, execute the search bench:

```bash
$ ruby bench/search/search_bench.rb \
    --problem grid --map bench/search/maps/small.txt \
    --algos bfs,dfs,iddfs,a_star
```

You will see an ASCII table summarizing nodes expanded and duration for
each algorithm. The CSV export can be loaded into a spreadsheet for
discussion.
