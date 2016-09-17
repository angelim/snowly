module EventAssignments
  def with_event_definitions(&block)
    context "importing event definitions" do

      let(:context_url)      { "http://iglucentral.com/schemas/com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0" }
      let(:ue_url)           { "http://iglucentral.com/schemas/com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0" }
      let(:context_location) { 'iglu:com.snowplowanalytics.snowplow/contexts/jsonschema/1-0-0'}
      let(:ue_location)      { 'iglu:com.snowplowanalytics.snowplow/unstruct_event/jsonschema/1-0-0'}
      let(:context_content)  { File.read(File.expand_path('../../fixtures/snowplow_context.json', __FILE__)) }
      let(:ue_content)       { File.read(File.expand_path('../../fixtures/snowplow_ue.json', __FILE__)) }
      let(:alternative_protocol_schema) { File.expand_path('../../protocol_resolver/snowplow_protocol.json', __FILE__) }

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
          'se_ca' => 'web',
          'se_ac' => 'click',
          'se_la' => 'label',
          'se_pr' => 'property',
          'se_va' => 1
        }
      end

      let(:invalid_se) do
        valid_se.merge('se_ca' => '', 'se_ac' => '')
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
          schema: 'iglu:snowly/context_test_0/jsonschema/1-0-0',
          data: {
            name: 'name',
            age: 10
          }
        }
      end

      let(:valid_co_object) do
        SnowplowTracker::SelfDescribingJson.new(valid_co_data[:schema],valid_co_data[:data])
      end

      let(:invalid_co_object) do
        SnowplowTracker::SelfDescribingJson.new(valid_co_data[:schema], {age: 1000})
      end

      let(:valid_co_data_1) do
        {
          schema: 'iglu:snowly/context_test_1/jsonschema/1-0-0',
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
      
      let(:non_array_cx) { Base64.strict_encode64(not_array_co) }
      let(:valid_base64_co) { Base64.strict_encode64(valid_co) }
      let(:valid_urlsafe_base64_co) { Base64.urlsafe_encode64(valid_co) }
      let(:valid_ue_data) do
        {
          schema: "iglu:snowly/event_test/jsonschema/1-0-0",
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

      let(:valid_ue_object) do
        SnowplowTracker::SelfDescribingJson.new(valid_ue_data[:schema], valid_ue_data[:data])
      end
      let(:invalid_ue_object) do
        SnowplowTracker::SelfDescribingJson.new(valid_ue_data[:schema], valid_ue_data[:data].merge(elapsed_time: 'none'))
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

      let(:valid_base64_ue) { Base64.strict_encode64(valid_ue) }
    
      instance_eval &block
    end
    
  end

end