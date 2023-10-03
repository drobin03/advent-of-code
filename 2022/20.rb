# require 'parallel'
require 'pry'
module Day20
  class Mixer
    def initialize(input, key = 1)
      @list = input.lines.map(&:to_i).each_with_index.map do |item, i|
        Struct.new(:pos, :value).new(
          i,
          item * key
        )
      end
      @sorted = @list
    end

    def mix
      @sorted = @list.inject(@sorted.dup) do |sorted, item|
        # puts sorted.map(&:value).to_s
        # puts "#{item.value} Moves"
        start = sorted.index(item)
        new_pos = (start + item.value) % (@list.length-1)
        sorted.delete_at(start)
        sorted.insert(new_pos, item)
        sorted
      end
    end
  end

  class << self
    def part_one(input)
      mixer = Mixer.new(input)
      sorted = mixer.mix
      zero = sorted.find_index { |i| i.value == 0 }
      targets = [1000,2000,3000].map { |t| (zero + t) % (sorted.length) }
      # puts targets.to_s

      values = targets.map {|t| sorted[t]}.map(&:value)
      # puts values.to_s
      values.sum
    end

    def part_two(input)
      mixer = Mixer.new(input, 811589153)
      sorted = nil
      10.times do
        sorted = mixer.mix
      end

      zero = sorted.find_index { |i| i.value == 0 }
      targets = [1000,2000,3000].map { |t| (zero + t) % (sorted.length) }
      # puts targets.to_s

      values = targets.map {|t| sorted[t]}.map(&:value)
      # puts values.to_s
      values.sum
    end
  end
end

