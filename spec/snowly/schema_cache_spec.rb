require 'spec_helper'

describe Snowly::SchemaCache do
  before { Snowly.development_iglu_resolver_path = File.expand_path("../../fixtures", __FILE__)+"/" }
  before { Snowly::SchemaCache.instance.reset_cache }
  it 'is singleton' do
    expect(Snowly::SchemaCache.instance).to eq Snowly::SchemaCache.instance    
  end
  let(:file_content) { File.read(File.expand_path('../../fixtures/snowly/context_test_0/jsonschema/1-0-0', __FILE__)) }
  
  context 'with external schema' do
    let(:url)           { "http://iglucentral.com/schemas/com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0" }
    let(:location)      { 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0'}
    context 'when already loaded' do
      before do
        stub_request(:get, url).to_return(body: file_content, status: 200)
        Snowly::SchemaCache.instance[location]
      end
      it 'does not save on cache' do
        expect(Snowly::SchemaCache.instance).not_to receive(:save_in_cache).with(location)
        Snowly::SchemaCache.instance[location]
      end
      it 'loads schema from cache' do
        expect(Snowly::SchemaCache.instance[location]).to eq file_content
      end
    end
    context 'when not yet loaded' do
      it 'saves on cache' do
        stub_request(:get, url).to_return(body: file_content, status: 200)
        expect(Snowly::SchemaCache.instance).to receive(:save_in_cache).with(location)
        Snowly::SchemaCache.instance[location]
      end
      it 'loads and returns schema' do
        stub_request(:get, url).to_return(body: file_content, status: 200)
        expect(Snowly::SchemaCache.instance[location]).to eq file_content
      end
    end
  end

  context 'with local schema' do
    let(:location) { 'iglu:snowly/context_test_0/jsonschema/1-0-0'}
    context 'when already loaded' do
      before { Snowly::SchemaCache.instance[location] }
      it 'does not save on cache' do
        expect(Snowly::SchemaCache.instance).not_to receive(:save_in_cache).with(location)
        Snowly::SchemaCache.instance[location]
      end
      it 'loads schema from cache' do
        expect(Snowly::SchemaCache.instance[location]).to eq file_content
      end
    end
    context 'when not yet loaded' do
      it 'saves on cache' do
        expect(Snowly::SchemaCache.instance).to receive(:save_in_cache).with(location)
        Snowly::SchemaCache.instance[location]
      end
      it 'loads and returns schema' do
        expect(Snowly::SchemaCache.instance[location]).to eq file_content
      end
    end
  end
end

