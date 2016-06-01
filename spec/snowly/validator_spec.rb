require 'yaml'
require 'rack/utils'
require 'spec_helper'

describe Snowly::Validator do
  def to_query(hash)
    Rack::Utils.build_nested_query(hash)
  end
  before { Snowly.local_iglu_resolver_path = File.expand_path("../../fixtures", __FILE__)+"/" }
  before { Snowly::SchemaCache.instance.reset_cache }

  let(:context_url)      { "http://iglucentral.com/schemas/com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0" }
  let(:ue_url)           { "http://iglucentral.com/schemas/com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0" }
  let(:context_location) { 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0'}
  let(:ue_location)      { 'iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0'}
  let(:context_content)  { File.read(File.expand_path('../../fixtures/snowplow_context.json', __FILE__)) }
  let(:ue_content)       { File.read(File.expand_path('../../fixtures/snowplow_ue.json', __FILE__)) }

  let(:validator) { Snowly::Validator.new to_query(hash) }
  let(:valid_root) do
    {
      uid: 1,
      aid: 'app',
      tna: '1.0',
      dtm: Time.now.to_i,
      e: 'se',
      ua: 'user agent',
      p: 'mob',
      eid: 'eventid',
      tv: 'tracker-1'
    }
  end

  let(:valid_se) do
    {
      se_ca: 'web',
      se_ac: 'click',
      se_la: 'label',
      se_pr: 'property',
      se_va: 1
    }
  end

  let(:invalid_se) do
    valid_se.delete_if { |k,v| ['se_ac', 'se_ca'].include?(k.to_s) }
  end

  let(:valid_co) do
      {
        schema: 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0',
        data: [ valid_co_data ]
      }.to_json
  end

  let(:invalid_co) do
      {
        schema: 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0',
        data: [ valid_co_data.deep_merge(data: {age: 1000}) ]
      }.to_json
  end

  let(:not_array_co) do
    {
      schema: 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0',
      data: valid_co_data
    }.to_json
  end

  let(:valid_co_data) do
    {
      schema: 'iglu:schemas/contexts/context_test_0/1-0-0',
      data: {
        name: 'name',
        age: 10
      }
    }
  end

  let(:valid_co_data_1) do
    {
      schema: 'iglu:schemas/contexts/context_test_1/1-0-0',
      data: {
        street: 'street'
      }
    }
  end

  let(:valid_co_multiple) do
    {
      schema: 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0',
      data: [ valid_co_data, valid_co_data_1]
    }.to_json
  end

  let(:invalid_co_multiple) do
    {
      schema: 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0',
      data: [ valid_co_data, valid_co_data_1.deep_merge(data: {street: 'home'}) ]
    }.to_json
  end
  
  let(:non_array_cx) { Base64.urlsafe_encode64(not_array_co) }
  let(:valid_base64_co) { Base64.urlsafe_encode64(valid_co) }
  let(:invalid_base64_co) do
    invalid = valid_co.dup
    invalid[:schema] = 'invalid'
    contexts = invalid.to_json
    Base64.encode64(contexts)
  end
  let(:valid_ue_data) do
    {
      schema: "iglu:schemas/unstruct/event_test/1-0-0",
      data: {
        category: 'reading',
        name: 'view',
        elapsed_time: 10,
        object_id: "oid",
        number_property_name: 'nprop',
        number_property_value: 1,
        string_property_name: 'sprop',
        string_property_value: 'sval'
      }
    }
  end

  let(:valid_ue) do
      {
        schema: 'iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0',
        data: valid_ue_data
      }.to_json
  end

  let(:invalid_ue) do
      {
        schema: 'iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0',
        data: valid_ue_data.deep_merge(data: { elapsed_time: 'none'} )
      }.to_json
  end

  let(:valid_base64_ue) { Base64.urlsafe_encode64(valid_ue) }

  context 'with mininum required attributes' do
    let(:hash) { valid_root.merge(e: 'ad') }
    it 'returns true' do
       expect(validator.validate).to be true
    end
    it 'does not set errors' do
      validator.validate
      expect(validator.errors).to eq []
    end
  end
  context 'with wrong type for attribute' do
    let(:hash) { valid_root.merge(e: 'ad', tid: 'none') }
    it 'sets error' do
      validator.validate
      puts validator.errors
      expect(validator.errors.count).to eq 1
    end
  end
  describe 'CustomDependency' do
    context 'with missing custom dependency' do
      let(:hash) { valid_root.merge(invalid_se) }
      it 'sets error' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 2
      end
    end
  end
  context 'with missing dependency' do
    let(:hash) { valid_root.merge(valid_se).tap{|n| n.delete(:p)} }
    it 'sets error' do
      validator.validate
      puts validator.errors
      expect(validator.errors.count).to eq 1
    end
  end
  context 'with context' do
    before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
    context 'and context is base64 and valid' do
      let(:hash) { valid_root.merge(e: 'ad', cx: valid_base64_co) }
      it 'returns true' do
        expect(validator.validate).to be true
      end
    end
    context 'and context is not an array' do
      let(:hash) { valid_root.merge(e: 'ad', co: not_array_co) }
      it 'returns false' do
        expect(validator.validate).to be false
      end
    end
    context 'and context is valid' do
      let(:hash) { valid_root.merge(e: 'ad', co: valid_co) }
      it 'returns true' do
        expect(validator.validate).to be true
      end
      it 'does not set errors' do
        validator.validate
        expect(validator.errors).to eq []
      end
    end
    context 'and context is invalid' do
      let(:hash) { valid_root.merge(e: 'ad', co: invalid_co) }
      it 'sets error' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 1
      end
    end
  end
  context 'with multiple contexts' do
    before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
    context "and they're both valid" do
      let(:hash) { valid_root.merge(e: 'ad', co: valid_co_multiple) }
      it 'returns true' do
        expect(validator.validate).to be true
      end
    end
    context 'and one is invalid' do
      let(:hash) { valid_root.merge(e: 'ad', co: invalid_co_multiple) }
      it 'returns true' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 1
      end
    end
  end
  context 'with unstruct event' do
    before { stub_request(:get, ue_url).to_return(body: ue_content, status: 200) }
    context 'and event is valid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_pr: valid_ue) }
      it 'returns true' do
        expect(validator.validate).to be true
      end
    end
    context 'and event is base64 and valid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_px: valid_base64_ue) }
      it 'returns true' do
        expect(validator.validate).to be true
      end
    end
    context 'when event is invalid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_pr: invalid_ue) }
      it 'returns true' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 1
      end
    end
  end
  context 'with unstruct event and context' do
    before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
    before { stub_request(:get, ue_url).to_return(body: ue_content, status: 200) }
    context 'and event is valid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_pr: valid_ue, co: valid_co) }
      it 'returns true' do
        expect(validator.validate).to be true
      end
    end
    context 'and context is invalid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_pr: valid_ue, co: invalid_co) }
      it 'sets error' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 1
      end
    end
    context 'and event is invalid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_pr: invalid_ue, co: valid_co) }
      it 'returns true' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 1
      end
    end
    context 'and event and context are invalid' do
      let(:hash) { valid_root.merge(e: 'ue', ue_pr: invalid_ue, co: invalid_co) }
      it 'returns true' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 2
      end
    end

  end
end