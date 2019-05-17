# frozen_string_literal: true

class MergeNode
  attr_reader :old_node, :new_node

  def initialize(old_node, new_node)
    @old_node = old_node
    @new_node = new_node
  end

  def execute
    ActiveRecord::Base.transaction do
      update_child_nodes
      update_activities
      update_evidence
      update_notes
      update_attachments
      old_node.delete
    end
  end

  private

  def update_activities
    activities_ids = old_node.activities.pluck :id
    Activity.where(id: activities_ids).update_all(trackable_id: new_node.id) if activities_ids.present?
  end

  def update_evidence
    evidence_ids = old_node.evidence.pluck :id
    Evidence.where(id: evidence_ids).update_all(node_id: new_node.id) if evidence_ids.present?
  end

  def update_notes
    notes_ids = old_node.notes.pluck :id
    Note.where(id: notes_ids).update_all(node_id: new_node.id) if notes_ids.present?
  end

  def update_child_nodes
    if old_node.children_count > 0
      Node.where(parent_id: old_node.id).update_all(parent_id: new_node.id)
      Node.reset_counters new_node.id, :children_count
    end
  end

  def update_attachments
    old_node.attachments.each {|r| r.node_id = new_node.id; r.save}
  end
end
