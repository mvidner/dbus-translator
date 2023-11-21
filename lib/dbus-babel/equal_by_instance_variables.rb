module DBusBabel
  # Define `==` by having the same class and same (==) instance variables.
  #
  # The strict comparison (`eql?`) is unchanged and will be `false`
  # for different objects.
  module EqualByInstanceVariables
    # Same instance variables and same class.
    # `expect(a).to eq(b)` in RSpec.
    def ==(other)
      return false unless other.class == self.class

      instance_variables_equal(other)
    end

    # Same instance variables and same superclass.
    # `expect(a).to match(b)` in RSpec.
    def ===(other)
      return false unless other.class.superclass == self.class.superclass

      instance_variables_equal(other)
    end

    def instance_variables_equal(other)
      instance_variables.all? do |iv|
        instance_variable_get(iv) == other.instance_variable_get(iv)
      end
    end
  end
end
