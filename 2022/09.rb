module Day09

  class Rope
    def initialize(knot_count = 1)
      @knots = knot_count.times.map { [0,0] }
      @head = @knots.first
      @tail_positions = [@knots.last]
    end

    def move_head(direction)
      case direction
      when 'U'
        @head[1] -= 1
      when 'D'
        @head[1] += 1
      when 'L'
        @head[0] -= 1
      when 'R'
        @head[0] += 1
      else
        throw Exception('invalid direction encountered', direction)
      end
      (1..@knots.length-1).each do |knot_index|
        move_knot_if_necessary(knot_index)
      end
    end

    def print_state
      bounds_x = (0..26) # [@head[0], @tail[0]].min..[@head[0], @tail[0]].max
      bounds_y = (-20..0) #[@head[1], @tail[1]].min..[@head[1], @tail[1]].max
      bounds_y.each do |row|
        cells = bounds_x.map do |col|
          case [col,row]
          when @head
            'H'
          when @knots.last
            'T'
          else
            @knots.index([col,row])&.to_s || '.'
          end
        end
        puts cells.join('')
      end
      puts "\n"
    end

    def knot_fell_behind?(knot_index)
      knot_before = @knots[knot_index - 1]
      knot = @knots[knot_index]
      distance = [(knot_before[0] - knot[0]).abs, (knot_before[1] - knot[1]).abs]
      distance.any? { |d| d >= 2 }
    end

    def move_knot_if_necessary(knot_index)
      return unless knot_fell_behind?(knot_index)
      knot_before = @knots[knot_index - 1]
      knot = @knots[knot_index]
      distance_x, distance_y = [(knot_before[0] - knot[0]), (knot_before[1] - knot[1])]
      if distance_x.abs > 0 && distance_y.abs > 0
        # diagonal
        move_x = distance_x > 0 ? 1 : -1
        move_y = distance_y > 0 ? 1 : -1
        move_knot(knot_index, [knot[0] + move_x, knot[1] + move_y])
      elsif distance_x.abs > 0
        # horizontal
        move = distance_x > 0 ? 1 : -1
        move_knot(knot_index, [knot[0] + move, knot[1]])
      else
        # vertical
        move = distance_y > 0 ? 1 : -1
        move_knot(knot_index, [knot[0], knot[1] + move])
      end
    end

    def move_knot(knot_index, new_pos)
      @knots[knot_index] = new_pos
      @tail_positions.append(new_pos) if knot_index == @knots.length - 1
    end

    def tail_positions
      @tail_positions
    end
  end

  class << self
    def part_one(input)
      rope = Rope.new(2)
      rope.print_state
      input.lines do |line|
        direction, amount = line.split(' ')
        puts "==== #{line.strip} ===="
        amount.to_i.times do
          rope.move_head(direction)
        end
        rope.print_state
      end
      rope.tail_positions.uniq.length
    end

    def part_two(input)
      rope = Rope.new(10)
      rope.print_state
      input.lines do |line|
        direction, amount = line.split(' ')
        puts "==== #{line.strip} ===="
        amount.to_i.times do
          rope.move_head(direction)
        end
        rope.print_state
      end
      rope.tail_positions.uniq.length
    end
  end
end
