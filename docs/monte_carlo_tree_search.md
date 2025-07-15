# Monte Carlo Tree Search

`Ai4r::Search::MCTS` implements the Monte Carlo Tree Search strategy used in many modern game agents. It works anywhere you can programmatically enumerate actions, transitions and rewards. The algorithm repeatedly selects a promising node, expands one child, performs a random simulation and backpropagates the reward.

See [Search Algorithms](search_algorithms.md) for BFS and DFS or
[A* Search](a_star_search.md) for heuristic search.

```ruby
require 'ai4r/search'

env = {
  actions_fn: ->(s) { s == :root ? %i[a b] : [] },
  transition_fn: ->(s, a) { a == :a ? :win : :lose },
  terminal_fn: ->(s) { %i[win lose].include?(s) },
  reward_fn: ->(s) { s == :win ? 1.0 : 0.0 }
}

mcts = Ai4r::Search::MCTS.new(**env)
best = mcts.search(:root, 50)
```

The callbacks are:

* `actions_fn.call(state)` – list available actions.
* `transition_fn.call(state, action)` – compute the next state.
* `terminal_fn.call(state)` – whether the state is terminal.
* `reward_fn.call(state)` – payoff for terminal states.

Only a few dozen iterations are often enough to obtain a good action in small games.

Experiment with the parameters or plug in your own environment to see how the algorithm balances exploration and exploitation. MCTS shines when the search space is enormous but simulations are cheap.

You can run the search benchmark [`bench/search`](../bench/search) to compare MCTS with other
search strategies.
For value-based approaches see [Reinforcement Learning](reinforcement_learning.md).

