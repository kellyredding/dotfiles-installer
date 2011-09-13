require 'ansi'
require 'erb'

require 'dotfiles_installer/actions'
require 'dotfiles_installer/utilities'
require 'dotfiles_installer/command_list'

# The dotfiles installer parses a sourcedir and links files to a homedir:
# - The installer provides install and uninstall commands that guide and update
#   as it performs its linkings.
# - Any source files with the '.erb' extension are rendered then linked
# - Nested files are linked to a corresponding dir made in the homedir
# - Uninstalls remove each symlink and its dir (if empty)

# the sourcedir, ~/.dotfiles:
# - bash
#   - aliases
#   - colors
# - bin
#   - a_script
# - gemrc
# - gitconfig.erb
# - gitignore
# _ irbrc

# installs in the homedir, ~:
# - .bash
#   - aliases      --> /Users/xxx/.dotfiles/bash/aliases
#   - colors       --> /Users/xxx/.dotfiles/bash/colors
# - .bin
#   - a_script     --> /Users/xxx/.dotfiles/bin/a_script
# - .gemrc         --> /Users/xxx/.dotfiles/gemrc
# - .gitconfig     --> /Users/xxx/.dotfiles/~gitconfig
# - .gitignore     --> /Users/xxx/.dotfiles/gitignore
# _ .irbrc         --> /Users/xxx/.dotfiles/irbrc

module DotfilesInstaller

  class Base
    include Utilities

    attr_reader :sourcedir, :homedir, :options

    def initialize(sourcedir, *args)
      @sourcedir = sourcedir
      @options = args.last.kind_of?(::Hash) ? args.pop : {}
      @homedir = args.pop || ENV["HOME"]
    end

  end

  # run the install or uninstall printing to $stdout and reading from $stdin
  class Interactive < Base

    def install
      self.execute(InstallCommands.new(self.source_map) do |prompt, inputs|
        print "#{prompt} #{inputs} "
        $stdin.gets.chomp
      end)
    end

    def uninstall
      self.execute(UninstallCommands.new(self.source_map) do |prompt, inputs|
        print "#{prompt} #{inputs} "
        $stdin.gets.chomp
      end)
    end

  end

end
