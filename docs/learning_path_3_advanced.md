## 🚀 AI4R Learning Path #3 – **Advanced Track**

> *Time to stop following recipes and start writing your own.*

You’ve tuned models, decoded Transformers, shaped rewards, and extended benchmarks. You’re not scared of source code.
Now we’ll go full throttle: hidden states, game AI, custom linkages, policy design, dimensionality crushes, and performance profiling.

This is where you stop being a user—and start being a builder.

### 🛠️ Prerequisites

* You’ve completed the Intermediate track or already forked the repo in anger
* You know your way around Ruby internals and a profiler (`ruby-prof`, `stackprof`, etc.)
* Some familiarity with Markov models and reinforcement theory won’t hurt

### 🕵️ Module 1 – **Hidden Markov Models**: Train, Decode, Reveal

> 🧠 *Learn: uncover hidden states from noisy sequences.*

1. Read `docs/hmm.md` and skim `hidden_markov_model.rb`.
2. Use a toy sequence (e.g. "Walk Shop Clean") to train via Baum-Welch.
3. Decode the hidden weather pattern using Viterbi.
4. Throw in a new observation type. See what breaks. Fix it.

✅ You now get:

* How HMMs “learn what you can’t see”
* Why decoding ≠ training
* When HMMs beat neural nets (small data, clean math)

### ♟️ Module 2 – **Monte Carlo Tree Search**: Your First Game AI

> 🧠 *Learn: simulate, score, and dominate.*

1. Dig into `monte_carlo_tree_search.rb`
2. Wrap Tic-Tac-Toe or Connect Four in a `GameState` class
3. Tweak UCT constants, rollout depth, and simulation count
4. Play against it. Lose. Cry. Tune. Win.

✅ You now get:

* The balance between exploration and exploitation
* How smart search *feels* like intelligence
* Why MCTS crushes brute force in complex trees

### 🪜 Module 3 – **Custom Linkage** in Hierarchical Clustering

> 🧠 *Learn: control clustering behavior like a puppet master.*

1. Explore `hierarchical_*.rb` implementations
2. Add `centroid_linkage` as a new strategy
3. Cluster the Iris dataset and render a dendrogram (ASCII, matplotlib, whatever)
4. Try cutting the tree at different levels—watch your groups shift

✅ You now get:

* How linkage rules shape the entire cluster tree
* That clusters aren't "discovered"—they're *constructed*

### 🎮 Module 4 – **Policy Iteration**: Smarter Agents, Less Guesswork

> 🧠 *Learn: teach agents to think ahead—not just react.*

1. Crack open `policy_iteration.rb`
2. Model an inventory control problem: states = stock levels, actions = order/wait
3. Shape your rewards, tune your discount factor
4. Compare to Q-Learning—who learns faster?

✅ You now get:

* Dynamic programming beats trial-and-error (sometimes)
* Policies are **learned strategies**, not just best guesses
* Cost structures define behavior

### 🌐 Module 5 – **Self-Organizing Maps** on High-Dimensional Data

> 🧠 *Learn: flatten 100-D space into something you can actually see.*

1. Grab some word embeddings (e.g., GloVe or fastText)
2. Train a 20×20 SOM with the built-in `som/` tools
3. Map semantic groups onto the grid—watch structure emerge
4. Play with learning rate and radius decay—feel the topology shift

✅ You now get:

* How SOMs learn without labels
* That 2D grids can reveal hidden dimensions
* Visual intuition is a debugging superpower

### ⚡ Module 6 – **Performance Profiling**: Make Ruby Run

> 🧠 *Learn: stop guessing where the slow parts are.*

1. Profile a heavy benchmark (e.g., MCTS, boosting) with `ruby-prof`
2. Spot bottlenecks—object churn, tight loops, data copies
3. Optimize:
   * Memoize expensive calls
   * Pre-allocate arrays
   * (Optional) Drop into C or Rust for hot paths
4. Benchmark again. Smile.

✅ You now get:

* How to read profiling output like a treasure map
* That most slowness is fixable
* Where Ruby still rules—and where it needs help

### 🏁 Capstone – **Composite AI Project**

> *Now you design the system.*

Choose a real-world problem and bring three AI4R techniques together. Examples:

* **Predictive Maintenance**
  * HMM for system state
  * SOM for anomaly maps
  * Policy Iteration for repairs
* **Game AI+**
  * MCTS for planning
  * Reinforcement for learning strategies
  * Clustering for board-state compression
* **Text Analytics**
  * SOM for visualizing embeddings
  * HMM for tagging
  * Boosted classifier for tone or topic

Deliverables:

* Working code with clean docs
* Custom metrics or visual output
* A short write-up: “what I built, why it works, what I’d do next”

### 🥇 You're Now Advanced

You can:

* Build and train models with hidden state
* Write a competitive game AI
* Extend clustering logic
* Model MDPs with rewards that matter
* Crush 100D vectors into 2D maps
* Optimize Ruby for AI workloads

You’re not just using AI4R. You’re shaping it.
Ready to open a PR? Propose a new module?
Start a new learning path for others?

Because now—you’re not just learning AI.
You’re teaching it back.
