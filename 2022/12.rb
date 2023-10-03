module Day12

  ELEVATION = (('a'..'z').each_with_index + [["S", 0], ["E", 25]]).to_h

  class << self
    def bounds
      @bounds ||= [
        Range.new(@grid.keys.map(&:first).minmax),
        Range.new(@grid.keys.map(&:last).minmax)
      ]
    end

    def in_bounds?(x,y)
      bounds[0].include?(x) && bounds[1].include(y)
    end

    def adjacent(x,y)
      [
        [x-1,y],
        [x+1,y],
        [x,y-1],
        [x,y+1],
      ]
    end

    def steppable?(from, to)
      ELEVATION[to] + 1 >= ELEVATION[from]
    end

    def traverse
      @distances = { }
      @distances[@end] =  0
      unvisited_nodes = @grid.keys
      while current_node = unvisited_nodes.reject { |n| @distances[n].nil? }.min_by { |n| @distances[n] }
        unvisited_nodes.delete(current_node)

        adjacent(*current_node).each do |a|
          if unvisited_nodes.include?(a) && steppable?(@grid[current_node], @grid[a])
            @distances[a] = @distances[current_node] + 1
          end
        end
      end
    end

    def init(input)
      @grid = {}
      input.lines(chomp: true).each_with_index do |line, y|
        line.chars.each_with_index do |height, x|
          pos = [x,y]
          @grid[pos] = height
        end
      end

      @start = @grid.key('S')
      @end = @grid.key('E')
    end

    def part_one(input)
      # return true
      init(input)
      traverse
      @distances[@start]
    end

    def part_two(input)
      init(input)
      traverse
      @grid.select { |k, v| v == 'a' }.keys.map { |k| @distances[k] }.compact.min
    end
  end
end

# require 'matrix'
# require 'pry'

# module Day12

#   class Graph
#     @nodes = []
#     @start = nil
#     @end = nil

#     def initialize(node_input)
#       @nodes = []
#       node_input.each_with_index do |row, row_i|
#         @nodes[row_i] = []
#         row.each_with_index do |col, col_i|
#           node = Node.new([row_i, col_i], col)
#           @nodes[row_i][col_i] = node
#           case col
#           when 'S'
#             @start = node
#             @start.distance_from_start = 0
#           when 'E'
#             @end = node
#           end
#         end
#       end

#       node_input.each_with_index do |row, row_i|
#         row.each_with_index do |col, col_i|
#           @nodes[row_i][col_i].add_edges([
#             node(row_i-1, col_i),
#             node(row_i+1, col_i),
#             node(row_i, col_i-1),
#             node(row_i, col_i+1),
#           ].compact)
#         end
#       end

#     end

#     def print_path(end_node = @end)
#       path = [end_node]
#       current_node = end_node
#       while current_node.prev_node
#         current_node = current_node.prev_node
#         path.prepend(current_node)
#       end
#       puts "\n\nGraph ------\n\n"
#       @nodes.each do |row|
#         row.each do |node|
#           case node
#           when @start
#             print 'S'
#           when @end
#             print 'E'
#           when end_node
#             print '?'
#           else
#             if path.include?(node)
#               next_node = path.find {|n| n.prev_node == node }
#               if (next_node.row > node.row)
#                 print 'v'
#               elsif (next_node.row < node.row)
#                 print '^'
#               elsif (next_node.col > node.col)
#                 print '>'
#               else
#                 print '<'
#               end
#             else
#               print '.'
#             end
#           end
#         end
#         print "\n"
#       end
#     end

#     def node(row_i, col_i)
#       return nil if row_i < 0 || col_i < 0 || row_i >= @nodes.length || col_i >= @nodes[0].length
#       @nodes[row_i][col_i]
#     end

#     def traverse(start_node = @start, end_node = @end)
#       # unvisited_nodes = @nodes - [start_node1]
#       queue = @nodes.flatten
#       until queue.empty?
#         closest = queue.select(&:distance_from_start).min_by { |n| n.distance_from_start }
#         puts "breaking" if !closest
#         break if !closest
#         queue.delete(closest)
#         # closest = @nodes.find { |n| n == closest }
#         puts queue.length if @start_printing

#         current_distance = closest.distance_from_start + 1
#         closest.edges
#           .select { |e| queue.include?(e) }
#           .reject { |e| e.distance_from_start && e.distance_from_start <= current_distance }
#           # .sort_by { |e| (end_node.position - e.position) - (end_node.position - start_node.position) }
#           .each do |edge|
#             # puts "considering new path: #{edge.to_s}" if (start_node == @start)
#             # puts "#{edge.distance_from_start} #{current_distance}" if @start_printing
#           # next if edge.distance_from_start && edge.distance_from_start < current_distance

#           # puts "#{edge.distance_from_start} >= #{current_distance}"

#           # print_path(edge) if @start_printing

#           edge.distance_from_start = current_distance
#           edge.prev_node = closest
#           # puts "found end node #{current_distance}" if edge == end_node
#           # puts "(#{edge.x}, #{edge.y}) == (#{end_node.x}, #{end_node.y})"
#           if edge == end_node && current_distance <= 474
#             @start_printing = true
#             # print_path(end_node)
#           end
#         end
#       end
#     end

#     def end_node
#       @end
#     end

#     class Node
#       HEIGHTS = ('a'..'z').to_a.prepend('S').append('E')

#       def initialize(position, height)
#         @distance_from_start = nil
#         @row = position[0]
#         @col = position[1]
#         @height = HEIGHTS.index(height)
#         @edges = []
#         @prev_node = nil
#         @visited = false
#       end
#       def visited
#         @visited
#       end

#       def visited=(v)
#         @visited = v
#       end

#       def height
#         @height
#       end

#       def position
#         row * col
#       end

#       def distance_from_start
#         @distance_from_start
#       end

#       def distance_from_start=(distance)
#         @distance_from_start = distance
#       end

#       def add_edges(nodes)
#         nodes.each do |node|
#           add_edge(node)
#         end
#       end

#       def add_edge(node)
#         return if (node.height > height+1)
#         @edges.append(node)
#       end

#       def edges
#         @edges
#       end

#       def to_s
#         "Node: height: #{@height}, at (#{@row},#{@col}), distance: #{distance_from_start}"
#       end

#       def prev_node=(node)
#         @prev_node = node
#       end

#       def prev_node
#         @prev_node
#       end

#       def row
#         @row
#       end

#       def col
#         @col
#       end

#       def ==(other_node)
#         @row == other_node.row && @col == other_node.col
#       end
#     end
#   end

#   class << self
#     def part_one(input)
#       graph = Graph.new(input.lines(chomp: true).map(&:chars))
#       graph.traverse
#       graph.print_path
#       graph.end_node.distance_from_start
#     end

#     def part_two(input)

#     end
#   end
# end
