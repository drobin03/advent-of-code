module Day06
  class << self
    def part_one(input)
      marker = []
      input.chars.index do |char|
        marker = [] if marker.include?(char)
        marker.append(char)
        marker.length == 4
      end + 1
    end

    def part_two(input)
      marker = []
      input.chars.index do |char|
        marker = marker.slice(marker.index(char)+1, marker.length) if marker.include?(char)
        marker.append(char)
        marker.length == 14
      end + 1
    end
  end
end
