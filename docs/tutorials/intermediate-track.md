# AI4R Intermediate Adventure: Level Up Your AI Game! ⚡

*"The expert in anything was once a beginner who refused to give up." - Helen Hayes*

Ready to dive deeper? This track transforms you from an AI enthusiast into a skilled practitioner. Less hand-holding, more discovery!

## 🎯 What You'll Master

- Neural networks and deep learning fundamentals
- Advanced algorithm optimization and tuning
- Complex problem-solving with hybrid approaches
- Real-world AI system design
- Performance optimization techniques

## 📚 Prerequisites

- Completed Beginner Track (or equivalent knowledge)
- Comfortable with basic Ruby programming
- Understanding of fundamental AI concepts

---

## Chapter 1: Neural Networks - The Brain-Inspired Revolution 🧠

### The Challenge: Beyond Simple Rules

Traditional algorithms follow explicit rules. Neural networks learn patterns from data, just like human brains learn from experience.

### 🧪 Experiment 1: Your First Neural Network

```ruby
require 'ai4r'

# Create a more complex dataset
complex_data = Ai4r::Data::DataSet.new(
  data_labels: ['x1', 'x2', 'x3', 'x4', 'class'],
  data_items: [
    [0.1, 0.2, 0.8, 0.9, 'A'],
    [0.9, 0.8, 0.1, 0.2, 'B'],
    [0.2, 0.1, 0.9, 0.8, 'A'],
    [0.8, 0.9, 0.2, 0.1, 'B'],
    [0.1, 0.3, 0.7, 0.9, 'A'],
    [0.9, 0.7, 0.3, 0.1, 'B'],
    [0.3, 0.1, 0.9, 0.7, 'A'],
    [0.7, 0.9, 0.1, 0.3, 'B']
  ]
)

# Compare traditional vs neural approaches
bench = Ai4r::Experiment::ClassifierBench.new(verbose: true)

# Traditional approaches
bench.add_classifier(:decision_tree, Ai4r::Classifiers::ID3.new,
  friendly_name: "Rule Master")

bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new,
  friendly_name: "Probability Calculator")

# Neural network approach
bench.add_classifier(:neural_net, Ai4r::Classifiers::MultilayerPerceptron.new([4, 6, 2]),
  friendly_name: "Brain Network")

# The showdown
results = bench.run(complex_data)
bench.display_results(results)

# Deep dive into neural network behavior
puts "\n🧠 Neural Network Analysis:"
neural_result = results[:neural_net]
puts "Training time: #{neural_result[:timing][:avg_training_time].round(4)}s"
puts "Accuracy: #{(neural_result[:metrics][:accuracy] * 100).round(1)}%"
puts "✨ Neural networks excel at finding complex patterns!"
```

### 🔍 Neural Network Insights

Neural networks shine when:
- **Pattern complexity**: Traditional rules break down
- **Feature interactions**: Multiple inputs affect outcomes
- **Adaptive learning**: The algorithm improves with more data

**Key Insight**: Neural networks trade interpretability for power!

---

## Chapter 2: Advanced Search - The Strategy Masters 🎯

### The Challenge: Strategic Thinking

Move beyond simple pathfinding to strategic game-playing where you must think several moves ahead.

### 🧪 Experiment 2: Game Intelligence Comparison

