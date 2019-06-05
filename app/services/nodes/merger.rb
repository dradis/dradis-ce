# frozen_string_literal: true

class Nodes::Merger
  SOURCES = {
    activities: :trackable_id,
    children: :parent_id,
    evidence: :node_id,
    notes: :node_id
  }.freeze

  attr_accessor :target_node_id, :source_node, :source_attachments

  def self.call(target_node_id, source_node, &block)
    new(target_node_id, source_node).call(&block)
  end

  def initialize(target_node_id, source_node)
    @source_attachments = source_node.attachments
    @source_node = source_node
    @target_node_id = target_node_id
  end

  def call(&block)
    Node.transaction do
      SOURCES.each do |relation, column|
        source_node.send(relation).update_all(column => target_node_id)
      end

      Node.reset_counters target_node_id, :children_count
      Node.reset_counters source_node.id, :children_count

      source_node.attachments.each do |attachment|
        attachment.node_id = target_node_id
        attachment.save
      end

      yield if block

      return []
    end
  rescue StandardError => e
    Rails.logger.error 'Node merge error occured, attempting to rectify attachments.'
    Rails.logger.error e.backtrace

    undo_attachments_move

    return [e.message]
  end

  def undo_attachments_move
    source_attachments.each do |attachment|
      next if File.exist? attachment.fullpath

      saved_attachment = Attachment.find(attachment.filename,
        conditions: { node_id: target_node_id })

      saved_attachment.node_id = source_node.id
      saved_attachment.save
    end
  end
end
