# Search Algorithms

## Overview

The AI4R search algorithms group provides implementations of fundamental search and optimization algorithms used in artificial intelligence. These algorithms demonstrate how to systematically explore problem spaces to find optimal or near-optimal solutions.

## Educational Purpose

Search algorithms demonstrate core concepts in artificial intelligence:
- **Problem Representation**: How to model states and actions
- **Search Strategies**: Different approaches to exploring solution spaces
- **Heuristic Functions**: Using domain knowledge to guide search
- **Optimality vs. Efficiency**: Trade-offs in search algorithm design

## Available Algorithms

### Informed Search

#### A* (A-Star) Search
- **File**: `lib/ai4r/search/a_star.rb`
- **Description**: Best-first search using heuristic function to guide exploration
- **Use Cases**: Pathfinding, route planning, puzzle solving
- **Educational Value**: Demonstrates optimal heuristic search and admissibility

**Key Features:**
- Multiple heuristic functions (Manhattan, Euclidean, Chebyshev)
- Step-by-step visualization of search process
- Open/closed list management
- Path reconstruction and cost calculation

**Example Usage:**
```ruby
# Create grid world
grid = [
  [0, 0, 0, 1, 0],
  [0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0],
  [1, 1, 0, 1, 0],
  [0, 0, 0, 0, 0]
]

# Find optimal path
astar = Ai4r::Search::AStar.new(grid)
path = astar.find_path([0, 0], [4, 4])
puts "Path: #{path.inspect}"
```

### Game Tree Search

#### Minimax Algorithm
- **File**: `lib/ai4r/search/minimax.rb`
- **Description**: Adversarial search for two-player zero-sum games
- **Use Cases**: Game AI, decision making, competitive scenarios
- **Educational Value**: Shows game theory and adversarial reasoning

**Key Features:**
- Alpha-beta pruning for efficiency
- Configurable search depth
- Game state evaluation functions
- Move ordering optimization

**Example Usage:**
```ruby
# Define game state evaluation
def evaluate_position(board)
  # Return position value from current player's perspective
  score = 0
  # ... evaluation logic ...
  score
end

# Create minimax search
minimax = Ai4r::Search::Minimax.new(
  max_depth: 6,
  evaluation_function: method(:evaluate_position)
)

# Find best move
best_move = minimax.search(current_board_state)
puts "Best move: #{best_move}"
```

## Key Concepts Demonstrated

### Search Space Representation
- **State Space**: All possible configurations of the problem
- **Action Space**: Available moves or transitions
- **Goal States**: Desired final configurations
- **Path Costs**: Expense of different solution paths

### Heuristic Functions
- **Admissibility**: Never overestimating true cost
- **Consistency**: Satisfying triangle inequality
- **Dominance**: Comparing heuristic effectiveness
- **Domain Knowledge**: Incorporating problem-specific insights

### Search Strategies
- **Best-First Search**: Expanding most promising nodes
- **Breadth-First Search**: Systematic level-by-level exploration
- **Depth-First Search**: Deep exploration before backtracking
- **Iterative Deepening**: Combining depth and breadth benefits

## Educational Features

### Visualization Tools
- **Search Tree Visualization**: See node expansion order
- **Path Highlighting**: Show optimal and explored paths
- **Cost Visualization**: Display g(n), h(n), and f(n) values
- **Step-by-Step Execution**: Trace algorithm behavior

### Interactive Examples
- **Grid World Navigation**: Visual pathfinding problems
- **Puzzle Solving**: 8-puzzle, 15-puzzle implementations
- **Game Playing**: Tic-tac-toe, Connect Four examples
- **Route Planning**: Real-world navigation scenarios

### Performance Analysis
- **Node Expansion Count**: Measure search efficiency
- **Memory Usage**: Track space requirements
- **Solution Quality**: Evaluate path optimality
- **Time Complexity**: Analyze algorithm performance

## Common Usage Patterns

### Basic Pathfinding
```ruby
# Create search problem
problem = Ai4r::Search::GridWorld.new(
  grid: grid,
  start: [0, 0],
  goal: [4, 4]
)

# Configure A* search
astar = Ai4r::Search::AStar.new(
  heuristic: :manhattan,
  verbose: true
)

# Find solution
solution = astar.solve(problem)
puts "Path length: #{solution.path.length}"
puts "Total cost: #{solution.cost}"
```

