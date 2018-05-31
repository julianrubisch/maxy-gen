require 'thor'

module Maxy
  module Gen
    class CLI < Thor
      desc "generate ABBREVIATION", "Generates a Max Patch JSON from an emmet-style abbreviation"
      method_option :blank, aliases: "-b"
      def generate(abbr='')
        puts 'blank' and return if options[:blank]
      end
    end
  end
end