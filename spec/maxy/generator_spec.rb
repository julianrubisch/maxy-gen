require "spec_helper"
require 'json'
require 'psych'

include Maxy::Gen

RSpec.describe Generator do

  it 'should raise an error if library is not installed' do
    allow(File).to receive(:exist?) { false }
    expect { Generator.new.generate(nil) }.to raise_error(RuntimeError)
  end

  it 'should generate the empty template if the argument is nil' do
    expect(Generator.new.generate(nil)).to eq(JSON.generate(Psych.load_file(File.join(__dir__, '../../assets/blank.yml'))))
  end

  it 'should generate two boxes and a line' do
    tree = ObjectNode.new('sig~', '100.', [ObjectNode.new('*~', '0.5', [])])
    generated = Generator.new.generate(tree)

    expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
    expect(JSON.parse(generated)['patcher']['lines']).not_to be_empty

    expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(3)
    expect(JSON.parse(generated)['patcher']['lines'].size).to eq(2)
  end

end