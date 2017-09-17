require "ffi"
module YogaLayout
  module Native
    Align = enum(
      :Auto,
      :FlexStart,
      :Center,
      :FlexEnd,
      :Stretch,
      :Baseline,
      :SpaceBetween,
      :SpaceAround,
    )

    Dimension = enum(
      :Width,
      :Height,
    )

    Direction = enum(
      :Inherit,
      :LTR,
      :RTL,
    )

    Display = enum(
      :Flex,
      :None,
    )

    Edge = enum(
      :Left,
      :Top,
      :Right,
      :Bottom,
      :Start,
      :End,
      :Horizontal,
      :Vertical,
      :All,
    )

    ExperimentalFeature = enum(
      :WebFlexBasis,
    )

    FlexDirection = enum(
      :Column,
      :ColumnReverse,
      :Row,
      :RowReverse,
    )

    Justify = enum(
      :FlexStart,
      :Center,
      :FlexEnd,
      :SpaceBetween,
      :SpaceAround,
    )

    LogLevel = enum(
      :Error,
      :Warn,
      :Info,
      :Debug,
      :Verbose,
      :Fatal,
    )

    MeasureMode = enum(
      :Undefined,
      :Exactly,
      :AtMost,
    )

    NodeType = enum(
      :Default,
      :Text,
    )

    Overflow = enum(
      :Visible,
      :Hidden,
      :Scroll,
    )

    PositionType = enum(
      :Relative,
      :Absolute,
    )

    PrintOptions = enum(
      :Layout, 1,
      :Style, 2,
      :Children, 4,
    )

    Unit = enum(
      :Undefined,
      :Point,
      :Percent,
      :Auto,
    )

    Wrap = enum(
      :NoWrap,
      :Wrap,
      :WrapReverse,
    )

  end
end
