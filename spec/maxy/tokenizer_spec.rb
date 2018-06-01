require "spec_helper"

RSpec.describe Maxy::Gen::Parser do
  it 'should tokenize a simple input string of type a-b-c' do
    tokens = Tokenizer.new('a-b-c').tokenize
    expect(tokens.map(&:type)).to eq([:identifier, :dash, :identifier, :dash, :identifier])
    expect(tokens.map(&:value)).to eq(['a', '-', 'b', '-', 'c'])
  end
end