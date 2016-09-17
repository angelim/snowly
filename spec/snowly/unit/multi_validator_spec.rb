require 'spec_helper'

describe Snowly::MultiValidator do
  let(:invalid_request) { { "e"=>"pv", "page"=>"Root README", "url"=>"http://github.com/snowplow/snowplow", "aid"=>"snowplow", "p"=>"web", "tv"=>"no-js-0.1.0" } }
  let(:valid_request)   { { "e"=>"pv", "page"=>"Root README", "url"=>"http://github.com/snowplow/snowplow", "aid"=>"snowplow", "p"=>"web", "tv"=>"no-js-0.1.0", "ua"=>"firefox", "eid"=>"u2i3" } }
  let(:valid_params)    { {"data" => [valid_request, valid_request] } }
  let(:invalid_params)  { {"data" => [valid_request, invalid_request] } }
  describe '#validate' do
    it 'calls validate for each request' do
      multi = Snowly::MultiValidator.new(valid_params)
      multi.validators.each do |validator|
        expect(validator).to receive(:validate)
      end
      multi.validate
    end
    it 'returns whether all requests are valid' do
      expect(Snowly::MultiValidator.new(valid_params).validate).to be true
    end
  end
  describe 'valid?' do
    context 'when all requests are valid' do
      it 'returns true' do
        multi = Snowly::MultiValidator.new(valid_params)
        multi.validate
        expect(multi).to be_valid
      end
    end
    context 'when one of the requests is invalid' do
      it 'returns false' do
        multi = Snowly::MultiValidator.new(invalid_params)
        multi.validate
        expect(multi).not_to be_valid
      end
    end
  end
end
