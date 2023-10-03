module Day03
  VALUE_HASH = (('a'..'z').to_a + ('A'..'Z').to_a).each_with_object({}).with_index {|(value, hash), i| hash[value] = i + 1 }
  class << self
    def part_one(input)
      input.lines.sum do |line|
        line_array = line.split("")
        compartment1, compartment2 = line_array.each_slice(line_array.size/2).to_a
        common = (compartment1 & compartment2).first
        VALUE_HASH[common]
      end
    end

    def part_two(input)
      input.lines.each_slice(3).sum do |group|
        group = group.map {|line| line.split("") }
        # puts "here", group[0][0], group[1][0]
        puts ""
        puts (group[0] & group[1])
        # puts group[0], group[1]
        # puts group[0] & group[1] & group[2]
        common = (group[0] & group[1] & group[2]).first
        # puts common
        VALUE_HASH[common] || 0
      end
    end
  end
end
