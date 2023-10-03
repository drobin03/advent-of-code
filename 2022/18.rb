require 'pry'
module Day18
  class Cube
    attr_reader :neighbors, :position

    def initialize(x,y,z)
      @position = [x,y,z]
      @neighbors = [
        [[x+1,y,z], nil],
        [[x-1,y,z], nil],
        [[x,y+1,z], nil],
        [[x,y-1,z], nil],
        [[x,y,z+1], nil],
        [[x,y,z-1], nil],
      ].to_h
    end

    def add_neighbor(cube)
      return unless @neighbors[cube.position].nil?
      @neighbors[cube.position] = cube
      cube.add_neighbor(self)
    end

    def empty_neighbors
      @empty_neighbors ||= neighbors.select { |pos, n| n.nil? }
    end

    def neighbors_by_air?(other_cube)
      enclosing_same_air = empty_neighbors.keys.intersection(other_cube.empty_neighbors.keys).length > 0
      side_by_side = neighbors.keys.include? other_cube.position
      enclosing_same_air || side_by_side
    end

    def to_s
      "Pos: #{@position.to_s}. N: #{neighbors.values.compact.length}"
    end
    def inspect
      to_s
    end
  end

  class << self

    def init(input)
      @cubes = {}

      input.scan(/\d+/).map(&:to_i).each_slice(3) do |pos|
        @cubes[pos] = Cube.new(*pos)
      end

      map_neighbors
    end

    def map_neighbors
      @cubes.values.each do |cube|
        missing_neighbors = cube.neighbors.select { |p, n| n.nil? }
        missing_neighbors.keys.each do |position|
          neighbor_cube = @cubes[position]
          cube.add_neighbor(neighbor_cube) if neighbor_cube
        end
      end
    end

    def adjacent_edges(x,y,z)
      [
        [x+1,y,z],
        [x-1,y,z],
        [x,y+1,z],
        [x,y-1,z],
        [x,y,z+1],
        [x,y,z-1],
      ]
    end

    def out_of_bounds(x,y,z)
      @bounds ||= [
        [@cubes.keys.map(&:first).min, @cubes.keys.map(&:first).max],
        [@cubes.keys.map{ |k| k[1] }.min, @cubes.keys.map{ |k| k[1] }.max],
        [@cubes.keys.map(&:last).min, @cubes.keys.map(&:last).max],
      ]
      !x.between?(*@bounds[0]) || !y.between?(*@bounds[1]) || !z.between?(*@bounds[2])
    end

    def range
      @range ||= 3.times.map do |i|
        min, max = @cubes.keys.map { |c| c[i] }.minmax
        Range.new(min - 1, max + 1)
      end
    end

    # def all
    #   range.
    # end

    def in_range?(x,y,z)
      range[0].include?(x) && range[1].include?(y) && range[2].include?(z)
    end

    def part_one(input)
      init(input)
      @cubes.values.inject(0) do |faces, c|
        faces += c.neighbors.values.select(&:nil?).count
        faces
      end
    end

    def part_two(input)
      init(input)

      @exterior = []
      # Start outside, find all reachable faces
      to_visit = [range.map(&:begin)]

      while c = to_visit.shift
        @exterior << c
        adjacent_edges(*c).each do |a|
          next if !in_range?(*a) || @cubes.has_key?(a) || @exterior.include?(a) || to_visit.include?(a)
          to_visit << a
        end
      end



      # # For every empty neighbor, distinct,
      # # find all it's air neighbors'
      # # if out-of-bounds (max x, min x), must be an edge
      # # otherwise, keep looking

      # possible_pockets = @cubes.values.flat_map { |c| c.empty_neighbors.keys }.uniq

      # pockets = []

      # while possible_pockets.length > 0
      #   puts "Remaining #{possible_pockets.length}"
      #   air_cube = possible_pockets.shift
      #   next if out_of_bounds(*air_cube)
      #   pocket = [air_cube]
      #   adjacent_air = adjacent_edges(*air_cube).reject { |e| @cubes[e] }
      #   while adjacent_air.length > 0
      #     adjacent_air_cube = adjacent_air.shift
      #     if out_of_bounds(*adjacent_air_cube)
      #       possible_pockets = possible_pockets - adjacent_air
      #       adjacent_air = []
      #       pocket = nil
      #       next
      #     end
      #     pocket.append(adjacent_air_cube)
      #     puts pocket.size, adjacent_air_cube.to_s
      #     adjacent_air = adjacent_air + adjacent_edges(*adjacent_air_cube).reject { |e| @cubes[e] }
      #   end
      #   pockets.append(pocket) if pocket
      # end

      (@cubes.values.flat_map { |c| c.empty_neighbors.keys.intersection(@exterior) } ).count
    end
  end
end
