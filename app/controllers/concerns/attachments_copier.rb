module AttachmentsCopier
  def copy_attachments(record)
    record.content.scan(Attachment::SCREENSHOT_REGEX).each do |screenshot_path|
      full_screenshot_path, _, _, _, project_id, node_id, filename, _ = screenshot_path

      attachment = Attachment.find_by(filename: CGI::unescape(filename), node_id: record.node_id_was)

      if attachment
        new_attachment = attachment.copy_to(record.node)
        new_filename = new_attachment.url_encoded_filename
        new_path = full_screenshot_path.gsub(
          /nodes\/[0-9]+\/attachments\/.+/,
          "nodes/#{new_attachment.node_id}/attachments/#{new_filename}"
        )

        record.content = record.content.gsub(full_screenshot_path, new_path)
      end
    end
  end
end
