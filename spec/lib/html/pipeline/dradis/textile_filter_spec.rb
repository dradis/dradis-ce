require 'rails_helper'

describe HTML::Pipeline::Dradis::TextileFilter do
  it 'does not treat the emails with period as inline code with no_inline_code enabled' do
    source = 'Hello @user.test@gmail.com'
    result = '<div><p>Hello @user.test@gmail.com</p></div>'
    expect(described_class.call(source, { no_inline_code: true }).to_s).to eq(result)
  end

  it 'renders an email address wrapped in @...@ as inline code' do
    source = 'Contact @admin@starfleet.com@ for access.'
    result = '<div><p>Contact <code>admin@starfleet.com</code> for access.</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'renders multiple email addresses wrapped in @...@ as inline code' do
    source = 'Reach @admin@starfleet.com@ or @ops@starfleet.com@.'
    result = '<div><p>Reach <code>admin@starfleet.com</code> or <code>ops@starfleet.com</code>.</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'does not convert an email address inside a bc. code block' do
    source = 'bc. Contact @admin@starfleet.com@ for access.'
    result = '<div><pre><code>Contact @admin@starfleet.com@ for access.</code></pre></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'leaves an email address wrapped in @...@ literal with no_inline_code enabled' do
    source = 'Contact @admin@starfleet.com@ for access.'
    result = '<div><p>Contact @admin@starfleet.com@ for access.</p></div>'
    expect(described_class.call(source, { no_inline_code: true }).to_s).to eq(result)
  end

  it 'does not convert an email-like pattern inside an href attribute' do
    source = '"Phishing link":http://evil.com/@admin@starfleet.com@/login'
    result = '<div><p><a href="http://evil.com/@admin@starfleet.com@/login">Phishing link</a></p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'does not convert an email address inside a bc(class). code block' do
    source = 'bc(alert). Contact @admin@starfleet.com@ for access.'
    result = '<div><pre class="alert"><code class="alert">Contact @admin@starfleet.com@ for access.</code></pre></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'renders an email address with a dotted local part wrapped in @...@ as inline code' do
    source = 'Contact @first.last@starfleet.com@ for access.'
    result = '<div><p>Contact <code>first.last@starfleet.com</code> for access.</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'renders an email address with a hyphenated local part wrapped in @...@ as inline code' do
    source = 'Contact @first-last@starfleet.com@ for access.'
    result = '<div><p>Contact <code>first-last@starfleet.com</code> for access.</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'leaves an email address inside a bare URL untouched so it stays one string for AutolinkFilter' do
    source = 'http://evil.com/@admin@starfleet.com@/login'
    result = '<div><p>http://evil.com/@admin@starfleet.com@/login</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'degrades gracefully, without raising, when input already contains the internal sentinel character' do
    source = "Weird\uFDD0input and contact @admin@starfleet.com@ for access."
    result = '<div><p>Weird@input and contact <code>admin@starfleet.com</code> for access.</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'leaves an unterminated inline-code span untouched' do
    source = '@unterminated@inline.code'
    result = '<div><p>@unterminated@inline.code</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'leaves adjacent double @ markers untouched' do
    source = '@@multipleinline@@'
    result = '<div><p>@@multipleinline@@</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'leaves mismatched @ markers untouched' do
    source = '@@@mismatched@@'
    result = '<div><p>@@@mismatched@@</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

  it 'does not protect a bare email address that is not wrapped in @...@' do
    source = 'Contact admin@starfleet.com for access.'
    result = '<div><p>Contact admin@starfleet.com for access.</p></div>'
    expect(described_class.call(source, {}).to_s).to eq(result)
  end

end
