require 'yoga_layout/wrapper'

module YogaLayout
  # YogaLayout::Node is the main object you will be interfacing with when using
  # Yoga in Ruby. YogaLayout::Node is a thin FFI wrapper around the core Yoga
  # library.
  #
  # Use Nodes to build up a tree that describes your layout. Set layout and
  # style properties to define your layout constraints.
  #
  # Once you have set up a tree of nodes with styles you will want to get the
  # result of a layout calculation. Call {#calculate_layout} to perform layout
  # calculation. Once this function returns the results of the layout
  # calculation is stored on each node. Traverse the tree and retrieve the
  # values from each node.
  class Node < YogaLayout::Wrapper
    # Create a new Node with a specific config.
    #
    # @param config [YogaLayout::Config]
    # @return [YogaLayout::Node]
    def self.new_with_config(config)
      new(auto_ptr(YogaLayout::Bindings.YGNodeNewWithConfig(config.pointer)))
    end

    # @override
    # @api private
    def self.unsafe_new_pointer
      YogaLayout::Bindings.YGNodeNew
    end

    # @override
    # @api private
    def self.unsafe_free_pointer(pointer)
      YogaLayout::Bindings.YGNodeFree(pointer)
    end

    def initialize(auto_ptr = nil)
      super(auto_ptr)

      @children = []
      @parent = nil
      @data = nil
      @measure_func = nil
      @baseline_func = nil
    end

    # Automagically map every YGNode* function that recieves a YGNodeRef as the
    # first value. :tada:.
    ::YogaLayout::Bindings.functions.values.each do |fn_info|
      native_name, args, return_type = fn_info
      native_name = native_name.to_s
      next unless native_name =~ /^YGNode(Style|Layout)?(Set|Get)/
      next unless args.first == :YGNodeRef

      # Don't expose methods that return pointers automatically: We should
      # always wrap those pointers in Ruby objects for safety.
      next if return_type == :YGNodeRef
      next if return_type == :YGConfigRef
      next if return_type == :pointer

      ruby_name = YogaLayout.underscore(native_name.gsub(/^YGNode/, ''))
      map_method(ruby_name.to_sym, native_name.to_sym)
    end

    def reset
      if has_children?
        raise Error, "Cannot reset a node which still has children attached"
      end

      unless parent.nil?
        raise Error, "Cannot reset a node still attached to a parent"
      end

      YogaLayout::Bindings.YGNodeReset(pointer)
      @measure_func = nil
      @baseline_func = nil
      @data = nil
    end

    def insert_child(node, idx)
      if node.parent
        raise Error, "Child #{node} already has a parent, it must be removed first."
      end

      if has_measure_func?
        raise Error, "Cannot add child: Nodes with measure functions cannot have children."
      end

      result = YogaLayout::Bindings.YGNodeInsertChild(pointer, node.pointer, idx)
      @children.insert(idx, node)
      node.parent = self
      result
    end

    def remove_child(node)
      # If asked to remove a child that isn't a child, Yoga just does nothing, so this is okay
      result = YogaLayout::Bindings.YGNodeRemoveChild(pointer, node.pointer)
      if @children.delete(node)
        node.parent = nil
      end
      result
    end

    def get_child(idx)
      ruby_child = @children[idx]
      child_pointer = YogaLayout::Bindings.YGNodeGetChild(pointer, idx)
      return nil if ruby_child.nil? && child_pointer.nil?
      unless ruby_child && ruby_child.pointer.address == child_pointer.address
        raise Error, "Ruby child #{ruby_child.inspect} (index #{idx}) does not wrap native child #{child_pointer}"
      end
      ruby_child
    end

    def get_parent
      ruby_parent = parent
      parent_pointer = YogaLayout::Bindings.YGNodeGetParent(pointer)
      return nil if ruby_parent.nil? && parent_pointer.nil?
      unless ruby_parent && ruby_parent.pointer == parent_pointer
        raise Error, "Ruby parent #{ruby_parent.inspect} does not wrap native parent #{parent_pointer}"
      end
      ruby_parent
    end

    def set_measure_func(callable = nil, &block)
      if has_children?
        raise Error, 'Cannot set measure function: Nodes with measure functions cannot have children.'
      end
      @measure_func = callable || block
      if @measure_func
        YogaLayout::Bindings.YGNodeSetMeasureFunc(pointer, native_measure_func)
      else
        YogaLayout::Bindings.YGNodeSetMeasureFunc(pointer, nil)
      end
    end

    def get_measure_func
      @measure_func
    end

    def set_baseline_func(callable = nil, &block)
      @baseline_func = callable || block
      if @baseline_func
        YogaLayout::Bindings.YGNodeSetBaselineFunc(pointer, native_baseline_func)
      else
        YogaLayout::Bindings.YGNodeSetBaselineFunc(pointer, nil)
      end
    end

    def get_baseline_func
      @baseline_func
    end

    def mark_dirty
      unless has_measure_func?
        raise Error, "Only leaf nodes with custom measure functions should manually mark themselves as diry"
      end

      YogaLayout::Bindings.YGNodeMarkDirty(pointer)
    end

    map_method(:dirty?, :YGNodeIsDirty)

    def has_measure_func?
      get_measure_func != nil
    end

    def has_children?
      get_child_count != 0
    end

    protected

    attr_accessor :parent

    def native_measure_func
      @native_measure_func ||= ::FFI::Function.new(
        :YGSize, [
          :YGNodeRef,
          :float,
          :YGMeasureMode,
          :float,
          :YGMeasureMode,
        ],
        method(:native_measure_func_callback)
      )
    end

    def native_measure_func_callback(_, widht, width_mode, height, height_mode)
      # we ignore the YGNodeRef param because we can just use "self" instead
      @measure_func.call(self, widht, width_mode, height, height_mode)
    end

    def native_baseline_func
      @native_baseline_func ||= ::FFI::Function.new(
        :float,
        [:YGNodeRef, :float, :float],
        method(:native_baseline_func_callback)
      )
    end

    def native_baseline_func_callback(_, width, height)
      @baseline_func.call(self, width, height)
    end
  end
end
