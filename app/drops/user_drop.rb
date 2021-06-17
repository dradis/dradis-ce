class UserDrop < BaseDrop
  delegate :name, :email, to: :@record
end
