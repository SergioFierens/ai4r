# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r/classifiers/hyperpipes'
require 'minitest/autorun'
require 'set'
require 'yaml'

include Ai4r::Classifiers
include Ai4r::Data

class HyperpipesTest < Minitest::Test
  fixture = YAML.load_file(File.expand_path('../fixtures/marketing_target_numeric.yml', __dir__))

  @@data_labels = fixture['data_labels']
  @@data_items  = fixture['data_items']

  def setup
    @data_set = DataSet.new(data_items: @@data_items, data_labels: @@data_labels)
  end

  def test_build_pipe
    classifier = Hyperpipes.new
    assert_equal [{}, { max: -1.0 / 0, min: 1.0 / 0 }, {}],
                 classifier.send(:build_pipe, @data_set)
  end

  def test_build
    assert_raises(ArgumentError) { Hyperpipes.new.build(DataSet.new) }
    classifier = Hyperpipes.new.build(@data_set)
    assert classifier.pipes.include?('Y')
    assert classifier.pipes.include?('N')
  end

  def test_eval
    classifier = Hyperpipes.new.build(@data_set)
    assert classifier
    assert_equal('N', classifier.eval(['Chicago',  55, 'M']))
    assert_equal('N', classifier.eval(['New York', 35, 'F']))
    assert_equal('Y', classifier.eval(['New York', 25, 'M']))
    assert_equal('Y', classifier.eval(['Chicago',  85, 'F']))
  end

  def test_get_rules
    classifier = Hyperpipes.new.build(@data_set)
    age = 28
    gender = 'M'
    marketing_target = nil
    eval classifier.get_rules
    assert_equal 'Y', marketing_target
    age = 44
    city = 'New York'
    eval classifier.get_rules
    assert_equal 'N', marketing_target
  end

  def test_pipes_summary
    classifier = Hyperpipes.new.build(@data_set)
    summary = classifier.pipes_summary
    expected = {
      'Y' => {
        'city' => Set['New York', 'Chicago'],
        'age' => [18, 85],
        'gender' => Set['M', 'F']
      },
      'N' => {
        'city' => Set['New York', 'Chicago'],
        'age' => [31, 71],
        'gender' => Set['F', 'M']
      }
    }
    assert_equal(expected, summary)
  end

  def test_tie_break
    classifier = Hyperpipes.new.set_parameters(tie_break: :last).build(@data_set)
    assert_equal 'N', classifier.eval(['Chicago', 40, 'F'])
    classifier = Hyperpipes.new.set_parameters(tie_break: :random,
                                               random_seed: 2).build(@data_set)
    assert_equal 'Y', classifier.eval(['Chicago', 40, 'F'])
  end

  def test_margin
    classifier = Hyperpipes.new.build(@data_set)
    assert_equal 'Y', classifier.eval(['Chicago', 30, 'F'])
    classifier = Hyperpipes.new.set_parameters(margin: 5).build(@data_set)
    assert_equal 'N', classifier.eval(['Chicago', 30, 'F'])
  end
end
