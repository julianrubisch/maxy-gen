require 'thor'
require 'psych'
require 'json'

module Maxy
  module Gen
    class CLI < Thor
      desc "generate ABBREVIATION", "Generates a Max Patch JSON from an emmet-style abbreviation"
      method_option :blank, aliases: "-b"
      def generate(abbr='')
        puts JSON.generate(Psych.load_file(File.join(__dir__, '../../../assets/blank.yml'))) and return if options[:blank]
      end
    end
  end
end