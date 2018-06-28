require 'json'
require 'psych'

module Maxy
  module Gen
    class Generator
      OFFSET_X = 20
      OFFSET_Y = 20
      STEP_X = 70
      STEP_Y = 40
      HEIGHT = 22
      WIDTH = 50

      attr_accessor :library

      def initialize
        raise 'No object definitions were found. please run `maxy-gen install` first' unless File.exist?("#{ENV['HOME']}/.maxy-gen/library.yml")

        @object_count = 1
        @patch = Psych.load_file(File.join(__dir__, '../../../assets/blank.yml')).dup
        @library = Psych.load_file("#{ENV['HOME']}/.maxy-gen/library.yml").dup
      end

      def generate(root_node)
        return JSON.generate(@patch) if root_node.nil?

        node = align_tree(root_node.child_nodes[0])
        generate_node(node, "obj_#{@object_count}")
        @patch['patcher']['boxes'].compact!
        @patch['patcher']['lines'].compact!
        JSON.generate(@patch)
      end

      def generate_node(node, id)
        @patch['patcher']['boxes'] << make_box(node, id)
        @object_count += 1

        node.child_nodes.each_with_index do |child_node, index|
          child_id = "obj_#{@object_count}"
          generate_node(child_node, child_id)
          if node.flags.include? :connect_children_individually
            @patch['patcher']['lines'] << make_line(id, child_id, index, 0)
          elsif node.flags.include? :connect_all_child_inlets
            0.upto(child_node.args.split.count - 1) do |i|
              @patch['patcher']['lines'] << make_line(id, child_id, 0, i)
            end
          else
            @patch['patcher']['lines'] << make_line(id, child_id)
          end
        end
      end

      def make_box(node, id)
        box = @library[:objects][node.name].dup
        box['id'] = id
        box['patching_rect'] = [OFFSET_X + (node.x_rank - 1) * STEP_X, OFFSET_Y + (node.y_rank - 1) * STEP_Y, box['width'] || WIDTH, box['height'] || HEIGHT]
        box['text'] += " #{node.args}" unless box['text'].nil?

        box
      end

      def make_line(parent_id, child_id, parent_outlet = 0, child_inlet = 0)
        {
          patchline:
          {
            destination: [child_id, child_inlet],
            source: [parent_id, parent_outlet]
          }
        }
      end

      def align_tree(node, x_rank = 1, y_rank = 1)
        node.x_rank = x_rank
        node.y_rank = y_rank

        y_rank += 1

        node.child_nodes.each do |child|
          align_tree(child, x_rank, y_rank)
          x_rank += 1
        end

        node
      end
    end
  end
end
