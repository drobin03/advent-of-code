module Day02
  class << self
    def part_one(input)
      value_map = {
        'A' => 1, # rock
        'B' => 2, # paper
        'C' => 3, # scissors
        'X' => 1, # rock
        'Y' => 2, # paper
        'Z' => 3, # scissors
      }
      input.lines.sum do |line|
        their_move, your_move = line.split(' ').map { |move| value_map[move] }
        result = (your_move - their_move) % 3
        score = case result
          when 0
            3
          when 1
            6
          else
            0
        end
        score + your_move
      end
    end

    def part_two(input)
      moves =[
        'A',
        'B',
        'C',
      ]
      value_map = {
        'A' => 0, # rock
        'B' => 1, # paper
        'C' => 2, # scissors
        'X' => 0, # lose
        'Y' => 3, # draw
        'Z' => 6, # wiin
      }
      input.lines.sum do |line|
        their_move, score = line.split(' ').map { |move| value_map[move] }

        your_move = case score
        when 0
          (their_move + 2) % 3
        when 3
          their_move
        when 6
          (their_move + 1) % 3
        end
        # puts "#{line.split(' ').map { |move| MOVE_MAP[move] }.reverse} : #{score} + #{your_move}"
        score + your_move + 1
      end
    end
  end
end
