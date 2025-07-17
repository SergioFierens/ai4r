require_relative '../../test_helper'
require_relative '../../../bench/common/cli'

class BenchCliTest < Minitest::Test
  def test_parse_with_custom_option
    cli = Bench::Common::CLI.new('foo', %w[a b], [:m]) do |opts, options|
      opts.on('--flag VALUE', String) { |v| options[:flag] = v }
    end
    opts = cli.parse(%w[--algos a,b --export res.csv --flag bar])
    assert_equal %w[a b], opts[:algos]
    assert_equal 'res.csv', opts[:export]
    assert_equal 'bar', opts[:flag]
  end
end
