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

        if @results.first.key?(:accuracy)
          med_train = @results.map { |r| r[:training_ms] }.sort[@results.length / 2]
          med_pred = @results.map { |r| r[:predict_ms] }.sort[@results.length / 2]
          med_size = @results.map { |r| r[:model_size_kb] }.sort[@results.length / 2]

          @results.map do |r|
            {
              algorithm: r[:algorithm],
              accurate: r[:accuracy] >= 0.95,
              fast_train: r[:training_ms] <= med_train,
              fast_predict: r[:predict_ms] <= med_pred,
              tiny_model: r[:model_size_kb] <= med_size * 0.5,
              interpretable: %w[id3 hyperpipes].include?(r[:algorithm])
            }
          end
        else
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
      end

      def print_badges_table(badges)
        metrics = badges.first.keys
        widths = metrics.map do |m|
          [m.to_s.length, *badges.map { |r| r[m].to_s.length }].max
        end
        header = metrics.each_with_index.map { |m, i| m.to_s.ljust(widths[i]) }.join(' | ')
        puts header
        puts '-' * header.length
        badges.each do |r|
          row = metrics.each_with_index.map do |m, i|
            val = r[m]
            val = if val == true
                    '✓'
                  else
                    (val == false ? '' : val)
                  end
            val.to_s.ljust(widths[i])
          end.join(' | ')
          puts row
        end
      end
    end
  end
end
