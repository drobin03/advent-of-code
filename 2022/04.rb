module Day04
  class << self
    def part_one(input)
      ranges = input.lines.map do |line|
        sections = line.split(',')
        sections.map { |s| Range.new(*s.split('-').map(&:to_i)) }
      end

      ranges.select do |range1, range2|
        covers = range1.cover?(range2) || range2.cover?(range1)
        if (covers)
          # puts range1.to_s + " Covers " range2.to_s
        else
          puts range1.to_s + " NO Covers " + range2.to_s
        end

        # overlap = range.any? do |r|
        #   big_ranges.flatten.any? {|t| (t.cover? r) || (r.cover? t) }
        # end
        # big_ranges += range
        # overlap\
        covers
      end.length
    end

    def part_two(input)
      ranges = input.lines.map do |line|
        sections = line.split(',')
        sections.map { |s| Range.new(*s.split('-').map(&:to_i)) }
      end

      ranges.select do |range1, range2|
        range1.first <= range2.last && range2.first <= range1.last
      end.length
    end
  end
end
