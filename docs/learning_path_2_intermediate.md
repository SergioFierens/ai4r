## 🏃‍♂️ AI4R Learning Path #2 – **Intermediate Track**

> *From “I can run a model” to “I can tune, extend, and build smart stuff that actually works.”*

You’ve trained your first models, tweaked some clusters, maybe even backprop’ed a neural net. Nice.

Now it’s time to go deeper: tune ensembles, shape rewards, mess with distance functions, evolve a Sudoku solver—and crack open a Transformer like it’s no big deal. Let’s go.

### 🛠️ Prerequisites

* You’ve finished the **Beginner Track** (or already speak fluent `require 'ai4r'`)
* You’ve cloned the repo and can run tests with `bundle exec rake`
* You’re cool with Git (or brave enough to fake it)

### 🌳 Module 1 – Forests, Boosting & the Art of Tuning

> 🧠 *Learn: tree ensembles are overpowered—and totally tunable.*

1. Read through `random_forest.rb` and `gradient_boosting.rb`.
2. Copy `compare_all.rb` to `forest_vs_boost.rb`.
3. Play with `num_trees`, `max_depth`, `learning_rate`, etc.
4. Graph accuracy vs. hyperparameters—bonus points for pretty colors.

✅ You now understand:

* Why RandomForest works out of the box
* Why GradientBoosting can beat it—with tuning

### 🔬 Module 2 – Distance is a Choice, Not a Fact

> 🧠 *Learn: the way your model measures similarity changes everything.*

1. Add `chebyshev` to `lib/ai4r/proximity.rb`
2. Swap it into KMeans or DBSCAN in `kmeans_vs_dbscan.rb`
3. Watch clusters shift dramatically—even though the data didn’t

✅ You now understand:

* How distance metrics control clustering
* That Euclidean isn't always right

### 🧬 Module 3 – Roll Your Own Genetic Algorithm

> 🧠 *Learn: if you can encode a problem, you can evolve a solution.*

1. Peek at `tsp_chromosome.rb`.
2. Build a new chromosome (e.g., 4x4 Sudoku)
3. Plug it into the GA engine and evolve till solved
4. Mutation rate too high? Watch it crash. Too low? It stalls.

✅ You now understand:

* Chromosome design = creative encoding
* Mutation & crossover = controlled chaos

### 🎮 Module 4 – Q-Learning, but Make It Smarter

> 🧠 *Learn: shaping rewards teaches agents faster than yelling “wrong!”*

1. Start with the grid-world in `docs/reinforcement_learning.md`
2. Add:
   * Negative reward for each step
   * Big bonus for early success
3. Compare convergence speed (how many episodes to learn)

✅ You now understand:

* Rewards aren’t just feedback—they’re a strategy
* Agents learn what you *incentivize*, not what you *want*

### 🤖 Module 5 – A Tiny Transformer That You Can Actually Read

> 🧠 *Learn: break down attention, multi-heads, and sequence scaling—line by line.*

1. Open `transformer.rb`—yes, read the whole thing
2. Copy the inline example to `mini_transformer.rb`
3. Tweak:
   * Sequence length (10 vs 50)
   * Head count (2 vs 4)
4. Watch parameter count, runtime, and output patterns shift

✅ You now understand:

* Why attention is expensive
* What multi-head actually means in code

### 📊 Module 6 – Metrics That Matter

> 🧠 *Learn: building your own metric is the most honest way to evaluate.*

1. Check out `bench/common/metrics.rb`
2. Add a `balanced_accuracy` or `f_beta` function
3. Re-run a classifier bench and print your custom metric
4. Push it to your fork—you’re officially contributing

✅ You now understand:

* Metrics shape how models are judged
* “Accuracy” alone isn’t enough

### 🏁 Capstone – Mix & Match Time

Pick a real dataset (UCI, Kaggle, or scrape your own).
Then:

* Train a boosted classifier
* Cluster users or records
* Recommend an action policy using Q-Learning
* Tune, measure, iterate—then ship your notebook or `.rb` file

Document your decisions like this:

1. What you’re solving
2. What you tried
3. What worked (and didn’t)
4. What you learned

✅ You’ve combined multiple AI techniques into a single project. Boom.

### 🥈 You’ve Leveled Up

You now:

* Know how to tune tree-based models
* Customize core behavior (metrics, distances, fitness)
* Build your own problem encodings
* Understand RL reward design
* Actually *get* Transformers
* Can extend and contribute to AI4R itself

Next stop: **Advanced Track** — Hidden Markov Models, Monte Carlo Tree Search, custom benchmarks, and serious optimization.

Ready to break things?
