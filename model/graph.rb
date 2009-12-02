# require 'scruffy'
# 
# class Graph
#   
#   def plot(project)
#     graph = Scruffy::Graph.new
#     graph.title = 'Build Performance over time'
#     graph.value_formatter = Scruffy::Formatters::Percentage.new(:precision => 0)
#     graph.add :stacked do |stack|
#       stack.add :bar, 'Failure', [10, 12]
#       stack.add :bar, "Success", [5, 7]
#     end
#     graph.point_markers = ["Success", "Rate"]
#     graph.render :width => 500, :to => 'build_graph.png', :as => 'png'
#   end
# end


require 'SVG/Graph/Bar'

fields = %w(Jan Feb Mar);
data_sales_02 = [12, 45, 21]

graph = SVG::Graph::Bar.new(
  :height => 500,
  :width => 300,
  :fields => fields
)

graph.add_data(
  :data => data_sales_02,
  :title => 'Sales 2002'
)

# print "Content-type: image/svg+xml\r\n\r\n"
# print graph.burn