require 'rails_helper'

describe Dradis::Plugins::Echo::LanguageToolService do
  let(:service) do
    described_class.new(
      address: 'http://languagetool.local:8081',
      fields: { 'Description' => 'This are a mistake.' },
      language: 'en-GB'
    )
  end

  def stub_http(body:, response_class: Net::HTTPOK, code: '200')
    response = response_class.new('1.1', code, '')
    allow(response).to receive(:body).and_return(body)
    http = instance_double(Net::HTTP)
    allow(http).to receive(:post).and_return(response)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    http
  end

  describe '#call' do
    context 'when LanguageTool returns matches' do
      let(:lt_body) do
        {
          'matches' => [
            {
              'offset' => 5,
              'length' => 3,
              'message' => 'Possible agreement error',
              'replacements' => [{ 'value' => 'is' }, { 'value' => 'was' }]
            }
          ]
        }.to_json
      end

      before { stub_http(body: lt_body) }

      it 'returns one match per flagged segment' do
        expect(service.call.length).to eq(1)
      end

      it 'maps all match attributes' do
        match = service.call.first
        expect(match[:field_name]).to eq('Description')
        expect(match[:offset]).to eq(5)
        expect(match[:length]).to eq(3)
        expect(match[:message]).to eq('Possible agreement error')
        expect(match[:exact]).to eq('are')
        expect(match[:replacements]).to eq(['is', 'was'])
      end

      it 'caps replacements at 3' do
        many_body = {
          'matches' => [
            {
              'offset' => 0,
              'length' => 4,
              'message' => 'Error',
              'replacements' => [1, 2, 3, 4].map { |n| { 'value' => "r#{n}" } }
            }
          ]
        }.to_json
        stub_http(body: many_body)

        expect(service.call.first[:replacements].length).to eq(3)
      end
    end

    it 'sends the language to LanguageTool' do
      http = stub_http(body: { 'matches' => [] }.to_json)

      service.call

      expect(http).to have_received(:post).with('/v2/check', include('language=en-GB'))
    end

    context 'when LanguageTool rejects the request' do
      before do
        stub_http(
          body: "Error: 'en-XX' is not a language code known to LanguageTool.",
          code: '400',
          response_class: Net::HTTPBadRequest
        )
      end

      it 'raises RejectedError with the LanguageTool message' do
        expect { service.call }.to raise_error(
          described_class::RejectedError,
          "LanguageTool rejected the request: Error: 'en-XX' is not a language code known to LanguageTool."
        )
      end
    end

    context 'when LanguageTool returns invalid JSON' do
      before { stub_http(body: '<html>Bad gateway</html>') }

      it 'raises UnavailableError' do
        expect { service.call }.to raise_error(described_class::UnavailableError)
      end
    end

    context 'when LanguageTool times out' do
      before { allow(Net::HTTP).to receive(:start).and_raise(Net::ReadTimeout) }

      it 'raises UnavailableError' do
        expect { service.call }.to raise_error(described_class::UnavailableError)
      end
    end

    context 'when LanguageTool connection is refused' do
      before { allow(Net::HTTP).to receive(:start).and_raise(Errno::ECONNREFUSED) }

      it 'raises UnavailableError' do
        expect { service.call }.to raise_error(described_class::UnavailableError)
      end
    end
  end
end
