# Genetic Algorithms in Ruby :: AI4R

## The European Rock Tour Problem (Also known as the Travelling salesman problem)

An ageing rock band was planning its (hopefully) last european tour. They were planning to visit 15 european cities: Barcelona, Berlin, Brussels, Dublin, Hamburg, Kiev, London, Madrid, Milan, Moscow, Munich, Paris, Rome, Vienna, and Warsaw.

![European Tour](../site/src/documentation/resources/images/europe2.png)

They start planning the trip, when they realize that they could save a lot of money, if they ordered the cities to minimize the traveling cost. So they decided to try all possible combinations. They sat in front of the computer, visited their favorite traveling site, and started typing. 53 hours and several liters of coffee later, they realized it was a little bit more complicated than what they expected. They called their drummer (who was on vacations) and explained the problem to him. Fortunately, their drummer had a Master in Computer Science degree.

**Drummer** – Boys, if you continue, you will have to try 1,307,674,368,000 combinations. You are in front of a NP Problem.

**Band member #1** – Oh man! So it is going to take us all day!

**Band member #2** – And maybe more, 'cause this internet connection sucks...

**Drummer** – err... yes, it would take a while. But don't worry, I am sure we can get to a good solution using stochastic search algorithms applied to this problem..

**Band** – (Silence)

**Drummer** – .. that is, we are going to move from solution to solution in the space of candidate solutions, using techniques similar to what nature use for evolution, these are known as genetic algorithms.

**Band** – (Silence)

**Drummer** - ... What I mean is, we will pick some of them randomly, leave the ugly ones behind, and mate with the good looking ones...

**Band** – YEAH! THAT'S THE MAN! LET'S DO IT!

I forgot to tell another restriction of this problem: This band is really bad (What did you expect? Their drummer is a computer geek!) so once they visited a city, they cannot go back there.

## Introduction to Genetic Algorithms in Ruby

A Genetic Algorithm is a particular class of evolutionary algorithm and stochastic search. It aims to find the best possible solution in a solution domain, by selecting a simple set of solutions (chosen randomly or with a simple heuristic), and making it "evolve".

It works based on the following pseudocode:

1. Choose initial population
2. Evaluate the fitness of each individual in the population
3. Repeat as many times as generations we allow
   1. Select randomly best-ranking individuals to reproduce
   2. Breed new generation through crossover and mutation (genetic operations) and give birth to offspring
   3. Evaluate the individual fitnesses of the offspring
   4. Replace worst ranked part of population with offspring

## Implementation of Chromosome class for the Travelling salesman problem

In AI4R, the GeneticAlgorithm module implements the GeneticSearch and Chromosome classes. GeneticSearch is a generic class, and can be used to solve any kind of problems. The GeneticSearch class performs a stochastic search following the algorithm mentioned in the previous section.

