require "spec_helper"
require 'json'
require 'psych'

include Maxy::Gen

RSpec.describe Generator do

  it 'should generate the empty template if the argument is nil' do
    expect(Generator.new.generate(nil)).to eq(JSON.generate(Psych.load_file(File.join(__dir__, '../../assets/blank.yml'))))
  end

  it 'should generate two boxes and a line' do
    tree = ObjectNode.new('sig~', '100.', [ObjectNode.new('*~', '0.5', [])])

    expect(JSON.parse(Generator.new.generate(tree))['patcher']['boxes']).not_to be_empty
  end

end