require 'assert'

module DotfilesInstaller


  class RunnerTests < Assert::Context
    desc "a runner"
    before { @runner = TestRunner.new }
    subject { @runner }

    should have_reader :output_io

  end


end
