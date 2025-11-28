require 'rails_helper'

describe HTML::Pipeline::Dradis::Sanitize do
  let(:context) {
    { whitelist: HTML::Pipeline::Dradis::Sanitize::ALLOWLIST }
  }
  let(:pipeline_filters) { [HTML::Pipeline::SanitizationFilter] }
  let(:pipeline) { HTML::Pipeline.new(pipeline_filters, context) }

  context 'allowed elements' do
    it 'allows style="text-align" as a property when sanitizing' do
      str = "<div><p style=\"text-align:center;\">test alignment</p></div>"

      expect(pipeline.call(str)[:output].to_s).to eq(str)
    end
  end


  context 'disallowed elements' do
    %w[
      script iframe object embed applet link style video audio
      form meta svg math
    ].each do |disallowed_element|

      it "sanitizes the #{disallowed_element}" do
        str = "<#{disallowed_element}>test output</#{disallowed_element}>"
        expect(['test output', '']).to include(pipeline.call(str)[:output].to_s)
      end
    end
  end

  context 'disallowed attribtues' do
    %w[
      onclick onload onerror onfocus onmouseover onanimationstart onplay
    ].each do |attribute|
      it "sanitizes the on attribute #{attribute}" do
        str = "<div on=\"#{attribute}\">test output</div>"
        expect(pipeline.call(str)[:output].to_s).to eq('<div>test output</div>')
      end
    end

    %w[
      expression() background:url() color:test
    ].each do |attribute|
      it "sanitizes the style attribute #{attribute}" do
        str = "<div style=\"#{attribute}\">test output</div>"
        expect(pipeline.call(str)[:output].to_s).to eq('<div>test output</div>')
      end
    end
  end
end
