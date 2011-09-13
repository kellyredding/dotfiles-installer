require 'assert'

module DotfilesInstaller


  class CommandListTests < Assert::Context
    desc "a command list"
    before { @cmd_list = TestActionsCommands.new({}) }
    subject { @cmd_list }

    should have_reader :source_map
    should have_accessor :commands
    should have_instance_methods :ep

    should "expand paths" do
      assert_equal File.expand_path("./test"), subject.ep("./test")
    end

  end


  class InstallCommandsTests < Assert::Context
  end


  class UninstallCommandsTests < Assert::Context
  end


end
