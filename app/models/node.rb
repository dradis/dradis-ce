# Dradis Note objects are associated with a Node. It is possible to create a
# tree structure of Nodes to hierarchically structure the information held
# in the repository.
#
# Each Node has a :parent node and a :label. Nodes can also have many
# Attachment objects associated with them.
class Node < ActiveRecord::Base
  include NodeProperties

  module Types
    DEFAULT = 0
    HOST = 1
    METHODOLOGY = 2
    ISSUELIB = 3
  end

  acts_as_tree

  # -- Relationships --------------------------------------------------------
  has_many :notes, dependent: :destroy
  has_many :evidence, dependent: :destroy
  has_many :activities, as: :trackable

  def nested_activities
    sql = "(`activities`.`trackable_type`='Node' AND "\
          " `activities`.`trackable_id`=#{id})"

    # Don't check for note/evidence activities unless we actually have
    # notes/evidence, because "IN ()" isn't valid MySQL.

    # Cache ids in a local variable so we don't make the same SQL request twice
    if (e_ids = evidence_ids).any?
      sql << " OR (`activities`.`trackable_type`='Evidence' AND "\
             "`activities`.`trackable_id` IN (#{e_ids.join(",")}))"
    end
    if (n_ids = note_ids).any?
      sql << " OR (`activities`.`trackable_type`='Note' AND "\
             " `activities`.`trackable_id` IN (#{n_ids.join(",")}))"
    end
    Activity.where(sql)
  end


  # -- Callbacks ------------------------------------------------------------
  before_destroy :destroy_attachments
  before_save do |record|
    record.type_id = Types::DEFAULT unless record.type_id
    record.position = 0 unless record.position
  end

  # -- Validations ----------------------------------------------------------
  validates_presence_of :label

  # -- Scopes ---------------------------------------------------------------
  scope :in_tree, -> {
    where("type_id IN (?)", [Types::DEFAULT, Types::HOST]).where(parent_id: nil)
  }


  # -- Class Methods --------------------------------------------------------
  # Returns or creates the Node that acts as container for all Issues in a
  # given project
  def self.issue_library
    if (issue_lib = where(type_id: Node::Types::ISSUELIB).limit(1).first)
      issue_lib
    else
      create(label: 'All issues', type_id: Node::Types::ISSUELIB)
    end
  end

  # Returns or creates the Node that acts as container for all Methodologies in
  # a given project
  def self.methodology_library
    if (methodology_lib = where(type_id: Node::Types::METHODOLOGY).limit(1).first)
      methodology_lib
    else
      create(label: 'Methodologies', type_id: Node::Types::METHODOLOGY)
    end
  end

  # When Upload plugins create new nodes, they'll do so under this parent node
  def self.plugin_parent_node
    if (parent_node = where(label: ::Configuration.plugin_parent_node).limit(1).first)
      parent_node
    else
      create(label: ::Configuration.plugin_parent_node)
    end
  end

  # Security scanner output files uploaded via the Upload Manager use thsi node
  # as container
  def self.plugin_uploads_node
    if (uploads_node = where(label: ::Configuration.plugin_uploads_node).limit(1).first)
      uploads_node
    else
      create(label: ::Configuration.plugin_uploads_node)
    end
  end

  # -- Instance Methods -----------------------------------------------------
  def ancestor_of?(node)
    node && node.ancestors.include?(self)
  end

  def root_node?
    parent.nil?
  end

  # Return all the Attachment objects associated with this Node.
  def attachments
    Attachment.find(:all, :conditions => {:node_id => self.id})
  end

  private
  # Whenever a node is deleted all the associated attachments have to be
  # deleted too
  def destroy_attachments
    attachments_dir = Attachment.pwd.join(self.id.to_s)
    FileUtils.rm_rf attachments_dir if File.exists?(attachments_dir)
  end
end
