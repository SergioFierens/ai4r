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

        badges = compute_badges
        puts "\n"
        print_badges_table(badges) if badges
      end

      def export_csv(path)
        CSV.open(path, 'w') do |csv|
          csv << @metrics
          @results.each { |r| csv << @metrics.map { |m| r[m] } }
        end
      end

      private

      def compute_badges
        return nil if @results.empty?
        median = @results.map { |r| r[:duration_ms] }.sort[@results.length / 2]
        min_sse = @results.map { |r| r[:sse] }.compact.min

        @results.map do |r|
          {
            algorithm: r[:algorithm],
            compact: if r[:sse]
                       r[:sse] == min_sse
                     else
                       r[:silhouette] && r[:silhouette] >= 0.65
                     end,
            fast: r[:duration_ms] <= median,
            memory_heavy: r[:memory_peaked],
            iter_sensitive: r[:iterations].to_i > 10
          }
        end
      end

      def print_badges_table(badges)
        metrics = %i[algorithm compact fast memory_heavy iter_sensitive]
        widths = metrics.map do |m|
          [m.to_s.length, *badges.map { |r| r[m].to_s.length }].max
        end
        header = metrics.each_with_index.map { |m, i| m.to_s.ljust(widths[i]) }.join(' | ')
        puts header
        puts '-' * header.length
        badges.each do |r|
          row = metrics.each_with_index.map do |m, i|
            val = r[m]
            val = val ? '✓' : '' if [ :compact, :fast, :memory_heavy, :iter_sensitive ].include?(m)
            val.to_s.ljust(widths[i])
          end.join(' | ')
          puts row
        end
      end
    end
  end
end
