require 'spec_helper'
describe 'Tracker Validation' do
  attr_reader :emitter
  
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
    context 'with two events' do
      before(:all) do
        @emitter ||= Snowly::Emitter.new(emitter_type: 'closure')
      end
      context 'when both are valid' do
        let(:se1) { Snowly::Transformer.transform(valid_se) }
        let(:se2) { Snowly::Transformer.transform(invalid_se) }
        it 'returns 200' do
          tracker.track_struct_event(*valid_se.values)
          tracker.track_struct_event(*valid_se.values)
          tracker.flush
          expect(response.code).to eq '200'
        end
        it 'returns empty errors' do
          tracker.track_struct_event(*valid_se.values)
          tracker.track_struct_event(*valid_se.values)
          tracker.flush
          expect(JSON.load(response.body).first['errors']).to be_empty
          expect(JSON.load(response.body).last['errors']).to be_empty
        end
      end
      context 'when one is invalid' do
        it 'returns 500' do
          tracker.track_struct_event(*valid_se.values)
          tracker.track_struct_event(*invalid_se.values)
          tracker.flush
          expect(response.code).to eq '500'
        end
        it 'returns errors' do
          tracker.track_struct_event(*valid_se.values)
          tracker.track_struct_event(*invalid_se.values)
          tracker.flush
          expect(JSON.load(response.body).first['errors']).to be_empty
          expect(JSON.load(response.body).last['errors'].count).to eq 2
        end
      end
    end

    %w(cloudfront closure).each do |emitter_type|
      let(:response)  { emitter.responses.first }
      let(:body)      { JSON.load(response.body).first['content'] }
      let(:errors)    { JSON.load(response.body).first['errors'] }

      context "with emitter: #{emitter_type}" do
        before(:all) do
          @emitter ||= Snowly::Emitter.new(emitter_type: emitter_type)
        end
        context 'with valid structured event request' do
          let(:translated_se) { Snowly::Transformer.transform(valid_se) }

          it 'returns 200 for valid structured event request' do
            tracker.track_struct_event(*valid_se.values)
            tracker.flush
            expect(response.code).to eq '200'
          end
          it 'returns valid content' do
            tracker.track_struct_event(*valid_se.values)
            tracker.flush
            expect(body).to include translated_se
          end
        end

        context 'with invalid structured event' do
          let(:translated_se) { Snowly::Transformer.transform(invalid_se) }
          it 'returns 500 for invalid structured event request' do
            tracker.track_struct_event(*invalid_se.values)
            tracker.flush
            expect(response.code).to eq '500'
          end
          it 'returns errors' do
            tracker.track_struct_event(*invalid_se.values)
            tracker.flush
            expect(errors.count).to eq 2
          end
        end
        context 'with context' do
          context 'and context is valid' do
            before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
            let(:valid_se_co) { valid_se.merge(co: [valid_co_object]) }
            it 'returns 200' do
              tracker.track_struct_event(*valid_se_co.values)
              tracker.flush
              expect(response.code).to eq '200'
            end
          end
          context 'and context is invalid' do
            let(:invalid_se_co) { valid_se.merge(co: [invalid_co_object]) }
            it 'returns errors' do
              tracker.track_struct_event(*invalid_se_co.values)
              tracker.flush
              expect(errors.count).to eq 2
            end
          end
        end
        context 'with unstructured event' do
          before { stub_request(:get, context_url).to_return(body: context_content, status: 200) }
          context 'when valid' do
            it 'returns 200' do
              tracker.track_unstruct_event(valid_ue_object)
              tracker.flush
              expect(response.code).to eq '200'
            end
          end
          context 'when invalid' do
            it 'returns errors' do
              tracker.track_unstruct_event(invalid_ue_object)
              tracker.flush
              expect(errors.count).to eq 1
            end
          end
        end
      end
    end
  end

end