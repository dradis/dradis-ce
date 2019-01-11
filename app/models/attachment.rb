=begin
**
** attachment.rb
** 7 March 2009
**
** Desc:
** This class in an abstraction layer to the attachments folder. It allows
** access to the folder content in a way that mimics the working of ActiveRecord
**
** The Attachment class inherits from the ruby core File class
**
** License:
**   See LICENSE.txt for copyright and licensing information.
**
=end


# ==Description
# This class in an abstraction layer to the <tt>attachments/</tt> folder. It allows
# access to the folder content in a way that mimics the working of ActiveRecord
#
# The Attachment class inherits from the ruby core File class
#
# Folder structure
# The attachement folder structure example:
# AttachmentPWD
#    |
#    - 1     - this directory level represents the nodes, folder name = node id
#    |   |
#    |   - 3.image.gif
#    |   - 4.another_image.gif
#    |
#    - 2
#        |
#        - 1.icon.gif
#        - 2.another_icon.gif
#
# ==General usage
#   attachment = Attachment.new("images/my_image.gif", :node_id => 1)
#
# This will create an instance of an attachment that belongs to node with ID = 0
# Nothing has been saved yet
#
#   attachment.save
#
# This will save the attachment in the attachment directory structure
#
# You can inspect the saved instance:
#   attachment.node_id
#   attachment.id
#   attachment.filename
#   attachment.fullpath
#
#   attachments = Attachment.find(:all)
# Creates an array instance that contains all the attachments
#
#   Attachment.find(:all, :conditions => {:node_id => 1})
# Creates an array instance that contains all the attachments for node with ID=1
#
#   Attachment.find('test.gif', :conditions => {:node_id => 1})
# Retrieves the test.gif image that is associated with node 1

class Attachment < File

  require 'fileutils'
  # Set the path to the attachment storage
  AttachmentPwd = Rails.env.test? ? Rails.root.join('tmp', 'attachments') : Rails.root.join('attachments')
  FileUtils.mkdir_p(AttachmentPwd) unless File.exists?(AttachmentPwd)

  # -- Class Methods  ---------------------------------------------------------

  def self.all(*args)
    find(:all, *args)
  end

  def self.create(*args)
    new(*args).save
  end

  def self.count
    find(:all).count
  end

  # Return the attachment instance(s) based on the find parameters
  def self.find(*args)
    options = args.extract_options!
    dir = Dir.new(pwd)

    # makes the find request and stores it to resources
    return_value = case args.first
    when :all, :first, :last
      attachments = []
      if options[:conditions] && options[:conditions][:node_id]
        node_id = options[:conditions][:node_id].to_s
        raise "Node with ID=#{node_id} does not exist" unless Node.exists?(node_id)
        if (File.exist?( File.join(pwd, node_id)))
          node_dir = Dir.new(pwd.join(node_id)).sort
          node_dir.each do |attachment|
            next unless (attachment =~ /^(.+)$/) == 0 && !File.directory?(pwd.join(node_id, attachment))
            attachments << Attachment.new(:filename => $1, :node_id => node_id.to_i)
          end
        end
      else
        dir.each do |node|
          next unless node =~ /^\d*$/
          node_dir = Dir.new(pwd.join(node)).sort
          node_dir.each do |attachment|
            next unless (attachment =~ /^(.+)$/) == 0 && !File.directory?(pwd.join(node, attachment))
            attachments << Attachment.new(:filename => $1, :node_id => node.to_i)
          end
        end
        attachments.sort_by!(&:filename)
      end

      # return based on the request arguments
      case args.first
      when :first
        attachments.first
      when :last
        attachments.last
      else
        attachments
      end
    else
      # in this routine we find the attachment by file name and node id
      filename = args.first
      attachments = []
      raise "You need to supply a node id in the condition parameter" unless options[:conditions] && options[:conditions][:node_id]
      node_id = options[:conditions][:node_id].to_s
      raise "Node with ID=#{node_id} does not exist" unless Node.exists?(node_id)
      node_dir = Dir.new(pwd.join(node_id)).sort
      node_dir.each do |attachment|
        next unless ((attachment =~ /^(.+)$/) == 0 && $1 == filename)
        attachments << Attachment.new(:filename => $1, :node_id => node_id.to_i)
      end
      raise "Could not find Attachment with filename #{filename}" if attachments.empty?
      attachments.first
    end
    return return_value
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end

  # Class method that returns the path to the attachment storage
  def self.pwd
    AttachmentPwd
  end

  # Obtain a suitable attachment name for a recently uploaded file. If the
  # original file name is still available, use it, otherwise, provide count-based
  # an alternative.
  def self.available_name(node, args={})
    original = args.fetch(:original)

    if node.attachments.map(&:filename).include?(original)
      attachments_pwd = Attachment.pwd.join(node.id.to_s)

      # The original name is taken, so we'll add the "_copy-XX." suffix
      extension = File.extname(original)
      basename  = File.basename(original, extension)
      sequence  = Dir.glob(attachments_pwd.join("#{basename}_copy-*#{extension}")).map { |a| a.match(/_copy-([0-9]+)#{extension}\z/)[1].to_i }.max || 0
      "%s_copy-%02i%s" % [basename, sequence + 1, extension]
    else
      original
    end
  end

  # -- Instance Methods  ------------------------------------------------------

  attr_accessor :filename, :node_id, :tempfile
  attr_reader :id

  # Initializes the attachment instance
  def initialize(*args)
    options   = args.extract_options!
    @filename = options[:filename]
    @node_id  = options[:node_id]
    @tempfile = args[0] || options[:tempfile]

    if File.exists?(fullpath) && File.file?(fullpath)
      super(fullpath, 'rb+')
      @initialfile = fullpath.clone
    elsif @tempfile && File.basename(@tempfile) != ''
      @initialfile = Rails.root.join('tmp', File.basename(@tempfile))
      super(@initialfile, 'wb+')
    else
      raise "No physical file available"
    end
  end

  # Closes the current file handle, this writes the content to the file system
  def save
    if File.exists?(fullpath) && File.file?(fullpath)
      self.close
    else
      raise "Node with ID=#{@node_id} does not exist" unless @node_id && Node.exists?(@node_id)

      @filename ||= File.basename(@tempfile)
      FileUtils.mkdir(File.dirname(fullpath)) unless File.exists?(File.dirname(fullpath))
      self.close
      FileUtils.cp(self.path, fullpath) if @intialfile != fullpath
      if ( @initialfile && @initialfile != fullpath )
        # If we are still a temp file
        FileUtils.rm(@initialfile)
      end
      @initialfile = fullpath.clone
    end
  end

  # Deletes the file that the instance is pointing to from memory
  def delete
    self.close
    if ( !@initialfile || (File.dirname(@initialfile) == Rails.root.join('tmp')) )
      raise "No physical file to delete"
    end
    FileUtils.rm(@initialfile)
  end

  # Retruns the full path of an attachment on the file system
  def fullpath
    self.class.pwd.join(@node_id.to_s, @filename.to_s)
  end

  # Provide a JSON representation of this object that can be understood by
  # components of the web interface
  def to_json(options={})
    {
      filename:   @filename,
      size:       File.size(self.fullpath),
      created_at: self.ctime
    }.to_json(options)
  end

end
