module AttachmentsCopier
  # Scans record content and for each attachment reference found,
  # 1. Copies the attachment to the new node
  # 2. Updates the content to point to the new attachment
  # Returns an array of copied attachments for that record
  def copy_attachments(record, source_node_id = nil)
    copied_attachments = []
    record.content.scan(Attachment::SCREENSHOT_REGEX).each do |screenshot_path|
      full_screenshot_path, _, _, _, project_id, node_id, filename, _ = screenshot_path
      source_node_id ||= record.node_id_was

      attachment = Attachment.find_by(filename: CGI::unescape(filename), node_id: source_node_id)

      if attachment
        new_attachment = attachment.copy_to(record.node)
        new_filename = new_attachment.url_encoded_filename
        new_path = full_screenshot_path.gsub(
          /nodes\/[0-9]+\/attachments\/.+/,
          "nodes/#{new_attachment.node_id}/attachments/#{new_filename}"
        )

        record.content = record.content.gsub(full_screenshot_path, new_path)
        copied_attachments << new_attachment
      end
    end
    copied_attachments
  end
end
