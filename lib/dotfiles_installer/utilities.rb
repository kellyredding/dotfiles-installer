module DotfilesInstaller::Utilities

  def source_paths
    Dir["#{File.expand_path(self.sourcedir)}/**/*"].
    select { |path| File.file?(path) }.
    reject { |path| ignored_file?(path) }.each do |path|
      yield path, home_path(path) if block_given?
    end
  end

  protected

  def home_path(source_path)
    source_path.
    gsub(/^#{File.expand_path(self.sourcedir)}\//, "#{self.homedir}/.").
    gsub(/.erb$/, '')
  end

  def ignored_file?(path)
    self.options[:ignored_filenames].include? File.basename(path)
  end

  # def empty_dir?(path)
  #   if File.exists?(d = File.dirname(path))
  #     Dir.entries(d).reject{|e| ['.', '..'].include?(e)}.empty?
  #   end
  # end

end
