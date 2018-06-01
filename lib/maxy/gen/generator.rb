require 'json'
require 'psych'

module Maxy
  module Gen
    class Generator
      def generate(node)
        return JSON.generate(Psych.load_file(File.join(__dir__, '../../../assets/blank.yml'))) if node.nil?
      end
    end
  end
end