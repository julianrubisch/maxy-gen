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

  it 'should parse an object with arguments' do
    tokens = [Token.new(:identifier, 'route'),
              Token.new(:arguments, '{fps vol}'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'print'),
              Token.new(:arguments, '{named_print}')]

    tree = Parser.new(tokens).parse
    expect(tree.name).to eq('route')
    expect(tree.args).to eq('fps vol')
    expect(tree.child_nodes[0].name).to eq('print')
    expect(tree.child_nodes[0].args).to eq('named_print')
  end
end