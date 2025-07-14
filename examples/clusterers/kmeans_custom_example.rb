# This example shows KMeans with a custom distance function and deterministic initialization.
# It also prints the number of iterations and the sum of squared errors (SSE).

require 'ai4r'
include Ai4r::Clusterers
include Ai4r::Data

# Simple two-cluster data set
points = [[1,1],[1,2],[2,1],[2,2],[8,8],[8,9],[9,8],[9,9]]
data_set = DataSet.new(data_items: points)

# Manhattan distance instead of the default squared Euclidean distance
manhattan = lambda do |a, b|
  a.zip(b).map { |x, y| (x - y).abs }.reduce(:+)
end

kmeans = KMeans.new
kmeans.set_parameters(distance_function: manhattan, random_seed: 1)
       .build(data_set, 2)

kmeans.clusters.each_with_index do |cluster, idx|
  puts "Cluster #{idx}: #{cluster.data_items.inspect}"
end

puts "Iterations: #{kmeans.iterations}"
puts "SSE: #{kmeans.sse}"
