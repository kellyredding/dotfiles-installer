module DotfilesInstaller::Utilities

  # nested source paths for not-ignored files
  def source_paths
    Dir["#{File.expand_path(self.sourcedir)}/**/*"].
    select { |path| File.file?(path) }.
    reject { |path| ignored_file?(path) }
  end

  # create a hash of soure_path keys with home_path values
  def source_map
    self.source_paths.inject({}) do |map, path|
      map[path] = self.home_path(path)
      map
    end
  end

  protected

  def home_path(source_path)
    source_path.
    gsub(/^#{File.expand_path(self.sourcedir)}\//, "#{self.homedir}/.").
    gsub(/.erb$/, '')
  end

  def ignored_file?(path)
    path_bn = File.basename(path)
    (self.options[:ignored_filenames] || []).include?(path_bn) || path_bn =~ /^~/
  end

end
