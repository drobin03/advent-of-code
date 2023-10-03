require 'matrix'
require 'pry'

module Day08
  class << self
    def part_one(input)
      grid = Matrix[*input.lines.reject(&:empty?).map { |line| line.strip.split('').map(&:to_i) }]
      visible = grid.each_with_index.select do |tree, row_i, col_i|
        row = grid.row(row_i)
        col = grid.column(col_i)
        next true if (row_i == 0 || row_i == row.size-1 || col_i == 0 || col_i == col.size-1)
        min = [
          row[0..col_i-1].max,
          row[col_i+1..row.size-1].max,
          col[0..row_i-1].max,
          col[row_i+1..col.size-1].max,
        ].min
        tree > min
      end
      visible.length
    end

    def visible(tree, list)
      return 0 if list.empty?
      visible = list.take_while { |el| tree > el }.length
      visible < list.length ? visible + 1 : visible
    end

    def part_two(input)
      grid = Matrix[*input.lines.reject(&:empty?).map { |line| line.strip.split('').map(&:to_i) }]
      grid.each_with_index.map do |tree, row_i, col_i|
        row = grid.row(row_i)
        col = grid.column(col_i)

        score = [
          visible(tree, row[0..col_i-1].reverse),
          visible(tree, row[col_i+1..row.size-1]),
          visible(tree, col[0..row_i-1].reverse),
          visible(tree, col[row_i+1..col.size-1]),
        ].inject(:*)

        # puts "Tree (#{row_i}, #{col_i}): #{score}"
        # puts [
        #   visible(tree, row[0..col_i-1].reverse),
        #   visible(tree, row[col_i+1..row.size-1]),
        #   visible(tree, col[0..row_i-1].reverse),
        #   visible(tree, col[row_i+1..col.size-1]),
        # ]
        score
      end.max
    end
  end
end
