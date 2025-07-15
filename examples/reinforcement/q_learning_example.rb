require 'ai4r/reinforcement/q_learning'

agent = Ai4r::Reinforcement::QLearning.new
agent.set_parameters(learning_rate: 0.5, discount: 1.0, exploration: 0.0)

# Simple two-state MDP
agent.update(:s1, :a, 0, :s2)
agent.update(:s1, :b, 1, :s1)

puts "Best action from s1: #{agent.choose_action(:s1)}"
