# frozen_string_literal: true

module AlgorithmHelper
  # Helper to test algorithm convergence
  def test_convergence(algorithm, data, options = {})
    max_iterations = options[:max_iterations] || 100
    tolerance = options[:tolerance] || 0.001
    
    previous_state = nil
    converged = false
    
    max_iterations.times do |i|
      algorithm.step(data)
      current_state = algorithm.current_state
      
      if previous_state && state_difference(previous_state, current_state) < tolerance
        converged = true
        return { converged: true, iterations: i + 1, final_state: current_state }
      end
      
      previous_state = current_state
    end
    
    { converged: false, iterations: max_iterations, final_state: algorithm.current_state }
  end
  
  # Helper to measure algorithm performance
  def measure_performance(algorithm, data, runs: 5)
    times = []
    memory_usage = []
    
    runs.times do
      before_memory = memory_usage_mb
      
      start_time = Time.now
      algorithm.run(data)
      elapsed = Time.now - start_time
      
      after_memory = memory_usage_mb
      
      times << elapsed
      memory_usage << (after_memory - before_memory)
    end
    
    {
      avg_time: times.sum / times.size,
      min_time: times.min,
      max_time: times.max,
      avg_memory: memory_usage.sum / memory_usage.size,
      runs: runs
    }
  end
  
  # Test algorithm with different parameter values
  def parameter_sweep(algorithm_class, data, parameter_ranges)
    results = []
    
    parameter_ranges.each do |param_name, values|
      values.each do |value|
        algorithm = algorithm_class.new
        algorithm.set_parameters(param_name => value)
        
        performance = measure_single_run(algorithm, data)
        results << {
          parameter: param_name,
          value: value,
          performance: performance
        }
      end
    end
    
    results
  end
  
  private
  
  def state_difference(state1, state2)
    # Simple Euclidean distance for numeric states
    if state1.is_a?(Array) && state2.is_a?(Array)
      Math.sqrt(state1.zip(state2).map { |a, b| (a - b)**2 }.sum)
    else
      state1 == state2 ? 0 : 1
    end
  end
  
  def memory_usage_mb
    # Simple approximation - in real scenario would use more sophisticated method
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0
  end
  
  def measure_single_run(algorithm, data)
    start_time = Time.now
    result = algorithm.run(data)
    elapsed = Time.now - start_time
    
    {
      time: elapsed,
      result: result,
      success: !result.nil?
    }
  end
end

RSpec.configure do |config|
  config.include AlgorithmHelper
end