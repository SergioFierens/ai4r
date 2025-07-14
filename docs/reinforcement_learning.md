# Reinforcement Learning

The `Ai4r::Reinforcement` module provides basic agents for Markov decision processes.

## Q-Learning

`Ai4r::Reinforcement::QLearning` implements the classic tabular algorithm.

```ruby
require 'ai4r/reinforcement/q_learning'

agent = Ai4r::Reinforcement::QLearning.new
agent.update(:s1, :a, 1, :s2)
agent.choose_action(:s1)
```

## Policy Iteration

`Ai4r::Reinforcement::PolicyIteration` alternates policy evaluation and improvement.
Supply state lists, possible actions, transition probabilities and rewards.

```ruby
require 'ai4r/reinforcement/policy_iteration'

pi = Ai4r::Reinforcement::PolicyIteration.new
policy = pi.policy_iteration(states, actions, transition, reward)
```
