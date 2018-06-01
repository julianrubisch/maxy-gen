require 'thor'
require 'psych'
require 'json'
require 'maxy/gen'

module Maxy
  module Gen
    class CLI < Thor
      desc "generate PATTERN", "Generates a Max Patch JSON from an emmet-style pattern"
      method_option :blank, aliases: "-b"
      def generate(pattern='')
        puts Generator.new.generate(nil) and return if options[:blank]

        tokens = Tokenizer.new(pattern).tokenize
        tree = Parser.new(tokens).parse

        puts tree.inspect
      end
    end
  end
end