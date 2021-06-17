class UserDrop < Liquid::Drop
  delegate :name, :email, to: :@record
end
