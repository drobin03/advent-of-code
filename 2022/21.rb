module Day21
  class << self

    class MonkeyMath
      attr_accessor :monkeys

      def initialize(input)
        @monkeys = input.lines(chomp: true).inject({}) do |monkeys, line|
          name, rest =  line.split(': ')
          if rest.match(/^\d+$/)
            value = rest.to_i
          else
            m1, operation, m2 = rest.split(' ')
          end
          monkeys[name] = {
            value: value,
            m1: m1,
            m2: m2,
            operation: operation
          }
          monkeys
        end
      end

      def value(monkey_name)
        monkey = @monkeys[monkey_name]
        # return monkey[:value] if monkey[:value]
        monkey[:value] ||= eval [value(monkey[:m1]), monkey[:operation], value(monkey[:m2])].join()
      end

      def reverse_value_lookup(monkey_name)
        parent_key, monkey = @monkeys.find { |k, m| [m[:m1], m[:m2]].include? monkey_name }

        # 10 = x / 5
        # x = 10 * 5
        # 10 = 5 / x
        # x = 5 / 10
        other_monkey = monkey[:m1] == monkey_name ? monkey[:m2] : monkey[:m1]
        if (monkey[:operation] == '=')
          value(other_monkey)
        else
          val = nil
          case monkey[:operation]
          when '*', '+'
            val = eval [
              reverse_value_lookup(parent_key),
              reverse_operation(monkey[:operation]),
              value(other_monkey)
            ].join()
            op = [
              monkey_name,
              '=',
              parent_key,
              reverse_operation(monkey[:operation]),
              other_monkey
            ].join(' ')
          when '/', '-'
            if (monkey_name == monkey[:m1])
              val = eval [
                reverse_value_lookup(parent_key),
                reverse_operation(monkey[:operation]),
                value(other_monkey)
              ].join()
              op = [
                monkey_name,
                '=',
                parent_key,
                reverse_operation(monkey[:operation]),
                other_monkey
              ].join(' ')
            else
              val = eval [
                value(other_monkey),
                monkey[:operation],
                reverse_value_lookup(parent_key),
              ].join()
              op = [
                monkey_name,
                '=',
                other_monkey,
                monkey[:operation],
                parent_key,
              ].join(' ')
            end
          end
          puts [parent_key, '=', monkey[:m1], monkey[:operation], monkey[:m2]].join(' ')
          puts op
          puts "===="
          val
        end
      end

      def reverse_operation(operation)
        [
          ['*', '/'],
          ['+', '-'],
        ].inject({}) do |opposites, (op1, op2)|
          opposites[op1] = op2
          opposites[op2] = op1
          opposites
        end[operation]
      end
    end

    def part_one(input)
      mm = MonkeyMath.new(input)
      mm.value('root')
    end

    def part_two(input)
      mm = MonkeyMath.new(input)
      mm.monkeys['root'][:operation] = '='
      mm.monkeys['humn'][:value] = nil
      mm.reverse_value_lookup('humn')
    end
  end
end
