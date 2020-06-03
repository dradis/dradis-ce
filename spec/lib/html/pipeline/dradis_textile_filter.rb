require 'rails_helper'

describe HTML::Pipeline::DradisTextileFilter do
  it 'does not treat the emails with period as inline code with no_inline_code enabled' do
    source = 'Hello @user.test@gmail.com'
    result = '<div><p>Hello @user.test@gmail.com</p></div>'
    expect(described_class.call(source, { no_inline_code: true }).to_s).to eq(result)
  end

end
