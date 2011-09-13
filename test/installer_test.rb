require 'assert'

module DotfilesInstaller

  class InstallerTests < Assert::Context
    desc "a basic installer"
    before do
      @source_files = [
        "bash/aliases",
        "bash/colors",
        "bin/a_script",
        "gemrc",
        "gitconfig.erb",
        "gitignore",
        "irbrc"
      ]
    end
    subject { @installer }

    should have_readers :sourcedir, :homedir, :options
    should have_instance_methods :source_paths, :install, :uninstall

    should "know its source files and ignore any :ignored_filenames" do
      source_paths = subject.source_paths

      assert_equal 7, source_paths.size
      @source_files.collect{|f| File.expand_path("./#{TESTDIRS_SOURCE}/#{f}")}.each do |path|
        assert_included path, source_paths
      end
      assert_not_included File.expand_path("./#{TESTDIRS_SOURCE}/ignored_file"), source_paths
      assert_not_included File.expand_path("./#{TESTDIRS_SOURCE}/bin/~also_ignored"), source_paths
    end

  end

  class InstallTests < InstallerTests
    desc "running an install"
    before do
      FileUtils.rm_rf(TESTDIRS_HOME)

      @exp_linked_files = @source_files.collect do |f|
        File.join(TESTDIRS_HOME, ".#{f}").gsub(/.erb/, '')
      end
      @installer.install
    end

    should "link up the sourcedir files to the homedir" do
      @exp_linked_files.each do |home_path|
        assert File.symlink?(home_path), "#{home_path} is not a symlink"
      end
    end

  end

  class UninstallTests < InstallTests
    desc "then running an uninstall"
    before { @installer.uninstall }

    should "rm all homedir links and any empty homedir dirs" do
      @exp_linked_files.each do |home_path|
        assert !File.exists?(home_path), "#{home_path} exists"
      end

      home_bash = File.join(TESTDIRS_HOME, ".bash")
      home_bin = File.join(TESTDIRS_HOME, ".bin")

      assert !File.exists?(home_bash), "#{home_bash} exists"
      assert !File.exists?(home_bin), "#{home_bin} exists"
    end

  end

end
