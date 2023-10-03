module Day10
  class << self
    def part_one(input)
      current_x = 1
      cycles = input.lines.map(&:chomp).inject([]) do |cycles, line|
        case line
        when 'noop'
          cycles.append(current_x)
        when /addx/
          2.times do
            cycles.append(current_x)
          end
          change = line.split(' ')[1].to_i
          current_x = current_x + change
        else
          raise Exception.new("Invalid cmd received: " + line)
        end
        cycles
      end
      signals = cycles.each_with_index.filter_map do |cycle, index|
        cycle_num = index + 1
        cycle * cycle_num if cycle_num % 40 == 20
      end
      signals.sum
    end

    def part_two(input)
      current_x = 1
      cycles = input.lines.map(&:chomp).inject([]) do |cycles, line|
        case line
        when 'noop'
          cycles.append(current_x)
        when /addx/
          2.times do
            cycles.append(current_x)
          end
          change = line.split(' ')[1].to_i
          current_x = current_x + change
        else
          raise Exception.new("Invalid cmd received: " + line)
        end
        cycles
      end

      print_screen(cycles)
    end

    def print_screen(cycles)
      dimensions = [6, 40]
      cycle = 0
      (1..dimensions[0]).each do |row|
        (1..dimensions[1]).each do |col|
          pixel_i = (row * col) - 1
          x = cycles[cycle]
          cycle = cycle + 1
          lit = [x-1, x, x+1].include?(col-1)
          print lit ? '⬜' : '  '
          sleep(0.005)
        end
        print "\n"
      end
    end
  end
end
