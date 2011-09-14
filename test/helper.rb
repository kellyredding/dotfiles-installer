# this file is automatically required in when you require 'assert' in your tests
# put test helpers here

# add root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

require 'fileutils'
require 'dotfiles_installer'

FIXTURE_SOURCEDIR = "test/fixtures/sourcedir"
FIXTURE_HOMEDIR   = "test/fixtures/homedir"
TESTDIRS_ROOT     = "testdirs"
TESTDIRS_SOURCE   = "#{TESTDIRS_ROOT}/sourcedir"
TESTDIRS_HOME     = "#{TESTDIRS_ROOT}/homedir"

class TestRunner < ::DotfilesInstaller::Runner
  def initialize
    super(nil, {:debug => true})
  end
end

class TestInstaller < ::DotfilesInstaller::Base
  def initialize
    super(TESTDIRS_SOURCE, TESTDIRS_HOME, {
      :ignored_filenames => %w[ignored_file]
    })
  end

  # force the install or uninstall on all files
  def install
    TestRunner.new.install(self.source_map) { |p, i| 'a' }
  end

  def uninstall
    TestRunner.new.uninstall(self.source_map) { |p, i| 'a' }
  end
end

class Assert::Context
  startup do
    FileUtils.mkdir_p(TESTDIRS_SOURCE)
    FileUtils.mkdir_p(TESTDIRS_HOME)
    FileUtils.cp_r(FIXTURE_SOURCEDIR, TESTDIRS_ROOT)
  end
  shutdown do
    FileUtils.rm_rf(TESTDIRS_ROOT)
  end

  before do
    @installer = TestInstaller.new
  end

end
