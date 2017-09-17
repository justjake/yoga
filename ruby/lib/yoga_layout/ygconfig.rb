module YogaLayout
  module Native
    # This file contains the Yoga functions that operate primarily on YGConfigRef

    # Set this to number of pixels in 1 point to round calculation results. If
    # you want to avoid rounding - set PointScaleFactor to 0
    remember_function :YGConfigSetPointScaleFactor, [:YGConfigRef, :float], :void

    # Yoga previously had an error where containers would take the maximum
    # space possible instead of the minimum like they are supposed to. In
    # practice this resulted in implicit behaviour similar to align-self:
    # stretch; Because this was such a long-standing bug we must allow legacy
    # users to switch back to this behaviour.
    remember_function :YGConfigSetUseLegacyStretchBehaviour, [:YGConfigRef, :bool], :void

    remember_function :YGConfigNew, [], :YGConfigRef
    remember_function :YGConfigFree, [:YGConfigRef], :void
    remember_function :YGConfigCopy, [
      :YGConfigRef, # dest
      :YGConfigRef, # source
    ], :void
    remember_function :YGConfigGetInstanceCount, [], :int32_t

    remember_function :YGConfigSetExperimentalFeatureEnabled, [:YGConfigRef, :YGExperimentalFeature, :bool], :void
    remember_function :YGConfigIsExperimentalFeatureEnabled, [:YGConfigRef, :YGExperimentalFeature], :bool

    remember_function :YGConfigSetUseWebDefaults, [:YGConfigRef, :bool], :void
    remember_function :YGConfigGetUseWebDefaults, [:YGConfigRef], :bool

    # "Exported only for C#"
    # TODO: should we wrap this in the Ruby library, or not?
    remember_function :YGConfigGetDefault, [], :YGConfigRef

    remember_function :YGConfigSetContext, [:YGConfigRef, :pointer], :void
    remember_function :YGConfigGetContext, [:YGConfigRef], :pointer
  end
end
