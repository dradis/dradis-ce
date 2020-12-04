class RenameService
  # Obtain a suitable filename for a new file. If the directory
  # does not contain a file with the same filename, use the original filename,
  # otherwise provide count-based alternative.
  #   original_filename is a String object
  #   pathname is a Pathname object
  def self.rename_file(original_filename:, pathname:)
    return original_filename unless File.exists?(pathname.join(original_filename))

    extension = File.extname(original_filename)
    basename  = File.basename(original_filename, extension)
    sequence  = Dir.glob(pathname.join("#{basename}_copy-*#{extension}")).map { |a| a.match(/_copy-([0-9]+)#{extension}\z/)[1].to_i }.max || 0
    "%s_copy-%02i%s" % [basename, sequence + 1, extension]
  end
end
