require "pry"

module Day11
  DIVISORS = [2, 3, 5, 7, 13, 11, 17, 19]
  class MonkeyBusiness
    def initialize(monkeys)
      @monkeys = monkeys
    end

    def perform_rounds(num)
      num.times do |i|
        puts "ROUND #{i} -----------"
        @monkeys.each do |monkey|
          monkey.items.dup.each do |item|
            # puts "Inspecting #{monkey.id} #{item} -- #{i}"
            item, throw_to = monkey.inspect_next_item.values_at(:item, :throw_to)
            throw_to(item, throw_to)
          end
        end
        # puts "Round #{i}:"
        # @monkeys.each do |m|
        #   puts "Monkey #{m.id}: #{m.items.join(', ')}"
        # end
        # return if (i == 1)
      end
    end

    def throw_to(item, id)
      # puts "Throwing #{item} to #{id}"
      # puts @monkeys.map(&:id)
      @monkeys.find { |m| m.id == id }.add_item(item)
    end

    def most_active(num)
      # puts @monkeys.sort_by { |m| m.items_inspected.length }.reverse.map { |m| m.items_inspected.length }
      @monkeys.sort_by { |m| m.items_inspected.length }.reverse.take(num)
    end
  end

  class Monkey
    def initialize(args)
      @id = args[:id]
      @items = args[:items]
      @operation = args[:operation]
      @test_divisible_by = args[:test_divisible_by]
      @true_throw_to = args[:true_throw_to]
      @false_throw_to = args[:false_throw_to]
      @items_inspected = []
    end

    def id
      @id
    end

    def items
      @items
    end

    def inspect_next_item
      item = @items.shift
      inspected = eval(@operation.gsub('old', 'item'))
      @items_inspected.append(inspected)

      inspected = inspected % DIVISORS.inject(:*)
      divisible = inspected % @test_divisible_by == 0
      { item: inspected, throw_to:  divisible ? @true_throw_to : @false_throw_to }
    end

    def add_item(item)
      @items.append(item)
    end

    def items_inspected
      @items_inspected
    end
  end

  class << self
    def part_one(input)
      monkeys = input.split("\n\n")
      monkeys = monkeys.map do |monkey|
        monkey = monkey.lines.inject({}) do |m, line|
          line = line.strip
          case line
          when /^Monkey/
            m[:id] = line.match(/Monkey ([0-9]+)/).captures[0].to_i
          when /^Starting items/
            m[:items] = line.split(':')[1].split(', ').compact.map(&:to_i)
          when /^Operation/
            m[:operation] = line.split('=')[1]
          when /^Test/
            m[:test_divisible_by] = line.match(/divisible by ([0-9]+)/).captures[0].to_i
          when /^If true/
            m[:true_throw_to] = line.split('throw to monkey')[1].to_i
          when /^If false/
            m[:false_throw_to] = line.split('throw to monkey')[1].to_i
          else
            raise Exception.new('Invalid input: ' + line)
          end
          m
        end
        Monkey.new(monkey)
      end

      mb = MonkeyBusiness.new(monkeys)
      mb.perform_rounds(20)
      mb.most_active(2).map(&:items_inspected).map(&:length).inject(:*)
    end

    def part_two(input)
      monkeys = input.split("\n\n")
      monkeys = monkeys.map do |monkey|
        monkey = monkey.lines.inject({}) do |m, line|
          line = line.strip
          case line
          when /^Monkey/
            m[:id] = line.match(/Monkey ([0-9]+)/).captures[0].to_i
          when /^Starting items/
            m[:items] = line.split(':')[1].split(', ').compact.map(&:to_i)
          when /^Operation/
            m[:operation] = line.split('=')[1]
          when /^Test/
            m[:test_divisible_by] = line.match(/divisible by ([0-9]+)/).captures[0].to_i
          when /^If true/
            m[:true_throw_to] = line.split('throw to monkey')[1].to_i
          when /^If false/
            m[:false_throw_to] = line.split('throw to monkey')[1].to_i
          else
            raise Exception.new('Invalid input: ' + line)
          end
          m
        end
        Monkey.new(monkey)
      end

      mb = MonkeyBusiness.new(monkeys)
      mb.perform_rounds(10000)
      mb.most_active(2).map(&:items_inspected).map(&:length).inject(:*)
    end
  end
end
