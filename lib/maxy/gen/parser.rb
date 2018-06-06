module Maxy
  module Gen
    class Parser
      def initialize(tokens)
        raise RuntimeError.new('No object definitions were found. please run `maxy-gen install` first') unless File.exist?("#{ENV['HOME']}/.maxy-gen/library.yml")

        @library = Psych.load_file("#{ENV['HOME']}/.maxy-gen/library.yml").freeze
        @tokens = tokens
      end

      def parse
        parse_obj
      end

      def parse_obj(obj_node=nil)
        return if @tokens.length == 0

        obj_name = parse_identifier

        arguments = parse_arguments || ''

        new_obj_node = ObjectNode.new(obj_name, arguments, [])
        obj_node.child_nodes << new_obj_node unless obj_node.nil?

        parse_plus(obj_node)

        parse_dash(new_obj_node)

        new_obj_node
      end

      def parse_arguments
        if peek(:arguments)
          args = consume(:arguments)
          args.value =~ /\A{([^{}]*)}\Z/
          $1
        end
      end

      def consume(expected_type)
        token = @tokens.shift
        if token.type == expected_type
          token
        else
          raise RuntimeError.new("Expected token type #{expected_type.inspect}, but got #{token.type.inspect}")
        end
      end

      def peek(expected_type)
        @tokens.length > 0 && @tokens.fetch(0).type == expected_type
      end

      def parse_identifier
        if peek(:identifier)
          obj_name = consume(:identifier).value
        else
          if peek(:escaped_identifier)
            obj_name = consume(:escaped_identifier).value
          end
        end
        raise RuntimeError.new("Could not find #{obj_name} in object definitions.") if @library[:objects][obj_name].nil?

        obj_name
      end

      def parse_plus(obj_node)
        if peek(:plus)
          consume(:plus)
          sibling_obj_name = parse_identifier
          sibling_args = parse_arguments || ''
          sibling_obj_node = ObjectNode.new(sibling_obj_name, sibling_args, [])
          obj_node.child_nodes << sibling_obj_node

          parse_plus(obj_node)

          parse_dash(sibling_obj_node)
        end
      end

      def parse_dash(obj_node)
        if peek(:dash)
          consume(:dash)
          parse_obj(obj_node)
        end
      end
    end

    ObjectNode = Struct.new(:name, :args, :child_nodes, :x_rank, :y_rank)
  end
end
