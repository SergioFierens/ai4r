# Genetic Algorithms

This example describes how AI4R uses genetic algorithms to solve the Travelling Salesman Problem. The "European Rock Tour" story demonstrates how a band attempts to minimize travel costs between cities.

## Algorithm Overview

Genetic algorithms evolve a population of candidate solutions:

1. Choose an initial population.
2. Evaluate the fitness of each individual.
3. Repeat for several generations:
   1. Select the best individuals.
   2. Breed a new generation through crossover and mutation.
   3. Evaluate offspring.
   4. Replace the worst individuals with new ones.

## Chromosome Implementation

Chromosomes must implement `Ai4r::GeneticAlgorithm::ChromosomeBase`.  The gem includes `TspChromosome`, which models a tour using a list of city indices. Fitness is the tour cost (lower is better), reproduction uses edge recombination, and mutation swaps two adjacent nodes with a probability related to fitness. The `seed` method generates an initial chromosome randomly.

```ruby
Ai4r::GeneticAlgorithm::TspChromosome.set_cost_matrix(data)
chromosome = Ai4r::GeneticAlgorithm::TspChromosome.new([0, 2, 1])
puts chromosome.fitness   # => -9
```

### Creating your own chromosome

Implement a subclass of `ChromosomeBase` defining the four required methods and
pass your class to `GeneticSearch`:

```ruby
class MyChromosome < Ai4r::GeneticAlgorithm::ChromosomeBase
  def fitness; ... end

  def self.seed; ... end
  def self.reproduce(a, b); ... end
  def self.mutate(chromosome); ... end
end

search = Ai4r::GeneticAlgorithm::GeneticSearch.new(50, 100, MyChromosome)
```

## Genetic Search

`GeneticSearch` performs the evolution. Initialize it with the population size and number of generations:

```ruby
search = Ai4r::GeneticAlgorithm::GeneticSearch.new(10, 20)
result = search.run
```

Running the search with a larger population and more generations usually finds cheaper tours.

## Example Usage

```ruby
require 'ai4r/genetic_algorithm/genetic_algorithm'
require 'csv'

# Load cost matrix from CSV
costs = []
CSV.read('travel_cost.csv').each { |row| costs << row.map(&:to_f) }
Ai4r::GeneticAlgorithm::TspChromosome.set_cost_matrix(costs)

search = Ai4r::GeneticAlgorithm::GeneticSearch.new(800, 100)
result = search.run
puts "Result cost: #{result.fitness}"
puts "Result tour: #{result.data.inspect}"
```

Typical results after 100 generations are far cheaper than random tours.

For more background, see the Wikipedia articles on the [Travelling Salesman Problem](http://en.wikipedia.org/wiki/Traveling_salesman_problem) and [Genetic Algorithms](http://en.wikipedia.org/wiki/Genetic_algorithm).
