require 'ansi'
require 'erb'

require 'dotfiles_installer/actions'

module DotfilesInstaller



  class CommandList
    include Actions

    attr_reader :source_map
    attr_accessor :commands

    def initialize(source_map)
      @source_map = source_map
      @commands = []
    end

    def ep(path)
      File.expand_path(path)
    end

  end



  class InstallCommands < CommandList

    attr_accessor :replace_all

    def initialize(source_map, &block)
      @replace_all = false
      super

      self.source_map.each do |source_path, home_path|
        self.create(source_path, home_path); next if !File.exist? self.ep(home_path)

        if File.identical? self.ep(source_path), self.ep(home_path)
          self.echo "identical #{home_path}"
        elsif self.replace_all
          self.replace(home_path, source_path)
        else
          case (block_given? ? yield("overwrite #{home_path}?", "[ynaq]") : "")
          when 'a'
            self.replace_all = true
            self.replace(home_path, source_path)
          when 'y'
            self..replace(home_path, source_path)
          when 'q'
            exit
          else
            self.echo "skipping #{home_path}"
          end
        end
      end

    end

  end



  class UninstallCommands < CommandList

    attr_accessor :remove_all

    def initialize(source_map)
      @remove_all = false
      super

      self.source_map.each do |source_path, home_path|
        next if !File.exist? self.ep(home_path)

        if self.remove_all
          self.remove(home_path)
        else
          case (block_given? ? yield("remove #{home_path}?", "[ynaq]") : "")
          when 'a'
            self.remove_all = true
            self.remove(home_path)
          when 'y'
            self.remove(home_path)
          when 'q'
            exit
          else
            self.echo "skipping #{home_path}"
          end
        end
      end

    end

  end


end
