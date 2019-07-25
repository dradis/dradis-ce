# frozen_string_literal: true

class Nodes::Merger
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
      move_attachments
      source_node.destroy

      return []
    end
  rescue StandardError => e
    Rails.logger.error 'Node merge error occured, attempting to rectify attachments.'
    Rails.logger.error e.backtrace

    undo_attachments_move

    []
  end

  private

    attr_accessor :target_node, :source_node, :moved_attachments

    DESCENDENT_RELATIONSHIPS = {
      activities: :trackable_id,
      children: :parent_id,
      evidence: :node_id,
      notes: :node_id
    }.freeze

    def move_descendents
      DESCENDENT_RELATIONSHIPS.each do |relation, column|
        source_node.send(relation).update_all(column => target_node.id)
      end
    end

    def reset_counter_caches
      Node.reset_counters target_node.id, :children_count
    end

    def move_attachments
      self.moved_attachments = []

      source_node.attachments.each do |attachment|
        moved_attachments << attachment.copy_to(target_node)
      end
    end

    def undo_attachments_move
      return unless moved_attachments&.any?
      moved_attachments.each(&:delete)
    end
end
