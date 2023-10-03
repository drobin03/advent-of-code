module Day13

  class Packet
    def initialize(packet_string)
      @values = eval(packet_string)
    end

    def values
      @values
    end

    def <=> (p2)
      compare(values, p2.values)
    end

    def to_s
      values.to_s
    end

    def compare(a1, a2)
      if (a1.kind_of?(Integer) && a2.kind_of?(Integer))
        return -1 if a2 < a1
        return 0 if a1 == a2
        return 1 if a1 < a2
      end

      a1 = a1.kind_of?(Array) ? a1 : [a1]
      a2 = a2.kind_of?(Array) ? a2 : [a2]
      a1.each_with_index do |v1, i|
        return -1 if i >= a2.length # A2 is shorter
        return compare(v1, a2[i]) if compare(v1, a2[i]) != 0
      end
      a1.length < a2.length ? 1 : 0
    end
  end

  class << self
    def part_one(input)
      input.split("\n\n").each_with_index.select do |pair,i|
        packet1, packet2 = pair.lines(chomp: true).map { |p| Packet.new(p) }
        # puts "#{packet1.to_s} < #{packet2.to_s}: #{packet1 < packet2 ? 'yes' : 'no'}"
        (packet1 <=> packet2) > 0
      end.map { |p,i| i+1 }.sum
    end

    def part_two(input)
      packets = input
        .lines(chomp: true)
        .reject{|line| line.empty? }
        .map { |line| Packet.new(line) }
        .sort { |p1, p2| p1 <=> p2 }
        .reverse
        .map(&:values)
      (packets.index([[6]])+1) * (packets.index([[2]])+1)
    end
  end
end
