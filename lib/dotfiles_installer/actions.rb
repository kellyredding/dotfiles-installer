module DotfilesInstaller::Actions

  def replace(home_path, source_path)
    [ self.remove_path(home_path),
      self.create(source_path, home_path)
    ].flatten
  end

  def remove(home_path)
    self.out("uninstalled #{home_path}")
    [ self.remove_path(home_path),
      self.remove_dir_if_empty(home_path)
    ].flatten
  end

  def remove_path(path)
    [ %Q{rm -f "#{self.ep(path)}"} ]
  end

  def remove_dir_if_empty(home_path)
    [ %Q{rmdir -p "#{File.dirname(self.ep(home_path))}" 2> /dev/null} ]
  end

  def create(source_path, home_path)
    self.out("installed #{home_path}")
    [ self.makedir(home_path),
      self.link(source_path =~ /.erb$/ ? generate(source_path) : source_path, home_path)
    ].flatten
  end

  def makedir(home_path)
    [ %Q{mkdir -p "#{self.ep(File.dirname(home_path))}"} ]
  end

  def link(source_path, home_path)
    [ %Q{ln -s "#{self.ep(source_path)}" "#{self.ep(home_path)}"} ]
  end

  def generate(source_path)
    source_path_dirname = File.dirname(File.expand_path(source_path))
    gen_source_filename = "~#{File.basename(source_path, ".erb")}"
    gen_source_path = File.join(source_path_dirname, gen_source_filename)
    File.open(gen_source_path, 'w') do |gen_source_file|
      gen_source_file.write ERB.new(File.read(File.expand_path(source_path))).result(binding)
    end
    gen_source_path
  end

end