However, the Chromosome class implementation is problem specific. AI4R built-in Chromosome class was designed to model the [Travelling salesman problem](http://en.wikipedia.org/wiki/Traveling_salesman_problem). You have to provide a matrix with the cost of traveling from one point to another (array of arrays of float values). If you want to solve other type of problem, you will have to modify the Chromosome class, by overwriting its fitness, reproduce, and mutate functions, to model your specific problem.

### Data representation

Each chromosome must represent a possible solution for the problem. This class contains an array with the list of visited nodes (cities of the tour). The size of the tour is obtained automatically from the traveling costs matrix. You have to assign the costs matrix BEFORE you run the genetic search. The following costs matrix could be used to solve the problem with only 3 cities:

```ruby
data_set = [  [ 0, 10, 5],
              [ 6,  0, 4],
              [25,  4, 0]
           ]
Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(data_set)
```

### Fitness function

The fitness function quantifies the optimality of a solution (that is, a chromosome) in a genetic algorithm so that that particular chromosome may be ranked against all the other chromosomes. Optimal chromosomes, or at least chromosomes which are more optimal, are allowed to breed and mix their datasets by any of several techniques, producing a new generation that will (hopefully) be even better.

The fitness function will return the complete tour cost represented by the chromosome, multiplied by -1. For example:

```ruby
data_set = [  [ 0, 10, 5],
              [ 6,  0, 4],
              [25,  4, 0]
           ]
Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(data_set)
chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 2, 1])
chromosome.fitness
  # => -9
```

That is: From 0 to 2 costs 5. From 2 to 1 costs 4. Total cost is 9.

### Reproduce function

Reproduction is used to vary the programming of a chromosome or chromosomes from one generation to the next. There are several ways to combine two chromosomes: One-point crossover, Two-point crossover, "Cut and splice", edge recombination, and more. The method is usually dependent of the problem domain. In this case, we have implemented edge recombination, which is the most used reproduction algorithm for the Travelling salesman problem. The edge recombination operator (ERO) is an operator that creates a path that is similar to a set of existing paths (parents) by looking at the edges rather than the vertices.

![Edge recombination](../site/src/documentation/resources/images/ero.gif)

The previous image was taken from Wikipedia, so hail to the author: Koala man (not me).

### Mutation function

Mutation function will be called for every member of the population, on each generation. But you do not want to mutate your chromosomes every time, especially if they are very fit. This is how it is currently implemented: With a probability of changing inversely proportional to its fitness, we swap 2 consecutive random nodes.

```ruby
def self.mutate(chromosome)
  if chromosome.normalized_fitness && rand < ((1 - chromosome.normalized_fitness) * 0.3)
    data = chromosome.data
    index = rand(data.length-1)
    data[index], data[index+1] = data[index+1], data[index]
    chromosome.data = data
    @fitness = nil
  end
end
```

### Seed function

Initializes an individual solution (chromosome) for the initial population. The built in seed function generates a chromosome randomly, but you can use some problem domain knowledge, to generate better initial solutions (although this not always deliver better results, it improves convergency times).

```ruby
def self.seed
  data_size = @@costs[0].length
  available = []
  0.upto(data_size-1) { |n| available << n }
  seed = []
  while available.length > 0 do 
    index = rand(available.length)
    seed << available.delete_at(index)
  end
  return Chromosome.new(seed)
end
```

## Implementation of GeneticSearch

The GeneticSearch class is a generic class to try to solve any kind of problem using genetic algorithms. If you want to model another type of problem, you will have to modify the Chromosome class, defining its fitness, mutate, and reproduce functions.

### Initialize the search

You have to provide two parameters during instantiation: The initial population size, and how many generations to produce. Large numbers will usually converge to better results, while small numbers will have better performance.

```ruby
search = Ai4r::GeneticAlgorithm::GeneticSearch.new(10, 20)
result = search.run
```

### Run method

Once you initialize an instance of GeneticSearch class, you can perform the search executing the run method. This method will:

1. Choose initial population
2. Evaluate the fitness of each individual in the population
3. Repeat as many times as generations we allow
   1. Select randomly the best-ranking individuals to reproduce
   2. Breed new generation through crossover and mutation (genetic operations) and give birth to offspring
   3. Evaluate the individual fitnesses of the offspring
   4. Replace worst ranked part of population with offspring

### Selection

Selection is the stage of a genetic algorithm in which individual genomes are chosen from a population for later breeding. There are several generic selection algorithms, such as tournament selection and roulette wheel selection. We implemented the latter.

1. The fitness function is evaluated for each individual, providing fitness values
2. The population is sorted by descending fitness values
3. The fitness values are then normalized. (Highest fitness gets 1, lowest fitness gets 0). The normalized value is stored in the "normalized_fitness" attribute of the chromosomes
4. A random number R is chosen. R is between 0 and the accumulated normalized value (all the normalized fitness values added together)
5. The selected individual is the first one whose accumulated normalized value (its normalized value plus the normalized values of the chromosomes prior to it) greater than R
6. We repeat steps 4 and 5, 2/3 times the population size

![Fitness](../site/src/documentation/resources/images/fitness.png)

The previous image was taken from Wikipedia, so hail to the author: Simon Hatton.

### Reproduction

The reproduction function combines each pair of selected chromosomes using the method Chromosome.reproduce.

The reproduction will also call the Chromosome.mutate method with each member of the population. You should implement Chromosome.mutate to only change (mutate) randomly. E.g. You could effectively change the chromosome only if:

```ruby
rand < ((1 - chromosome.normalized_fitness) * 0.4)
```

## How to use AI4R Genetic Search implementation

```ruby
# Cost of traveling from one point to another. E.g. Travelling from Node 0 to Node 2 costs 5.
data_set = [  [ 0, 10, 5],
              [ 6,  0, 4],
              [25,  4, 0]
           ]		

Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(data_set)

search = Ai4r::GeneticAlgorithm::GeneticSearch.new(10, 20)
result = search.run
puts "Result cost: #{result.fitness}"
puts "Result nodes: #{result.data.inspect}"
```

## How to run the example

You can run the example with `ruby genetic_algorithm_example.rb`. The genetic_algorithm_example.rb file contains:

```ruby
require "rubygems"
require "ai4r/genetic_algorithm/genetic_algorithm"
require "csv"

# Load data from data_set.csv
data_set = []
CSV::Reader.parse(File.open("#{File.dirname(__FILE__)}/travel_cost.csv", 'r')) do |row|
  data_set << row
end
data_labels = data_set.shift
data_set.collect! do |column|
  column.collect { |element| element.to_f}
end

Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(data_set)

puts "Beginning genetic search, please wait... "
search = Ai4r::GeneticAlgorithm::GeneticSearch.new(800, 100)
result = search.run
puts "Result cost: #{result.fitness}"
puts "Result tour: "
result.data.each { |c| print " #{data_labels[c]}"}
```

## Results of using Genetic Algorithms to the The European Rock Tour Problem (or Travelling salesman problem)

The cost of 3 randomly selected tours:
- $17486.01 : Madrid Vienna Moscow Berlin Brussels Munich Milan Barcelona London Hamburg Warsaw Dublin Kiev Paris Rome
- $20198.92 : London Rome Brussels Kiev Hamburg Warsaw Barcelona Paris Munich Dublin Vienna Moscow Madrid Milan Berlin
- $17799.34 : Madrid Milan Kiev Vienna Warsaw London Barcelona Hamburg Paris Munich Dublin Berlin Moscow Rome Brussels

3 tours obtained with an initial population of 800, and after 100 generations:
- $7611.99 : Moscow Kiev Warsaw Hamburg Berlin Munich Vienna Milan Rome Barcelona Madrid Paris Brussels London Dublin
- $7596.74 : Moscow Kiev Warsaw Berlin Hamburg Munich Vienna Milan Rome Barcelona Madrid Paris Brussels London Dublin (See Image)
- $7641.61 : Madrid Barcelona Rome Milan Paris Dublin London Brussels Hamburg Berlin Vienna Munich Warsaw Kiev Moscow

![Best tour result using Genetic Algorithms in ruby](../site/src/documentation/resources/images/europe3.png)

The GeneticSearch class is a generic class to try to solve any kind of problem using genetic algorithms. If you want to model another type of problem, you will have to modify the Chromosome class, defining its fitness, mutate, and reproduce functions.

## More about Genetic Algorithms and the Travelling salesman problem

- [Travelling salesman problem at Wikipedia](http://en.wikipedia.org/wiki/Traveling_salesman_problem)
- [Genetic Algorithms at Wikipedia](http://en.wikipedia.org/wiki/Genetic_algorithm)