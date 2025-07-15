# AI4R Learning Paths

AI4R offers three self-guided tracks to build your intuition for machine learning in Ruby. Start with the basics, progress to intermediate concepts, and finish with advanced topics. This page outlines each path; the first one is fully detailed below.

## Beginner Track

*Build core intuition for AI—step by step, in Ruby. No math PhD required.*

This track is for students, hobbyists and curious developers who want to understand AI, not just run it. You will train your first model, cluster unlabeled data, build a neural network from scratch and explore search trees using readable Ruby code.

### Prerequisites

1. **Run Ruby scripts** and install gems
   👉 [Quick Ruby setup & basics (ruby-lang.org)](https://www.ruby-lang.org/en/documentation/quickstart/)
2. **Install the AI4R gem**
   ```bash
   gem install ai4r
   ```
3. **(Optional)** Clone the repository to access examples and benchmarks
   ```bash
   git clone https://github.com/SergioFierens/ai4r
   cd ai4r
   bundle install
   ```

### Module 1 – "Hello, ZeroR" (≈ 30 min)

> Learn what a dataset is, what a label is, and why dumb models matter.

Start with the simplest possible model: always predict the most common label. It may sound silly, but it is a crucial baseline.

1. Read `lib/ai4r/classifiers/zero_r.rb`—yes, *read* the code.
2. Try it in IRB or a file:
   ```ruby
   require 'ai4r'
   dataset = Ai4r::Data::DataSet.new(:data_items => [[1],[2],[3]], :data_labels => [0,0,1])
   model   = Ai4r::Classifiers::ZeroR.new.build(dataset)
   puts model.eval([99])  # → 0
   ```

**Experiment:** Change the labels to `[1,1,0]`—what happens?

**You’ve learned:**
- How to use `DataSet`
- That even the worst model can be useful as a sanity check

### Module 2 – Your First Real Model: Logistic Regression (≈ 1 hour)

> Learn how a machine learns probabilities from labeled data.

Now we train a real model—one that actually learns. You will explore accuracy, train/test splits and compare to ZeroR.

1. Skim the source: `lib/ai4r/classifiers/logistic_regression.rb`
2. Run:
   ```bash
   ruby bench/classifier/compare_all.rb
   ```
   (It uses the Iris dataset by default.)
3. **Tweak the benchmark:** In `compare_all.rb`, comment out all models except `ZeroR` and `LogisticRegression`.

**Experiment:** Create your own mini dataset (e.g., two columns: height and weight; label: tall/short). Try training on it!

**You’ve learned:**
- What a real prediction model looks like
- How to measure model performance
- That you can beat dumb baselines, but it’s not automatic

### Module 3 – KMeans Clustering Playground (≈ 1.5 hours)

> Learn how to group unlabeled data based on patterns.

Here, the machine does not know the answer. It tries to group data anyway. This is unsupervised learning.

1. Run:
   ```bash
   ruby bench/clusterer/kmeans_vs_dbscan.rb
   ```
2. Note the centroid output—maybe even copy it into Google Sheets to plot.

**Experiment:**
- Change `k` from 3 to 5. What do the clusters look like now?
- Swap out the dataset for randomly generated points—does it still find clusters?

**You’ve learned:**
- What clustering means
- That how many clusters you ask for can drastically change the output
- That structure can be discovered even without labels

### Module 4 – Build a Neural Net: XOR with Backprop (≈ 1 hour)

> Learn how a neural network learns patterns a line can’t separate.

Build a neural net that learns XOR (logistic regression cannot do this).

```ruby
require 'ai4r'
nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])
2000.times { [[0,0],[0,1],[1,0],[1,1]].each { |x|
  nn.train(x, [x[0] ^ x[1]])
}}
puts nn.eval([1,0])  # ~1
puts nn.eval([0,0])  # ~0
```

**Experiment:**
- Reduce the iterations to 200—watch how poorly it performs.
- Try three hidden neurons instead of two.

**You’ve learned:**
- What makes neural nets different from linear models
- That training takes time and isn’t magic
- That structure (layers!) matters

### Module 5 – Search 101: BFS vs DFS (≈ 1 hour)

> Learn how machines explore trees and solve puzzles.

AI is not just about data—it is also about searching for solutions.

1. Run:
   ```bash
   ruby bench/search/astar_vs_dfs.rb
   ```
2. Swap in `BreadthFirst` instead of A* and watch it go.

**Experiment:**
- Count how many nodes were explored
- Try modifying the cost function or state space if you are brave

**You’ve learned:**
- Why smarter search strategies matter
- That brute force can work, but it is expensive

### Final Module – Build Your Own Mini Project (≈ 2 hours)

> Apply what you have learned to something new.

Pick a new dataset (try the UCI Machine Learning Repository or Kaggle) and:

1. Load it with `Ai4r::Data::DataSet`
2. Train a classifier (e.g., `LogisticRegression` or `ZeroR`)
3. Optionally try clustering the same data
4. Print and interpret your results

**You’ve learned:**
- How to go from raw data to a working AI model
- How to read and modify real Ruby implementations of classic algorithms
- That AI is not magic—it is just well-guided experimentation

### You Did It!

By now you have:

✔️ Run and modified classifiers, clusterers, neural nets and search algorithms
✔️ Compared performance using AI4R's benchmark suite
✔️ Built real intuition about how these algorithms work

You are no longer a beginner—you are a builder.

Ready for the Intermediate Path?

## Intermediate Track

*Coming soon.*

## Advanced Track

*Coming soon.*

