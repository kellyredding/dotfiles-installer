require 'assert'

module DotfilesInstaller

  class CommandActionsTests < Assert::Context
    desc "the command_list actions"
    before { @cmd_list = TestActionsCommands.new({}) }
    subject { @cmd_list }

    should have_instance_methods :replace, :remove, :create
    should have_instance_methods :makedir, :generate, :link, :echo

    should "echo info" do
      subject.echo(%Q{hello "~bob"})

      assert_equal [ %Q{echo hello "~bob"} ], subject.commands
    end

    should "link source paths" do
      exp_cmds = [
        %Q{ln -s "#{File.expand_path("source_path")}" "#{File.expand_path("home_dir/path")}"}
      ]
      subject.link("source_path", "home_dir/path")

      assert_equal exp_cmds, subject.commands
    end

    should "make home dirs" do
      subject.makedir("home_dir/path")

      assert_equal [%Q{mkdir -p "#{File.expand_path("home_dir")}"}], subject.commands
    end

    should "remove home paths" do
      exp_cmds = [
        %Q{rm -rf "#{File.expand_path("home_path")}"},
        %Q{rmdir -p "#{File.dirname(File.expand_path("home_path"))}" 2> /dev/null}
      ]
      subject.remove("home_path")

      assert_equal exp_cmds, subject.commands
    end

    should "replace home paths" do
      exp_cmds = [
        %Q{rm -rf "#{File.expand_path("home_dir/path")}"},
        %Q{mkdir -p "#{File.expand_path("home_dir")}"},
        %Q{ln -s "#{File.expand_path("source_path")}" "#{File.expand_path("home_dir/path")}"}
      ]
      subject.replace("home_dir/path", "source_path")

      assert_equal exp_cmds, subject.commands
    end

  end

  class CreateActionsTests < CommandActionsTests

    setup do
      @reg_source_path = File.join(TESTDIRS_SOURCE, "gitignore")
      @reg_home_path = File.join(TESTDIRS_HOME, ".gitignore")
      @erb_source_path = File.join(TESTDIRS_SOURCE, "gitconfig.erb")
      @erb_home_path = File.join(TESTDIRS_HOME, ".gitconfig")
      @gen_erb_source_path = subject.generate(@erb_source_path)
    end
    teardown do
      FileUtils.rm(@gen_erb_source_path) if File.exists?(@gen_erb_source_path)
    end

    should "generate a ~ prefixed file in the sourcedir when generating" do
      assert File.exists?(@gen_erb_source_path)
      assert_equal '~gitconfig', File.basename(@gen_erb_source_path)
      assert_equal "this was rendered", File.read(@gen_erb_source_path).strip
    end

    should "create an erb dotfile by generating then linking to the generated source file" do
      # clear this part of the setup for this test
      FileUtils.rm(@gen_erb_source_path)
      @gen_erb_source_path = File.join(TESTDIRS_SOURCE, "~gitconfig")

      exp_cmds = [
        %Q{mkdir -p "#{File.expand_path(File.dirname(@erb_home_path))}"},
        %Q{ln -s "#{File.expand_path(@gen_erb_source_path)}" "#{File.expand_path(@erb_home_path)}"}
      ]
      subject.create(@erb_source_path, @erb_home_path)

      assert_equal exp_cmds, subject.commands
      assert File.exists?(@gen_erb_source_path)
    end

    should "create a reg dotfile by just linking to the source file directly" do
      exp_cmds = [
        %Q{mkdir -p "#{File.expand_path(File.dirname(@reg_home_path))}"},
        %Q{ln -s "#{File.expand_path(@reg_source_path)}" "#{File.expand_path(@reg_home_path)}"}
      ]
      subject.create(@reg_source_path, @reg_home_path)

      assert_equal exp_cmds, subject.commands
    end

  end

end
