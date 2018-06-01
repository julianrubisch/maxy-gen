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
      end
    end
  end
end