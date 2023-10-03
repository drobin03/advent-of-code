class FallingIntoTheAbyss < Exception
end
class SourceBlocked < Exception
end

module Day14
  class Cave
    def initialize(rocks, sand_start:, has_floor: false)
      @rocks = rocks
      @sand = []
      @sand_start = sand_start
      @floor = rocks.map(&:last).max + 2 if has_floor
      @bounds = [
        [rocks.map(&:first).min - 1, [rocks.map(&:first).max, sand_start[0]].max + 1],
        [0, (@floor || rocks.map(&:last).max) + 1]
      ]
      @grid = []
      (@bounds[1][0]..@bounds[1][1]).each do |row|
        @grid[row] = []
        (@bounds[0][0]..@bounds[0][1]).each do |col|
          point = [col, row]
          if @rocks.include?(point)
            @grid[row][col] = '#'
          else
            @grid[row][col] = '.'
          end
        end
      end
    end

    def to_s
      # max_columns = @grid.map(&:length).max
      @grid.each do |row|
        row.each do |i|
          print i
        end
        print "\n"
      end
    end

    def sand
      @sand
    end

    def drip
      grain = @sand_start.dup
      while new_pos = fall(grain)
        grain = new_pos
        raise FallingIntoTheAbyss.new if (grain[1] >= @bounds[1][1])
      end
      @sand << grain
      @grid[grain[1]][grain[0]] = 'o'
      raise SourceBlocked.new if @sand_start == grain
    end

    def fall(grain)
      [
        [grain[0], grain[1]+1],
        [grain[0]-1, grain[1]+1],
        [grain[0]+1, grain[1]+1],
      ].find do |col, row|
        return false if @floor && row >= @floor
        @grid.each { |row| row[col] = '.' } if (@grid[row][col].nil?)
        @grid[row][col] == '.'
      end
    end
  end

  class << self
    def part_one(input)
      rocks = parse_rocks(input)

      cave = Cave.new(rocks, sand_start: [500,0])

      cave.to_s
      begin
        i = 0
        while true
          i = i + 1
          cave.drip
        end
      rescue FallingIntoTheAbyss
      rescue SourceBlocked
        cave.to_s
      end
      cave.sand.length
    end

    def part_two(input)
      rocks = parse_rocks(input)

      cave = Cave.new(rocks, sand_start: [500,0], has_floor: true)

      cave.to_s
      begin
        i = 0
        while true
          i = i + 1
          cave.drip
        end
      rescue FallingIntoTheAbyss
      rescue SourceBlocked
        cave.to_s
      end
      cave.sand.length
    end

    def parse_rocks(input)
      input.lines(chomp: true).flat_map do |line|
        vertices = line.split(' -> ').map { |v| v.split(',').map(&:to_i) }
        start = vertices.shift
        rock = [start]
        while next_v = vertices.shift
          if (next_v[0] == start[0])
            # vertical
            range = [start[1], next_v[1]]
            (range.min..range.max).reject { |y| start[1] == y }.map do |y|
              rock << [start[0], y]
            end
          else
             # horizontal
            range = [start[0], next_v[0]]
            (range.min..range.max).reject { |x| start[0] == x }.map do |x|
              rock << [x, start[1]]
            end
          end
          start = next_v.dup
        end
        rock
      end
    end
  end
end
