require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require File.dirname(__FILE__) + '/som_data'
require 'gnuplot'

layer = Ai4r::Som::TwoPhaseLayer.new(10)
som = Ai4r::Som::Som.new(SOM_DATA.first.length, 8, 8, layer)
som.initiate_map
som.train SOM_DATA

matrix = som.u_matrix
x = (0...som.columns).to_a
y = (0...som.rows).to_a

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.set 'pm3d map'
    plot.title = 'SOM U-Matrix'
    plot.data << Gnuplot::DataSet.new([x, y, matrix]) do |ds|
      ds.with = 'image'
      ds.using = '1:2:3'
    end
  end
end

