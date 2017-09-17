require "yoga_layout/version"
require "yoga_layout/bindings"

module YogaLayout
  def self.underscore(string)
    string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      downcase
  end

  class Node
    def self.new_unsafe
      node = YogaLayout::Bindings.YGNodeNew
      new(node)
    end

    def initialize(pointer)
      @pointer = pointer
    end

    def self.map_method(ruby_name, native_name)
      # look up function definition info that was remembered
      info = ::YogaLayout::Bindings.functions[native_name]
      if info.nil?
        raise ArgumentError, "Function #{native_name.inspect} not defined in YogaLayout::Native"
      end

      reciever, *args = info[1]
      unless reciever == :YGNodeRef
        raise ArgumentError, "Function #{native_name.inspect} does not take a YGNodeRef as arg[0]"
      end

      args_list = args.each_with_index.map do |a, i|
        as_string = if a.is_a?(Symbol)
                      a.to_s.gsub(/^YG/, '')
                    elsif a.respond_to?(:name)
                      a.name.to_s.split('::').last
                    else
                      "unknown"
                    end

        YogaLayout.underscore(as_string) + "_#{i}"
      end.join(', ')

      class_eval <<-EOS
        def #{ruby_name}(#{args_list})
          ::YogaLayout::Bindings.#{native_name}(@pointer, #{args_list})
        end
      EOS
    end

    # Automagically map every function that recieves a YGNodeRef as the first
    # value.
    ::YogaLayout::Bindings.functions.values.each do |fn_info|
      native_name, args = fn_info
      native_name = native_name.to_s
      next unless native_name =~ /^YGNode/
      next unless args.first == :YGNodeRef

      ruby_name = YogaLayout.underscore(native_name.gsub(/^YGNode/, ''))
      map_method(ruby_name.to_sym, native_name.to_sym)
    end
  end
end