### Game AI Implementation
```ruby
# Create game AI
class TicTacToeAI
  def initialize
    @minimax = Ai4r::Search::Minimax.new(
      max_depth: 9,
      evaluation_function: method(:evaluate_board)
    )
  end
  
  def choose_move(board)
    @minimax.search(board)
  end
  
  private
  
  def evaluate_board(board)
    # Evaluate board position for current player
    # Return positive for favorable, negative for unfavorable
  end
end

# Use in game
ai = TicTacToeAI.new
move = ai.choose_move(current_board)
```

### Custom Search Problems
```ruby
# Define custom search problem
class CustomProblem
  def initialize(initial_state, goal_state)
    @initial = initial_state
    @goal = goal_state
  end
  
  def initial_state
    @initial
  end
  
  def goal_test(state)
    state == @goal
  end
  
  def successors(state)
    # Return array of [action, new_state, cost] tuples
  end
  
  def heuristic(state)
    # Return heuristic estimate to goal
  end
end

# Solve custom problem
problem = CustomProblem.new(start, goal)
solution = Ai4r::Search::AStar.new.solve(problem)
```

## Integration with Other Components

### Data Structures
- **Priority Queues**: For best-first search implementation
- **Hash Tables**: For efficient state lookup
- **Graphs**: For problem representation
- **Trees**: For search tree maintenance

### Optimization
- **Memoization**: Caching computation results
- **Pruning**: Eliminating unpromising branches
- **Ordering**: Improving search efficiency
- **Parallelization**: Multi-threaded search

## Educational Progression

### Beginner Level
1. **Linear Search**: Sequential exploration
2. **Tree Search**: Understanding search trees
3. **Graph Search**: Handling repeated states

### Intermediate Level
1. **Uninformed Search**: BFS, DFS, uniform cost
2. **Informed Search**: A*, greedy best-first
3. **Heuristic Design**: Creating effective heuristics

### Advanced Level
1. **Adversarial Search**: Minimax, alpha-beta
2. **Constraint Satisfaction**: CSP solving
3. **Local Search**: Hill climbing, simulated annealing

## Performance Considerations

### Time Complexity
- **A***: O(b^d) where b=branching factor, d=depth
- **Minimax**: O(b^m) where m=maximum depth
- **Alpha-Beta**: O(b^(m/2)) with optimal ordering

### Space Complexity
- **A***: O(b^d) for storing open and closed lists
- **Minimax**: O(bm) for recursive call stack
- **Iterative Deepening**: O(bd) space with O(b^d) time

### Optimization Strategies
- **Heuristic Quality**: Better heuristics reduce search
- **Pruning**: Alpha-beta and other pruning techniques
- **Memory Management**: Efficient data structures
- **Parallelization**: Multi-core search algorithms

## Best Practices

### Heuristic Design
- **Admissibility**: Ensure heuristic never overestimates
- **Consistency**: Maintain triangle inequality
- **Efficiency**: Balance accuracy with computation speed
- **Domain Knowledge**: Incorporate problem-specific insights

### Algorithm Selection
- **A***: For optimal pathfinding with good heuristics
- **Minimax**: For two-player competitive games
- **Depth-First**: For memory-constrained problems
- **Breadth-First**: For unweighted shortest paths

### Implementation Tips
- **State Representation**: Efficient encoding of problem states
- **Duplicate Detection**: Avoid exploring same states
- **Memory Management**: Handle large search spaces
- **Debugging**: Visualize search process for debugging

### Common Pitfalls
- **Inadmissible Heuristics**: Can lead to suboptimal solutions
- **Memory Exhaustion**: Large search spaces require careful management
- **Infinite Loops**: Proper cycle detection is essential
- **Poor Heuristics**: Can make search inefficient

## Advanced Topics

### Meta-Heuristics
- **Genetic Algorithms**: Evolutionary search
- **Simulated Annealing**: Probabilistic optimization
- **Tabu Search**: Memory-based local search
- **Ant Colony Optimization**: Swarm intelligence

### Constraint Satisfaction
- **Backtracking**: Systematic constraint solving
- **Forward Checking**: Pruning inconsistent values
- **Arc Consistency**: Maintaining constraint consistency
- **Variable Ordering**: Heuristics for CSP solving

### Real-World Applications
- **Robot Navigation**: Path planning in robotics
- **Game AI**: Computer players for games
- **Route Planning**: GPS and mapping applications
- **Scheduling**: Resource allocation problems

This search algorithms framework provides a comprehensive foundation for understanding problem-solving in artificial intelligence through systematic exploration of solution spaces.