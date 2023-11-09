module DBusBabel
  # Define `==` by having the same class and same (==) instance variables.
  #
  # The strict comparison (`eql?`) is unchanged and will be `false`
  # for different objects.
  module EqualByInstanceVariables
    def ==(other)
      return false if other.class != self.class

      instance_variables.all? do |iv|
        instance_variable_get(iv) == other.instance_variable_get(iv)
      end
    end
  end
end
