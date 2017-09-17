require "spec_helper"

RSpec.describe YogaLayout do
  it "has a version number" do
    expect(YogaLayout::VERSION).not_to be nil
  end
end

RSpec.describe YogaLayout::Native do
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
  let(:native_nodes) { [] }

  def new_native_node
    node = YogaLayout::Native.YGNodeNew
    native_nodes << node
    node
  end

  after :each do
    native_nodes.each { |p| YogaLayout::Native.YGNodeFree(p) }
  end

  subject { described_class.new(new_native_node) }

  describe '#get_child_count' do
    it 'returns 0' do
      expect(subject.get_child_count).to eq(0)
    end

    context 'with a child' do
      before do
        subject.insert_child(new_native_node, 0)
      end

      it 'returns 1' do
        expect(subject.get_child_count).to eq(1)
      end
    end
  end
end
