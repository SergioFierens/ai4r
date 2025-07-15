# frozen_string_literal: true

# Author::    Sergio Fierens (Implementation only)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'set'
require_relative '../data/data_set'
require_relative '../classifiers/classifier'
require_relative '../classifiers/votes'

module Ai4r
  module Classifiers
    include Ai4r::Data

    # = Introduction
    #
    # A fast classifier algorithm, created by Lucio de Souza Coelho
    # and Len Trigg.
    class Hyperpipes < Classifier
      attr_reader :data_set, :pipes

      parameters_info tie_break: 'Strategy used when more than one class has the same maximal vote. ' \
                                  'Valid values are :last (default) and :random.',
                      margin: 'Numeric margin added to the bounds of numeric attributes.',
                      random_seed: 'Seed for random tie-breaking when tie_break is :random.'

      # @return [Object]
      def initialize
        @tie_break = :last
        @margin = 0
        @random_seed = nil
        @rng = nil
      end

      # Build a new Hyperpipes classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as
      # the item class.
      # @param data_set [Object]
      # @return [Object]
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @domains = data_set.build_domains

        @pipes = {}
        @domains.last.each { |cat| @pipes[cat] = build_pipe(@data_set) }
        @data_set.data_items.each { |item| update_pipe(@pipes[item.last], item) }

        self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      # Tie resolution is controlled by +tie_break+ parameter.
      # @param data [Object]
      # @return [Object]
      def eval(data)
        votes = Votes.new
        @pipes.each do |category, pipe|
          pipe.each_with_index do |bounds, i|
            if data[i].is_a? Numeric
              votes.increment_category(category) if data[i].between?(bounds[:min], bounds[:max])
            elsif bounds[data[i]]
              votes.increment_category(category)
            end
          end
        end
        rng = @rng || (@random_seed.nil? ? Random.new : Random.new(@random_seed))
        votes.get_winner(@tie_break, rng: rng)
      end

      # This method returns the generated rules in ruby code.
      # e.g.
      #
      #   classifier.get_rules
      #     # =>  if age_range == '<30' then marketing_target = 'Y'
      #           elsif age_range == '[30-50)' then marketing_target = 'N'
      #           elsif age_range == '[50-80]' then marketing_target = 'N'
      #           end
      #
      # It is a nice way to inspect induction results, and also to execute them:
      #     marketing_target = nil
      #     eval classifier.get_rules
      #     puts marketing_target
      #       # =>  'Y'
      # @return [Object]
      def get_rules
        rules = []
        rules << 'votes = Votes.new'
        data = @data_set.data_items.first
        labels = @data_set.data_labels.collect(&:to_s)
        @pipes.each do |category, pipe|
          pipe.each_with_index do |bounds, i|
            rule = "votes.increment_category('#{category}') "
            rule += if data[i].is_a? Numeric
                      "if #{labels[i]} >= #{bounds[:min]} && #{labels[i]} <= #{bounds[:max]}"
                    else
                      "if #{bounds.inspect}[#{labels[i]}]"
                    end
            rules << rule
          end
        end
        rules << "#{labels.last} = votes.get_winner(:#{@tie_break})"
        rules.join("\n")
      end

      # Return a summary representation of all pipes.
      #
      # The returned hash maps each category to another hash where the keys are
      # attribute labels and the values are either numeric ranges
      # `[min, max]` (including the optional margin) or a Set of nominal values.
      #
      #   classifier.pipes_summary
      #     # => { "Y" => { "city" => #{Set['New York', 'Chicago']},
      #                    "age" => [18, 85],
      #                    "gender" => #{Set['M', 'F']} },
      #          "N" => { ... } }
      #
      # The optional +margin+ parameter expands numeric bounds by the given
      # fraction.  A value of 0.1 would enlarge each range by 10%.
      # @param margin [Object]
      # @return [Object]
      def pipes_summary(margin: 0)
        raise 'Model not built yet' unless @data_set && @pipes

        labels = @data_set.data_labels[0...-1]
        summary = {}
        @pipes.each do |category, pipe|
          attr_summary = {}
          pipe.each_with_index do |bounds, i|
            if bounds.is_a?(Hash) && bounds.key?(:min) && bounds.key?(:max)
              min = bounds[:min]
              max = bounds[:max]
              range_margin = (max - min) * margin
              attr_summary[labels[i]] = [min - range_margin, max + range_margin]
            else
              attr_summary[labels[i]] = bounds.select { |_k, v| v }.keys.to_set
            end
          end
          summary[category] = attr_summary
        end
        summary
      end

      protected

      # @param data_set [Object]
      # @return [Object]
      def build_pipe(data_set)
        data_set.data_items.first[0...-1].collect do |att|
          if att.is_a? Numeric
            { min: Float::INFINITY, max: -Float::INFINITY }
          else
            Hash.new(false)
          end
        end
      end

      # @param pipe [Object]
      # @param data_item [Object]
      # @return [Object]
      def update_pipe(pipe, data_item)
        data_item[0...-1].each_with_index do |att, i|
          if att.is_a? Numeric
            min_val = att - @margin
            max_val = att + @margin
            pipe[i][:min] = min_val if min_val < pipe[i][:min]
            pipe[i][:max] = max_val if max_val > pipe[i][:max]
          else
            pipe[i][att] = true
          end
        end
      end
    end
  end
end
