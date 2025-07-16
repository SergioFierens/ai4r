# frozen_string_literal: true

require_relative '../../lib/ai4r/experiment/search_bench'
require_relative '../../lib/ai4r/search/a_star'
require_relative '../../lib/ai4r/search/minimax'

# Mock game state for testing
class MockGameState
  def initialize(moves = [[0, 0], [1, 1]], evaluation = 5, game_over = false)
    @moves = moves
    @evaluation = evaluation
    @game_over = game_over
  end
  
  def get_possible_moves
    @moves
  end
  
  def make_move(move)
    MockGameState.new(@moves - [move], @evaluation, @game_over)
  end
  
  def evaluate
    @evaluation
  end
  
  def game_over?
    @game_over
  end
  
  def current_player
    :x
  end
end

RSpec.describe Ai4r::Experiment::SearchBench do
  let(:bench) { described_class.new(verbose: false) }
  
  describe '#initialize' do
    it 'creates a new search bench with default options' do
      expect(bench).to be_a(described_class)
      expect(bench.verbose).to be false
      expect(bench.timeout).to eq(30)
    end
    
    it 'accepts custom options' do
      custom_bench = described_class.new(verbose: true, timeout: 60)
      expect(custom_bench.verbose).to be true
      expect(custom_bench.timeout).to eq(60)
    end
    
    it 'initializes empty collections' do
      expect(bench.algorithms).to be_empty
      expect(bench.problems).to be_empty
      expect(bench.results).to be_empty
    end
  end
  
  describe '#add_algorithm' do
    let(:astar) { Ai4r::Search::AStar.new(heuristic: :manhattan) }
    
    it 'adds an algorithm to the benchmark' do
      bench.add_algorithm(:astar, astar)
      expect(bench.algorithms).to have_key(:astar)
      expect(bench.algorithms[:astar][:instance]).to eq(astar)
    end
    
    it 'sets friendly name automatically' do
      bench.add_algorithm(:astar_manhattan, astar)
      expect(bench.algorithms[:astar_manhattan][:friendly_name]).to eq('Astar Manhattan')
    end
    
    it 'accepts custom friendly name' do
      bench.add_algorithm(:astar, astar, friendly_name: 'Custom A*')
      expect(bench.algorithms[:astar][:friendly_name]).to eq('Custom A*')
    end
    
    it 'detects algorithm type correctly' do
      bench.add_algorithm(:astar, astar)
      expect(bench.algorithms[:astar][:type]).to eq(:pathfinding)
    end
  end
  
  describe '#add_problem' do
    let(:pathfinding_problem) do
      {
        type: :pathfinding,
        grid: [[0, 0], [0, 0]],
        start: [0, 0],
        goal: [1, 1]
      }
    end
    
    let(:game_problem) do
      {
        type: :game,
        initial_state: MockGameState.new
      }
    end
    
    it 'adds a pathfinding problem' do
      bench.add_problem(:test_maze, pathfinding_problem)
      expect(bench.problems).to have_key(:test_maze)
      expect(bench.problems[:test_maze][:type]).to eq(:pathfinding)
    end
    
    it 'adds a game problem' do
      bench.add_problem(:test_game, game_problem)
      expect(bench.problems).to have_key(:test_game)
      expect(bench.problems[:test_game][:type]).to eq(:game)
    end
    
    it 'validates problem structure' do
      expect { bench.add_problem(:invalid, {}) }.to raise_error(ArgumentError)
      expect { bench.add_problem(:invalid, { type: :unknown }) }.to raise_error(ArgumentError)
    end
    
    it 'validates pathfinding problem requirements' do
      invalid_problem = { type: :pathfinding, grid: [[0, 0]] }
      expect { bench.add_problem(:invalid, invalid_problem) }.to raise_error(ArgumentError)
    end
    
    it 'validates game problem requirements' do
      invalid_problem = { type: :game }
      expect { bench.add_problem(:invalid, invalid_problem) }.to raise_error(ArgumentError)
    end
  end
  
  describe '#run' do
    let(:astar) { Ai4r::Search::AStar.new(heuristic: :manhattan) }
    let(:pathfinding_problem) do
      {
        type: :pathfinding,
        grid: [[0, 0, 0], [0, 1, 0], [0, 0, 0]],
        start: [0, 0],
        goal: [2, 2]
      }
    end
    
    before do
      bench.add_algorithm(:astar, astar)
      bench.add_problem(:simple_maze, pathfinding_problem)
    end
    
    it 'runs the benchmark successfully' do
      results = bench.run
      expect(results).to be_a(Hash)
      expect(results).to have_key(:astar)
      expect(results[:astar]).to have_key(:simple_maze)
    end
    
    it 'records success for valid algorithm/problem combination' do
      results = bench.run
      result = results[:astar][:simple_maze]
      expect(result[:success]).to be true
      expect(result[:solution]).not_to be_nil
      expect(result[:search_time]).to be > 0
    end
    
    it 'validates setup before running' do
      empty_bench = described_class.new
      expect { empty_bench.run }.to raise_error(RuntimeError, 'No algorithms added')
    end
    
    it 'handles incompatible algorithm/problem combinations' do
      minimax = Ai4r::Search::Minimax.new(max_depth: 3)
      bench.add_algorithm(:minimax, minimax)
      
      results = bench.run
      result = results[:minimax][:simple_maze]
      expect(result[:success]).to be false
      expect(result[:error]).to include('not compatible')
    end
    
    it 'handles algorithm timeouts' do
      slow_bench = described_class.new(timeout: 0.001)
      slow_bench.add_algorithm(:astar, astar)
      slow_bench.add_problem(:simple_maze, pathfinding_problem)
      
      results = slow_bench.run
      result = results[:astar][:simple_maze]
      expect(result[:success]).to be false
      expect(result[:error]).to include('timed out')
    end
    
    it 'handles algorithm errors gracefully' do
      # Create a problematic algorithm setup
      broken_problem = {
        type: :pathfinding,
        grid: nil,  # This will cause an error
        start: [0, 0],
        goal: [1, 1]
      }
      
      bench.add_problem(:broken_maze, broken_problem)
      results = bench.run
      
      result = results[:astar][:broken_maze]
      expect(result[:success]).to be false
      expect(result[:error]).to include('Algorithm failed')
    end
  end
  
  describe '#display_results' do
    let(:mock_results) do
      {
        astar: {
          simple_maze: {
            success: true,
            search_time: 0.001,
            nodes_explored: 10,
            solution_cost: 4,
            error: nil
          }
        }
      }
    end
    
    before do
      bench.add_algorithm(:astar, Ai4r::Search::AStar.new)
      bench.add_problem(:simple_maze, { type: :pathfinding, grid: [[0]], start: [0, 0], goal: [0, 0] })
    end
    
    it 'displays results without errors' do
      expect { bench.display_results(mock_results) }.not_to raise_error
    end
    
    it 'handles empty results' do
      expect { bench.display_results({}) }.not_to raise_error
    end
  end
  
  describe '#generate_insights' do
    let(:mock_results) do
      {
        astar: {
          simple_maze: {
            success: true,
            search_time: 0.001,
            nodes_explored: 10,
            solution_cost: 4,
            error: nil
          }
        }
      }
    end
    
    before do
      bench.add_algorithm(:astar, Ai4r::Search::AStar.new)
      bench.add_problem(:simple_maze, { type: :pathfinding, grid: [[0]], start: [0, 0], goal: [0, 0] })
    end
    
    it 'generates insights string' do
      insights = bench.generate_insights(mock_results)
      expect(insights).to be_a(String)
      expect(insights).to include('SEARCH ALGORITHM INSIGHTS')
    end
    
    it 'includes algorithm characteristics' do
      insights = bench.generate_insights(mock_results)
      expect(insights).to include('Algorithm Characteristics')
    end
    
    it 'includes problem analysis' do
      insights = bench.generate_insights(mock_results)
      expect(insights).to include('Problem Analysis')
    end
    
    it 'includes comparative analysis' do
      insights = bench.generate_insights(mock_results)
      expect(insights).to include('Comparative Analysis')
    end
    
    it 'includes learning recommendations' do
      insights = bench.generate_insights(mock_results)
      expect(insights).to include('Learning Recommendations')
    end
  end
  
  describe '#export_results' do
    let(:mock_results) do
      {
        astar: {
          simple_maze: {
            success: true,
            search_time: 0.001,
            nodes_explored: 10,
            solution_cost: 4,
            error: nil
          }
        }
      }
    end
    
    before do
      bench.add_algorithm(:astar, Ai4r::Search::AStar.new)
      bench.add_problem(:simple_maze, { type: :pathfinding, grid: [[0]], start: [0, 0], goal: [0, 0] })
      bench.instance_variable_set(:@results, mock_results)
    end
    
    after do
      # Clean up test files
      ['test_export.csv', 'test_export.json', 'test_export.html'].each do |file|
        File.delete(file) if File.exist?(file)
      end
    end
    
    it 'exports to CSV format' do
      expect { bench.export_results(:csv, 'test_export') }.not_to raise_error
      expect(File.exist?('test_export.csv')).to be true
    end
    
    it 'exports to JSON format' do
      expect { bench.export_results(:json, 'test_export') }.not_to raise_error
      expect(File.exist?('test_export.json')).to be true
    end
    
    it 'exports to HTML format' do
      expect { bench.export_results(:html, 'test_export') }.not_to raise_error
      expect(File.exist?('test_export.html')).to be true
    end
    
    it 'raises error for unsupported format' do
      expect { bench.export_results(:xml, 'test_export') }.to raise_error(ArgumentError)
    end
  end
  
  describe 'algorithm type detection' do
    it 'detects A* as pathfinding' do
      astar = Ai4r::Search::AStar.new
      bench.add_algorithm(:astar, astar)
      expect(bench.algorithms[:astar][:type]).to eq(:pathfinding)
    end
    
    it 'detects Minimax as game_tree' do
      minimax = Ai4r::Search::Minimax.new
      bench.add_algorithm(:minimax, minimax)
      expect(bench.algorithms[:minimax][:type]).to eq(:game_tree)
    end
    
    it 'defaults to unknown for unrecognized algorithms' do
      class MockAlgorithm; end
      mock_algo = MockAlgorithm.new
      bench.add_algorithm(:mock, mock_algo)
      expect(bench.algorithms[:mock][:type]).to eq(:unknown)
    end
  end
  
  describe 'algorithm compatibility' do
    it 'identifies compatible combinations' do
      astar = Ai4r::Search::AStar.new
      bench.add_algorithm(:astar, astar)
      
      pathfinding_problem = {
        type: :pathfinding,
        grid: [[0, 0], [0, 0]],
        start: [0, 0],
        goal: [1, 1]
      }
      bench.add_problem(:maze, pathfinding_problem)
      
      # Test the private method through running the benchmark
      results = bench.run
      expect(results[:astar][:maze][:success]).to be true
    end
    
    it 'identifies incompatible combinations' do
      minimax = Ai4r::Search::Minimax.new
      bench.add_algorithm(:minimax, minimax)
      
      pathfinding_problem = {
        type: :pathfinding,
        grid: [[0, 0], [0, 0]],
        start: [0, 0],
        goal: [1, 1]
      }
      bench.add_problem(:maze, pathfinding_problem)
      
      results = bench.run
      expect(results[:minimax][:maze][:success]).to be false
      expect(results[:minimax][:maze][:error]).to include('not compatible')
    end
  end
  
  describe 'performance metrics extraction' do
    let(:astar) { Ai4r::Search::AStar.new(heuristic: :manhattan) }
    let(:pathfinding_problem) do
      {
        type: :pathfinding,
        grid: [[0, 0, 0], [0, 1, 0], [0, 0, 0]],
        start: [0, 0],
        goal: [2, 2]
      }
    end
    
    before do
      bench.add_algorithm(:astar, astar)
      bench.add_problem(:simple_maze, pathfinding_problem)
    end
    
    it 'extracts A* performance metrics' do
      results = bench.run
      result = results[:astar][:simple_maze]
      
      expect(result[:nodes_explored]).to be > 0
      expect(result[:search_time]).to be > 0
      expect(result[:solution_cost]).to be > 0
    end
    
    it 'calculates solution quality for pathfinding' do
      results = bench.run
      result = results[:astar][:simple_maze]
      
      expect(result[:solution_cost]).to eq(result[:solution].length)
    end
  end
  
  describe 'game tree search integration' do
    let(:minimax) { Ai4r::Search::Minimax.new(max_depth: 2) }
    let(:game_problem) do
      {
        type: :game,
        initial_state: MockGameState.new
      }
    end
    
    before do
      bench.add_algorithm(:minimax, minimax)
      bench.add_problem(:test_game, game_problem)
    end
    
    it 'runs minimax on game problems' do
      results = bench.run
      result = results[:minimax][:test_game]
      
      expect(result[:success]).to be true
      expect(result[:solution]).not_to be_nil
      expect(result[:search_time]).to be > 0
    end
  end
  
  describe 'educational mode features' do
    let(:educational_bench) { described_class.new(educational_mode: true, verbose: false) }
    let(:astar) { Ai4r::Search::AStar.new(heuristic: :manhattan) }
    let(:pathfinding_problem) do
      {
        type: :pathfinding,
        grid: [[0, 0, 0], [0, 1, 0], [0, 0, 0]],
        start: [0, 0],
        goal: [2, 2]
      }
    end
    
    before do
      educational_bench.add_algorithm(:astar, astar)
      educational_bench.add_problem(:simple_maze, pathfinding_problem)
    end
    
    it 'includes educational insights when enabled' do
      results = educational_bench.run
      insights = educational_bench.generate_insights(results)
      
      expect(insights).to include('Algorithm Characteristics')
      expect(insights).to include('Problem Analysis')
      expect(insights).to include('Learning Recommendations')
    end
  end
  
  describe 'error handling' do
    it 'handles missing algorithms gracefully' do
      bench.add_problem(:test, { type: :pathfinding, grid: [[0]], start: [0, 0], goal: [0, 0] })
      expect { bench.run }.to raise_error(RuntimeError, 'No algorithms added')
    end
    
    it 'handles missing problems gracefully' do
      bench.add_algorithm(:astar, Ai4r::Search::AStar.new)
      expect { bench.run }.to raise_error(RuntimeError, 'No problems added')
    end
    
    it 'handles malformed problem definitions' do
      expect { bench.add_problem(:bad, { type: :pathfinding }) }.to raise_error(ArgumentError)
    end
  end
  
  describe 'memory tracking' do
    let(:memory_bench) { described_class.new(track_memory: true, verbose: false) }
    let(:astar) { Ai4r::Search::AStar.new(heuristic: :manhattan) }
    let(:pathfinding_problem) do
      {
        type: :pathfinding,
        grid: [[0, 0, 0], [0, 1, 0], [0, 0, 0]],
        start: [0, 0],
        goal: [2, 2]
      }
    end
    
    before do
      memory_bench.add_algorithm(:astar, astar)
      memory_bench.add_problem(:simple_maze, pathfinding_problem)
    end
    
    it 'tracks memory usage when enabled' do
      results = memory_bench.run
      result = results[:astar][:simple_maze]
      
      expect(result[:memory_usage]).to be_a(Numeric)
    end
  end
  
  describe 'timeout handling' do
    let(:timeout_bench) { described_class.new(timeout: 0.001, verbose: false) }
    let(:astar) { Ai4r::Search::AStar.new(heuristic: :manhattan) }
    let(:large_problem) do
      {
        type: :pathfinding,
        grid: Array.new(20) { Array.new(20, 0) },
        start: [0, 0],
        goal: [19, 19]
      }
    end
    
    before do
      timeout_bench.add_algorithm(:astar, astar)
      timeout_bench.add_problem(:large_maze, large_problem)
    end
    
    it 'handles timeouts gracefully' do
      results = timeout_bench.run
      result = results[:astar][:large_maze]
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('timed out')
    end
  end
end