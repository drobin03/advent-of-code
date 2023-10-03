require 'pry'

module Day19
  class Blueprint
    attr_reader :id

    def initialize(id, robot_costs = {
      ore: { ore: 2 },
      clay: { ore: 4 },
      obsidian: { ore: 4, clay: 20 },
      geode: { ore: 3, obsidian: 14 }
    })
      @id = id
      @robot_costs = robot_costs
      @building = nil
      @rounds = []
    end

    def run(minutes = 24)
      @total_minutes = minutes
      @untried_rounds = [
        {
          minute: 1,
          balance: {
            ore: 0,
            clay: 0,
            obsidian: 0,
            geode: 0
          },
          robots: {
            ore: 1,
            clay: 0,
            obsidian: 0,
            geode: 0
          },
          build: nil
        }
      ]
      @current_max = 0

      while @current_round = @untried_rounds.max_by { |r| weighted_balance(r[:balance], r[:robots], r[:build]) }
        # puts "Round #{@current_minute}. Trying #{@current_round[:build]}"
        @current_minute =  @current_round[:minute]
        @balance =  @current_round[:balance]
        @robots =  @current_round[:robots]
        @rounds << @current_round
        @untried_rounds.delete(@current_round)

        puts "#{id} Minute: #{@current_minute}. Build #{@current_round[:build]}. Robots #{@current_round[:robots].to_s}. Balance #{@current_round[:balance].to_s}" if @current_minute < 4

        next unless can_beat_current_max?

        # puts "Minute: #{@current_minute}. Build #{@current_round[:build]}. Robots #{@current_round[:robots].to_s}. Balance #{@current_round[:balance].to_s}" if @current_minute < 3
        build(@current_round[:build]) if @current_round[:build]

        mine

        if (@building)
          @robots[@building] += 1
          @building = nil
        end

        @current_max = @current_round[:balance][:geode] if (@current_round[:balance][:geode] > @current_max)
        if @current_minute >= minutes
          next
        end

        if afford?(:geode)
          schedule_build(:geode)
          next
        elsif afford?(:obsidian)
          need_more_obsidian = @robots[:obsidian] < @robot_costs[:geode][:obsidian]
          if need_more_obsidian
            schedule_build(:obsidian)
            # schedule_build(nil) if @current_round[:balance][:ore] < [@robot_costs[:ore][:ore], @robot_costs[:clay][:ore], @robot_costs[:obsidian][:ore], @robot_costs[:geode][:ore]].max
            # schedule_build(nil)
            next
          end
        end

        # If a certain robot could have been bought in the previous round – but no robot was bought in that round, then we don't need to buy it now. Saving only makes sense for another robot.
        # At the last minute, we do not need to produce a robot.
        # In the penultimate minute, we only need to produce geode robots.
        minutes_left = minutes - @current_minute
        next if (minutes_left <= 2)

        # In the pre-penultimate minute, we only need to produce geode, ore, or obsidian robots (i.e., no clay robots).
        need_more_clay = @robots[:clay] < @robot_costs[:obsidian][:clay] && minutes_left > 3
        need_more_ore = @robots[:ore] < [@robot_costs[:obsidian][:ore], @robot_costs[:geode][:ore]].max
        schedule_build(:clay) if afford?(:clay) && need_more_clay #&& @current_minute < 15
        # puts "ORE? #{afford?(:ore)} #{need_more_ore}" if @current_minute< 4
        schedule_build(:ore) if afford?(:ore) && need_more_ore # && @current_minute < 15
        schedule_build(nil) #if @current_round[:balance][:ore] < [@robot_costs[:ore][:ore], @robot_costs[:clay][:ore], @robot_costs[:obsidian][:ore], @robot_costs[:geode][:ore]].max #|| @current_round[:balance][:clay] < @robot_costs[:obsidian][:clay]
      end
    end

    def can_beat_current_max?
      rounds_left = (@total_minutes - @current_minute) + 1
      max_from_current = (rounds_left * @current_round[:robots][:geode]) + @current_round[:balance][:geode]
      max_from_possible_additions = rounds_left.times.sum {|r| r+1 }
      max_from_current + max_from_possible_additions > @current_max
    end

    def weighted_balance(balance, robots, build)
      weights = {
        geode: 100,
        obsidian: 10,
        clay: 2,
        ore: 1
      }
      balance.sum { |k, v| weights[k] * v } + robots.sum { |k, v| weights[k] * v } + (build ? 1 : 0)
    end

    def schedule_build(robot_type)
      @untried_rounds << {
        minute: @current_minute + 1,
        balance: @balance.dup,
        robots: @robots.dup,
        build: robot_type,
        previous_round: @current_round
      }
    end

    def best_path
      best = @rounds.map{ |r| r[:balance][:geode] }.max
      puts "#{@rounds.select { |r| r[:minute] == 24 && r[:balance][:geode] >= best }.count} best paths"
      # binding.pry
      # finish = @rounds.select { |r| r[:minute] == 24 }.max_by { |r| r[:balance][:geode] }
      finish = @rounds.select { |r| r[:minute] == 24 && r[:balance][:geode] >= best }.sample
      return unless finish

      r = finish
      path = [r]
      while r = r[:previous_round]
        path.prepend(r)
      end
      path
    end

    def max_geodes
      @rounds.select { |r| r[:minute] == 24 }.map { |r| r[:balance][:geode] }.max || 0
    end

    def mine
      @robots.each do |type, amount|
        @balance[type] += amount
      end
    end

    def build(robot)
      # puts "Minute #{@current_minute}: Building #{robot}"
      @building = robot
      cost = @robot_costs[robot]
      cost.each do |type, amount|
        @balance[type] -= amount
      end
    end

    def afford?(robot)
      cost = @robot_costs[robot]
      # puts "#{id} Minute: #{@current_minute}. Cost #{cost} Balance #{@current_round[:balance].to_s}" if @current_minute < 3 && robot == :ore
      cost.all? { |type, amount| @balance[type] >= amount }
    end
  end
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

      blueprints.each(&:run)

      puts "Done running"
      blueprints.each do |b|
        puts "ID: #{b.id}: #{b.max_geodes}"
        b.best_path&.each do |r|
          puts "Minute: #{r[:minute]}. Build #{r[:build]}. Robots #{r[:robots].to_s}. Balance #{r[:balance].to_s}"
        end
      end

      blueprints.map { |b| b.max_geodes * b.id }.sum
    end

    def part_two(input)

    end
  end
end
