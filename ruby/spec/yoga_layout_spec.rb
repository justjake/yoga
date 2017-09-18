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

  it 'can print' do
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
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to be(0)
  end

  # Strict test that garbage collecting a Node instance actually deallocates
  # the underlying YGNodeRef
  it 'garbage collects' do
    ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to be(0)

    allocated = described_class.new
    ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to be(1)

    allocated = nil
    ObjectSpace.garbage_collect
    expect(YogaLayout::Bindings.YGNodeGetInstanceCount).to be(0)
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
      subject.style_set_direction(:LTR)
      expect(subject.style_get_direction).to eq(:LTR)
    end
  end
end
