module Eventable
  extend ActiveSupport::Concern

  def local_event_payload
    {}
  end

  def to_event_payload
    {
      id: self.id,
      class: self.class.name
    }.merge(local_event_payload)
  end
end
