require 'scruffy'

class Graph
  
  # def plot(project)
  #   graph = Scruffy::Graph.new
  #   graph.title = 'Build Performance over time'
  #   graph.value_formatter = Scruffy::Formatters::Percentage.new(:precision => 0)
  #   graph.add :stacked do |stack|
  #     stack.add :bar, 'Failure', [10, 12]
  #     stack.add :bar, "Success", [5, 7]
  #   end
  #   graph.point_markers = ["Success", "Rate"]
  #   graph.render :width => 500, :to => 'build_graph.png', :as => 'png'    
  # end
end