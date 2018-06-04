module Maxy
  module Gen
    class Parser
      def initialize(tokens)
        @tokens = tokens
      end

      def parse
        parse_obj
      end

      def parse_obj(obj_node=nil)
        return if @tokens.length == 0

        if peek(:identifier)
          obj_name = consume(:identifier).value
        else
          if peek(:escaped_identifier)
            obj_name = consume(:escaped_identifier).value
          end
        end
        arguments = ''
        if peek(:arguments)
          arguments = parse_arguments
        end

        new_obj_node = ObjectNode.new(obj_name, arguments, [])
        obj_node.child_nodes << new_obj_node unless obj_node.nil?

        if peek(:dash)
          consume(:dash)
          parse_obj(new_obj_node)
        end

        new_obj_node
      end

      def parse_arguments
        args = consume(:arguments)
        args.value =~ /\A{([^{}]*)}\Z/
        $1
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
    end

    ObjectNode = Struct.new(:name, :args, :child_nodes)
  end
end
