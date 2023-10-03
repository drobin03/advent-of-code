require 'pry'

module Day17
  GRID_WIDTH = 7

  class Rock
    def initialize(type, start_pos)
      case type
      when '-'
        @tiles = [
          [start_pos[:left], start_pos[:bottom]],
          [start_pos[:left] + 1, start_pos[:bottom]],
          [start_pos[:left] + 2, start_pos[:bottom]],
          [start_pos[:left] + 3, start_pos[:bottom]],
        ]
      when '+'
        @tiles = [
          [start_pos[:left], start_pos[:bottom] + 1],
          [start_pos[:left] + 1, start_pos[:bottom]],
          [start_pos[:left] + 1, start_pos[:bottom] + 1],
          [start_pos[:left] + 1, start_pos[:bottom] + 2],
          [start_pos[:left] + 2, start_pos[:bottom] + 1],
        ]
      when 'L'
        @tiles = [
          [start_pos[:left], start_pos[:bottom]],
          [start_pos[:left] + 1, start_pos[:bottom]],
          [start_pos[:left] + 2, start_pos[:bottom]],
          [start_pos[:left] + 2, start_pos[:bottom] + 1],
          [start_pos[:left] + 2, start_pos[:bottom] + 2],
        ]
      when 'l'
        @tiles = [
          [start_pos[:left], start_pos[:bottom]],
          [start_pos[:left], start_pos[:bottom] + 1],
          [start_pos[:left], start_pos[:bottom] + 2],
          [start_pos[:left], start_pos[:bottom] + 3],
        ]
      when '⬜️'
        @tiles = [
          [start_pos[:left], start_pos[:bottom]],
          [start_pos[:left], start_pos[:bottom] + 1],
          [start_pos[:left] + 1, start_pos[:bottom]],
          [start_pos[:left] + 1, start_pos[:bottom] + 1],
        ]
      else
        raise Exception.new("Invalid type: #{type}")
      end
    end

    def tiles
      @tiles
    end

    def top
      @top || tiles.map { |t| t.last }.max
    end

    def bottom
      @bottom || tiles.map { |t| t.last }.min
    end

    def left
      @left || tiles.map { |t| t.first }.min
    end

    def right
      @right || tiles.map { |t| t.first }.max
    end

    def freeze
      @top = top
      @bottom = bottom
      @left = left
      @right = right
    end

    def in_spaces?(spaces)
      spaces.any? { |s| @tiles.include? s }
    end

    def move_left(rocks_in_range)
      return if left <= 0
      new_pos = @tiles.map { |t| [t[0]-1, t[1]] }
      return if rocks_in_range.any? { |r| r.in_spaces?(new_pos) }
      @tiles = new_pos
    end

    def move_right(rocks_in_range)
      return if right >= GRID_WIDTH-1
      new_pos = @tiles.map { |t| [t[0]+1, t[1]] }
      return if rocks_in_range.any? { |r| r.in_spaces?(new_pos) }
      @tiles = new_pos
    end

    def move_down(rocks_in_range)
      return if bottom <= 0
      new_pos = @tiles.map { |t| [t[0], t[1]-1] }
      return if rocks_in_range.any? { |r| r.in_spaces?(new_pos) }
      @tiles = new_pos
    end
  end

  class PyroclasticFlow
    def initialize(input)
      @jets = input.lines.first.chars
      @jet_cursor = 0
      @rock_type_cursor = 0
      @rocks = []
      @grid = {}
      @memo = {}
      @height = -1

      @rock_types = [
        '-',
        '+',
        'L',
        'l',
        '⬜️'
      ]
    end

    def drop_rocks(rock_count)
      rock_count.times do |i|
        add_rock(@rock_types[@rock_type_cursor])
        return @height + 1 if pattern_detected?(rock_count)

        @rock_type_cursor = (@rock_type_cursor + 1) % @rock_types.length
      end
      @rocks.map(&:top).max + 1
    end

    def pattern_detected?(desired_count)
      state = [@rock_type_cursor, @jet_cursor].hash
      rock_count = @rocks.length
      return unless @memo[state]

      last_rock_count, last_height = @memo[state]
      rocks_to_add = rock_count - last_rock_count
      height_to_add = @height - last_height
      return unless (desired_count - rock_count) % rocks_to_add == 0

      @height += (desired_count - rock_count) / rocks_to_add * height_to_add
    ensure
      @memo[state] = [rock_count, @height]
    end

    def visualize(rock_in_motion = nil)
      print "\n\n"
      rocks = rock_in_motion ? @rocks + [rock_in_motion] : @rocks
      top = rocks.map(&:top).max + 1

      0.upto(top).to_a.reverse.each do |row|
        0.upto(GRID_WIDTH-1).each do |col|
          if (rocks.flat_map(&:tiles).include? [col, row])
            print '#'
          else
            print '.'
          end
        end
        print "\n"
      end
    end

    def add_rock(rock_type)
      start_pos = { left: 2, bottom: @height + 4 }
      rock = Rock.new(rock_type, start_pos)
      moving = true
      while moving
        @rocks_in_range = @rocks.select { |r| r.top >= (rock.bottom - 1) }
        push_with_jet(rock)
        moving = fall(rock)
      end

      rock.freeze
      @rocks.append(rock)
      @height = @rocks.map { |r| r.top }.max
    end

    def push_with_jet(rock)
      case @jets[@jet_cursor]
      when '>'
        rock.move_right(@rocks_in_range)
      when '<'
        rock.move_left(@rocks_in_range)
      end
      @jet_cursor = (@jet_cursor + 1) % @jets.length
    end

    def space_blocked(x,y)
      @rocks.none? { |r| r.in_space?(x,y) }
    end

    def fall(rock)
      rock.move_down(@rocks_in_range)
    end
  end

  class << self
    def part_one(input)
      PyroclasticFlow.new(input).drop_rocks(2022)
    end

    def part_two(input)
      PyroclasticFlow.new(input).drop_rocks(1000000000000)
    end
  end
end
