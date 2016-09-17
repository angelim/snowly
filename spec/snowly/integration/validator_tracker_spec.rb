require 'spec_helper'
describe 'Tracker Validation' do
  attr_reader :emitter
  
  before(:all) do
    @emitter ||= Snowly::Emitter.new
  end

  before { emitter.reset_responses! }

  let(:snowplow_subject) do
    @snow_subject ||= begin
      SnowplowTracker::Subject.new.tap do |snow_subject|
        snow_subject.set_platform 'mob'
        snow_subject.set_user_id '1'
        snow_subject.set_useragent 'user agent'
      end
    end
  end

  let(:tracker) do
      SnowplowTracker::Tracker.new(emitter.emitter, snowplow_subject, nil, 'tracker-1')
  end

  with_event_definitions do
    let(:response)  { emitter.responses.first }
    let(:body)      { JSON.load(response.body)['content'] }
    let(:errors)    { JSON.load(response.body)['errors'] }

    context 'with valid structured event request' do
      let(:translated_se) { Snowly::Transformer.transform(valid_se) }

      it 'returns 200 for valid structured event request' do
        tracker.track_struct_event(*valid_se.values)
        expect(response.code).to eq '200'
      end
      it 'returns valid content' do
        tracker.track_struct_event(*valid_se.values)
        expect(body).to include translated_se
      end
    end

    context 'with invalid structured event' do
      let(:translated_se) { Snowly::Transformer.transform(invalid_se) }
      it 'returns 500 for invalid structured event request' do
        tracker.track_struct_event(*invalid_se.values)
        expect(response.code).to eq '500'
      end
      it 'returns errors' do
        tracker.track_struct_event(*invalid_se.values)
        expect(errors.count).to eq 2
      end
    end
    context 'with context' do
      context 'and context is valid' , :focus do
        before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
        let(:valid_se_co) { valid_se.merge(co: [valid_co_object]) }
        it 'returns 200' do
          tracker.track_struct_event(*valid_se_co.values)
          expect(response.code).to eq '200'
        end
      end
      context 'and context is invalid' do
        let(:invalid_se_co) { valid_se.merge(co: [invalid_co_object]) }
        it 'returns errors' do
          tracker.track_struct_event(*invalid_se_co.values)
          expect(errors.count).to eq 2
        end
      end
    end
    context 'with unstructured event' do
      before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
      context 'when valid' do
        it 'returns 200' do
          tracker.track_unstruct_event(valid_ue_object)
          expect(response.code).to eq '200'
        end
      end
      context 'when invalid' do
        it 'returns errors' do
          tracker.track_unstruct_event(invalid_ue_object)
          expect(errors.count).to eq 1
        end
      end
    end
  end

end