require 'rails_helper'
require_dependency 'inline_oneboxer'

describe InlineOneboxer do

  it "should return nothing with empty input" do
    expect(InlineOneboxer.new([]).process).to be_blank
  end

  it "can onebox a topic" do
    topic = Fabricate(:topic)
    results = InlineOneboxer.new([topic.url]).process
    expect(results).to be_present
    expect(results[0].url).to eq(topic.url)
    expect(results[0].title).to eq(topic.title)
  end

  it "doesn't onebox private messages" do
    topic = Fabricate(:private_message_topic)
    results = InlineOneboxer.new([topic.url]).process
    expect(results).to be_blank
  end

end