```ruby
require 'ai4r'

# Create a strategic game state
class TicTacToeState
  def initialize(board = nil, player = :x)
    @board = board || Array.new(3) { Array.new(3, :empty) }
    @player = player
  end
  
  def get_possible_moves
    moves = []
    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        moves << [i, j] if cell == :empty
      end
    end
    moves
  end
  
  def make_move(move)
    new_board = @board.map(&:dup)
    new_board[move[0]][move[1]] = @player
    next_player = @player == :x ? :o : :x
    TicTacToeState.new(new_board, next_player)
  end
  
  def evaluate
    # Check wins
    lines = @board + @board.transpose + [diagonal1, diagonal2]
    lines.each do |line|
      return 10 if line.all? { |cell| cell == :x }
      return -10 if line.all? { |cell| cell == :o }
    end
    0
  end
  
  def game_over?
    evaluate != 0 || get_possible_moves.empty?
  end
  
  def current_player
    @player
  end
  
  private
  
  def diagonal1
    [0, 1, 2].map { |i| @board[i][i] }
  end
  
  def diagonal2
    [0, 1, 2].map { |i| @board[i][2-i] }
  end
end

# Set up strategic intelligence test
bench = Ai4r::Experiment::SearchBench.new(verbose: true)

# Different strategic depths
bench.add_algorithm(:shallow_thinker, 
  Ai4r::Search::Minimax.new(max_depth: 2),
  friendly_name: "Quick Thinker")

bench.add_algorithm(:deep_thinker, 
  Ai4r::Search::Minimax.new(max_depth: 6),
  friendly_name: "Strategic Master")

bench.add_algorithm(:pruning_master, 
  Ai4r::Search::Minimax.new(max_depth: 8, alpha_beta: true),
  friendly_name: "Efficiency Expert")

# Create game scenario
game_state = TicTacToeState.new([
  [:x, :empty, :empty],
  [:empty, :o, :empty],
  [:empty, :empty, :empty]
], :x)

bench.add_problem(:strategic_game, {
  type: :game,
  initial_state: game_state
}, friendly_name: "Strategic Battle")

# Battle of minds
results = bench.run
bench.display_results(results)

# Strategy analysis
puts "\n🎯 Strategic Analysis:"
results.each do |algo, result|
  game_result = result[:strategic_game]
  puts "#{algo}: #{game_result[:nodes_explored]} positions considered, #{(game_result[:search_time] * 1000).round(2)}ms"
end
```

### 🔍 Strategy Insights

Strategic algorithms reveal:
- **Depth vs Speed**: Deeper thinking takes more time
- **Pruning Power**: Alpha-beta pruning maintains quality while improving speed
- **Diminishing Returns**: Sometimes thinking too deep doesn't help

**Key Insight**: Intelligence isn't just about thinking deep - it's about thinking smart!

---

## Chapter 3: Optimization Mastery - Finding the Best Solution 🚀

### The Challenge: Complex Optimization

Real-world problems often have no clear "right" answer - just better and worse solutions.

### 🧪 Experiment 3: Evolutionary Problem Solving

```ruby
require 'ai4r'

# Create a complex optimization problem
class TravelingSalesman
  def initialize(cities)
    @cities = cities
    @distances = calculate_distances
  end
  
  def distance(city1, city2)
    @distances[city1][city2]
  end
  
  def total_distance(route)
    total = 0
    route.each_with_index do |city, i|
      next_city = route[(i + 1) % route.length]
      total += distance(city, next_city)
    end
    total
  end
  
  private
  
  def calculate_distances
    # Simple distance matrix for demo
    {
      'A' => {'A' => 0, 'B' => 10, 'C' => 15, 'D' => 20},
      'B' => {'A' => 10, 'B' => 0, 'C' => 35, 'D' => 25},
      'C' => {'A' => 15, 'B' => 35, 'C' => 0, 'D' => 30},
      'D' => {'A' => 20, 'B' => 25, 'C' => 30, 'D' => 0}
    }
  end
end

# Define optimization chromosome
class RouteChromosome
  attr_accessor :data
  
  def initialize(cities = nil)
    @cities = cities || ['A', 'B', 'C', 'D']
    @data = @cities.shuffle
    @problem = TravelingSalesman.new(@cities)
  end
  
  def fitness
    1.0 / (1.0 + @problem.total_distance(@data))
  end
  
  def reproduce(other)
    # Order crossover
    child = RouteChromosome.new(@cities)
    child.data = @data.dup
    child
  end
  
  def mutate
    return unless rand < 0.1
    i, j = [rand(@data.length), rand(@data.length)]
    @data[i], @data[j] = @data[j], @data[i]
  end
  
  def self.seed
    new
  end
end

# Run evolutionary optimization
puts "🧬 Evolutionary Optimization Challenge!"

# Create genetic algorithm
ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(100, 50)
ga.set_chromosome_class(RouteChromosome)

# Evolve solution
puts "Evolving optimal route..."
best_route = ga.run

puts "\n🏆 Evolution Results:"
puts "Best route: #{best_route.data.join(' → ')}"
puts "Total distance: #{TravelingSalesman.new(['A', 'B', 'C', 'D']).total_distance(best_route.data)}"
puts "Fitness: #{best_route.fitness.round(4)}"
```

### 🔍 Optimization Insights

Evolutionary algorithms teach us:
- **Iterative Improvement**: Solutions get better over time
- **Population Diversity**: Multiple approaches prevent local optima
- **Mutation Balance**: Too much chaos kills progress, too little prevents discovery

**Key Insight**: Sometimes the best solution emerges from organized chaos!

