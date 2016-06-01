require 'spec_helper'

describe "Collector" do
  describe 'GET #index' do
    it "should allow accessing the home page" do
      get '/'
      expect(last_response).to be_ok
    end

    it 'has showcase links' do
      get '/'
      expect(last_response.body).to include("/i?")
    end
    context 'when the local resolver path is set' do
      before { Snowly.local_iglu_resolver_path = 'myresolverpath' }
      it 'shows local iglu resolver' do
        get '/'
        expect(last_response.body).to include("myresolverpath")
      end
    end
    context 'when no resolver has been set' do
      before { Snowly.local_iglu_resolver_path = nil }
      it 'shows warning' do
        get '/'
        expect(last_response.body).to include("The Local Iglu Resolver Path is missing")
      end
    end
    context 'when no schemas were resolved' do
      before { Snowly.local_iglu_resolver_path = nil }
      it 'shows empty resolver message' do
        get '/'
        expect(last_response.body).to include("No resolved schemas")
      end
    end
    context 'when there are resolved schemas' do
      before { Snowly.local_iglu_resolver_path = File.expand_path("../../../fixtures", __FILE__) }
      it 'shows schemas in local resolver' do
        get '/'
        expect(last_response.body).to include("fixtures/schemas/contexts/context_test_0/1-0-0")
      end
    end
  end
  describe 'GET /i' do
    context 'with a valid request' do
      let(:valid_request) { '/i?&e=pv&page=Root%20README&url=http%3A%2F%2Fgithub.com%2Fsnowplow%2Fsnowplow&aid=snowplow&p=web&tv=no-js-0.1.0&ua=firefox&&eid=u2i3' }
      it 'responds with 200' do
        get valid_request
        expect(last_response).to be_ok
      end
    end
    context 'with an invalid request' do
      let(:invalid_request) { '/i?&e=pv&page=Root%20README&url=http%3A%2F%2Fgithub.com%2Fsnowplow%2Fsnowplow&aid=snowplow&p=i&tv=no-js-0.1.0' }
      it 'responds with 500' do
        get invalid_request
        expect(last_response).not_to be_ok
      end
      it 'renders errors' do
        get invalid_request
        expect(last_response.body).to include("errors")
      end
    end
  end
end