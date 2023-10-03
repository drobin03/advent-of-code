module Day05
  class << self
    def part_one(input)
      position, moves = input.split("\n\n")

      stacks = []
      position.lines do |line|
        columns = line.chars.each_slice(4).map(&:to_s).map(&:strip)
        columns.each_with_index do |col, i|
          letter = col.gsub(/[^A-Z]/,'').strip
          stacks[i] ||= []
          stacks[i].prepend(letter) unless letter.empty?
        end
      end
      puts stacks[0]

      moves.lines do |move|
        amount, start, dest = move.match(/move (\d+) from (\d+) to (\d+)/).captures.map(&:to_i)

        amount.times do
          stacks[dest-1].append(stacks[start-1].pop)
        end
      end

      stacks.map(&:pop).join('')
    end

    def part_two(input)
      position, moves = input.split("\n\n")

      stacks = []
      position.lines do |line|
        columns = line.chars.each_slice(4).map(&:to_s).map(&:strip)
        columns.each_with_index do |col, i|
          letter = col.gsub(/[^A-Z]/,'').strip
          stacks[i] ||= []
          stacks[i].prepend(letter) unless letter.empty?
        end
      end
      puts stacks[0]

      moves.lines do |move|
        amount, start, dest = move.match(/move (\d+) from (\d+) to (\d+)/).captures.map(&:to_i)

        stacks[dest-1].concat(stacks[start-1].pop(amount))
      end

      stacks.map(&:pop).join('')
    end
  end
end
