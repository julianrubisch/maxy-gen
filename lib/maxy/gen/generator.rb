require 'json'
require 'psych'

module Maxy
  module Gen
    class Generator
      TEMPLATE = Psych.load_file(File.join(__dir__, '../../../assets/blank.yml'))

      def initialize
        @object_count = 0
        @patch = TEMPLATE
      end

      def generate(node)
        return JSON.generate(@patch) if node.nil?

        @patch['patcher']['boxes'] = []
        @patch['patcher']['boxes'] << 'test'
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