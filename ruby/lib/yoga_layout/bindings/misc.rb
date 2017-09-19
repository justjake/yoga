module YogaLayout
  module Bindings
    # Disabled, because YGLogger type is unsupported by Ruby's FFI
    # remember_function :YCConfigSetLogger, [:YGConfigRef, :YGLogger], :void
    remember_function :YGLog, [:YGNodeRef, :YGLogLevel, :string, :varargs], :void
    remember_function :YGLogWithConfig, [:YGConfigRef, :YGLogLevel, :string, :varargs], :void
    remember_function :YGAssert, [:bool, :string], :void
    remember_function :YGAssertWithNode, [:YGNodeRef, :bool, :string], :void
    remember_function :YGAssertWithConfig, [:YGConfigRef, :bool, :string], :void

    # Disabled, because YGLogger type is unsupported by Ruby's FFI
    # rememebr_function :YGConfigSetLogger, [:YGConfigRef, :YGLogger], :void
    remember_function :YGLog, [:YGNodeRef, :YGLogLevel, :string, :varargs], :void
    remember_function :YGLogWithConfig, [:YGConfigRef, :YGLogLevel, :string, :varargs], :void
    remember_function :YGAssert, [:bool, :string], :void
    remember_function :YGAssertWithNode, [:YGNodeRef, :bool, :string], :void
    remember_function :YGAssertWithConfig, [:YGConfigRef, :bool, :string], :void

    remember_function :YGSetMemoryFuncs, [:YGMalloc, :YGCalloc, :YGRealloc, :YGFree], :void

    remember_function :YGFloatIsUndefined, [:float], :bool
  end
end
