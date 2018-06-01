require "spec_helper"

include Maxy::Gen

RSpec.describe Parser do
  it 'should parse a simple input string of type a-b-c' do
    tokens = [Token.new(:identifier, 'cycle~'),
              Token.new(:dash, '-'),
              Token.new(:identifier, '*~'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'dac~')]

    tree = Parser.new(tokens).parse
    expect(tree.name).to eq('cycle~')
    expect(tree.child_nodes[0].name).to eq('*~')
    expect(tree.child_nodes[0].child_nodes[0].name).to eq('dac~')
  end
end