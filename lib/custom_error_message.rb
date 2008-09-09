module ActiveRecord
  class Errors

    # Redefine the ActiveRecord::Errors::full_messages method:
    #  Returns all the full error messages in an array. 'Base' messages are handled as usual.
    #  Non-base messages are prefixed with the attribute name as usual UNLESS they begin with '^'
    #  in which case the attribute name is omitted.
    #  E.g. validates_acceptance_of :accepted_terms, :message => '^Please accept the terms of service'
    def full_messages
      full_messages = []

      @errors.each_key do |attr|
        if errors = process_error_messages(attr)
          full_messages.push *errors
        end
      end

      return full_messages
    end

    def on(attribute)
      errors = process_error_messages(attribute) or return nil
      errors.size == 1 ? errors.first : errors
    end

    private 

    def process_error_messages(attr)
      errors = @errors[attr.to_s]
      return nil if errors.nil?

      result = []
      errors.each do |msg|
        next if msg.nil?

        if attr == "base"
          result << msg
        elsif msg =~ /^\^/
          result << msg[1..-1]
        else
          result << @base.class.human_attribute_name(attr) + " " + msg
        end
      end
      result 
    end

  end
end
