require 'rails_helper'

describe HTML::Pipeline::DradisTextileCommentsFilter do

  it 'does not treat the emails with period as inline code' do
    source = 'Hello @user.test@gmail.com'
    result = '<div><p>Hello @user.test@gmail.com</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

end
