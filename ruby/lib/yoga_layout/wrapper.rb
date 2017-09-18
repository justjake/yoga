module YogaLayout
  # Abstract base class for wrapping a FFI::AutoPointer in a Ruby class
  class Wrapper
    # Create a new native object.
    # Must be implemented by a subclass.
    #
    # @abstract
    # @api private
    def self.unsafe_new_pointer
      raise ::NotImplementedError
    end

    # Free a native object as created by unsafe_new_pointer
    # Must be implemented by a subclass.
    #
    # @abstract
    # @api private
    def self.unsafe_free_pointer(pointer)
      raise ::NotImplementedError
    end

    # Convert a pointer into an AutoPointer.
    #
    # A FFI::AutoPointer automatically calls its destructor function when it
    # would be garbage collected by the Ruby runtime. By using autopointers, we
    # can extend the Ruby garbage collector to cover memory allocated by Yoga.
    #
    # Care must be taken to maintain a reference to each autopointer for as
    # long as a function could retrieve that node.
    #
    # @api private
    # @param pointer [FFI::Pointer]
    # @return [FFI::AutoPointer]
    def self.auto_ptr(pointer)
      ::FFI::AutoPointer.new(pointer, self.method(:unsafe_free_pointer))
    end

    # Define a method on this class that wraps the given YogaLayout::Binding
    # FFI function. The wrapper's {#pointer} will be passed as the first argument
    # to the FFI function.
    #
    # @api private
    # @param ruby_name [Symbol] The name of the method to define on this class.
    # @param binding_name [Sybmol] The name of the FFI function in {YogaLayout::Binding.functions}.
    def self.map_method(ruby_name, binding_name)
      info = YogaLayout::Bindings.functions.fetch(binding_name)
      _, binding_args, return_type = info
      reciever_type, *method_args = binding_args

      args_list_literal = method_args.each_with_index.map do |type, i|
        as_string = if type.is_a?(Symbol)
                 type.to_s.gsub(/^YG/, '')
               elsif type.respond_to?(:name)
                 type.name.to_s.split('::').last
               else
                 "unknown"
               end
        YogaLayout.underscore(as_string) + "_#{i}"
      end.join(', ')

      class_eval <<-EOS
        def #{ruby_name}(#{args_list_literal})
          ::YogaLayout::Bindings.#{binding_name}(pointer, #{args_list_literal})
        end
      EOS
    end

    # Create a new instane of this wrapper class.
    #
    # A new underlying native object will be created, unless you pass an
    # existing AutoPointer.
    #
    # @param auto_ptr [FFI::AutoPointer] wrap this native object
    def initialize(auto_ptr = nil)
      auto_ptr ||= self.class.auto_ptr(self.class.unsafe_new_pointer)

      unless auto_ptr.is_a?(::FFI::AutoPointer)
        raise ::TypeError, "auto_ptr must be an FFI::AutoPointer, was #{auto_ptr.inspect}"
      end

      @pointer = auto_ptr
    end

    # @api private
    attr_reader :pointer

    def ==(other)
      other.class == self.class && other.pointer.address == pointer.address
    end

    def inspect
      "#<#{self.class} pointer=#{pointer.inspect}>"
    end
  end
end
