# frozen_string_literal: true

# SimpleCov configuration for AI4R
# This file is loaded automatically when SimpleCov starts

SimpleCov.start do
  # Coverage report name
  project_name 'AI4R - Ruby AI Library'
  
  # Coverage directory
  coverage_dir 'coverage'
  
  # Minimum coverage requirements
  minimum_coverage 85
  minimum_coverage_by_file 70
  
  # Enable branch coverage
  enable_coverage :branch
  
  # Groups for better organization
  add_group 'Classifiers', 'lib/ai4r/classifiers'
  add_group 'Clusterers', 'lib/ai4r/clusterers'
  add_group 'Neural Networks', 'lib/ai4r/neural_network'
  add_group 'Genetic Algorithms', 'lib/ai4r/genetic_algorithm'
  add_group 'Search Algorithms', 'lib/ai4r/search'
  add_group 'Data Structures', 'lib/ai4r/data'
  add_group 'Experiments', 'lib/ai4r/experiment'
  add_group 'Machine Learning', 'lib/ai4r/machine_learning'
  
  # Filters
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/test_legacy_backup/'
  add_filter '/vendor/'
  add_filter '/examples/'
  add_filter '/docs/'
  add_filter '/coverage/'
  
  # Track files with no tests
  track_files 'lib/**/*.rb'
  
  # Refuse to run tests if coverage drops below threshold
  refuse_coverage_drop
  
  # Maximum coverage drop allowed
  maximum_coverage_drop 5
end