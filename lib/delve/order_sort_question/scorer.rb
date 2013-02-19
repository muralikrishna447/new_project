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

      # Public: given a solution attempt, it scores it against the actual solution and
      # returns the score, bounded between [0.0, 1.0].
      #
      # A score of 1.0 is a perfect 100%, and a score of 0.0 is a 0%.
      def solution_score(attempt)
        if attempt.size != @solution.size
          raise "user attempt had a different number of items from the solution"
        end

        count = attempt.size

        possible_correct = 0
        correct = 0

        (0..(count - 2)).each do |i|
          ((i + 1)..(count - 1)).each do |j|
            possible_correct += 1
            a = @solution[i]
            b = @solution[j]
            correct += 1 if attempt.index(a) < attempt.index(b)
          end
        end

        if possible_correct.zero?
          # avoid div by zero
          0.0
        else
          correct.to_f / possible_correct
        end
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
