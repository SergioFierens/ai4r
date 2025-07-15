# Search Bench

A tiny benchmarking harness for basic search algorithms. Problems and
algorithms live under this folder while shared helpers are kept in
`bench/common`. Use it to compare BFS, DFS, IDDFS and A* on the same
problem with minimal setup.

## Quick start

```
$ ruby bench/search/search_bench.rb \
    --problem grid --map bench/search/maps/small.txt \
    --algos bfs,a_star --export out.csv
```

Console output shows a table of metrics and the CSV can be loaded into a
spreadsheet. Swap the problem or algorithm names to try DFS, IDDFS or the
classic eight puzzle.

## Metrics

* `solution_depth` – length of the returned path minus one
* `nodes_expanded` – how many states were expanded
* `max_frontier_size` – maximum size of the frontier data structure
* `duration_ms` – wall clock time in milliseconds
* `completed` – `true` when a goal was reached

## Adding an algorithm

1. Implement a runner under `bench/search/runners/` inheriting from
   `Bench::Common::BaseRunner`.
2. Append its name to `RUNNERS` in `search_bench.rb`.
3. Update the examples above.
