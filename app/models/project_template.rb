# Parse a Dradis template and convert into a ProjectTemplate object for easy
# access to the templates's meta data such as name, author, etc.
#
# See:
#   http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/
#   http://asciicasts.com/episodes/219-active-model
#   https://github.com/rails/rails/blob/master/activemodel/lib/active_model/conversion.rb
class ProjectTemplate
  include FileBackedModel

  # Tell the FileBackedModel module where to find the files on disk
  set_extension :xml
  set_pwd setting: 'admin:paths:templates:projects', default: Rails.root.join('../../shared/templates/projects/').to_s

  def content
    self.doc.to_s
  end
  def content=(new_content)
    @content = new_content
    initialize_doc_from_content
  end

  def doc
    @doc ||= initialize_doc_from_content
  end

  def filename
    @filename ||= "auto_#{Time.now.to_i}"
  end

  def full_path
    ProjectTemplate.pwd.join(self.filename + '.xml')
  end

  def name
    @name ||= get_name_or_set_default
  end

  def self.find_template(template)
    all.find { |t| t.filename == template || t.name == template }
  end

  private
  def initialize_doc_from_content
    doc = Nokogiri::XML(@content)
    doc.root = Nokogiri::XML::Node.new('dradis-template', doc) unless doc.root

    doc
  end

  def get_name_or_set_default
    name_node = self.doc.at_xpath('/dradis-template/name')
    if name_node.nil?
      if self.doc.root.children.any?
        name_node = self.doc.root.children.first.add_previous_sibling('<name>Name is undefined please define a name for this template</name>')
      else
        name_node = self.doc.root.add_child('<name>Name is undefined please define a name for this template</name>')
      end
    end
    name_node.text
  end
end
