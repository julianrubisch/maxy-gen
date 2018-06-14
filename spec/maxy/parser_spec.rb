require "spec_helper"

include Maxy::Gen

RSpec.describe Parser do
  it 'should parse a simple input string of type a-b-c' do
    tokens = [Token.new(:identifier, 'cycle~'),
              Token.new(:dash, '-'),
              Token.new(:escaped_identifier, '\*~'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'dac~')]

    tree = Parser.new(tokens).parse
    expect(tree.child_nodes[0].name).to eq('cycle~')
    expect(tree.child_nodes[0].child_nodes[0].name).to eq('\*~')
    expect(tree.child_nodes[0].child_nodes[0].child_nodes[0].name).to eq('dac~')
  end

  it 'should parse an object with arguments' do
    tokens = [Token.new(:identifier, 'route'),
              Token.new(:arguments, '{fps vol}'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'print'),
              Token.new(:arguments, '{named_print}')]

    tree = Parser.new(tokens).parse
    expect(tree.child_nodes[0].name).to eq('route')
    expect(tree.child_nodes[0].args).to eq('fps vol')
    expect(tree.child_nodes[0].child_nodes[0].name).to eq('print')
    expect(tree.child_nodes[0].child_nodes[0].args).to eq('named_print')
  end

  it 'should raise a parsing error when an unknown object is passed' do
    tokens = [Token.new(:identifier, 'foo~'),
              Token.new(:dash, '-'),
              Token.new(:escaped_identifier, '\*~')]

    expect { Parser.new(tokens).parse }.to raise_error(RuntimeError)
  end

  it 'should parse a plus for path splitting' do
    tokens = [Token.new(:identifier, 'loadbang'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'int'),
              Token.new(:arguments, '{5}'),
              Token.new(:plus, '+'),
              Token.new(:identifier, 'int'),
              Token.new(:arguments, '{7}'),
              Token.new(:plus, '+'),
              Token.new(:identifier, 'float'),
              Token.new(:arguments, '{400.}'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'cycle~')]

    tree = Parser.new(tokens).parse
    expect(tree.child_nodes[0].name).to eq('loadbang')
    expect(tree.child_nodes[0].child_nodes.size).to eq(3)
    expect(tree.child_nodes[0].child_nodes[2].child_nodes.size).to eq(1)
  end

  it 'should parse a nested group' do
    tokens = [Token.new(:identifier, 'inlet'),
              Token.new(:dash, '-'),
              Token.new(:oparen, '('),
              Token.new(:escaped_identifier, '\*'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'outlet'),
              Token.new(:cparen, ')'),
              Token.new(:plus, '+'),
              Token.new(:oparen, '('),
              Token.new(:identifier, 'trigger'),
              Token.new(:arguments, '{b}'),
              Token.new(:dash, '-'),
              Token.new(:oparen, '('),
              Token.new(:identifier, 'outlet'),
              Token.new(:plus, '+'),
              Token.new(:identifier, 'print'),
              Token.new(:cparen, ')'),
              Token.new(:cparen, ')')]
    tree = Parser.new(tokens).parse

    expect(tree.child_nodes[0].name).to eq('inlet')
    expect(tree.child_nodes[0].child_nodes.size).to eq(2)
    expect(tree.child_nodes[0].child_nodes[0].child_nodes.size).to eq(1)
    expect(tree.child_nodes[0].child_nodes[1].child_nodes.size).to eq(2)
  end

  it 'should reject everything but a + after a group' do
    tokens = [Token.new(:identifier, 'inlet'),
              Token.new(:dash, '-'),
              Token.new(:oparen, '('),
              Token.new(:escaped_identifier, '\*'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'outlet'),
              Token.new(:cparen, ')'),
              Token.new(:dash, '-'),
              Token.new(:identifier, 'print')]

    expect { Parser.new(tokens).parse }.to raise_error(RuntimeError)
  end

  it 'should parse a row to multiple expression (=) ' do
    tokens = [Token.new(:identifier, 'trigger'),
              Token.new(:arguments, '{b b b}'),
              Token.new(:equals, '='),
              Token.new(:oparen, '('),
              Token.new(:identifier, 'int'),
              Token.new(:plus, '+'),
              Token.new(:identifier, 'int'),
              Token.new(:plus, '+'),
              Token.new(:identifier, 'int'),
              Token.new(:cparen, ')')]
    tree = Parser.new(tokens).parse

    expect(tree.child_nodes[0].name).to eq('trigger')
    expect(tree.child_nodes[0].child_nodes.size).to eq(3)
    expect(tree.child_nodes[0].flags).to include(:connect_children_individually)
    expect(tree.child_nodes[0].child_nodes[0]).to eq(ObjectNode.new('int', '', [], 0, 0, []))
    expect(tree.child_nodes[0].child_nodes[2]).to eq(ObjectNode.new('int', '', [], 0, 0, []))
  end

end