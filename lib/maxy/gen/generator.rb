require 'json'
require 'psych'

module Maxy
  module Gen
    class Generator
      TEMPLATE = Psych.load_file(File.join(__dir__, '../../../assets/blank.yml'))
      LIBRARY = Psych.load_file(File.join(__dir__, '../../../assets/library.yml'))
      OFFSET_X = 40
      OFFSET_Y = 40
      STEP_Y = 40
      HEIGHT = 22
      WIDTH = 50

      def initialize
        @object_count = 0
        @patch = TEMPLATE

      end

      def generate(node)
        return JSON.generate(@patch) if node.nil?

        @patch['patcher']['boxes'] = []
        cycle = LIBRARY['objects']['cycle~']
        cycle['patching_rect'] = [OFFSET_X, OFFSET_Y, cycle['width'] || WIDTH, cycle['height'] || HEIGHT]
        cycle['text'] += ' 440.'
        @patch['patcher']['boxes'] << cycle
        JSON.generate(@patch)
      end
    end

    Box = Struct.new( :id,
                      :maxclass,
                      :numinlets,
                      :numoutlets,
                      :outlettype,
                      :patching_rect,
                      :style,
                      :text)
  end
end