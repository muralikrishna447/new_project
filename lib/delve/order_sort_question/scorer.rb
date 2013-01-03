module Delve
  module OrderSortQuestion
    class Scorer
      # Public: Given a solution, constructs a scorer.
      #
      # `solution` can be an array of objects to be compared with an attempt.
      def initialize(solution)
        @solution = solution
      end

      # Public: returns true if an attempt exactly matches this solution.
      def matches?(attempt)
        @solution == attempt
      end

      # Public: given a solution attempt, it returns how far away that attempt
      # is from the actual solution.
      #
      # A distance of 0 implies an exact match, and a distance of `solution.size`
      # implies the worst score possible.
      def distance_from_solution(attempt)
        # Convert the solution attempt into an array of indexes into the @solution
        # array. We can then attempt to sort this array to determine how far an attempt
        # is from a solution.
        indexes = get_permutation(attempt)

        swaps = 0

        # Standard bubble sort.
        loop do
          swapped = false
          0.upto(indexes.size - 2) do |i|
            if indexes[i] > indexes[i + 1]
              indexes[i], indexes[i + 1] = indexes[i + 1], indexes[i]
              swapped = true
            end
          end

          if swapped
            swaps += 1
          else
            break
          end
        end

        swaps
      end

    private

      # Convert the solution attempt into an array of positions
      # based off the original @solution.
      def get_permutation(attempt)
        attempt.map { |item| @solution.index(item) }
      end
    end
  end
end
