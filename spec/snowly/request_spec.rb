require 'spec_helper'

describe Snowly::Request do
  let(:query)       { "e=se&aid=app&tna=1.0"}
  let(:parsed_hash) { {"e" => 'se', 'aid' => 'app', 'tna' => '1.0'} }
  let(:hash)        { {"event" => "se", "app_id" => "app", "name_tracker" => "1.0" } }
  let(:json)        { hash.to_json }
  let(:request)     { Snowly::Request.new query }

  describe '#as_json' do
    it 'returns transformed JSON' do
      expect(request.as_json).to eq json
    end
  end

  describe '#as_hash' do
    it 'returns transformed hash' do
      expect(request.as_hash).to eq hash  
    end
  end

  describe 'parsed_query' do
    it 'returns hash from query string' do
      expect(request.parsed_query).to eq parsed_hash  
    end
  end
end