require "yoga_layout/version"
require "yoga_layout/yoga_layout"
require "ffi"

module YogaLayout
  def self.underscore(string)
    string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      downcase
  end

  # Native is the libffi wrapper around Yoga.
  # It does not implement anything novel like memory management or nice ruby types.
  # It's just a compatibility layer.
  module Native
    extend FFI::Library
    # ref https://github.com/ffi/ffi/wiki/Loading-Libraries#in-memory-libraries
    # I think Yoga should have been loaded by the native xtension yoga_layout/yoga_layout
    ffi_lib ::FFI::USE_THIS_PROCESS_AS_LIBRARY

    # This file is auto-genrated by ../../enums.py
    require 'yoga_layout/enums'

    def self.functions
      @functions ||= {}
    end

    # Wrapper around FFI::Library.attach_function that also remembers the function
    # name and arguments for later static analysis
    def self.remember_function(*args)
      result = attach_function(*args)
      functions[args.first] = args
      result
    end


    typedef :pointer, :YGNodeRef

    # This is adapted by hand from the C API docs,
    # ref https://facebook.github.io/yoga/docs/api/c/

    # Lifecycle
    remember_function :YGNodeNew, [], :YGNodeRef
    remember_function :YGNodeReset, [:YGNodeRef], :void
    remember_function :YGNodeFree, [:YGNodeRef], :void
    remember_function :YGNodeFreeRecursive, [:YGNodeRef], :void

    # Children
    remember_function :YGNodeInsertChild, [:YGNodeRef, :YGNodeRef, :uint32_t], :void
    remember_function :YGNodeRemoveChild, [:YGNodeRef, :YGNodeRef], :void
    remember_function :YGNodeGetChild, [:YGNodeRef, :uint32_t], :YGNodeRef
    remember_function :YGNodeGetChildCount, [:YGNodeRef], :uint32_t

    # Printing (for debug???)
    remember_function :YGNodePrint, [:YGNodeRef, PrintOptions], :void
  end

  class Node
    def self.new_unsafe
      node = YogaLayout::Native.YGNodeNew
      new(node)
    end

    def initialize(pointer)
      @pointer = pointer
    end

    def self.map_method(ruby_name, native_name)
      # look up function definition info that was remembered
      info = ::YogaLayout::Native.functions[native_name]
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
                      "unknown_#{i}"
                    end

        YogaLayout.underscore(as_string)
      end.join(', ')

      class_eval <<-EOS
        def #{ruby_name}(#{args_list})
          ::YogaLayout::Native.#{native_name}(@pointer, #{args_list})
        end
      EOS
    end

    # Automagically map every function that recieves a YGNodeRef as the first
    # value.
    ::YogaLayout::Native.functions.values.each do |fn_info|
      native_name, args = fn_info
      native_name = native_name.to_s
      next unless native_name =~ /^YGNode/
      next unless args.first == :YGNodeRef

      ruby_name = YogaLayout.underscore(native_name.gsub(/^YGNode/, ''))
      map_method(ruby_name.to_sym, native_name.to_sym)
    end
  end
end
