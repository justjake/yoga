require 'yoga_layout/wrapper'

module YogaLayout
  # Config changes the way the Yoga layout system works.
  #
  # Yoga has the concept of experiments. An experiment is a feature which is
  # not yet stable. To enable a feature use the
  # {#set_experimental_feature_enabled} method.  Once a feature has been tested
  # and is ready to be released as a stable API we will remove its feature
  # flag.
  #
  # @example Use web defaults by default
  #   YogaLayout::Config.default.set_use_web_defaults(true)
  #
  # @example Create a node tree with a custom config
  #   config = YogaLayout::Config.new
  #   node = YogaLayout::Node.new_with_config(config)
  #   node.insert_child(config.new_node, 0)
  class Config < YogaLayout::Wrapper
    # @override
    # @api private
    def self.unsafe_new_pointer
      YogaLayout::Bindings.YGConfigNew
    end

    # @override
    # @api private
    def self.unsafe_free_pointer(pointer)
      YogaLayout::Bindings.YGConfigFree(pointer)
    end

    # Use this to adjust the default settings.
    def self.default
      # Not using auto_ptr, because you can't deallocate the default config
      @default ||= new(YogaLayout::Bindings.YGConfigGetDefault)
    end

    # Convinience method to create new nodes with this config.
    #
    # @return [YogaLayout::Node]
    def new_node
      YogaLayout::Node.new_with_config(self)
    end

    map_method(:copy_from, :YGConfigCopy)

    map_method(:set_point_scaling_factor, :YGConfigSetPointScaleFactor)
    map_method(:set_use_legacy_stretch_behavior, :YGConfigSetUseLegacyStretchBehaviour)

    map_method(:set_experimental_feature_enabled, :YGConfigSetExperimentalFeatureEnabled)
    map_method(:experimental_feature_enabled?, :YGConfigIsExperimentalFeatureEnabled)

    map_method(:set_use_web_defaults, :YGConfigSetUseWebDefaults)
    map_method(:use_web_defaults?, :YGConfigGetUseWebDefaults)
  end
end