---

## Chapter 4: Performance Optimization - Speed Meets Intelligence ⚡

### The Challenge: Real-World Performance

Academic problems are nice, but real applications need to be fast, efficient, and scalable.

### 🧪 Experiment 4: Performance Profiling

```ruby
require 'ai4r'
require 'benchmark'

# Create performance testing framework
class PerformanceProfiler
  def initialize
    @results = {}
  end
  
  def profile_algorithm(name, &block)
    puts "⏱️  Profiling #{name}..."
    
    # Warm up
    3.times { yield }
    
    # Measure
    times = []
    memory_before = GC.stat[:heap_allocated_pages]
    
    10.times do
      start_time = Time.now
      yield
      times << (Time.now - start_time)
    end
    
    memory_after = GC.stat[:heap_allocated_pages]
    
    @results[name] = {
      avg_time: times.sum / times.length,
      min_time: times.min,
      max_time: times.max,
      memory_used: (memory_after - memory_before) * 16 * 1024, # Approximate KB
      consistency: (times.max - times.min) / times.sum
    }
    
    puts "  Average: #{(@results[name][:avg_time] * 1000).round(2)}ms"
    puts "  Memory: #{@results[name][:memory_used]}KB"
    puts "  Consistency: #{(@results[name][:consistency] * 100).round(1)}%"
  end
  
  def compare_results
    puts "\n📊 Performance Comparison:"
    puts "-" * 50
    
    @results.each do |name, metrics|
      puts "#{name}:"
      puts "  Speed: #{(metrics[:avg_time] * 1000).round(2)}ms"
      puts "  Memory: #{metrics[:memory_used]}KB"
      puts "  Reliability: #{(100 - metrics[:consistency] * 100).round(1)}%"
    end
    
    # Find winners
    fastest = @results.min_by { |_, metrics| metrics[:avg_time] }
    most_efficient = @results.min_by { |_, metrics| metrics[:memory_used] }
    
    puts "\n🏆 Performance Winners:"
    puts "⚡ Fastest: #{fastest[0]}"
    puts "💾 Most Memory Efficient: #{most_efficient[0]}"
  end
end

# Performance showdown
profiler = PerformanceProfiler.new

# Create test datasets of different sizes
small_data = create_test_data(50)
large_data = create_test_data(500)

def create_test_data(size)
  items = []
  size.times do |i|
    items << [
      rand > 0.5 ? 'high' : 'low',
      rand > 0.5 ? 'yes' : 'no',
      rand > 0.5 ? 'A' : 'B'
    ]
  end
  
  Ai4r::Data::DataSet.new(
    data_labels: ['feature1', 'feature2', 'class'],
    data_items: items
  )
end

# Profile different algorithms
bench = Ai4r::Experiment::ClassifierBench.new(verbose: false)

profiler.profile_algorithm("Decision Tree (Small)") do
  bench.add_classifier(:dt, Ai4r::Classifiers::ID3.new)
  bench.run(small_data)
end

profiler.profile_algorithm("Neural Network (Small)") do
  bench.add_classifier(:nn, Ai4r::Classifiers::MultilayerPerceptron.new([2, 4, 2]))
  bench.run(small_data)
end

profiler.profile_algorithm("Decision Tree (Large)") do
  bench.add_classifier(:dt_large, Ai4r::Classifiers::ID3.new)
  bench.run(large_data)
end

profiler.compare_results
```

### 🔍 Performance Insights

Performance optimization reveals:
- **Scalability Matters**: Algorithms behave differently at scale
- **Memory vs Speed**: Often a trade-off between the two
- **Consistency**: Predictable performance is often more valuable than peak performance

**Key Insight**: The "best" algorithm depends on your constraints!

---

## Chapter 5: Hybrid Intelligence - Combining Approaches 🤝

### The Challenge: Best of All Worlds

Real AI systems often combine multiple approaches for optimal results.

### 🧪 Experiment 5: Ensemble Methods

