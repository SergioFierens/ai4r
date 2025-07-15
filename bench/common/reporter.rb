require 'csv'

module Bench
  module Common
    # Prints tables and exports CSV results.
    class Reporter
      def initialize(results, metrics)
        @results = results
        @metrics = [:algorithm] + metrics
      end

      def print_table
        widths = @metrics.map do |m|
          [m.to_s.length, *@results.map { |r| r[m].to_s.length }].max
        end
        header = @metrics.each_with_index.map { |m, i| m.to_s.ljust(widths[i]) }.join(' | ')
        puts header
        puts '-' * header.length
        @results.each do |r|
          row = @metrics.each_with_index.map { |m, i| r[m].to_s.ljust(widths[i]) }.join(' | ')
          puts row
        end
      end

      def export_csv(path)
        CSV.open(path, 'w') do |csv|
          csv << @metrics
          @results.each { |r| csv << @metrics.map { |m| r[m] } }
        end
      end
    end
  end
end
