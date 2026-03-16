module AttachmentsCopier
  # Scans record content and for each attachment reference found,
  # 1. Copies the attachment to the new node
  # 2. Updates the content to point to the new attachment
  # 3. Returns a hash that maps the previous image name to the copied image name so that it can be found later by new node id
  def copy_attachments(record, source_node_id = nil)
    copied_attachments_map = {}

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
        copied_attachments_map[filename] = new_filename
      end
    end
    copied_attachments_map
  end
end