```ruby
require 'ai4r'

# Create ensemble classifier
class EnsembleClassifier
  def initialize(classifiers)
    @classifiers = classifiers
    @trained = false
  end
  
  def build(dataset)
    puts "🤝 Training ensemble of #{@classifiers.length} classifiers..."
    @classifiers.each_with_index do |(name, classifier), i|
      puts "  Training #{name}... (#{i+1}/#{@classifiers.length})"
      classifier.build(dataset)
    end
    @trained = true
    self
  end
  
  def eval(features)
    raise "Ensemble not trained!" unless @trained
    
    # Collect votes from all classifiers
    votes = {}
    @classifiers.each do |name, classifier|
      vote = classifier.eval(features)
      votes[vote] = (votes[vote] || 0) + 1
    end
    
    # Return majority vote
    votes.max_by { |_, count| count }[0]
  end
  
  def get_rules
    "Ensemble of #{@classifiers.length} classifiers using majority voting"
  end
end

# Create test scenario
test_data = Ai4r::Data::DataSet.new(
  data_labels: ['feature1', 'feature2', 'feature3', 'class'],
  data_items: [
    ['high', 'yes', 'red', 'positive'],
    ['low', 'no', 'blue', 'negative'],
    ['high', 'no', 'red', 'positive'],
    ['low', 'yes', 'blue', 'negative'],
    ['medium', 'yes', 'green', 'positive'],
    ['medium', 'no', 'green', 'negative'],
    ['high', 'yes', 'blue', 'positive'],
    ['low', 'no', 'red', 'negative']
  ]
)

# Build ensemble
ensemble = EnsembleClassifier.new({
  decision_tree: Ai4r::Classifiers::ID3.new,
  naive_bayes: Ai4r::Classifiers::NaiveBayes.new,
  nearest_neighbor: Ai4r::Classifiers::IB1.new
})

# Compare individual vs ensemble
bench = Ai4r::Experiment::ClassifierBench.new(verbose: true)

bench.add_classifier(:decision_tree, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)
bench.add_classifier(:ensemble, ensemble, friendly_name: "Team AI")

results = bench.run(test_data)
bench.display_results(results)

puts "\n🤝 Ensemble Insights:"
ensemble_result = results[:ensemble]
individual_results = results.reject { |k, _| k == :ensemble }

avg_individual_accuracy = individual_results.values.map { |r| r[:metrics][:accuracy] }.sum / individual_results.size
ensemble_accuracy = ensemble_result[:metrics][:accuracy]

puts "Individual average: #{(avg_individual_accuracy * 100).round(1)}%"
puts "Ensemble accuracy: #{(ensemble_accuracy * 100).round(1)}%"
puts "Ensemble improvement: #{((ensemble_accuracy - avg_individual_accuracy) * 100).round(1)}%"
```

### 🔍 Ensemble Insights

Ensemble methods show:
- **Wisdom of Crowds**: Multiple weak learners create strong results
- **Error Reduction**: Different algorithms make different mistakes
- **Robustness**: Less likely to fail catastrophically

**Key Insight**: Teamwork makes the dream work, even for algorithms!

---

## 🚀 Your Intermediate Mastery

### What You've Conquered
- ✅ Neural networks and pattern recognition
- ✅ Strategic game-playing algorithms
- ✅ Evolutionary optimization techniques
- ✅ Performance profiling and optimization
- ✅ Ensemble methods and hybrid approaches

### Advanced Concepts Unlocked
- **Gradient Descent**: How neural networks learn
- **Alpha-Beta Pruning**: Efficient strategic search
- **Genetic Algorithms**: Evolution-inspired optimization
- **Ensemble Learning**: Combining multiple models
- **Performance Profiling**: Measuring real-world efficiency

### Ready for the Final Challenge?
The **Advanced Track** awaits! You'll master:
- Deep learning architectures
- Advanced optimization algorithms
- Large-scale system design
- Cutting-edge AI research applications

### Your Intermediate Arsenal
You now wield:
- **Multi-layer neural networks** for complex pattern recognition
- **Strategic search algorithms** for game-playing and planning
- **Evolutionary algorithms** for optimization problems
- **Performance analysis tools** for real-world applications
- **Ensemble methods** for robust AI systems

---

## 🎯 Capstone Project: Build Your AI Laboratory

Create a comprehensive AI research platform:

```ruby
# Your mission: Build a multi-algorithm, multi-problem AI lab
# Requirements:
# 1. Compare at least 5 different algorithms
# 2. Test on at least 3 different problem types
# 3. Include performance profiling
# 4. Create ensemble methods
# 5. Generate research-quality analysis

# This is your chance to show mastery of intermediate AI concepts!
```

**Remember**: You're no longer just using AI - you're understanding how to make it better!

---

*"The best way to predict the future is to create it." - Peter Drucker*

**Next Adventure**: [Advanced Track](advanced-track.md) - Where AI experts are forged!