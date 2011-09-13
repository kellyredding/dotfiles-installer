require 'assert'

module DotfilesInstaller

  class InstallerTests < Assert::Context
    desc "a basic installer"
    subject { @installer }

    should have_readers :sourcedir, :homedir, :options
    should have_instance_methods :source_paths, :install, :uninstall

    should "know its source files and ignore any :ignored_filenames" do
      source_paths = subject.source_paths

      assert_equal 7, source_paths.size
      [ "bash/aliases",
        "bash/colors",
        "bin/a_script",
        "gemrc",
        "gitconfig.erb",
        "gitignore",
        "irbrc"
      ].collect{|f| File.expand_path("./#{TESTDIRS_SOURCE}/#{f}")}.each do |path|
        assert_included path, source_paths
      end
      assert_not_included File.expand_path("./#{TESTDIRS_SOURCE}/ignored_file"), source_paths
    end

  end

end
