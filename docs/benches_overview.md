# Bench Suite Overview

Benchmark scripts for selected algorithms live in the `bench/` directory. Each
"lab" focuses on a family of algorithms and owns its datasets, runners and
problems. Shared helpers such as the CLI, metrics and table reporter reside in
`bench/common`.

Currently the search lab is available under `bench/search`.

## Adding a new lab

1. Create a subfolder under `bench/` (for example `clusterer/`).
2. Provide a `<lab>_bench.rb` entry point delegating to `Bench::Common::CLI`.
3. Implement lab specific runners and problems similar to the search lab.
4. Document usage in a README inside the new folder.
