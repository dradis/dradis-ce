class NamingService
  # If filename exists within the directory,
  # return a count based alternative, E.g. file_name-copy-01.png, file_name-copy-02.png
  # If not, return the original filename.
  #   original_filename: the filename in String
  #   pathname: Pathname object
  def self.name_file(original_filename:, pathname:)
    if File.exists?(pathname.join(original_filename))
      extension = File.extname(original_filename)
      basename = File.basename(original_filename, extension)
      files = Dir.glob(pathname.join("#{basename}_copy-*#{extension}"))
      sequence = files.map { |file| file.match(/_copy-([0-9]+)#{extension}\z/)[1].to_i }.max || 0
      "%s_copy-%02i%s" % [basename, sequence + 1, extension]
    else
      original_filename
    end
  end
end
