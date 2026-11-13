# Backs the setup wizard's shared password form, so its errors show next to
# the fields like every other form.
class SharedPasswordForm
  include ActiveModel::Model

  attr_accessor :password, :password_confirmation

  validates :password, confirmation: true, presence: true
  validates :password_confirmation, presence: true

  def save
    return false unless valid?

    ::Configuration.find_by_name('admin:password').update!(
      value: ::BCrypt::Password.create(password)
    )
  end
end
