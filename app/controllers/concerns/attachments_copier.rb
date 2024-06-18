module AttachmentsCopier
  def copy_attachments(record)
    record.content.scan(Attachment::SCREENSHOT_REGEX).each do |screenshot_url|
      _, _, _, _, project_id, node_id, filename, _ = screenshot_url

      attachment = Attachment.find_by(filename: filename, node_id: record.node_id_was)

      if attachment
        new_attachment = attachment.copy_to(record.node)
        new_url = screenshot_url[0].gsub(
          /nodes\/[0-9]+\/attachments/,
          "nodes/#{new_attachment.node_id}/attachments"
        )

        record.content = record.content.gsub(screenshot_url[0], new_url)
      end
    end
  end
end
