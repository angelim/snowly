require 'yaml'
require 'rack/utils'
require 'spec_helper'

describe Snowly::Validator do
  def to_query(hash)
    Rack::Utils.build_nested_query(hash)
  end
  before { Snowly.development_iglu_resolver_path = File.expand_path("../../../fixtures", __FILE__)+"/" }
  before { Snowly::SchemaCache.instance.reset_cache }

  let(:validator) { Snowly::Validator.new to_query(hash) }

  with_event_definitions do
    context 'with mininum required attributes' do
      let(:hash) { valid_root.merge(e: 'ad') }
      it 'returns true' do
         expect(validator.validate).to be true
      end
      it 'does not set errors' do
        validator.validate
        expect(validator.errors).to eq []
      end
      context 'and an alternative more restrictive protocol schema' do
        let(:custom_schema) { Snowly::ProtocolSchemaFinder.new(alternative_protocol_schema).schema }
        before do
          allow_any_instance_of(Snowly::Validator)
            .to receive(:protocol_schema)
            .and_return(custom_schema)
        end
        it 'set errors' do
          validator.validate
          puts validator.errors
          expect(validator.errors.count).to eq 2
        end
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
      context 'and context is urlsafe_base64 and valid' do
        let(:hash) { valid_root.merge(e: 'ad', cx: valid_urlsafe_base64_co) }
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
end