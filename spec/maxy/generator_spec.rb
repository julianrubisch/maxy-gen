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

  it 'should generate three boxes and two lines' do
    tree = ObjectNode.new('sig~', '100.', [ObjectNode.new('\*~', '0.5', [ObjectNode.new('dac~', '', [])])])
    generator = Generator.new
    generated = generator.generate(tree)

    expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
    expect(JSON.parse(generated)['patcher']['lines']).not_to be_empty

    expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(4)
    expect(JSON.parse(generated)['patcher']['lines'].size).to eq(3)
  end

  it 'should generate three boxes and two lines out of a split path' do
    tree = ObjectNode.new('loadbang', '100.', [ObjectNode.new('int', '1', []), ObjectNode.new('float', '5.2', [ObjectNode.new('print', '', [])])])
    generator = Generator.new
    generated = generator.generate(tree)

    expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
    expect(JSON.parse(generated)['patcher']['lines']).not_to be_empty

    expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(5)
    expect(JSON.parse(generated)['patcher']['lines'].size).to eq(4)
    expect(JSON.parse(generated)['patcher']['lines'].select { |l| l['patchline']['source'][0] == 'obj_1' unless l.nil? }.size).to eq(2)

  end


end