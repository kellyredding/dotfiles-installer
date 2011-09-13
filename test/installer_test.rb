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
    before { @installer.install }

    should "link up the sourcedir files to the homedir" do
      @source_files.collect{|f| File.join(TESTDIRS_HOME, ".#{f}").gsub(/.erb/, '')}.each do |home_path|
        assert File.symlink?(home_path), "#{home_path} is not a symlink"
      end
    end

  end

  class UninstallTests < InstallerTests
    desc "running an uninstall"

    should "rm all homedir links and any empty homedir dirs" do
    end

  end

end
