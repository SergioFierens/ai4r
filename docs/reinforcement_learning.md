# Reinforcement Learning

The `Ai4r::Reinforcement` module provides basic agents for Markov decision processes.

## Q-Learning

`Ai4r::Reinforcement::QLearning` implements the classic tabular algorithm.

### Parameters

* `learning_rate` – update step size (default `0.1`).
* `discount` – discount factor for future rewards (default `0.9`).
* `exploration` – probability of choosing a random action (default `0.1`).

```ruby
require 'ai4r/reinforcement/q_learning'

agent = Ai4r::Reinforcement::QLearning.new
agent.update(:s1, :a, 1, :s2)
agent.choose_action(:s1)
```

See `examples/reinforcement/q_learning_example.rb` for a runnable script.

## Policy Iteration

`Ai4r::Reinforcement::PolicyIteration` alternates policy evaluation and improvement.
Supply state lists, possible actions, transition probabilities and rewards.

### Parameters

* `discount` – discount factor for future rewards (default `0.9`).

```ruby
require 'ai4r/reinforcement/policy_iteration'

pi = Ai4r::Reinforcement::PolicyIteration.new
policy = pi.policy_iteration(states, actions, transition, reward)
```

For algorithms based on random playouts see [Monte Carlo Tree Search](monte_carlo_tree_search.md).
For classical graph search techniques see [Search Algorithms](search_algorithms.md).
