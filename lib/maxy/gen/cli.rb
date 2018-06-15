require 'thor'
require 'psych'
require 'json'
require 'fileutils'
require 'nokogiri'
require 'maxy/gen'

module Maxy
  module Gen
    class CLI < Thor
      map "g" => :generate
      map "i" => :install

      desc "generate PATTERN", "Generates a Max Patch JSON from an emmet-style pattern"
      method_option :blank, aliases: "-b"
      def generate(pattern='')
        puts Generator.new.generate(nil) and return if options[:blank]

        tokens = Tokenizer.new(pattern).tokenize
        tree = Parser.new(tokens).parse

        puts Generator.new.generate(tree)
      end

      desc "install", "Generate max objects library from local maxref pages"
      def install
        library = {objects: {}}
        maxref_xml_root = '/Applications/Max.app/Contents/Resources/C74/docs/refpages'

        print "Path to Max Refpages [#{maxref_xml_root}]:"
        case choice = $stdin.gets.chomp
        when ''
        when /\A.+/i
          maxref_xml_root = choice
        else fail "cannot understand `#{choice}'"
        end

        Dir.foreach(maxref_xml_root) do |mod|
          next if mod =~ /\.\.?/
          if File.directory?("#{maxref_xml_root}/#{mod}")
            Dir.glob("#{maxref_xml_root}/#{mod}/*.maxref.xml").each do |maxref|
              doc = File.open(maxref) { |f| Nokogiri::XML(f) }

              obj_name = doc.xpath('//c74object/@name').to_s
              inlets = doc.xpath('//inlet')
              outlets = doc.xpath('//outlet')

              library[:objects][obj_name] = {}
              library[:objects][obj_name]['maxclass'] = 'newobj'
              library[:objects][obj_name]['style'] = ''
              library[:objects][obj_name]['text'] = obj_name
              library[:objects][obj_name]['numinlets'] = inlets.size
              library[:objects][obj_name]['numoutlets'] = outlets.size
            end
          end
        end

        library[:objects].select { |k, _v| k.match?(/\A^[-+*={}()].*/) }.each do |k, _v|
          key = "\\#{k}"
          library[:objects][key] = library[:objects].delete k
        end

        unless File.directory?("#{ENV['HOME']}/.maxy-gen")
          FileUtils.mkdir_p("#{ENV['HOME']}/.maxy-gen")
        end
        File.open("#{ENV['HOME']}/.maxy-gen/library.yml", 'w') {|f| f.write library.to_yaml }

        print "Successfully installed max object definitions."

      end
    end
  end
end