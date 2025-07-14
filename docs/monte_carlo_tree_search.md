# Monte Carlo Tree Search

`Ai4r::Search::MCTS` provides a generic implementation of the popular Monte Carlo Tree Search algorithm. It can be used for game playing or any domain where the available actions, state transitions and rewards can be described programmatically.

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
