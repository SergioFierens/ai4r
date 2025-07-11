require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require File.dirname(__FILE__) + '/som_data'
require 'gnuplot'

layer = Ai4r::Som::TwoPhaseLayer.new(10)
som = Ai4r::Som::Som.new(SOM_DATA.first.length, 8, 8, layer)
som.initiate_map
som.train SOM_DATA

mapping = som.map_samples(SOM_DATA)
points = mapping.map { |_s, (row, col)| [col, row] }
x = points.map(&:first)
y = points.map(&:last)

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title = 'Sample Mapping'
    plot.style 'data points'
    plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
      ds.with = 'points'
    end
  end
end

