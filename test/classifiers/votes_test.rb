# Author::    Will Warner
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r/classifiers/votes'
require 'test/unit'

class VotesTest < Test::Unit::TestCase
  def setup
    @votes = Votes.new
  end

  def test_without_category
    assert_equal(0, @votes.tally_for("Y"))
  end

  def test_increment
    @votes.increment_category("Y")
    assert_equal(1, @votes.tally_for("Y"))
  end

  def test_get_winner
    @votes.increment_category("Y")
    @votes.increment_category("Y")
    @votes.increment_category("N")
    assert_equal("Y", @votes.get_winner)
  end

  def test_get_winner_with_tie
    @votes.increment_category("N")
    @votes.increment_category("Y")
    @votes.increment_category("X")
    @votes.increment_category("Y")
    @votes.increment_category("N")
    assert_equal("Y", @votes.get_winner)
  end
end
