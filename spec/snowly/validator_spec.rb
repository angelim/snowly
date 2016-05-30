require 'yaml'
require 'rack/utils'
require 'spec_helper'

describe Snowly::Validator do
  def to_query(hash)
    Rack::Utils.build_nested_query(hash)
  end
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
      }
  end

  let(:valid_co_data) do
    {
      schema: 'iglu:br.com.digitalpages/dp_client_context/jsonschema/1-0-0',
      data: {
        system_id: 1,
        institution_id: 1
      }
    }
  end

  let(:non_array_co) do
      {
        schema: 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0',
        data: valid_co_data
      }
  end
  
  let(:non_array_cx) { Base64.encode64(non_array_co.to_json) }
  let(:valid_base64_co) { Base64.encode64(valid_co.to_json) }
  let(:invalid_base64_co) do
    invalid = valid_co.dup
    invalid[:schema] = 'invalid'
    contexts = invalid.to_json
    Base64.encode64(contexts)
  end
  let(:valid_ue) do
    {
      schema: "iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0",
      data: {
        schema: "iglu:br.com.digitalpages/dp_publication_event/jsonschema/1-0-0",
        data: {
          category: 'reading',
          name: 'view_page',
          publication_id: 1,
          page: 'page',
          load_time: 10,
          elapsed_time: 10,
          object_id: "oid",
          number_property_name: 'nprop',
          number_property_value: 1,
          string_property_name: 'sprop',
          string_property_value: 'sval'
        }
      }
    }
  end
  let(:valid_base64_ue) { Base64.encode64(valid_ue.to_json) }

  context 'with mininum required attributes', :focus do
    let(:hash) { valid_root.merge(e: 'ad') }
    it 'returns true' do
       expect(validator.validate).to be true
    end
    it 'does not set errors' do
      validator.validate
      expect(validator.errors).to eq []
    end
  end
  context 'with wrong type for attribute', focus: true do
    let(:hash) { valid_root.merge(e: 'ad', tid: 'none') }
    it 'sets error' do
      validator.validate
      puts validator.errors
      expect(validator.errors.count).to eq 1
    end
  end
  describe 'CustomDependency' do
    context 'with missing custom dependency', :focus do
      let(:hash) { valid_root.merge(invalid_se) }
      it 'sets error' do
        validator.validate
        puts validator.errors
        expect(validator.errors.count).to eq 2
      end
    end
  end
  context 'with missing dependency', :focus do
    let(:hash) { valid_root.merge(valid_se).tap{|n| n.delete(:p)} }
    it 'sets error' do
      validator.validate
      puts validator.errors
      expect(validator.errors.count).to eq 1
    end
  end
end