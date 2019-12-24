class AddProjectIdToVersions < ActiveRecord::Migration[5.1]
  def change
    add_reference :versions, :project, index: true
  end
end
