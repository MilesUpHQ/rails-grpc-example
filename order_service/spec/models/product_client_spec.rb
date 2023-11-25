require 'rails_helper'

RSpec.describe ProductClient, type: :model do
  describe '.fetch_details' do
    let(:product_ids) { [1, 2, 3] }
    let(:product_service_url) { "#{ProductClient::PRODUCT_SERVICE_URL}?product_ids=#{product_ids.join(',')}" }
    let(:mocked_response) { instance_double('HTTParty::Response', success?: true, parsed_response: { 'data' => 'some data' }) }

    before do
      allow(HTTParty).to receive(:get).with(product_service_url).and_return(mocked_response)
    end

    it 'fetches product details successfully' do
      result = ProductClient.fetch_details(product_ids)
      expect(HTTParty).to have_received(:get).with(product_service_url)
      expect(result).to eq({ 'data' => 'some data' })
    end

    context 'when the response is unsuccessful' do
      let(:mocked_response) { instance_double('HTTParty::Response', success?: false, parsed_response: {}) }

      it 'returns an empty hash' do
        result = ProductClient.fetch_details(product_ids)
        expect(HTTParty).to have_received(:get).with(product_service_url)
        expect(result).to eq({})
      end
    end
  end
end
