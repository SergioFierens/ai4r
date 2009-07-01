# Data
require File.dirname(__FILE__) +  "/ai4r/data/data_set"
require File.dirname(__FILE__) +  "/ai4r/data/statistics"
require File.dirname(__FILE__) +  "/ai4r/data/proximity"
require File.dirname(__FILE__) +  "/ai4r/data/parameterizable"
# Clusterers
require File.dirname(__FILE__) +  "/ai4r/clusterers/clusterer"
require File.dirname(__FILE__) +  "/ai4r/clusterers/k_means"
require File.dirname(__FILE__) +  "/ai4r/clusterers/bisecting_k_means"
require File.dirname(__FILE__) +  "/ai4r/clusterers/single_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/complete_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/average_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/weighted_average_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/centroid_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/median_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/ward_linkage"
require File.dirname(__FILE__) +  "/ai4r/clusterers/diana"
# Classifiers
require File.dirname(__FILE__) +  "/ai4r/classifiers/classifier"
require File.dirname(__FILE__) +  "/ai4r/classifiers/id3"
require File.dirname(__FILE__) +  "/ai4r/classifiers/prism"
require File.dirname(__FILE__) +  "/ai4r/classifiers/one_r"
require File.dirname(__FILE__) +  "/ai4r/classifiers/zero_r"
require File.dirname(__FILE__) +  "/ai4r/classifiers/hyperpipes"
require File.dirname(__FILE__) +  "/ai4r/classifiers/naive_bayes"
# Neural networks
require File.dirname(__FILE__) +  "/ai4r/neural_network/backpropagation"
require File.dirname(__FILE__) +  "/ai4r/neural_network/hopfield"
# Genetic Algorithms
require File.dirname(__FILE__) +  "/ai4r/genetic_algorithm/genetic_algorithm"
# SOM
require File.dirname(__FILE__) +  "/ai4r/som/som"