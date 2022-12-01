module Day01
  class << self
    def part_one(input)
      elves = input.split("\n\n")

      puts "Found #{elves.count} elves"
      summed = elves.map do |elf|
        calories = elf.split("\n").map(&:to_i).sum
      end

      puts "Max calories: #{summed.max}"
    end

    def part_two(input)
      elves = input.split("\n\n")

      puts "Found #{elves.count} elves"
      summed = elves.map do |elf|
        calories = elf.split("\n").map(&:to_i).sum
      end

      sorted = summed.sort.reverse
      puts sorted[0], sorted[1], sorted[2]

      puts "Total calories: #{[sorted[0], sorted[1], sorted[2]].sum}"
    end
  end
end
