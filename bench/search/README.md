# Search Bench

A tiny benchmarking harness for basic search algorithms. Problems and
algorithms live under this folder while shared helpers are kept in
`bench/common`. Use it to compare BFS, DFS, IDDFS and A* on the same
problem with minimal setup.

## Quick start

```
$ ruby -Ilib bench/search/search_bench.rb \
    --problem grid --map bench/search/maps/small.txt \
    --algos bfs,a_star --export out.csv
```

Running from the repository requires the `-Ilib` flag so Ruby picks up the
library without installing the gem.

Console output shows a table of metrics and the CSV can be loaded into a
spreadsheet. Swap the problem or algorithm names to try DFS, IDDFS or the
classic eight puzzle.

### Example: grid path finding

Run the bench on a tiny maze to see BFS and A* in action:

```bash
ruby -Ilib bench/search/search_bench.rb \
    --problem grid --map bench/search/maps/small.txt \
    --algos bfs,a_star
```

You'll get a short table with depth, nodes expanded and runtime. For a step-by-step walkthrough see [../../docs/search_bench.md](../../docs/search_bench.md).

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
