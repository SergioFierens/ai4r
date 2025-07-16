# Search Bench

Benchmark BFS, DFS, IDDFS and A* on small search problems. The bench shares the common CLI with other labs.

```bash
ruby -Ilib bench/search/search_bench.rb \
    --problem grid --map bench/search/maps/small.txt \
    --algos bfs,a_star
```

## Walk through the grid example

1. The map file `bench/search/maps/small.txt` defines a 5x4 maze where `S` is the start and `G` the goal.
2. Running the command loads the grid problem and searches for a path using BFS and A*.
3. Metrics such as solution depth, nodes expanded and runtime are printed as a table.
4. A second table marks algorithms that are compact or fast.
5. Use `--export FILE` to save the metrics as CSV for later analysis.

Example output:

```text
algorithm | solution_depth | nodes_expanded | max_frontier_size | duration_ms | completed
-----------------------------------------------------------------------------------------
bfs       | 3              | 4              | 2                 | 0.04        | true
astar     | 3              | 4              | 2                 | 0.06        | true
```
