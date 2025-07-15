module Bench
  module Search
    module Problems
      # 2D grid navigation using a simple text map.
      class Grid
        attr_reader :start_state

        def self.from_file(path)
          lines = File.readlines(path, chomp: true)
          new(lines)
        end

        def initialize(lines)
          @grid = lines.map(&:chars)
          @height = @grid.length
          @width = @grid.first.length
          @start_state = find('S')
          @goal = find('G')
        end

        def goal?(state)
          state == @goal
        end

        def neighbors(state)
          x, y = state
          n = {}
          [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]].each do |nx, ny|
            next if nx.negative? || ny.negative? || nx >= @width || ny >= @height

            cell = @grid[ny][nx]
            next if cell == '#'

            n[[nx, ny]] = 1
          end
          n
        end

        def heuristic(state)
          (state[0] - @goal[0]).abs + (state[1] - @goal[1]).abs
        end

        private

        def find(char)
          @grid.each_with_index do |row, y|
            x = row.index(char)
            return [x, y] if x
          end
          nil
        end
      end
    end
  end
end
