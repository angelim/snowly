require 'spec_helper'

describe Snowly::Request do
  let(:query)             { "e=se&aid=app&tna=1.0"}
  let(:parsed_hash)       { {"e" => 'se', 'aid' => 'app', 'tna' => '1.0'} }
  let(:hash)              { {"event" => "se", "app_id" => "app", "name_tracker" => "1.0" } }
  let(:json)              { hash.to_json }
  let(:get_request)       { Snowly::Request.new query }
  let(:post_request)      { Snowly::Request.new(parsed_hash) }

  describe '#as_json' do
    context 'with querystring' do
      it 'returns transformed JSON' do
        expect(get_request.as_json).to eq json
      end
    end
    context 'with post payload' do
      it 'returns transformed JSON', :focus do
        expect(post_request.as_json).to eq json
      end
    end
  end

  describe '#as_hash' do
    context 'with querystring' do
      it 'returns transformed hash' do
        expect(get_request.as_hash).to eq hash
      end
    end
    context 'with post payload' do
      it 'returns transformed hash' do
        expect(post_request.as_hash).to eq hash
      end
    end
  end

  describe '#parse_query' do
    it 'returns hash from query string' do
      parsed_payload = get_request.parse_query(query)
      expect(parsed_payload).to eq parsed_hash
    end
  end
end