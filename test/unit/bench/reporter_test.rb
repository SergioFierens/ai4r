require_relative '../../test_helper'
require_relative '../../../bench/common/reporter'
require 'tempfile'

class BenchReporterTest < Minitest::Test
  def setup
    @results = [
      { algorithm: 'a', accuracy: 0.9, training_ms: 1, predict_ms: 1, model_size_kb: 10 },
      { algorithm: 'b', accuracy: 1.0, training_ms: 2, predict_ms: 2, model_size_kb: 20 }
    ]
    @metrics = %i[accuracy training_ms predict_ms model_size_kb]
  end

  def test_print_table_and_export
    reporter = Bench::Common::Reporter.new(@results, @metrics)
    out, = capture_io { reporter.print_table }
    assert_includes out, 'algorithm'
    assert_includes out, 'accuracy'
    Tempfile.create('report') do |f|
      reporter.export_csv(f.path)
      f.rewind
      csv = f.read
      assert_includes csv, 'algorithm,accuracy,training_ms,predict_ms,model_size_kb'
      assert_includes csv, 'a,0.9,1,1,10'
    end
  end
end
