require 'assert'

module DotfilesInstaller

  class CommandActionsTests < Assert::Context
    desc "the command_list actions"
    before { @runner = ::TestRunner.new }
    subject { @runner }

    should have_instance_methods :replace, :remove, :create
    should have_instance_methods :makedir, :generate, :link

    should "link source paths" do
      exp_cmds = [
        %Q{ln -s "#{File.expand_path("source_path")}" "#{File.expand_path("home_dir/path")}"}
      ]

      assert_equal exp_cmds, subject.link("source_path", "home_dir/path")
    end

    should "make home dirs" do
      exp_cmds = [ %Q{mkdir -p "#{File.expand_path("home_dir")}"} ]
      assert_equal exp_cmds, subject.makedir("home_dir/path")
    end

    should "remove home paths" do
      exp_cmds = [
        %Q{rm -f "#{File.expand_path("home_path")}"},
        %Q{rmdir -p "#{File.dirname(File.expand_path("home_path"))}" 2> /dev/null}
      ]

      assert_equal exp_cmds, subject.remove("home_path")
    end

    should "replace home paths" do
      exp_cmds = [
        %Q{rm -f "#{File.expand_path("home_dir/path")}"},
        %Q{mkdir -p "#{File.expand_path("home_dir")}"},
        %Q{ln -s "#{File.expand_path("source_path")}" "#{File.expand_path("home_dir/path")}"}
      ]

      assert_equal exp_cmds, subject.replace("home_dir/path", "source_path")
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

      assert_equal exp_cmds, subject.create(@erb_source_path, @erb_home_path)
      assert File.exists?(@gen_erb_source_path)
    end

    should "create a reg dotfile by just linking to the source file directly" do
      exp_cmds = [
        %Q{mkdir -p "#{File.expand_path(File.dirname(@reg_home_path))}"},
        %Q{ln -s "#{File.expand_path(@reg_source_path)}" "#{File.expand_path(@reg_home_path)}"}
      ]

      assert_equal exp_cmds, subject.create(@reg_source_path, @reg_home_path)
    end

  end

end
