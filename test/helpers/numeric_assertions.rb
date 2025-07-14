# frozen_string_literal: true

module NumericAssertions
  def assert_float_equal(expected, actual, eps = 1e-6)
    assert (expected - actual).abs <= eps,
           "Expected #{expected} within +/-#{eps}, got #{actual}"
  end

  def assert_matrix_equal(m1, m2, eps = 1e-6)
    assert_equal m1.size, m2.size
    m1.zip(m2) do |row1, row2|
      assert_equal row1.size, row2.size
      row1.zip(row2) { |a, b| assert_float_equal a, b, eps }
    end
  end

  def assert_monotonic_decrease(enum)
    last = enum.first
    enum.each do |val|
      assert val <= last, 'Sequence not monotonically decreasing'
      last = val
    end
  end

  def assert_pct_between(expected_pct, actual_pct, tolerance = 0.05)
    delta = expected_pct * tolerance
    assert_in_delta expected_pct, actual_pct, delta,
                    "Expected #{actual_pct} within #{delta} of #{expected_pct}"
  end

  def assert_improves(before, after)
    assert after > before, "Expected #{after} to improve over #{before}"
  end
end
