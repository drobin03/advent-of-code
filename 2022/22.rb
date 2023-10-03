require 'pry'
module Day22
  class Map
    DIRECTIONS = ['R', 'D', 'L', 'U']

    attr_accessor :current_pos

    def initialize(input)
      @map = input.lines(chomp: true).each_with_index.inject({}) do |map, (line, row)|
        line.chars.each_with_index do |char, col|
          next if (char == ' ')
          map[[col, row]] = char
        end
        map
      end

      @current_pos = {
        row: 0,
        col: columns_in_row(0).find { |col| @map[[col, 0]] == '.' },
        dir: 'R'
      }
    end

    def columns_in_row(row)
      columns = bounds[0]
      (0..columns).to_a.select { |col| @map[[col, row]] }
    end

    def rows_in_column(col)
      rows = bounds[1]
      (0..rows).to_a.select { |row| @map[[col, row]] }
    end

    def tile_at(pos)
      @map[[pos[:col], pos[:row]]]
    end

    def move
      new_pos = @current_pos.dup
      case @current_pos[:dir]
      when 'L'
        new_pos[:col] = new_pos[:col] - 1
        new_pos[:col] = columns_in_row(@current_pos[:row]).last if tile_at(new_pos) == nil
      when 'R'
        new_pos[:col] = new_pos[:col] + 1
        new_pos[:col] = columns_in_row(@current_pos[:row]).first if tile_at(new_pos) == nil
      when 'U'
        new_pos[:row] = new_pos[:row] - 1
        new_pos[:row] = rows_in_column(@current_pos[:col]).last if tile_at(new_pos) == nil
      when 'D'
        new_pos[:row] = new_pos[:row] + 1
        new_pos[:row] = rows_in_column(@current_pos[:col]).first if tile_at(new_pos) == nil
      end
      puts "Attempting #{new_pos[:col]}, #{new_pos[:row]} = #{tile_at(new_pos)}"
      return false if tile_at(new_pos) == '#'
      @map[[@current_pos[:col], @current_pos[:row]]] = { 'L': '<', 'R': '>', 'U': '^', 'D': 'v' }[@current_pos[:dir].to_sym]
      @current_pos = new_pos
      true
    end

    def turn(dir)
      current_idx = DIRECTIONS.index @current_pos[:dir]
      case dir
      when 'L'
        current_idx -= 1
      when 'R'
        current_idx += 1
      end
      @current_pos[:dir] = DIRECTIONS[current_idx % DIRECTIONS.length]
    end

    def bounds
      @bounds ||= [@map.keys.map(&:first).max, @map.keys.map(&:last).max]
    end

    def to_s
      (0..bounds[1]).each do |row|
        (0..bounds[0]).each do |col|
          if [@current_pos[:col], @current_pos[:row]] == [col, row]
            print @current_pos[:dir]
          else
            print @map[[col, row]] || ' '
          end
        end
        print "\n"
      end
    end
  end

  class Cube < Map
    def initialize(input, size = [4,4])
      super(input)

      @faces = []
      unassigned = @map.dup
      while unassigned.length > 0
        start = unassigned.keys.first
        face = {}
        (start[1]..(start[1] + size[1] - 1)).each do |row|
          (start[0]..(start[0] + size[0] - 1)).each do |col|
            face[[col, row]] = unassigned.delete([col, row])
          end
        end
        @faces << face
      end
      (0..bounds[1]).each do |row|
        (0..bounds[0]).each do |col|
          if [@current_pos[:col], @current_pos[:row]] == [col, row]
            print @current_pos[:dir]
          else
            if @map[[col, row]]
              face = @faces.index { |f| !f[[col, row]].nil? }
              print face + 1
            else
              print ' '
            end
          end
        end
        print "\n"
      end
    end
  end

  class << self
    def part_one(input)
      map, moves = input.join("\n").split("\n\n")
      map = Map.new(map)
      moves = moves.scan(/\d+|[A-Z]/).map { |m| m.match(/\d+/) ? m.to_i : m }

      moves.each do |move|
        if (move.is_a? Integer)
          move.times do
            moved = map.move
            break unless moved
          end
          puts "\n\nMove #{move}"
        else
          puts "\n\Turn #{move}. #{map.current_pos[:dir]}"
          map.turn(move)
        end
        # map.to_s
      end

      # puts map.current_pos.to_s
      # puts [
      #   (map.current_pos[:col]+1) * 4,
      #   (map.current_pos[:row]+1) * 1000,
      #   Map::DIRECTIONS.index(map.current_pos[:dir])
      # ].to_s
      [
        (map.current_pos[:col]+1) * 4,
        (map.current_pos[:row]+1) * 1000,
        Map::DIRECTIONS.index(map.current_pos[:dir])
      ].sum
    end

    def part_two(input)
      map, moves = input.join("\n").split("\n\n")
      map = Cube.new(map)
      moves = moves.scan(/\d+|[A-Z]/).map { |m| m.match(/\d+/) ? m.to_i : m }

      # moves.each do |move|
      #   if (move.is_a? Integer)
      #     move.times do
      #       moved = map.move
      #       break unless moved
      #     end
      #     puts "\n\nMove #{move}"
      #   else
      #     puts "\n\Turn #{move}. #{map.current_pos[:dir]}"
      #     map.turn(move)
      #   end
      #   # map.to_s
      # end

      # puts map.current_pos.to_s
      # puts [
      #   (map.current_pos[:col]+1) * 4,
      #   (map.current_pos[:row]+1) * 1000,
      #   Map::DIRECTIONS.index(map.current_pos[:dir])
      # ].to_s
      [
        (map.current_pos[:col]+1) * 4,
        (map.current_pos[:row]+1) * 1000,
        Map::DIRECTIONS.index(map.current_pos[:dir])
      ].sum
    end
  end
end
