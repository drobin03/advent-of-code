module Day23
  class << self
    def move(elf)
      col, row = elf
      surround = {
        NW: [col-1, row-1],
        N: [col, row-1],
        NE: [col+1, row-1],
        E: [col+1, row],
        SE: [col+1, row+1],
        S: [col, row+1],
        SW: [col-1, row+1],
        W: [col-1, row]
      }
      # puts "Considering #{elf.to_s}. #{surround.values.to_s} #{surround.values.map {|s| @map[s] }.to_s}"
      return nil if surround.values.none? { |v| @map[v] == '#' } # Don't move if all surrounding spaces are empty

      @considered_directions.each do |dir|
        surround_to_check = case dir
        when :N
          [:N, :NW, :NE]
        when :S
          [:S, :SW, :SE]
        when :W
          [:W, :NW, :SW]
        when :E
          [:E, :NE, :SE]
        end
        return surround[dir] if surround_to_check.none? { |s| @map[surround[s]] == '#' }
      end
      return nil
    end

    def bounds
      elves = @map.filter { |k, v| v == '#' }.keys
      [
        Range.new(*elves.map(&:first).minmax),
        Range.new(*elves.map(&:last).minmax)
      ]
    end

    def display
      print " "
      bounds[0].each do |col|
        print col.abs
      end
      print "\n"
      bounds[1].each do |row|
        print row.abs
        bounds[0].each do |col|
          print @map[[col, row]] || '.'
        end
        print "\n"
      end
    end

    def part_one(input)
      @map = {}
      @considered_directions = [:N, :S, :W, :E]

      input.each_with_index do |line, row|
        line.chars.each_with_index do |char, col|
          @map[[col, row]] = char
        end
      end

      display

      10.times do |x|
        @moves = []
        elves = @map.filter { |k, v| v == '#' }.keys
        elves.each do |elf|
          @moves.append({ from: elf, to: move(elf) })
        end

        @moves = @moves.reject do |m|
          m[:to].nil? || @moves.select {|o| o[:to] == m[:to] }.size > 1 # remove duplicate targets
        end

        @moves.each do |move|
          @map[move[:from]] = '.'
          @map[move[:to]] = '#'
        end

        @considered_directions.append(@considered_directions.shift)
        @moves = []

        puts "======= #{x+1} ======="
        display

      end

      count = 0
      bounds[1].each do |row|
        bounds[0].each do |col|
          count += 1 if (@map[[col, row]] != '#')
        end
      end
      count
    end

    def part_two(input)
      @map = {}
      @considered_directions = [:N, :S, :W, :E]

      input.each_with_index do |line, row|
        line.chars.each_with_index do |char, col|
          @map[[col, row]] = char
        end
      end

      display

      moving = true
      round = 0
      while moving
        @moves = []
        destinations = {}
        round += 1
        elves = @map.filter { |k, v| v == '#' }.keys
        elves.each do |elf|
          to = move(elf)
          next unless to
          @moves.append({ from: elf, to: to })
          destinations[to] ||= 0
          destinations[to] += 1
        end

        @moves = @moves.reject do |m|
          destinations[m[:to]] > 1 # remove duplicate targets
        end

        @moves.each do |move|
          @map[move[:from]] = '.'
          @map[move[:to]] = '#'
        end

        moving = @moves.length > 0
        @considered_directions.append(@considered_directions.shift)
        @moves = []

        puts "======= #{round} ======="
        # display
      end

      round
    end
  end
end
