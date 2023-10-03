require 'matrix'

BOUNDS =
module Day15
  class Map
    def initialize(input)
      @sensors = input.lines.map do |line|
        sx, sy, bx, by = line
          .scan(/-?\d+/)
          .map(&:to_i)
        {
          sensor: [sx, sy],
          beacon: [bx, by],
          radius: distance([sx, sy], [bx, by])
        }
      end
      @sensor_points = @sensors.flat_map { |s| [s[:sensor], s[:beacon]] }
      @grid = {}

      @columns = Range.new(*[
        @sensors.map {|s| s[:sensor][0] - s[:radius] }.min,
        @sensors.map {|s| s[:sensor][0] + s[:radius] }.max
      ])
      # @sensors.each do |sensor|
      #   puts "Sensor #{sensor.to_s}"
      #   plot(sensor[:sensor], sensor[:beacon])
      # end
    end

    def visualize
      Range.new(*[@grid.keys.map(&:last).min, @grid.keys.map(&:last).max]).each do |y|
        print "#{y}  "
        Range.new(*[@grid.keys.map(&:first).min, @grid.keys.map(&:first).max]).each do |x|
          print @grid[[x,y]] || '.'
        end
        print "\n"
      end
    end

    def distance(pointA, pointB)
      # ((point[0] - sensor[0]).abs + (point[1] - sensor[1]).abs)
      (pointA[0] - pointB[0]).abs + (pointA[1] - pointB[1]).abs
    end

    def fill(x, y, value)
      return unless @grid[[x,y]].nil? || @grid[[x,y]] == '.'
      @grid[[x,y]] = value
    end

    def fill_circle(center_x, center_y, radius, value)
      ((center_x - radius)..(center_x)).each_with_index do |row, remaining|
        ((center_y - remaining)..(center_y + remaining)).each do |col|
          fill(row, col, value)
        end
      end
      ((center_x)..(center_x + radius)).to_a.reverse.each_with_index do |row, remaining|
        ((center_y - remaining)..(center_y + remaining)).each do |col|
          fill(row, col, value)
        end
      end
    end

    def bound(point)
      return nil unless point[0].between?(0,4000000) && point[1].between?(0,4000000)
      point
    end

    def outline(center_x, center_y, radius)
      radius = radius + 1
      ((center_x - radius)..(center_x + radius)).flat_map do |x|
        radius_remainder = radius - (x - center_x).abs
        # puts "at #{x}, trying #{[x, (center_y - radius_remainder)]} and #{[x, (center_y + radius_remainder)]}"
        [
          [x, (center_y - radius_remainder)],
          [x, (center_y + radius_remainder)]
        ].uniq
      end
    end

    def plot(sensor, beacon)
      fill(sensor[0], sensor[1], 'S')
      fill(beacon[0], beacon[1], 'B')
      puts "Distance #{distance(sensor, beacon)}"
      # fill_circle(sensor[0], sensor[1], distance(sensor, beacon), '#')
    end

    def in_range(point, sensor, radius)
      # puts "Checking #{point.to_s} against #{sensor.to_s} w distance (#{radius}) <= #{((point[0] - sensor[0]).abs + (point[1] - sensor[1]).abs)}"
      distance(point, sensor) <= radius
    end

    def row(index)
      sensors = @sensors.flat_map { |s| [s[:sensor], s[:beacon]] }
      @columns.map do |x|
        check_point([x,index])
      end
    end

    def check_point(point)
      return 'S' if @sensor_points.include? point
      @sensors.any? { |s| in_range(point, s[:sensor], s[:radius]) } ? '#' : '.'
    end

    def single_point
      possibilities = @sensors.flat_map do |s|
        outline(s[:sensor][0], s[:sensor][1], s[:radius]).select {|p| bound(p) }
      end

      puts possibilities.to_s

      possibilities.find do |p|
        check_point(p) == '.'
      end
    end
  end
  class << self
    def part_one(input)
      return true
      map = Map.new(input)
      # map.visualize
      map.row(2000000).select { |v| v == '#' }.count # answer 5147333
    end

    def part_two(input)
      map = Map.new(input)
      point = map.single_point
      puts point.to_s
      (point[0] * 4000000) + point[1]
    end
  end
end
