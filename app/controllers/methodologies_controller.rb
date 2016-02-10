class MethodologiesController < ProjectScopedController

  before_filter :find_methodologylib
  before_filter :find_methodology, only: [:edit, :update, :update_task, :destroy]

  def index
    @methodologies = []

    # How ugly is using the :filename to store the note's :id?
    @methodologies = @methodologylib.notes.map{|n| Methodology.new(filename: n.id, content: n.text)}

    @methodology_templates = Methodology.all
  end

  def add
    @methodology = Methodology.find(params[:id])
  end

  def create
    @methodology = Methodology.find(params[:methodology_id])
    old_name = @methodology.name
    new_name = params[:methodology].fetch(:name, old_name)
    @methodology.name = new_name

    @methodologylib.notes.create(author: 'methodology builder', text: @methodology.content, category: Category.first)

    flash[:info] = "'#{old_name}' added as '#{new_name}'"
    redirect_to methodologies_path
  end

  def edit
  end

  def update
    if @note.update_attribute(:text, params[:methodology][:content])
      redirect_to methodologies_path, notice: "Methodology [#{@methodology.name}] updated."
    else
      redirect_to methodologies_path, alert: "Methodology [#{@methodology.name}] could not be updated."
    end
  end

  def update_task
    section = params.fetch(:section, 'undefined')
    task = params.fetch(:task, 'undefined')
    checked = params.fetch(:checked, 0)

    doc = Nokogiri::XML(@note.text)
    task_node = doc.xpath("//section/name[text()='#{section}']/..//task[text()='#{task}']").first
    return unless task_node

    if (checked == 0)
      task_node.remove_attribute('checked')
    else
      task_node.set_attribute('checked', 'checked')
    end

    @note.update_attribute(:text, doc.to_s)
    render json: { status: 'ok' }
  end

  def destroy
    if (note = @methodologylib.notes.where(id: params[:id]).first)
      note.destroy
    end
    flash[:info] = "Methodology deleted"
    redirect_to methodologies_path()
  end


  def preview
    @methodology = Methodology.new(content: params[:content])
    respond_to do |format|
      format.js
    end
  end


  private
  def find_methodology
    @note = @methodologylib.notes.where(id: params[:id]).first
    if @note
      @methodology = Methodology.new(filename: @note.id, content: @note.text)
    else
      redirect_to methodologies_path, notice: 'Methodology not found!'
    end
  end
  def find_methodologylib
    @methodologylib = Node.methodology_library
  end
end
