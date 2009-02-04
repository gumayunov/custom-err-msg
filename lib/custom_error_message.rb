module CustomErrorMessage
  def self.included(receiver)
    receiver.send :include, InstanceMethods
    receiver.class_eval do
      alias_method_chain :full_messages, :tilde
    end
  end

  module InstanceMethods
    # Redefine the full_messages method:
    #  Returns all the full error messages in an array. 'Base' messages are handled as usual.
    #  Non-base messages are prefixed with the attribute name as usual UNLESS they begin with '^'
    #  in which case the attribute name is omitted.
    #  E.g. validates_acceptance_of :accepted_terms, :message => '^Please accept the terms of service'

    private
    def full_messages_with_tilde
      process_procs
      full_messages = full_messages_without_tilde
      full_messages.map do |message|
        if starts_with_humanized_column_followed_by_circumflex? message
          message.gsub(/^.+\^/, '')
        else
          message
        end
      end
    end

    def process_procs
      @errors.each_pair do |field, messages|
        only_string_messages = messages.map do |message|
          if message.respond_to? :to_proc
            "^#{message.to_proc.call(@base)}"
          else
            message
          end
        end

        @errors[field] = only_string_messages
      end
    end

    def starts_with_humanized_column_followed_by_circumflex?(message)
      @errors.keys.any?{|column| message.match(/^#{column.to_s.humanize} \^/)}
    end
  end
end
