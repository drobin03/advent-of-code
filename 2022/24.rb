require 'pry'

module Day24
  class << self
    def move_wind(winds)
      winds.dup.map do |wind|
        case wind[:val]
        when '>'
          wind[:pos][0] += 1
          wind[:pos][0] = wind_bounds[0].first unless (wind_bounds[0].include? wind[:pos][0])
        when '<'
          wind[:pos][0] -= 1
          wind[:pos][0] = wind_bounds[0].last unless (wind_bounds[0].include? wind[:pos][0])
        when '^'
          wind[:pos][1] -= 1
          wind[:pos][1] = wind_bounds[1].last unless (wind_bounds[1].include? wind[:pos][1])
        when 'v'
          wind[:pos][1] += 1
          wind[:pos][1] = wind_bounds[1].first unless (wind_bounds[1].include? wind[:pos][1])
        end
        wind
      end
    end

    def wind_bounds
      [
        1..(bounds[0].last - 1),
        1..(bounds[1].last - 1),
      ]
    end

    def bounds
      @bounds ||= [
        Range.new(*@map.keys.map(&:first).minmax), #col
        Range.new(*@map.keys.map(&:last).minmax), #row
      ]
    end

    def possible_steps(from)
      [
        [from[0], from[1]-1], # up
        [from[0], from[1]+1], # down
        [from[0]-1, from[1]], # left
        [from[0]+1, from[1]], # right
        from                  # stay
      ]
    end

    def display(winds)
      bounds[1].each do |row|
        bounds[0].each do |col|
          pos = [col, row]
          w = winds.select {|w| w[:pos] == pos }
          if w.length > 0
            print w.length > 1 ? w.length : w.first[:val]
          elsif @map[pos] == '#'
            print '#'
          else
            print '.'
          end
        end
        print "\n"
      end
    end

    def distance(point1, point2)
      [
        point1[0] - point2[0],
        point1[1] - point2[1]
      ].map(&:abs).sum
    end

    def part_one(input)
      @map = input.each_with_index.inject({}) do |map, (line, row)|
        line.chars.each_with_index do |char, col|
          map[[col, row]] = char
        end
        map
      end

      start = @map.select { |pos, val| pos[1] == 0 && val == '.' }.keys.first
      finish = @map.select { |pos, val| pos[1] == bounds[1].last && val == '.' }.keys.first


      wind_positions = {}
      wind_positions[0] = @map.select { |pos, val| %w[> < ^ v].include? val }
                              .map { |pos, val| { pos: pos.dup, val: val } }

      untried_paths = [{ pos: start, minute: 0 }]
      visited_paths = {}

      # 18.times do |minute|
      #   winds = wind_positions[minute+1] ||= move_wind(wind_positions[minute])
      #   puts "=== #{minute+1} ==="
      #   display(winds)
      # end
      # return

      # puts Vector[*finish] - Vector[*start]
      # next path
      deleted  = {}
      while path = untried_paths.min_by { |p| distance(finish, p[:pos]) + (0.001 * p[:minute]) }
        minute = path[:minute] + 1

        # Remove any steps that can't possibly make it.
        if visited_paths[finish]
          shortest_possible = path[:minute] + distance(finish, path[:pos])
          if shortest_possible >= visited_paths[finish]
            # once we've reached the finish once, stop any paths that are already past that time
            untried_paths = untried_paths.reject { |p| (p[:minute] + distance(finish, p[:pos])) >= visited_paths[finish] }
            # puts "untried #{untried_paths.length}"
            # untried_paths.delete(path)
            # puts "untried #{untried_paths.length}"
            # puts "been here before #{path.to_s}" if (deleted[path])
            deleted[path] = true
            # puts "deleting #{untried_paths.length}"
            next
          end
        end

        winds = wind_positions[minute] ||= move_wind(wind_positions[minute-1])
        wind_tiles = winds.map.inject({}) do |wind_tiles, wind|
          wind_tiles[wind[:pos]] = true
          wind_tiles
        end
        # puts "=== #{minute+1} ==="
        # display(winds)

        untried_paths += possible_steps(path[:pos])
                            .reject { |s| @map[s] == '#' || @map[s].nil? } # wall, or off-board
                            .reject { |s| wind_tiles[s] } # if wind is blocking
                            .reject do |s|
                              if s == path[:pos]
                                # Don't wait:
                                # 1. If wind will take your spot (removed by condition above)
                                # 2. If no spaces were blocked by wind
                                possible_steps(path[:pos]).none? { |p| wind_tiles[p] }
                              else
                                false
                                # visited_paths[s] && visited_paths[s] <= minute # if we've already visited earlier, ignore
                              end
                            end
                            .reject do |s|
                              if visited_paths[finish]
                                # Remove if it's impossible to finish faster.
                                minute + distance(finish, s) >= visited_paths[finish]
                              else
                                false
                              end
                            end
                            .map { |s| { pos: s, prev: path, minute: minute } }
                            .map do |s|
                              # puts "adding #{s[:pos]} again: #{path.to_s}" if deleted[s]
                              s
                            end
        # binding.pry
        # puts minute, untried_paths.length
        puts "Made it in #{path[:minute]}" if path[:pos] == finish
        visited_paths[path[:pos]] = path[:minute] unless visited_paths[path[:pos]] && visited_paths[path[:pos]] > path[:minute]
        untried_paths.delete(path)
      end

      # move wind
      # choose next shortest path (up,down,l,r OR wait), add to untried
      #

      visited_paths[finish]
    end

    def part_two(input)
      raise NotImplementedError
    end
  end
end
