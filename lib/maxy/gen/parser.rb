module Maxy
  module Gen
    class Parser
      def initialize(tokens)
        raise RuntimeError.new('No object definitions were found. please run `maxy-gen install` first') unless File.exist?("#{ENV['HOME']}/.maxy-gen/library.yml")

        @library = Psych.load_file("#{ENV['HOME']}/.maxy-gen/library.yml").freeze
        @tokens = tokens
        @tree = RootNode.new([])
        @groups = []
      end

      def parse(parent_node=@tree, closing_group=false)
        if closing_group
          if peek(:dash) || peek(:identifier) || peek(:escaped_identifier)
            raise RuntimeError.new("Parsing Error: only + is allowed after a ) closing a group.")
          end
        else
          parse_begin_group parent_node
          child_node = parse_identifier parent_node
          parse_less_than child_node
          parse_equals child_node
          parse_dash child_node
        end

        parse_plus parent_node

        parse_end_group
      end

      def parse_begin_group(parent)
        if peek(:oparen)
          consume(:oparen)
          @groups << parent
        end
      end

      def parse_end_group
        return @tree if @tokens.empty?
        if peek(:cparen)
          consume(:cparen)
          parse(@groups.pop, true)
        end
      end

      def parse_identifier(parent)
        if peek(:identifier)
          obj_name = consume(:identifier).value
        elsif peek(:escaped_identifier)
          obj_name = consume(:escaped_identifier).value
        end

        arguments = parse_arguments || ''

        raise RuntimeError.new("Could not find #{obj_name} in object definitions.") if @library[:objects][obj_name].nil?

        new_obj_node = ObjectNode.new(obj_name, arguments, [])
        parent.child_nodes << new_obj_node

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

      def parse_plus(obj_node)
        if peek(:plus)
          consume(:plus)
          parse(obj_node)
        end
      end

      def parse_dash(obj_node)
        if peek(:dash)
          consume(:dash)
          parse(obj_node)
        end
      end

      def parse_equals(obj_node)
        if peek(:equals)
          consume(:equals)
          obj_node.flags << :connect_children_individually
          parse(obj_node)
        end
      end

      def parse_less_than(obj_node)
        if peek(:less_than)
          consume(:less_than)
          obj_node.flags << :connect_all_child_inlets
          parse(obj_node)
        end
      end
    end

    ObjectNode = Struct.new(:name, :args, :child_nodes, :x_rank, :y_rank, :flags) do
      def initialize(name, args, child_nodes, x_rank=0, y_rank=0, flags=[])
        super
      end
    end
    RootNode = Struct.new(:child_nodes)

  end
end
