module DotfilesInstaller::Actions

  def replace(home_path, source_path)
    remove(home_path)
    link(source_path, home_path)
  end

  def remove(home_path)
    run_cmd %Q{rm -rf "#{self.ep(home_path)}"}
  end

  def link(source_path, home_path)
    self.makedir(home_path)
    if source_path =~ /.erb$/
      run_cmd(nil, "generating #{home_path}") do
        File.open(File.expand_path(home_path), 'w') do |new_file|
          new_file.write ERB.new(File.read(File.expand_path(source_path))).result(binding)
        end
      end
    else
      link_cmd = %Q{ln -s "#{self.ep(source_path)}" "#{self.ep(home_path)}"}
      run_cmd link_cmd, "linking #{home_path}"
    end
  end

  protected

  def ep(path)
    File.expand_path(home_path)
  end

  def makedir(home_path)
    home_dir = File.expand_path(File.dirname(home_path))
    mkdir_cmd =  %Q{mkdir -p "#{home_dir}"}
    run_cmd(mkdir_cmd, nil) if !File.exist? home_dir
  end



end
