require "spec_helper"

RSpec.describe YogaLayout do
  it "has a version number" do
    expect(YogaLayout::VERSION).not_to be nil
  end
end

RSpec.describe YogaLayout::Bindings do
  it 'can lifecycle' do
    node = described_class.YGNodeNew
    described_class.YGNodeFree(node)
  end

  xit 'can print' do
    node = described_class.YGNodeNew
    described_class.YGNodePrint(node, 4)
    described_class.YGNodeFree(node)
  end
end

RSpec.describe YogaLayout::Node do
  subject { described_class.new }

  # Ensure we aren't leaking any native objects.
  #
  # We can't do this in an after(:each) block, because RSpec's memoizer (for
  # subject {...}) retains a reference to the `subject` during the after()
  # block.
  after(:all) do
    ::ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to eq(0)
  end

  # Strict test that garbage collecting a Node instance actually deallocates
  # the underlying YGNodeRef
  it 'garbage collects' do
    ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to eq(0)

    allocated = descrieqd_class.new
    ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to eq(1)

    allocated = nil
    ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to eq(0)
  end

  describe '#get_child_count' do
    it 'returns 0' do
      expect(subject.get_child_count).to eq(0)
    end

    context 'with a child' do
      before do
        subject.insert_child(described_class.new, 0)
      end

      it 'returns 1' do
        expect(subject.get_child_count).to eq(1)
      end
    end
  end

  describe 'fatal invariants do not abort(2) the process' do
    it 'insert child when child already has parent' do
      other_parent = described_class.new
      child = described_class.new
      other_parent.insert_child(child, 0)
      expect { subject.insert_child(child, 0) }.to raise_error(YogaLayout::Error)
    end
  end

  describe '#style_set_direction' do
    it 'can set direction' do
      subject.style_set_direction(:ltr)
      expect(subject.style_get_direction).to eq(:ltr)
    end
  end
end

RSpec.describe('examples') do
  describe('example 1') do
    # Translation of the C example into Ruby:
    #
    #   YGNodeRef root = YGNodeNew();
    #   YGNodeStyleSetWidth(root, 500);
    #   YGNodeStyleSetHeight(root, 120);
    #   YGNodeStyleSetFlexDirection(root, YGFlexDirectionRow);
    #   YGNodeStyleSetPadding(root, YGEdgeAll, 20);
    #
    #   YGNodeRef image = YGNodeNew();
    #   YGNodeStyleSetWidth(image, 80);
    #   YGNodeStyleSetMargin(image, YGEdgeEnd, 20);
    #
    #   YGNodeRef text = YGNodeNew();
    #   YGNodeStyleSetHeight(text, 25);
    #   YGNodeStyleSetAlignSelf(text, YGAlignCenter);
    #   YGNodeStyleSetFlexGrow(text, 1);
    #
    #   YGNodeInsertChild(root, image, 0);
    #   YGNodeInsertChild(root, text, 1);
    it 'works with low-level syntax' do
      root = YogaLayout::Node.new
      root.style_set_width(500)
      root.style_set_height(120)
      root.style_set_flex_direction(:row)
      root.style_set_padding(:all, 20)

      image = YogaLayout::Node.new
      image.style_set_width(80)
      image.style_set_margin(:end, 20)

      text = YogaLayout::Node.new
      text.style_set_height(25)
      text.style_set_align_self(:center)
      text.style_set_flex_grow(1)

      root.insert_child(image, 0)
      root.insert_child(text, 1)
      root.calculate_layout

      root.print(1 | 2 | 4 | 8)
    end

    it 'works with ruby syntax' do
      root = YogaLayout::Node.new.set_styles(
        width: 500,
        height: 100,
        flex_direction: :row,
        padding: 20,
      )

      image = YogaLayout::Node.new.set_styles(
        width: 80,
        margin_end: 20,
      )

      text = YogaLayout::Node.new.set_styles(
        height: 25,
        align_self: :center,
        flex_grow: 1,
      )

      root.insert_child(image, 0).insert_child(text, 1).calculate_layout
      root.print(1 | 2 | 4 | 8)
    end

    it 'works with shorthand syntax' do
      layout = YogaLayout::Node[
        width: 500,
        height: 100,
        flex_direction: :row,
        padding: 20,
        children: [
          YogaLayout::Node[
            width: 80,
            margin_end: 20,
          ],
          YogaLayout::Node[
            height: 25,
            align_self: :center,
            flex_grow: 1,
          ]
        ],
      ].print(1 | 2 | 4 | 8)
    end
  end
end
