require 'assert'

module DotfilesInstaller

  class BaseTests < Assert::Context
    desc "the installer actions"
    subject { @installer }

    should have_class_methods :replace, :remove, :create, :generate, :link, :makedir

    should "make home dirs" do
      assert_equal [%Q{mkdir -p "#{File.expand_path("home_dir")}"}], subject.class.makedir("home_dir/path")
    end

    should "link source paths" do
      exp_cmds = [
        %Q{mkdir -p "#{File.expand_path("home_dir")}"},
        %Q{ln -s "#{File.expand_path("source_path")}" "#{File.expand_path("home_dir/path")}"}
      ]
      assert_equal exp_cmds, subject.class.link("source_path", "home_dir/path")
    end

    should "remove home paths" do
      assert_equal [%Q{rm -rf "#{File.expand_path("home_path")}"}], subject.class.remove("home_path")
    end

    should "replace home paths" do
      exp_cmds = [
        subject.class.remove("home_dir/path"),
        subject.class.link("source_path", "home_dir/path")
      ].flatten
      assert_equal exp_cmds, subject.class.replace("home_dir/path", "source_path")
    end

  end

  class CreateTests < BaseTests

    setup do
      @reg_source_path = File.join(TESTDIRS_SOURCE, "gitignore")
      @reg_home_path = File.join(TESTDIRS_HOME, ".gitignore")
      @erb_source_path = File.join(TESTDIRS_SOURCE, "gitconfig.erb")
      @erb_home_path = File.join(TESTDIRS_HOME, ".gitconfig")
      @gen_erb_source_path = subject.class.generate(@erb_source_path)
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

      cmds = subject.class.link(@gen_erb_source_path, @erb_home_path)
      create_cmds = subject.class.create(@erb_source_path, @erb_home_path)

      assert_equal cmds, create_cmds
      assert File.exists?(@gen_erb_source_path)
    end

    should "create a reg dotfile by just linking to the source file directly" do
      cmds = subject.class.link(@reg_source_path, @reg_home_path)
      create_cmds = subject.class.create(@reg_source_path, @reg_home_path)

      assert_equal cmds, create_cmds
    end

  end

end
