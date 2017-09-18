require 'yoga_layout/wrapper'

module YogaLayout
  # TODO: document or remove support
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

    # TODO: rest of the class
  end
end
