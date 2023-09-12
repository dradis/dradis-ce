json.(card, :id, :description, :due_date, :name, :fields)

json.assignees card.assignees, :id, :email
