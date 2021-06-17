class UserDrop < BaseDrop
  delegate :id, :name, :email, to: :@record
end
