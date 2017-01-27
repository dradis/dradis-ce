module AttachmentsHelper
  # Simulate a file upload by copying a file already present in our
  # file tree (fixtures folder) to that node attachments folder
  def upload(name, node)
    FileUtils.mkdir_p Attachment.pwd.join(node.id.to_s).to_s
    FileUtils.cp Rails.root.join("spec/fixtures/files/rails.png").to_s,
                 Attachment.pwd.join(node.id.to_s, name).to_s
  end
end
