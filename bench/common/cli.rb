require 'optparse'
require_relative 'reporter'

module Bench
  module Common
    # Generic command line interface for benches.
    class CLI
      def initialize(bench_name, algos, metrics, &custom)
        @bench_name = bench_name
        @algos = algos
        @metrics = metrics
        @custom = custom
      end

      def parse(argv)
        options = { algos: [] }
        parser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby bench/#{@bench_name}/#{@bench_name}_bench.rb [options]"
          opts.on('--algos x,y,z', Array, 'Algorithms to run') { |v| options[:algos] = v }
          opts.on('--export FILE', 'Export CSV file') { |v| options[:export] = v }
          @custom&.call(opts, options)
        end
        parser.parse!(argv)
        options
      end

      def report(results, export_path = nil)
        reporter = Reporter.new(results.map(&:to_h), @metrics)
        reporter.print_table
        reporter.export_csv(export_path) if export_path
      end
    end
  end
end
