# frozen_string_literal: true

require 'benchmark'
require 'spec_helper'

RSpec.describe 'Clusterer Performance Benchmarks' do
  include DataHelper
  
  let(:small_dataset) { generate_clustered_data(clusters: 3, points_per_cluster: 50) }
  let(:medium_dataset) { generate_clustered_data(clusters: 5, points_per_cluster: 200) }
  let(:large_dataset) { generate_clustered_data(clusters: 10, points_per_cluster: 500) }
  
  let(:clusterers) do
    {
      kmeans: Ai4r::Clusterers::KMeans,
      bisecting_kmeans: Ai4r::Clusterers::BisectingKMeans,
      single_linkage: Ai4r::Clusterers::SingleLinkage,
      complete_linkage: Ai4r::Clusterers::CompleteLinkage,
      average_linkage: Ai4r::Clusterers::AverageLinkage
    }
  end
  
  describe 'execution time benchmarks' do
    it 'benchmarks small dataset' do
      results = benchmark_clusterers(small_dataset, 3)
      report_results("Small Dataset (150 points)", results)
      
      # Performance expectations
      results.each do |name, time|
        expect(time).to be < 1.0, "#{name} took too long: #{time}s"
      end
    end
    
    it 'benchmarks medium dataset' do
      results = benchmark_clusterers(medium_dataset, 5)
      report_results("Medium Dataset (1000 points)", results)
      
      results.each do |name, time|
        expect(time).to be < 5.0, "#{name} took too long: #{time}s"
      end
    end
    
    it 'benchmarks large dataset' do
      results = benchmark_clusterers(large_dataset, 10)
      report_results("Large Dataset (5000 points)", results)
      
      results.each do |name, time|
        expect(time).to be < 30.0, "#{name} took too long: #{time}s"
      end
    end
  end
  
  describe 'scalability analysis' do
    it 'measures scalability with increasing data size' do
      sizes = [100, 500, 1000, 2000]
      scalability_results = {}
      
      clusterers.each do |name, klass|
        times = []
        
        sizes.each do |size|
          data = generate_clustered_data(
            clusters: 5,
            points_per_cluster: size / 5
          )
          
          time = Benchmark.realtime do
            klass.new.build(data, 5)
          end
          
          times << time
        end
        
        scalability_results[name] = {
          sizes: sizes,
          times: times,
          complexity: estimate_complexity(sizes, times)
        }
      end
      
      report_scalability(scalability_results)
    end
  end
  
  describe 'memory usage benchmarks' do
    it 'measures memory consumption' do
      memory_results = {}
      
      clusterers.each do |name, klass|
        before_memory = memory_usage
        
        clusterer = klass.new
        clusterer.build(medium_dataset, 5)
        
        after_memory = memory_usage
        memory_used = after_memory - before_memory
        
        memory_results[name] = memory_used
      end
      
      report_memory_usage(memory_results)
    end
  end
  
  private
  
  def benchmark_clusterers(dataset, k)
    results = {}
    
    clusterers.each do |name, klass|
      time = Benchmark.realtime do
        klass.new.build(dataset, k)
      end
      
      results[name] = time
    end
    
    results
  end
  
  def report_results(title, results)
    puts "\n#{title}:"
    puts "-" * 50
    
    sorted_results = results.sort_by { |_, time| time }
    sorted_results.each do |name, time|
      puts sprintf("%-20s: %8.4f seconds", name, time)
    end
  end
  
  def report_scalability(results)
    puts "\nScalability Analysis:"
    puts "-" * 50
    
    results.each do |name, data|
      puts "\n#{name}:"
      data[:sizes].zip(data[:times]).each do |size, time|
        puts sprintf("  %5d points: %8.4f seconds", size, time)
      end
      puts "  Estimated complexity: #{data[:complexity]}"
    end
  end
  
  def report_memory_usage(results)
    puts "\nMemory Usage:"
    puts "-" * 50
    
    results.each do |name, memory|
      puts sprintf("%-20s: %8.2f MB", name, memory)
    end
  end
  
  def estimate_complexity(sizes, times)
    return "unknown" if sizes.size < 3
    
    # Simple complexity estimation based on growth rate
    ratios = times.each_cons(2).zip(sizes.each_cons(2)).map do |(t1, t2), (s1, s2)|
      (t2 / t1) / (s2.to_f / s1)
    end
    
    avg_ratio = ratios.sum / ratios.size
    
    case avg_ratio
    when 0.8..1.2 then "O(n)"
    when 1.8..2.2 then "O(n²)"
    when 0.9..1.1 then "O(n log n)"
    else "O(n^#{Math.log(avg_ratio) / Math.log(2)})"
    end
  end
  
  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0  # MB
  end
end