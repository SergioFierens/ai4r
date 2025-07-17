# frozen_string_literal: true

# Synthetic Dataset Generator for Educational Clustering
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../../data/data_set'

module Ai4r
  module Clusterers
    # Generator for synthetic datasets to demonstrate clustering concepts
    class SyntheticDatasetGenerator
      # Generate Gaussian blobs - ideal for K-means
      def generate_blobs(n_centers, n_samples, cluster_std = 1.0)
        data_items = []
        samples_per_center = n_samples / n_centers

        n_centers.times do |_center_idx|
          # Random center location
          center_x = rand(-10.0..10.0)
          center_y = rand(-10.0..10.0)

          samples_per_center.times do
            # Generate point around center with Gaussian noise
            x = center_x + gaussian_random(0, cluster_std)
            y = center_y + gaussian_random(0, cluster_std)
            data_items << [x, y]
          end
        end

        # Add remaining samples to random centers
        remaining = n_samples - (samples_per_center * n_centers)
        remaining.times do
          rand(n_centers)
          center_x = rand(-10.0..10.0)
          center_y = rand(-10.0..10.0)

          x = center_x + gaussian_random(0, cluster_std)
          y = center_y + gaussian_random(0, cluster_std)
          data_items << [x, y]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: %w[x y]
        )
      end

      # Generate two interleaving half-circles (moons)
      def generate_moons(n_samples, noise = 0.1)
        data_items = []
        samples_per_moon = n_samples / 2

        # First moon (upper)
        samples_per_moon.times do
          angle = rand(0..Math::PI)
          x = Math.cos(angle)
          y = Math.sin(angle)

          # Add noise
          x += gaussian_random(0, noise)
          y += gaussian_random(0, noise)

          data_items << [x, y]
        end

        # Second moon (lower, shifted)
        samples_per_moon.times do
          angle = rand(0..Math::PI)
          x = 1 - Math.cos(angle)
          y = -Math.sin(angle) - 0.5

          # Add noise
          x += gaussian_random(0, noise)
          y += gaussian_random(0, noise)

          data_items << [x, y]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: %w[x y]
        )
      end

      # Generate concentric circles
      def generate_circles(n_samples, noise = 0.05, factor = 0.8)
        data_items = []
        samples_per_circle = n_samples / 2

        # Inner circle
        samples_per_circle.times do
          angle = rand(0..(2 * Math::PI))
          radius = factor

          x = radius * Math.cos(angle)
          y = radius * Math.sin(angle)

          # Add noise
          x += gaussian_random(0, noise)
          y += gaussian_random(0, noise)

          data_items << [x, y]
        end

        # Outer circle
        samples_per_circle.times do
          angle = rand(0..(2 * Math::PI))
          radius = 1.0

          x = radius * Math.cos(angle)
          y = radius * Math.sin(angle)

          # Add noise
          x += gaussian_random(0, noise)
          y += gaussian_random(0, noise)

          data_items << [x, y]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: %w[x y]
        )
      end

      # Generate anisotropic (stretched) clusters
      def generate_anisotropic(n_samples)
        data_items = []
        samples_per_cluster = n_samples / 3

        # Cluster 1: Stretched horizontally
        samples_per_cluster.times do
          x = gaussian_random(0, 2.0)  # Wide in x
          y = gaussian_random(0, 0.5)  # Narrow in y
          data_items << [x, y + 3]
        end

        # Cluster 2: Stretched vertically
        samples_per_cluster.times do
          x = gaussian_random(0, 0.5)  # Narrow in x
          y = gaussian_random(0, 2.0)  # Wide in y
          data_items << [x + 5, y]
        end

        # Cluster 3: Diagonal stretch
        samples_per_cluster.times do
          x = gaussian_random(0, 1.0)
          y = gaussian_random(0, 1.0)

          # Rotate 45 degrees and stretch
          new_x = (x + y) * 0.7
          new_y = (-x + y) * 0.3

          data_items << [new_x - 2, new_y - 3]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: %w[x y]
        )
      end

      # Generate clusters with varying densities
      def generate_varied_density(n_samples)
        data_items = []

        # Dense cluster (40% of samples)
        dense_samples = (n_samples * 0.4).to_i
        dense_samples.times do
          x = gaussian_random(0, 0.3)
          y = gaussian_random(0, 0.3)
          data_items << [x, y]
        end

        # Medium density cluster (35% of samples)
        medium_samples = (n_samples * 0.35).to_i
        medium_samples.times do
          x = gaussian_random(3, 0.8)
          y = gaussian_random(3, 0.8)
          data_items << [x, y]
        end

        # Sparse cluster (25% of samples)
        sparse_samples = n_samples - dense_samples - medium_samples
        sparse_samples.times do
          x = gaussian_random(-3, 1.5)
          y = gaussian_random(-3, 1.5)
          data_items << [x, y]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: %w[x y]
        )
      end

      # Generate dataset with noise points
      def generate_with_noise(n_samples, noise_ratio = 0.2)
        cluster_samples = (n_samples * (1 - noise_ratio)).to_i
        noise_samples = n_samples - cluster_samples

        data_items = []

        # Generate 3 clean clusters
        samples_per_cluster = cluster_samples / 3

        # Cluster 1
        samples_per_cluster.times do
          x = gaussian_random(-2, 0.5)
          y = gaussian_random(2, 0.5)
          data_items << [x, y]
        end

        # Cluster 2
        samples_per_cluster.times do
          x = gaussian_random(2, 0.5)
          y = gaussian_random(2, 0.5)
          data_items << [x, y]
        end

        # Cluster 3
        (cluster_samples - (2 * samples_per_cluster)).times do
          x = gaussian_random(0, 0.5)
          y = gaussian_random(-2, 0.5)
          data_items << [x, y]
        end

        # Add noise points randomly distributed
        noise_samples.times do
          x = rand(-6.0..6.0)
          y = rand(-6.0..6.0)
          data_items << [x, y]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items.shuffle, # Shuffle to mix noise with clusters
          data_labels: %w[x y]
        )
      end

      # Generate mixed shapes for algorithm comparison
      def generate_mixed_shapes(n_samples)
        data_items = []
        samples_per_shape = n_samples / 4

        # Circular cluster
        samples_per_shape.times do
          angle = rand(0..(2 * Math::PI))
          radius = rand(0.5..1.0)
          x = (radius * Math.cos(angle)) - 3
          y = (radius * Math.sin(angle)) + 3
          data_items << [x, y]
        end

        # Elongated cluster
        samples_per_shape.times do
          x = gaussian_random(0, 2.0)
          y = gaussian_random(0, 0.3)
          data_items << [x + 3, y + 3]
        end

        # L-shaped cluster
        samples_per_shape.times do
          if rand < 0.5
            # Horizontal part of L
            x = rand(-1.0..1.0)
            y = rand(-0.2..0.2)
          else
            # Vertical part of L
            x = rand(-0.2..0.2)
            y = rand(0.0..2.0)
          end
          data_items << [x - 3, y - 3]
        end

        # Dense blob
        (n_samples - (3 * samples_per_shape)).times do
          x = gaussian_random(0, 0.4)
          y = gaussian_random(0, 0.4)
          data_items << [x + 3, y - 3]
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: %w[x y]
        )
      end

      # Generate high-dimensional data (for curse of dimensionality demonstration)
      def generate_high_dimensional(n_samples, n_features, n_clusters = 3)
        data_items = []
        samples_per_cluster = n_samples / n_clusters

        n_clusters.times do |_cluster_idx|
          # Random cluster center in high-dimensional space
          center = Array.new(n_features) { rand(-5.0..5.0) }

          samples_per_cluster.times do
            point = center.map { |coord| coord + gaussian_random(0, 1.0) }
            data_items << point
          end
        end

        # Add remaining samples
        remaining = n_samples - (samples_per_cluster * n_clusters)
        remaining.times do
          rand(n_clusters)
          center = Array.new(n_features) { rand(-5.0..5.0) }
          point = center.map { |coord| coord + gaussian_random(0, 1.0) }
          data_items << point
        end

        labels = (0...n_features).map { |i| "feature_#{i}" }

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: labels
        )
      end

      # Generate categorical data for demonstrating categorical clustering
      def generate_categorical_data(n_samples)
        data_items = []

        # Define categories
        categories = {
          color: %w[red blue green yellow],
          size: %w[small medium large],
          shape: %w[circle square triangle]
        }

        # Create 3 prototypical clusters
        prototypes = [
          { color: 'red', size: 'large', shape: 'circle' },
          { color: 'blue', size: 'small', shape: 'square' },
          { color: 'green', size: 'medium', shape: 'triangle' }
        ]

        samples_per_cluster = n_samples / 3

        prototypes.each do |prototype|
          samples_per_cluster.times do
            # Each attribute has 80% chance to match prototype
            item = categories.map do |attr, values|
              if rand < 0.8
                prototype[attr]
              else
                values.sample
              end
            end

            data_items << item
          end
        end

        # Add remaining random samples
        remaining = n_samples - (samples_per_cluster * 3)
        remaining.times do
          item = categories.values.map(&:sample)
          data_items << item
        end

        Ai4r::Data::DataSet.new(
          data_items: data_items.shuffle,
          data_labels: categories.keys.map(&:to_s)
        )
      end

      # Generate time series data for temporal clustering
      def generate_time_series_data(n_series, series_length)
        data_items = []

        # Pattern 1: Sine wave with noise
        (n_series / 3).times do
          series = []
          series_length.times do |t|
            value = Math.sin(2 * Math::PI * t / 20.0) + gaussian_random(0, 0.1)
            series << value
          end
          data_items << series
        end

        # Pattern 2: Linear trend with noise
        (n_series / 3).times do
          series = []
          slope = rand(0.01..0.05)
          intercept = rand(-1.0..1.0)

          series_length.times do |t|
            value = (slope * t) + intercept + gaussian_random(0, 0.1)
            series << value
          end
          data_items << series
        end

        # Pattern 3: Step function
        (n_series - (2 * (n_series / 3))).times do
          series = []
          step_time = rand((series_length / 4)..(3 * series_length / 4))

          series_length.times do |t|
            base_value = t < step_time ? 0.0 : 1.0
            value = base_value + gaussian_random(0, 0.1)
            series << value
          end
          data_items << series
        end

        labels = (0...series_length).map { |i| "t_#{i}" }

        Ai4r::Data::DataSet.new(
          data_items: data_items,
          data_labels: labels
        )
      end

      # Educational explanation of each dataset type
      def explain_dataset_types
        puts '=== Synthetic Dataset Types for Clustering Education ==='
        puts

        explanations = {
          'Gaussian Blobs' => {
            description: 'Well-separated spherical clusters with Gaussian noise',
            best_for: 'K-means, hierarchical clustering',
            challenges: 'None - ideal clustering scenario',
            parameters: 'n_centers, n_samples, cluster_std'
          },

          'Moons' => {
            description: 'Two interleaving half-circle shapes',
            best_for: 'DBSCAN, spectral clustering',
            challenges: 'Non-convex shapes, K-means fails',
            parameters: 'n_samples, noise level'
          },

          'Circles' => {
            description: 'Concentric circles',
            best_for: 'Kernel methods, spectral clustering',
            challenges: 'Not linearly separable, K-means fails',
            parameters: 'n_samples, noise, factor (size ratio)'
          },

          'Anisotropic' => {
            description: 'Stretched/elongated clusters',
            best_for: 'Methods with appropriate distance metrics',
            challenges: 'Demonstrates importance of distance metric choice',
            parameters: 'n_samples, stretch directions'
          },

          'Varied Density' => {
            description: 'Clusters with different densities',
            best_for: 'DBSCAN with careful parameter tuning',
            challenges: "Single density threshold doesn't work",
            parameters: 'n_samples, density ratios'
          },

          'With Noise' => {
            description: 'Clean clusters plus random noise points',
            best_for: 'DBSCAN, robust clustering methods',
            challenges: 'Noise handling, robustness testing',
            parameters: 'n_samples, noise_ratio'
          },

          'Mixed Shapes' => {
            description: 'Various cluster shapes in one dataset',
            best_for: 'Algorithm comparison studies',
            challenges: 'No single algorithm works perfectly',
            parameters: 'n_samples, shape variety'
          },

          'High Dimensional' => {
            description: 'Many features, demonstrates curse of dimensionality',
            best_for: 'Dimensionality reduction + clustering',
            challenges: 'Distance metrics become meaningless',
            parameters: 'n_samples, n_features, n_clusters'
          }
        }

        explanations.each do |name, info|
          puts "#{name}:"
          puts "  Description: #{info[:description]}"
          puts "  Best for: #{info[:best_for]}"
          puts "  Challenges: #{info[:challenges]}"
          puts "  Parameters: #{info[:parameters]}"
          puts
        end
      end

      # Generate a comprehensive dataset collection for education
      def generate_educational_collection
        datasets = {}

        puts 'Generating comprehensive educational dataset collection...'

        # Basic datasets
        datasets[:easy_blobs] = generate_blobs(3, 300, 0.5)
        datasets[:hard_blobs] = generate_blobs(5, 500, 1.2)
        datasets[:moons] = generate_moons(400, 0.1)
        datasets[:circles] = generate_circles(300, 0.05)
        datasets[:anisotropic] = generate_anisotropic(400)
        datasets[:varied_density] = generate_varied_density(600)
        datasets[:noisy] = generate_with_noise(300, 0.2)
        datasets[:mixed_shapes] = generate_mixed_shapes(400)

        # Advanced datasets
        datasets[:high_dim_5d] = generate_high_dimensional(300, 5, 3)
        datasets[:high_dim_20d] = generate_high_dimensional(300, 20, 4)
        datasets[:categorical] = generate_categorical_data(200)
        datasets[:time_series] = generate_time_series_data(60, 50)

        puts "Generated #{datasets.length} educational datasets:"
        datasets.each do |name, dataset|
          n_samples = dataset.data_items.length
          n_features = dataset.data_items.first&.length || 0
          puts "  #{name}: #{n_samples} samples, #{n_features} features"
        end

        datasets
      end

      private

      # Box-Muller transform for Gaussian random numbers
      def gaussian_random(mean = 0, std_dev = 1)
        # Use cached value if available (Box-Muller generates two values)
        if @cached_gaussian
          result = @cached_gaussian
          @cached_gaussian = nil
          return mean + (std_dev * result)
        end

        # Generate two uniform random numbers
        u1 = rand
        u2 = rand

        # Box-Muller transform
        mag = std_dev * Math.sqrt(-2.0 * Math.log(u1))
        @cached_gaussian = mag * Math.cos(2.0 * Math::PI * u2)

        mean + (mag * Math.sin(2.0 * Math::PI * u2))
      end
    end
  end
end
