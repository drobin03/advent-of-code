require 'parallel'

module Day19
  class << self
    def part_one(input)
      blueprints = input.lines(chomp: true).map do |line|
        # Blueprint 1: Each ore robot costs 2 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 20 clay. Each geode robot costs 3 ore and 14 obsidian.
        costs = {
          ore: { ore: nil },
          clay: { ore: nil },
          obsidian: { ore: nil, clay: nil },
          geode: { ore: nil, obsidian: nil }
        }
        id, costs[:ore][:ore], costs[:clay][:ore], costs[:obsidian][:ore], costs[:obsidian][:clay], costs[:geode][:ore], costs[:geode][:obsidian] = line.scan(/\d+/).map(&:to_i)
        Blueprint.new(id, costs)
      end
      Parallel.map(blueprints, &:quality).sum
    end

    def part_two(input)
      raise NotImplementedError
    end
  end
end


class Resources < Struct.new(:ore, :clay, :obsidian, :geode)

  def Resources.[](ore: 0, clay: 0, obsidian: 0, geode: 0)
    new(ore, clay, obsidian, geode)
  end

  def +(other)
    Resources.new(*values.zip(other.values).map { |v1, v2| v1 + v2 })
  end

  def -(other)
    Resources.new(*values.zip(other.values).map { |v1, v2| v1 - v2 })
  end

  def >=(other)
    values.zip(other.values).all? { |v1, v2| v1 >= v2 }
  end

  def each
    yield :geode, geode
    yield :obsidian, obsidian
    yield :clay, clay
    yield :ore, ore
  end

end

######################################################################

class State < Struct.new(:minutes, :resources, :production)

  def produce
    State.new(minutes - 1, resources + production, production)
  end

  def add_production(cost, new_production)
    State.new(minutes, resources - cost, production + new_production)
  end

  def max_geode_possible
    resources.geode + production.geode * minutes  + (minutes * (minutes + 1) / 2)
  end

end

######################################################################

class Blueprint

  ROBOTS = Resources.new(
    Resources[ore: 1],
    Resources[clay: 1],
    Resources[obsidian: 1],
    Resources[geode: 1],
  )

  attr_reader :id

  def initialize(id, robot_costs = {
    ore: { ore: 2 },
    clay: { ore: 4 },
    obsidian: { ore: 4, clay: 20 },
    geode: { ore: 3, obsidian: 14 }
  })
    @id = id
    @build_costs = Resources.new(
      Resources[ore: robot_costs[:ore][:ore]],
      Resources[ore: robot_costs[:clay][:ore]],
      Resources[ore: robot_costs[:obsidian][:ore], clay: robot_costs[:obsidian][:clay]],
      Resources[ore: robot_costs[:geode][:ore], obsidian: robot_costs[:geode][:obsidian]],
    )

    @max_necessary = Resources.new(
      @build_costs.values.map(&:ore).max,
      @build_costs.values.map(&:clay).max,
      @build_costs.values.map(&:obsidian).max,
      Float::INFINITY,
    )
  end

  def quality
    id * max_geode(24)
  end

  def max_geode(minutes = 32)
    @max_geode = 0
    check_options(State.new(minutes, Resources[], ROBOTS.ore))
    @max_geode
  end

  def check_options(state)
    @max_geode = state.resources.geode if @max_geode < state.resources.geode

    # Rule: Stop when it's time to stop!
    return if state.minutes <= 0

    # Optimization: If we can't possibly produce enough geode in the time
    # left to beat the maximum already found, then skip it.
    return if state.max_geode_possible < @max_geode

    next_state = state.produce

    @build_costs.each do |robot_type, cost|
      # Rule: Make sure we can afford to build the robot
      next unless state.resources >= cost

      # Optimization: Don't bother building robots if we already produce
      # enough of a given resource to buy whatever we need.
      next if state.production[robot_type] >= @max_necessary[robot_type]

      check_options(next_state.add_production(cost, ROBOTS[robot_type]))

      # Optimization: If we have an option to build a high value robot
      # assume that is always the best option and ignore other build
      # options. This WILL fail in some cases (in partciular the example)
      # but seems to works with the real input.
      break if %i[geode obsidian].include?(robot_type)
    end

    # Optimization: If we had enough ore to buy anything we want,
    # then we should have built something - no need to consider a
    # "produce only" option.
    return if state.resources.ore >= @max_necessary.ore

    check_options(next_state)
  end

end

######################################################################

# solve_with_format([Blueprint], EXAMPLE => 33) do |blueprints|
#   Parallel.map(blueprints, &:quality).sum
# end

# solve_with_format([Blueprint]) do |blueprints|
#   Parallel.map(blueprints.first(3), &:max_geode).reduce(:*)
# end
