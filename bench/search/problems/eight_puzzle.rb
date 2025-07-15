module Bench
  module Search
    module Problems
      # Classic 8-puzzle sliding tiles problem.
      class EightPuzzle
        GOAL = '123456780'.freeze
        attr_reader :start_state

        def initialize(start_state)
          @start_state = start_state
        end

        def goal?(state)
          state == GOAL
        end

        def neighbors(state)
          idx = state.index('0')
          x = idx % 3
          y = idx / 3
          n = {}
          [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]].each do |nx, ny|
            next if nx.negative? || ny.negative? || nx >= 3 || ny >= 3
            swap = ny * 3 + nx
            new_state = state.dup
            new_state[idx] = new_state[swap]
            new_state[swap] = '0'
            n[new_state] = 1
          end
          n
        end

        def heuristic(state)
          total = 0
          state.chars.each_with_index do |ch, index|
            next if ch == '0'
            goal_index = GOAL.index(ch)
            x1 = index % 3
            y1 = index / 3
            x2 = goal_index % 3
            y2 = goal_index / 3
            total += (x1 - x2).abs + (y1 - y2).abs
          end
          total
        end
      end
    end
  end
end
