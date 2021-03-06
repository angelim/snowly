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
      before { Snowly.development_iglu_resolver_path = 'myresolverpath' }
      it 'shows local iglu resolver' do
        get '/'
        expect(last_response.body).to include("myresolverpath")
      end
    end
    context 'when no resolver has been set' do
      before { Snowly.development_iglu_resolver_path = nil }
      it 'shows warning' do
        get '/'
        expect(last_response.body).to include("The Local Iglu Resolver Path is missing")
      end
    end
    context 'when no schemas were resolved' do
      before { Snowly.development_iglu_resolver_path = nil }
      it 'shows empty resolver message' do
        get '/'
        expect(last_response.body).to include("No resolved schemas")
      end
    end
    context 'when there are resolved schemas' do
      before { Snowly.development_iglu_resolver_path = File.expand_path("../../../fixtures", __FILE__) }
      it 'shows schemas in local resolver' do
        get '/'
        expect(last_response.body).to include("fixtures/snowly/context_test_0/jsonschema/1-0-0")
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
      context 'when in production mode' do
        it 'responds with image content type' do
          get valid_request
          expect(last_response.content_type).to eq 'image/gif'
        end
      end
      context 'when in debug mode' do
        before { Snowly.debug_mode = true }
        it 'responds with json content type' do
          get valid_request
          expect(last_response.content_type).to eq 'application/json'
        end
      end
    end
    context 'with an invalid request' do
      before { Snowly.debug_mode = false }
      let(:invalid_request) { '/i?&e=pv&page=Root%20README&url=http%3A%2F%2Fgithub.com%2Fsnowplow%2Fsnowplow&aid=snowplow&p=i&tv=no-js-0.1.0' }
      it 'responds with 500' do
        get invalid_request
        expect(last_response).not_to be_ok
      end
      it 'renders errors' do
        get invalid_request
        expect(last_response.body).to include("errors")
      end
      it 'always responds with json content type' do
        get invalid_request
        expect(last_response.content_type).to eq 'application/json'
      end
    end
  end
  describe 'POST /com.snowplowanalytics.snowplow/tp2' do
    let(:url) { '/com.snowplowanalytics.snowplow/tp2' }
    context 'with a valid request' do
      let(:valid_params) { {"data" => [{ "e"=>"pv", "page"=>"Root README", "url"=>"http://github.com/snowplow/snowplow", "aid"=>"snowplow", "p"=>"web", "tv"=>"no-js-0.1.0", "ua"=>"firefox", "eid"=>"u2i3" }] } }
      it 'responds with 200' do
        post url, JSON.dump(valid_params)
        expect(last_response).to be_ok
      end
    end
    context 'with an invalid request' do
      let(:invalid_params) { { "data" => [{ "e"=>"pv", "page"=>"Root README", "url"=>"http://github.com/snowplow/snowplow", "aid"=>"snowplow", "p"=>"web", "tv"=>"no-js-0.1.0" }] } }
      it 'responds with 500' do
        post url, invalid_params
        expect(last_response).not_to be_ok
      end
      it 'renders errors' do
        post url, JSON.dump(invalid_params)
        expect(last_response.body).to include("errors")
      end
    end
  end
end