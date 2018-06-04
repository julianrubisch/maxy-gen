require 'json'
require 'psych'

module Maxy
  module Gen
    class Generator
      TEMPLATE = Psych.load_file(File.join(__dir__, '../../../assets/blank.yml')).freeze
      OFFSET_X = 20
      OFFSET_Y = 20
      STEP_Y = 40
      HEIGHT = 22
      WIDTH = 50

      attr_accessor :library

      def initialize
        raise RuntimeError.new('No object definitions were found. please run `maxy-gen install` first') unless File.exist?("#{ENV['HOME']}/.maxy-gen/library.yml")

        @object_count = 1
        @patch = TEMPLATE.freeze
        @library = Psych.load_file("#{ENV['HOME']}/.maxy-gen/library.yml").freeze
      end

      def generate(node)
        return JSON.generate(@patch) if node.nil?

        generate_node(node, "obj_#{@object_count}")
        JSON.generate(@patch)
      end

      def generate_node(node, id)
        @patch['patcher']['boxes'] << make_box(node, id)
        @object_count += 1

        node.child_nodes.each do |child_node|
          child_id = "obj_#{@object_count}"
          generate_node(child_node, child_id)
          @patch['patcher']['lines'] << make_line(id, child_id)
        end
      end

      def make_box(node, id)
        box = @library[:objects][node.name]
        box['id'] = id
        box['patching_rect'] = [OFFSET_X, OFFSET_Y + @object_count * STEP_Y, box['width'] || WIDTH, box['height'] || HEIGHT]
        unless box['text'].nil?
          box['text'] += " #{node.args}"
        end

        box
      end

      def make_line(parent_id, child_id)
        { patchline: { destination: [child_id, 0], source: [parent_id, 0]} }
      end
    end
    #
    # Box = Struct.new( :id,
    #                   :maxclass,
    #                   :numinlets,
    #                   :numoutlets,
    #                   :outlettype,
    #                   :patching_rect,
    #                   :style,
    #                   :text)
  end
end