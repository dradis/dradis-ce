module Eventable
  extend ActiveSupport::Concern

  def local_payload
    {}
  end

  def to_payload
    {
      id: self.id,
      class: self.class.name
    }.merge(local_payload)
  end
end
