require 'spec_helper'

describe Snowly::SchemaCache do
  it 'is singleton' do
    expect(Snowly::SchemaCache.instance).to eq Snowly::SchemaCache.instance    
  end

  let(:url)           { "http://iglucentral.com/schemas/com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0" }
  let(:location)      { 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0'}
  let(:file_content) { File.read(File.expand_path('../../../fixtures/snowly/context_test_0/jsonschema/1-0-0', __FILE__)) }
  
  context 'without development resolver' do
    before { Snowly.development_iglu_resolver_path = nil }
    before { Snowly::SchemaCache.instance.reset_cache }
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

  context 'with development resolver' do
    before { Snowly.development_iglu_resolver_path = File.expand_path("../../../fixtures", __FILE__)+"/" }
    before { Snowly::SchemaCache.instance.reset_cache }
    let(:location) { 'iglu:snowly/context_test_0/jsonschema/1-0-0'}
    context 'when schema is found' do
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
      context 'when using external resolver' do
        before { Snowly.development_iglu_resolver_path = "http://snowly"}
        let(:url) { "http://snowly/context_test_0/jsonschema/1-0-0" }
        it 'saves on cache' do
          stub_request(:get, url).to_return(body: file_content, status: 200)
          expect(Snowly::SchemaCache.instance).to receive(:save_in_cache).with(location)
          Snowly::SchemaCache.instance[location]
        end
      end
    end
    context 'when schema is not in development resolver' do
      let(:location) { 'iglu:snowly/context_test_0/jsonschema/2-0-0'}
      it 'warns about not finding schema in local resolver', :focus do
        stub_request(:get, url).to_return(body: file_content, status: 200)
        expect(Snowly.logger).to receive(:warn)
        Snowly::SchemaCache.instance[location]
      end
      it 'loads schema from iglucentral' do
        expect(Snowly::SchemaCache.instance).to receive(:save_in_cache).with(location)
        Snowly::SchemaCache.instance[location]
      end
    end
    context 'when schema is not in any resolver' do
      let(:location) { 'iglu:snowly/context_test_0/jsonschema/2-0-0'}
      it 'logs an error', :focus do
        stub_request(:get, url).to_return(body: 'not json', status: 200)
        expect(Snowly.logger).to receive(:error)
        Snowly::SchemaCache.instance[location]
      end
      it 'sets schema cache to nil' do
        expect(Snowly::SchemaCache.instance[location]).to be_nil
      end
    end
  end
end

