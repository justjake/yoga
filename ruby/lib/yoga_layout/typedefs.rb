module YogaLayout
  module Native
    typedef :pointer, :YGNodeRef
    typedef :pointer, :YGConfigRef

    class Size < FFI::Struct
      layout :width, :float,
        :height, :float
    end
    typedef Size.by_value, :YGSize

    class Value < FFI::Struct
      layout :value, :float,
        :unit, :YGUnit
    end
    typedef Value.by_value, :YGValue

    callback :YGMeasureFunc, [
      :YGNodeRef,
      :float, # width
      :YGMeasureMode, # widthMode
      :float, # height
      :YGMeasureMode, # heightMode
    ], :YGSize

    callback :YGPrintFunc, [:YGNodeRef], :void

    callback :YGBaselineFunc, [
      :YGNodeRef,
      :float, # width
      :float, # height
    ], :float

    # Can't support YGLogger type because Ruby's FFI bindings don't support
    # va_args types on major platforms.
    #
    # callback :YGLogger, [
    #   :YGConfigRef,
    #   :YGNodeRef,
    #   :YGLogLevel,
    #   :string, # format
    #   :va_list, # args
    # ], :int

    # it would be crazy to actually use ruby to implement these...
    callback :YGMalloc, [:size_t], :pointer
    callback :YGCalloc, [:size_t, :size_t], :pointer
    callback :YGRealloc, [:pointer, :size_t], :pointer
    callback :YGFree, [:pointer], :void
  end
end
