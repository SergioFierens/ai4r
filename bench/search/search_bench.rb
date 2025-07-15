#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../common/cli'
require_relative 'problems/grid'
require_relative 'problems/eight_puzzle'
require_relative 'runners/bfs_runner'
require_relative 'runners/dfs_runner'
require_relative 'runners/iddfs_runner'
require_relative 'runners/a_star_runner'

module Bench
  module Search
    SEARCH_METRICS = %i[solution_depth nodes_expanded max_frontier_size duration_ms completed].freeze

    RUNNERS = {
      'bfs' => Runners::BfsRunner,
      'dfs' => Runners::DfsRunner,
      'iddfs' => Runners::IddfsRunner,
      'a_star' => Runners::AStarRunner
    }.freeze

    PROBLEMS = {
      'grid' => Problems::Grid,
      'eight_puzzle' => Problems::EightPuzzle
    }.freeze

    module_function

    def run(argv)
      cli = Bench::Common::CLI.new('search', RUNNERS.keys, SEARCH_METRICS) do |opts, options|
        opts.on('--problem NAME', PROBLEMS.keys, 'Problem name') { |v| options[:problem] = v }
        opts.on('--map FILE', 'Grid map file for grid problem') { |v| options[:map] = v }
        opts.on('--start STATE', 'Initial state for eight puzzle') { |v| options[:start] = v }
      end
      options = cli.parse(argv)

      raise ArgumentError, 'Please select algorithms with --algos' if options[:algos].empty?
      problem_class = PROBLEMS[options[:problem]] or raise ArgumentError, 'Unknown problem'
      problem = if problem_class == Problems::Grid
                   map_path = options[:map] || raise(ArgumentError, 'Map required')
                   problem_class.from_file(map_path)
                 else
                   start_state = options[:start] || Problems::EightPuzzle::GOAL
                   problem_class.new(start_state)
                 end

      results = options[:algos].map do |name|
        runner = RUNNERS[name].new(problem)
        runner.call
      end
      cli.report(results, options[:export])
    end
  end
end

Bench::Search.run(ARGV) if $PROGRAM_NAME == __FILE__
