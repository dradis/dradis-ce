# frozen_string_literal: true

class Nodes::Merger
  include AttachmentsCopier

  def self.call(target_node, source_node)
    new(target_node, source_node).call
  end

  def initialize(target_node, source_node)
    @source_node = source_node
    @target_node = target_node
  end

  def call
    Node.transaction do
      move_descendents
      reset_counter_caches
      update_properties
      update_attachments

      Node.destroy(source_node.id)
    end
  rescue StandardError => e
    Rails.logger.error 'Node merge error occured, attempting to rectify attachments.'
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")

    undo_attachments_copy

    source_node
  end

  private

  attr_accessor :target_node, :source_node, :copied_attachments

  DESCENDENT_RELATIONSHIPS = {
    activities: :trackable_id,
    children: :parent_id,
    evidence: :node_id,
    notes: :node_id
  }.freeze

  def move_descendents
    DESCENDENT_RELATIONSHIPS.each do |relation, column|
      collection = source_node.send(relation)
      collection_ids = collection.pluck(:id)

      collection.update_all(column => target_node.id)
      collection.klass.where(id: collection_ids).touch_all
    end

    # touch all issues since update_all doesn't run callbacks
    target_node.issues.touch_all
  end

  def reset_counter_caches
    Node.reset_counters target_node.id, :children_count
  end

  def update_properties
    source_node.properties.each do |key, value|
      case key.to_sym
      when :services
        value.each do |service|
          data = service.merge(source: :merge)
          target_node.set_service data
        end
      when :services_extras
        value.each do |protocol_port, extras|
          protocol, port = protocol_port.split('/')

          extras.each do |extra|
            data = {
              extra[:id] => extra[:output],
              source: extra[:source],
              port: port.to_i,
              protocol: protocol
            }

            target_node.set_service data
          end
        end
      else
        target_node.set_property key, value
      end
    end

    target_node.save
  end

  def update_attachments
    self.copied_attachments = {}

    target_node.evidence.each do |evidence|
      result = copy_attachments(evidence, source_node.id)
      self.copied_attachments.merge!(result)
      evidence.save! if evidence.changed?
    end

    # Copy any remaining attachments that were not referenced in any evidence
    source_node.attachments.each do |attachment|
      # Skip if already copied
      unless copied_attachments.key?(attachment.filename)
        new_attachment = attachment.copy_to(target_node)
        self.copied_attachments[attachment.filename] = new_attachment.filename
      end
    end

    # Update any screenshots in Issue content that still point to the source node
    update_issue_screenshot_links
  end

  def update_issue_screenshot_links
    return if copied_attachments.empty?

    source_node.project.issues.find_each do |issue|
      next unless Attachment::SCREENSHOT_REGEX.match?(issue.text)

      copied_attachments.each do |old_filename, new_filename|
        old_screenshot_path = "nodes/#{source_node.id}/attachments/#{old_filename}"
        next unless issue.text.include?(old_screenshot_path)

        new_screenshot_path = "nodes/#{target_node.id}/attachments/#{new_filename}"
        issue.text = issue.text.gsub(old_screenshot_path, new_screenshot_path)
      end

      issue.save! if issue.changed?
    end
  end

  def undo_attachments_copy
    return unless copied_attachments&.any?
    copied_attachments.values.each do |new_filename|
      attachment = Attachment.find_by(filename: new_filename, node_id: target_node.id)
      attachment.delete if attachment
    end
  end
end
