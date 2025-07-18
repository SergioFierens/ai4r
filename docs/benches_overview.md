# Bench Suite Overview

Benchmark scripts for selected algorithms live in the `bench/` directory. Each
"lab" focuses on a family of algorithms and owns its datasets, runners and
problems. Shared helpers such as the CLI, metrics and table reporter reside in
`bench/common`.

Labs exist for search algorithms, clustering algorithms and classifiers:
- [`bench/search`](../bench/search) – run BFS against A* in the [grid example](search_bench.md)
- [`bench/clusterer`](../bench/clusterer) – cluster blobs in the [demo](clusterer_bench.md)
- [`bench/classifier`](../bench/classifier) – predict iris species in the [classification tour](classifier_bench.md)

## Adding a new lab

1. Create a subfolder under `bench/` (for example `clusterer/`).
2. Provide a `<lab>_bench.rb` entry point delegating to `Bench::Common::CLI`.
3. Implement lab specific runners and problems similar to the search lab.
4. Document usage in a README inside the new folder.
