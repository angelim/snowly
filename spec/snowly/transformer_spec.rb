require 'spec_helper'
describe Snowly::Transformer do
  let(:source) do
    {
      "e" => "e",
      "ip" => "ip",
      "aid" => "aid",
      "p" => "p",
      "tid" => "tid",
      "uid" => "uid",
      "duid" => "duid",
      "nuid" => "nuid",
      "ua" => "ua",
      "fp" => "fp",
      "vid" => "vid",
      "sid" => "sid",
      "dtm" => "dtm",
      "ttm" => "ttm",
      "stm" => "stm",
      "tna" => "tna",
      "tv" => "tv",
      "cv" => "cv",
      "lang" => "lang",
      "f_pdf" => "f_pdf",
      "f_fla" => "f_fla",
      "f_java" => "f_java",
      "f_dir" => "f_dir",
      "f_qt" => "f_qt",
      "f_realp" => "f_realp",
      "f_wma" => "f_wma",
      "f_gears" => "f_gears",
      "f_ag" => "f_ag",
      "cookie" => "cookie",
      "res" => "res",
      "cd" => "cd",
      "tz" => "tz",
      "refr" => "refr",
      "url" => "url",
      "page" => "page",
      "cs" => "cs",
      "ds" => "ds",
      "vp" => "vp",
      "eid" => "eid",
      "co" => { name:'co' }.to_json,
      "cx" => "cx",
      "ev_ca" => "ev_ca",
      "ev_ac" => "ev_ac",
      "ev_la" => "ev_la",
      "ev_pr" => "ev_pr",
      "ev_va" => "ev_va",
      "se_ca" => "se_ca",
      "se_ac" => "se_ac",
      "se_la" => "se_la",
      "se_pr" => "se_pr",
      "se_va" => "se_va",
      "ue_pr" => { name:'ue_pr' }.to_json,
      "ue_px" => "ue_px",
      "tr_id" => "tr_id",
      "tr_af" => "tr_af",
      "tr_tt" => "tr_tt",
      "tr_tx" => "tr_tx",
      "tr_sh" => "tr_sh",
      "tr_ci" => "tr_ci",
      "tr_st" => "tr_st",
      "tr_co" => "tr_co",
      "ti_id" => "ti_id",
      "ti_sk" => "ti_sk",
      "ti_na" => "ti_na",
      "ti_nm" => "ti_nm",
      "ti_ca" => "ti_ca",
      "ti_pr" => "ti_pr",
      "ti_qu" => "ti_qu",
      "pp_mix" => "pp_mix",
      "pp_max" => "pp_max",
      "pp_miy" => "pp_miy",
      "pp_may" => "pp_may",
      "tr_cu" => "tr_cu",
      "ti_cu" => "ti_cu"
    }
  end
  let(:translated) do
    {
      "event" => "e",
      "user_ipaddress" => "ip",
      "app_id" => "aid",
      "platform" => "p",
      "txn_id" => "tid",
      "user_id" => "uid",
      "domain_userid" => "duid",
      "network_userid" => "nuid",
      "useragent" => "ua",
      "user_fingerprint" => "fp",
      "domain_sessionidx" => "vid",
      "domain_sessionid" => "sid",
      "dvce_created_tstamp" => "dtm",
      "true_tstamp" => "ttm",
      "dvce_sent_tstamp" => "stm",
      "name_tracker" => "tna",
      "v_tracker" => "tv",
      "v_collector" => "cv",
      "br_lang" => "lang",
      "br_features_pdf" => "f_pdf",
      "br_features_flash" => "f_fla",
      "br_features_java" => "f_java",
      "br_features_director" => "f_dir",
      "br_features_quicktime" => "f_qt",
      "br_features_realplayer" => "f_realp",
      "br_features_windowsmedia" => "f_wma",
      "br_features_gears" => "f_gears",
      "br_features_silverlight" => "f_ag",
      "br_cookies" => "cookie",
      "screen_res_width_x_height" => "res",
      "br_colordepth" => "cd",
      "os_timezone" => "tz",
      "page_referrer" => "refr",
      "page_url" => "url",
      "page_title" => "page",
      "doc_charset" => "cs",
      "doc_width_x_height" => "ds",
      "browser_viewport_width_x_height" => "vp",
      "event_id" => "eid",
      "contexts" => "co",
      "contexts" => "cx",
      "se_category" => "ev_ca",
      "se_action" => "ev_ac",
      "se_label" => "ev_la",
      "se_property" => "ev_pr",
      "se_value" => "ev_va",
      "se_category" => "se_ca",
      "se_action" => "se_ac",
      "se_label" => "se_la",
      "se_property" => "se_pr",
      "se_value" => "se_va",
      "unstruct_event" => "ue_pr",
      "unstruct_event" => "ue_px",
      "tr_orderid" => "tr_id",
      "tr_affiliation" => "tr_af",
      "tr_total" => "tr_tt",
      "tr_tax" => "tr_tx",
      "tr_shipping" => "tr_sh",
      "tr_city" => "tr_ci",
      "tr_state" => "tr_st",
      "tr_country" => "tr_co",
      "ti_orderid" => "ti_id",
      "ti_sku" => "ti_sk",
      "ti_name" => "ti_na",
      "ti_name" => "ti_nm",
      "ti_category" => "ti_ca",
      "ti_price" => "ti_pr",
      "ti_quantity" => "ti_qu",
      "pp_xoffset_min" => "pp_mix",
      "pp_xoffset_max" => "pp_max",
      "pp_yoffset_min" => "pp_miy",
      "pp_yoffset_max" => "pp_may",
      "tr_currency" => "tr_cu",
      "ti_currency" => "ti_cu"
    }
  end
  describe '.translate' do
    it 'maps query string keys to snowplow fields' do
      expect(subject.transform(source)).to eq translated
    end
    context 'with unknown keys' do
      let(:source_with_unknown) { source.merge("unknown" => "unknown")}
      it 'ignores unknown keys' do
        expect(subject.transform(source_with_unknown)).to eq translated
      end
    end
  end
  describe '.convert' do
    context 'with string type' do
      let(:result) { subject.convert('valid', 'string') }
      it 'returns string' do
        expect(result).to be_a String
      end
    end
    context 'with integer type' do
      context 'and value is integer' do
        let(:result) { subject.convert('1', 'integer') }
        it 'returns integer' do
          expect(result).to eq 1
        end
      end
      context 'and value is not integer' do
        let(:result) { subject.convert('abc', 'integer') }
        it 'returns string' do
          expect(result).to eq 'abc'
        end
      end
    end
    context 'with float type' do
      let(:result) { subject.convert('1.99', 'number') }
      context 'and value is float' do
        it 'returns float' do
          expect(result).to eq 1.99
        end
      end
      context 'and value is not float' do
        let(:result) { subject.convert('abc', 'number') }
        it 'returns string' do
          expect(result).to eq 'abc'
        end
      end
    end
  end
end
