require 'rails_helper'

describe Comment do

  #it { should validate_presence_of(:node) }
  #it { should validate_presence_of(:category) }

  it { should belong_to :commentable }

end
