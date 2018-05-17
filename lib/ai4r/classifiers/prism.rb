# Author::    Sergio Fierens (Implementation only, Cendrowska is 
# the creator of the algorithm)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
#
# J. Cendrowska (1987). PRISM: An algorithm for inducing modular rules. 
# International Journal of Man-Machine Studies. 27(4):349-370.

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  module Classifiers

    # = Introduction
    # This is an implementation of the PRISM algorithm (Cendrowska, 1987) 
    # Given a set of preclassified examples, it builds a set of rules
    # to predict the class of other instaces.
    # 
    # J. Cendrowska (1987). PRISM: An algorithm for inducing modular rules. 
    # International Journal of Man-Machine Studies. 27(4):349-370.
    class Prism < Classifier
            
      attr_reader :data_set, :rules

      # Build a new Prism classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as 
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        domains = @data_set.build_domains
        instances = @data_set.data_items.collect {|data| data }
        @rules = []
        domains.last.each do |class_value|
          while(has_class_value(instances, class_value))
            rule = build_rule(class_value, instances)
            @rules << rule
            instances = instances.select {|data| !matches_conditions(data, rule[:conditions])}
          end
        end
        return self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'      
      def eval(instace)
        @rules.each do |rule|
          return rule[:class_value] if matches_conditions(instace, rule[:conditions])
        end
        return nil
      end
      
      # This method returns the generated rules in ruby code.
      # e.g.
      #   
      #   classifier.get_rules
      #     # => if age_range == '<30' then marketing_target = 'Y'
      #    elsif age_range == '>80' then marketing_target = 'Y'
      #    elsif city == 'Chicago' and age_range == '[30-50)' then marketing_target = 'Y'
      #    else marketing_target = 'N'
      #    end
      #
      # It is a nice way to inspect induction results, and also to execute them:  
      #        age_range = '[30-50)'
      #        city = 'New York'
      #        eval(classifier.get_rules) 
      #        puts marketing_target
      #         'Y'
      def get_rules
        out = "if #{join_terms(@rules.first)} then #{then_clause(@rules.first)}"
        @rules[1...-1].each do |rule| 
          out += "\nelsif #{join_terms(rule)} then #{then_clause(rule)}"
        end
        out += "\nelse #{then_clause(@rules.last)}" if @rules.size > 1
        out += "\nend"
        return out
      end
      
      protected
      
      def get_attr_value(data, attr)
        data[@data_set.get_index(attr)]
      end
      
      def has_class_value(instances, class_value)
        instances.each { |data| return true if data.last == class_value}
        return false
      end
      
      def is_perfect(instances, rule)
        class_value = rule[:class_value]
        instances.each do |data| 
          return false if data.last != class_value and matches_conditions(data, rule[:conditions])
        end
        return true
      end
      
      def matches_conditions(data, conditions)
        conditions.each_pair do |attr_label, attr_value|
          return false if get_attr_value(data, attr_label) != attr_value
        end
        return true
      end
      
      def build_rule(class_value, instances)
        rule = {:class_value => class_value, :conditions => {}}
        rule_instances = instances.collect {|data| data }
        attributes = @data_set.data_labels[0...-1].collect {|label| label }
        until(is_perfect(instances, rule) || attributes.empty?)
          freq_table = build_freq_table(rule_instances, attributes, class_value)
          condition = get_condition(freq_table)
          rule[:conditions].merge!(condition)
          rule_instances = rule_instances.select do |data| 
            matches_conditions(data, condition) 
          end
        end
        return rule
      end
      
      # Returns a structure with the folloring format:
      # => {attr1_label => { :attr1_value1 => [p, t], attr1_value2 => [p, t], ... },
      #     attr2_label => { :attr2_value1 => [p, t], attr2_value2 => [p, t], ... },
      #     ...
      #     }
      # where p is the number of instances classified as class_value
      # with that attribute value, and t is the total number of instances with 
      # that attribute value
      def build_freq_table(rule_instances, attributes, class_value)
        freq_table = Hash.new()
        rule_instances.each do |data|
          attributes.each do |attr_label|
            attr_freqs = freq_table[attr_label] || Hash.new([0, 0])
            pt = attr_freqs[get_attr_value(data, attr_label)]
            pt = [(data.last == class_value) ? pt[0]+1 : pt[0], pt[1]+1]
            attr_freqs[get_attr_value(data, attr_label)] = pt
            freq_table[attr_label] = attr_freqs
          end
        end
        return freq_table
      end
      
      # returns a single conditional term: {attrN_label => attrN_valueM}
      # selecting the attribute with higher pt ratio
      # (occurrences of attribute value classified as class_value / 
      #  occurrences of attribute value)
      def get_condition(freq_table)
        best_pt = [0, 0]
        condition = nil
        freq_table.each do |attr_label, attr_freqs|
          attr_freqs.each do |attr_value, pt|
            if(better_pt(pt, best_pt))
              condition = { attr_label => attr_value }
              best_pt = pt
            end
          end
        end
        return condition
      end
      
      # pt = [p, t]
      # p = occurrences of attribute value with instance classified as class_value
      # t = occurrences of attribute value
      # a pt is better if:
      #   1- its ratio is higher
      #   2- its ratio is equal, and has a higher p 
      def better_pt(pt, best_pt)
        return false if pt[1] == 0
        return true if best_pt[1] == 0
        a = pt[0]*best_pt[1]
        b = best_pt[0]*pt[1]
        return true if a>b || (a==b && pt[0]>best_pt[0])
        return false
      end
      
      def join_terms(rule)
        terms = []
        rule[:conditions].each do |attr_label, attr_value| 
            terms << "#{attr_label} == '#{attr_value}'"
        end
        "#{terms.join(" and ")}"
      end
      
      def then_clause(rule)
        "#{@data_set.category_label} = '#{rule[:class_value]}'"
      end
          
    end
  end
end

