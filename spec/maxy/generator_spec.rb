require "spec_helper"
require 'json'
require 'psych'

include Maxy::Gen

RSpec.describe Generator do

  it 'should raise an error if library is not installed' do
    allow(File).to receive(:exist?) { false }
    expect { Generator.new.generate(nil) }.to raise_error(RuntimeError)
  end

  describe 'if library is present' do

    before(:each) do
      allow(File).to receive(:exist?) { true }
      allow(Psych).to receive(:load_file).with(/blank.yml/).and_return({ 'patcher' => { 'boxes' => [], 'lines' => [] } })
      allow(Psych).to receive(:load_file).with(/library.yml/).and_return({ objects: {
                'sig~' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'sig~',
                  numinlets: 1,
                  numoutlets: 1
                },
                '\*~' => {
                  maxclass: 'newobj',
                  style: '',
                  text: '*~',
                  numinlets: 2,
                  numoutlets: 1
                },
                'dac~' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'dac~',
                  numinlets: 2,
                  numoutlets: 0
                },
                'loadbang' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'loadbang',
                  numinlets: 0,
                  numoutlets: 1
                },
                'int' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'int',
                  numinlets: 2,
                  numoutlets: 1
                },
                'float' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'float',
                  numinlets: 2,
                  numoutlets: 1
                },
                'print' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'print',
                  numinlets: 1,
                  numoutlets: 0
                },
                '\*' => {
                  maxclass: 'newobj',
                  style: '',
                  text: '\*',
                  numinlets: 2,
                  numoutlets: 1
                },
                'outlet' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'outlet',
                  numinlets: 1,
                  numoutlets: 0
                },
                'trigger' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'trigger',
                  numinlets: 1,
                  numoutlets: 1
                },
                'inlet' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'inlet',
                  numinlets: 0,
                  numoutlets: 1
                },
                'select' => {
                  maxclass: 'newobj',
                  style: '',
                  text: 'select',
                  numinlets: 1,
                  numoutlets: 1
                }
            }
        })
    end

    it 'should generate the empty template if the argument is nil' do        
      expect(Generator.new.generate(nil)).to eq(JSON.generate(Psych.load_file(File.join(__dir__, '../../assets/blank.yml'))))
    end

    it 'should generate three boxes and two lines' do
      tree = RootNode.new([
                            ObjectNode.new('sig~', '100.', [
                              ObjectNode.new('\*~', '0.5', [
                                ObjectNode.new('dac~', '', [])
                              ])
                            ])
                          ])
      generator = Generator.new
      generated = generator.generate(tree)

      expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
      expect(JSON.parse(generated)['patcher']['lines']).not_to be_empty

      expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(3)
      expect(JSON.parse(generated)['patcher']['lines'].size).to eq(2)
    end

    it 'should generate three boxes and two lines out of a split path' do
        tree = RootNode.new([
                                ObjectNode.new('loadbang', '100.', [
                                    ObjectNode.new('int', '1', []),
                                    ObjectNode.new('float', '5.2', [
                                        ObjectNode.new('print', '', [])
                                    ])
                                ])
                            ])
        generator = Generator.new
        generated = generator.generate(tree)

        expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
        expect(JSON.parse(generated)['patcher']['lines']).not_to be_empty

        expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(4)
        expect(JSON.parse(generated)['patcher']['lines'].size).to eq(3)
        expect(JSON.parse(generated)['patcher']['lines'].select { |l| l['patchline']['source'][0] == 'obj_1' unless l.nil? }.size).to eq(2)
    end

    it 'should generate only unique IDs when generating two objects of the same type' do
        tree = RootNode.new([
                                ObjectNode.new('inlet', '', [
                                    ObjectNode.new('\*', '1.', [
                                        ObjectNode.new('outlet', '', [])
                                    ]),
                                    ObjectNode.new('trigger', '', [
                                        ObjectNode.new('outlet', '', [])
                                    ])
                                ])
                            ])
        generator = Generator.new
        generated = generator.generate(tree)

        duplicate_keys = JSON.parse(generated)['patcher']['boxes'].group_by { |box| box['id'] }.select { |k, v| v.size > 1 }

        expect(duplicate_keys).to be_empty
    end

    it 'should connect children individually if asked to do so' do
        tree = RootNode.new([
                                ObjectNode.new('trigger', 'b b b', [
                                    ObjectNode.new('int', '', []),
                                    ObjectNode.new('int', '', []),
                                    ObjectNode.new('int', '', [])
                                ], 0, 0, [:connect_children_individually])
                            ])
        generator = Generator.new
        generated = generator.generate(tree)

        lines = JSON.parse(generated)['patcher']['lines']

        expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
        expect(lines).not_to be_empty

        expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(4)
        expect(lines.size).to eq(3)
        expect(lines[0]['patchline']['source']).to eq(['obj_1', 0])
        expect(lines[1]['patchline']['source']).to eq(['obj_1', 1])
        expect(lines[2]['patchline']['source']).to eq(['obj_1', 2])
    end

    it 'should connect to all child nodes if asked to do so' do
      tree = RootNode.new([
                              ObjectNode.new('int', '3', [
                                  ObjectNode.new('select', '1 2 3', [])
                              ], 0, 0, [:connect_all_child_inlets])
                          ])
      generator = Generator.new
      generated = generator.generate(tree)

      lines = JSON.parse(generated)['patcher']['lines']

      expect(JSON.parse(generated)['patcher']['boxes']).not_to be_empty
      expect(lines).not_to be_empty

      expect(JSON.parse(generated)['patcher']['boxes'].size).to eq(2)
      expect(lines.size).to eq(3)
      expect(lines[0]['patchline']['source']).to eq(['obj_1', 0])
      expect(lines[1]['patchline']['source']).to eq(['obj_1', 0])
      expect(lines[2]['patchline']['source']).to eq(['obj_1', 0])
      expect(lines[0]['patchline']['destination']).to eq(['obj_2', 0])
      expect(lines[1]['patchline']['destination']).to eq(['obj_2', 1])
      expect(lines[2]['patchline']['destination']).to eq(['obj_2', 2])
    end
  end
end
