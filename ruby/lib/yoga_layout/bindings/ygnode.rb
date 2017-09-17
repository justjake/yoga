module YogaLayout
  module Bindings
    # This file defines non-propety methods of YGNodde

    # Lifecycle
    remember_function :YGNodeNew, [], :YGNodeRef
    remember_function :YGNodeNewWithConfig, [:YGConfigRef], :YGNodeRef
    remember_function :YGNodeFree, [:YGNodeRef], :void
    remember_function :YGNodeFreeRecursive, [:YGNodeRef], :void
    remember_function :YGNodeReset, [:YGNodeRef], :void
    remember_function :YGNodeGetInstanceCount, [], :int32_t

    # Children
    remember_function :YGNodeInsertChild, [:YGNodeRef, :YGNodeRef, :uint32_t], :void
    remember_function :YGNodeRemoveChild, [:YGNodeRef, :YGNodeRef], :void
    remember_function :YGNodeGetChild, [:YGNodeRef, :uint32_t], :YGNodeRef
    remember_function :YGNodeGetParent, [:YGNodeRef], :YGNodeRef
    remember_function :YGNodeGetChildCount, [:YGNodeRef], :uint32_t

    # Layout
    remember_function :YGNodeCalculateLayout, [
      :YGNodeRef,
      :float, # availableWidth
      :float, # availibleHeight
      :YGDirection, # parentDirection
    ], :void
    # Mark a node as dirty. Only valid for nodes with a custom measure
    # function set. YG knows when to mark all other nodes as dirty but because
    # nodes with measure functions depends on information not known to YG they
    # must perform this dirty marking manually.
    remember_function :YGNodeMarkDirty, [:YGNodeRef], :void
    remember_function :YGNodeIsDirty, [:YGNodeRef], :bool

    # Printing (for debug???)
    remember_function :YGNodePrint, [:YGNodeRef, PrintOptions], :void

    remember_function :YGFloatIsUndefined, [:float], :bool

    # No idea what this is used for
    remember_function :YGNodeCanUseCachedMeasurement, [
      :YGMeasureMode, # widthMode
      :float, # width
      :YGMeasureMode, # heightMode
      :float, # height
      :YGMeasureMode, # lastWidthMode
      :float, # lastWidth
      :YGMeasureMode, # lastHeightMode
      :float, # lastHeight
      :float, # lastComputedWidth
      :float, # lastComputedHeight
      :float, # marginRow
      :float, # marginColumn
      :YGConfigRef, # config
    ], :bool

    remember_function :YGNodeCopyStyle, [
      :YGNodeRef, # destination
      :YGNodeRef, # source
    ], :void
  end
end
