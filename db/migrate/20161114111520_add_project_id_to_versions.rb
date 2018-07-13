class AddProjectIdToVersions < ActiveRecord::Migration[5.0]
  def change
    add_reference :versions, :project, index: true, foreign_key: true
  end
end
