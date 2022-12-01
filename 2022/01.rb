module Day01
  class << self
    def part_one(input)
      elves = input.split("\n\n")

      summed = elves.map do |elf|
        calories = elf.split("\n").map(&:to_i).sum
      end

      puts "Max calories: #{summed.max}"
    end

    def part_two(input)
      elves = input.split("\n\n")

      summed = elves.map do |elf|
        calories = elf.split("\n").map(&:to_i).sum
      end

      puts "Top 3 total calories: #{summed.max(3).sum}"
    end
  end
end
