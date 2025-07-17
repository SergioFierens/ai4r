# frozen_string_literal: true

require 'benchmark'

module Ai4r
  module Core
    module Benchmarks
      # Runner for algorithm benchmarks
      class BenchmarkRunner
        attr_reader :results
        
        def initialize(name)
          @name = name
          @results = {}
        end
        
        # Run a single benchmark
        def benchmark(description, &block)
          puts "\nBenchmarking: #{description}"
          puts "-" * 50
          
          result = Benchmark.measure(&block)
          
          @results[description] = {
            real_time: result.real,
            cpu_time: result.total,
            system_time: result.stime,
            user_time: result.utime
          }
          
          report_result(description, result)
          result
        end
        
        # Compare multiple implementations
        def compare(implementations)
          puts "\nComparison: #{@name}"
          puts "=" * 70
          
          Benchmark.bm(30) do |x|
            implementations.each do |name, block|
              result = x.report(name, &block)
              @results[name] = {
                real_time: result.real,
                cpu_time: result.total
              }
            end
          end
        end
        
        # Run benchmarks with different input sizes
        def scalability_test(sizes, &block)
          puts "\nScalability Test: #{@name}"
          puts "=" * 70
          puts sprintf("%-15s %15s %15s %15s", "Size", "Time (s)", "Time/Item", "Growth Rate")
          puts "-" * 70
          
          previous_time = nil
          previous_size = nil
          
          sizes.each do |size|
            time = Benchmark.realtime { block.call(size) }
            time_per_item = time / size
            
            growth_rate = if previous_time && previous_size
              time_ratio = time / previous_time
              size_ratio = size.to_f / previous_size
              time_ratio / size_ratio
            end
            
            @results["size_#{size}"] = {
              size: size,
              time: time,
              time_per_item: time_per_item,
              growth_rate: growth_rate
            }
            
            puts sprintf("%-15d %15.6f %15.9f %15s", 
                        size, time, time_per_item, 
                        growth_rate ? sprintf("%.3f", growth_rate) : "N/A")
            
            previous_time = time
            previous_size = size
          end
          
          estimate_complexity
        end
        
        # Memory usage benchmark
        def memory_benchmark(description, &block)
          puts "\nMemory Benchmark: #{description}"
          puts "-" * 50
          
          before_memory = current_memory_mb
          
          result = block.call
          
          after_memory = current_memory_mb
          memory_used = after_memory - before_memory
          
          @results["#{description}_memory"] = {
            memory_used_mb: memory_used,
            before_mb: before_memory,
            after_mb: after_memory
          }
          
          puts "Memory used: #{memory_used.round(2)} MB"
          puts "Before: #{before_memory.round(2)} MB, After: #{after_memory.round(2)} MB"
          
          result
        end
        
        # Generate summary report
        def summary
          puts "\n" + "=" * 70
          puts "Benchmark Summary: #{@name}"
          puts "=" * 70
          
          @results.each do |description, data|
            puts "\n#{description}:"
            data.each do |key, value|
              puts "  #{key}: #{format_value(value)}"
            end
          end
        end
        
        private
        
        def report_result(description, result)
          puts "Real time: #{result.real.round(6)}s"
          puts "CPU time:  #{result.total.round(6)}s (user: #{result.utime.round(6)}s, system: #{result.stime.round(6)}s)"
        end
        
        def current_memory_mb
          if RUBY_PLATFORM =~ /linux/
            `ps -o rss= -p #{Process.pid}`.to_i / 1024.0
          elsif RUBY_PLATFORM =~ /darwin/
            `ps -o rss= -p #{Process.pid}`.to_i / 1024.0
          else
            # Fallback for other platforms
            GC.stat[:heap_allocated_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE] / 1024.0 / 1024.0
          end
        end
        
        def estimate_complexity
          # Simple complexity estimation based on growth rates
          growth_rates = @results.values
            .select { |r| r[:growth_rate] }
            .map { |r| r[:growth_rate] }
            .compact
          
          return "Unknown" if growth_rates.empty?
          
          avg_growth = growth_rates.sum / growth_rates.size
          
          complexity = case avg_growth
          when 0.9..1.1 then "O(n)"
          when 0.4..0.6 then "O(√n)"
          when 1.9..2.1 then "O(n²)"
          when 2.9..3.1 then "O(n³)"
          when 0.0..0.2 then "O(log n)"
          when 0.8..1.2 then "O(n log n)"
          else "O(n^#{Math.log2(avg_growth).round(2)})"
          end
          
          puts "\nEstimated complexity: #{complexity}"
          complexity
        end
        
        def format_value(value)
          case value
          when Float
            value.round(6)
          when nil
            "N/A"
          else
            value
          end
        end
      end
    end
  end
end