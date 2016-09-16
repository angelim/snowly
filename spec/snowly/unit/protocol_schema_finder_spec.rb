require 'spec_helper'

describe Snowly::ProtocolSchemaFinder do
  let(:default_description) { 'Representation of Snowplow Protocol in JSON Schema format for validation' }
  
  context 'with default protocol schema' do
    let(:schema_description) { Snowly::ProtocolSchemaFinder.new.schema['description'] }
    it 'returns the correct schema' do
      expect(schema_description).to eq default_description
    end
  end

  context 'with custom protocol schema' do
    let(:alternative_description) { 'Alternative Snowplow Protocol' }
    let(:alternative_schema_path) { File.expand_path('../../../protocol_resolver/snowplow_protocol.json', __FILE__) }

    context 'when schema is given' do
      let(:schema_description) { Snowly::ProtocolSchemaFinder.new(alternative_schema_path).schema['description'] }
      it 'returns the correct schema' do
        expect(schema_description).to eq alternative_description
      end
    end

    context 'when schema is in resolver path' do
      before do
        allow(Snowly).to receive(:development_iglu_resolver_path).and_return(File.expand_path("../../../protocol_resolver", __FILE__)+"/") 
      end
      let(:schema_description) { Snowly::ProtocolSchemaFinder.new.schema['description'] }
      it 'returns the correct schema' do
        expect(schema_description).to eq alternative_description
      end
    end
  end
end