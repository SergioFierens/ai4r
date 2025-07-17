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
require "#{File.dirname(__FILE__)}/../data/data_set"
require "#{File.dirname(__FILE__)}/../classifiers/classifier"
require "#{File.dirname(__FILE__)}/../classifiers/votes"

module Ai4r
  module Classifiers
    include Ai4r::Data

    # = Introduction
    #
    # A fast classifier algorithm, created by Lucio de Souza Coelho
    # and Len Trigg.
    class Hyperpipes < Classifier
      attr_reader :data_set, :pipes

      # Build a new Hyperpipes classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @domains = data_set.build_domains

        @pipes = {}
        @domains.last.each { |cat| @pipes[cat] = build_pipe(@data_set) }
        @data_set.data_items.each { |item| update_pipe(@pipes[item.last], item) }

        return self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      # In case of a tie, the last category should win: http://www.csee.wvu.edu/~timm/tmp/r7.pdf
      def eval(data)
        # Validate input dimensions
        expected_attrs = @data_set.data_labels.length - 1
        if data.length != expected_attrs
          raise ArgumentError, "Wrong number of attributes. Expected #{expected_attrs}, got #{data.length}"
        end
        
        votes = Votes.new
        matches_per_category = {}
        
        @pipes.each do |category, pipe|
          matches = 0
          pipe.each_with_index do |bounds, i|
            if data[i].is_a? Numeric
              matches += 1 if data[i].between?(bounds[:min], bounds[:max])
            elsif bounds[data[i]]
              matches += 1
            end
          end
          matches_per_category[category] = matches
          # Vote for category only if all attributes match (AND rule)
          votes.increment_category(category) if matches == pipe.length
        end
        
        winner = votes.get_winner
        
        # If no exact match, find the nearest hyperrectangle
        if winner.nil? && !@pipes.empty?
          # Calculate distance to each hyperrectangle
          min_distance = Float::INFINITY
          nearest_category = nil
          
          @pipes.each do |category, pipe|
            distance = 0.0
            pipe.each_with_index do |bounds, i|
              if data[i].is_a? Numeric
                # Distance to hyperrectangle boundary
                if data[i] < bounds[:min]
                  distance += (bounds[:min] - data[i]) ** 2
                elsif data[i] > bounds[:max]
                  distance += (data[i] - bounds[:max]) ** 2
                end
                # If within bounds, distance contribution is 0
              else
                # For categorical, distance is 0 if match, 1 if not
                distance += 1 unless bounds[data[i]]
              end
            end
            
            if distance < min_distance
              min_distance = distance
              nearest_category = category
            end
          end
          
          winner = nearest_category
        end
        
        return winner
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
        rules << "#{labels.last} = votes.get_winner"
        return rules.join("\n")
      end

      protected

      def build_pipe(data_set)
        data_set.data_items.first[0...-1].collect do |att|
          if att.is_a? Numeric
            { min: 1.0 / 0, max: -1.0 / 0 }
          else
            Hash.new(false)
          end
        end
      end

      def update_pipe(pipe, data_item)
        data_item[0...-1].each_with_index do |att, i|
          if att.is_a? Numeric
            pipe[i][:min] = att if att < pipe[i][:min]
            pipe[i][:max] = att if att > pipe[i][:max]
          else
            pipe[i][att] = true
          end
        end
      end
    end
  end
end
