module Changey
  class Track

    class Nothing
    end

    attr_reader :attribute
    attr_accessor :direction            # :from or :to
    attr_accessor :expected_value       # The value expected
    attr_accessor :expected_other_value # The value expected in the opposite state

    attr_accessor :validates
    attr_accessor :before_saves
    attr_accessor :after_saves
    attr_accessor :after_commits

    def initialize(attribute)
      @attribute = attribute
      @expected_other_value = Nothing
      @validates = []
      @before_saves = []
      @after_saves = []
      @after_commits = []
    end

    def run?(record)
      return false unless record.send("#{attribute}_changed?")

      previous_value = record.send("#{attribute}_was")
      current_value  = record.send(attribute)

      if expected_other_value != Nothing
        if direction == :from && previous_value == expected_value && current_value == expected_other_value
          return true
        end

        if direction == :to && current_value == expected_value && previous_value == expected_other_value
          return true
        end
      else
        if direction == :from && previous_value == expected_value
          return true
        end

        if direction == :to && current_value == expected_value
          return true
        end
      end

      return false
    end

  end
end
