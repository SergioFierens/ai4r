# Hidden Markov Models

`Ai4r::Hmm::HiddenMarkovModel` implements a basic discrete hidden Markov model.
You configure the hidden states, observable symbols and the probability matrices.
The class exposes two main methods:

* `eval(sequence)` – returns the probability of an observation sequence using the forward algorithm.
* `decode(sequence)` – returns the most likely hidden state sequence using the Viterbi algorithm.

## Example

```ruby
require 'ai4r/hmm/hidden_markov_model'

states = [:Rainy, :Sunny]
observations = [:walk, :shop, :clean]
start_prob = [0.6, 0.4]
transition = [[0.7, 0.3], [0.4, 0.6]]
emission = [[0.1, 0.4, 0.5], [0.6, 0.3, 0.1]]

hmm = Ai4r::Hmm::HiddenMarkovModel.new(
  states: states,
  observations: observations,
  start_prob: start_prob,
  transition_prob: transition,
  emission_prob: emission
)

prob = hmm.eval([:walk, :shop, :clean])
path = hmm.decode([:walk, :shop, :clean])
```

`prob` will contain `0.033612` and `path` will contain `[:Sunny, :Rainy, :Rainy]`.
