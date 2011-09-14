require 'ansi'
require 'erb'

require 'dotfiles_installer/actions'

module DotfilesInstaller

  class Runner
    include Actions

    attr_reader :output_io

    def initialize(output_io, options={})
      @output_io = output_io
      @options = options
    end

    def install(source_map, &block)
      replace_all = false

      source_map.each do |source_path, home_path|
        if !File.exist? self.ep(home_path)
          self.execute(self.create(source_path, home_path))
          next
        end

        if File.identical? self.ep(source_path), self.ep(home_path)
          self.out "identical #{home_path}"
        elsif replace_all
          self.execute(self.replace(home_path, source_path))
        else
          case (block_given? ? yield("overwrite #{home_path}?", "[ynaq]") : "")
          when 'a'
            replace_all = true
            self.execute(self.replace(home_path, source_path))
          when 'y'
            self.execute(self.replace(home_path, source_path))
          when 'q'
            exit
          else
            self.out "skipping #{home_path}"
          end
        end
      end

    end

    def uninstall(source_map)
      remove_all = false

      source_map.each do |source_path, home_path|
        if !File.exist? self.ep(home_path)
          next
        end

        if remove_all
          self.execute(self.remove(home_path))
        else
          case (block_given? ? yield("remove #{home_path}?", "[ynaq]") : "")
          when 'a'
            remove_all = true
            self.execute(self.remove(home_path))
          when 'y'
            self.execute(self.remove(home_path))
          when 'q'
            exit
          else
            self.out "skipping #{home_path}"
          end
        end
      end

    end

    protected

    def execute(commands)
      commands.flatten.each do |cmd|
        out(" => #{cmd}") if @options[:debug]
        system(cmd)
      end
    end

    def out(msg)
      @output_io.puts(msg) if @output_io
    end

    def ep(path)
      File.expand_path(path)
    end

  end

end
