require "spec_helper"

RSpec.describe Maxy::Gen::Parser do
  it 'should tokenize a simple input string of type a-b-c' do
    tokens = Tokenizer.new('cycle~-*~-dac~').tokenize
    expect(tokens.map(&:type)).to eq([:identifier, :dash, :identifier, :dash, :identifier])
    expect(tokens.map(&:value)).to eq(["cycle~", "-", "*~", "-", "dac~"])
  end

  it 'should tokenize an escaped identifier' do
    tokens = Tokenizer.new('sig~-\-~-cycle~').tokenize
    expect(tokens.map(&:type)).to eq([:identifier, :dash, :escaped_identifier, :dash, :identifier])
  end
end