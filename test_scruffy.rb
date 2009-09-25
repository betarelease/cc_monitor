require 'rubygems'
require 'scruffy'

graph = Scruffy::Graph.new
graph.title = "Favourite Snacks"
graph.renderer = Scruffy::Renderers::Pie.new

graph.add :pie, '', {
  'Apple' => 20,
  'Banana' => 100,
  'Orange' => 70,
  'Taco' => 30
}

# graph.render :to => "pie_test.svg"
graph.render :width => 300, :height => 200,
  :to => "pie_test.png", :as => 'png'
