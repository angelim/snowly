module Snowly
  module Transformer
    module_function
    # Boolean fields are mapped to string because the tracker sends '1' or '0' in the query string.
    # The actual conversion to boolean happens during the enrichment phase.
    MAP = {
      "e" => { field: "event", type: 'string' },
      "ip" => { field: "user_ipaddress", type: "string" },
      "aid" => { field: "app_id", type: "string" },
      "p" => { field: "platform", type: "string" },
      "tid" => { field: "txn_id", type: "integer" },
      "uid" => { field: "user_id", type: "string" },
      "duid" => { field: "domain_userid", type: "string" },
      "nuid" => { field: "network_userid", type: "string" },
      "ua" => { field: "useragent", type: "string" },
      "fp" => { field: "user_fingerprint", type: "integer" },
      "vid" => { field: "domain_sessionidx", type: "integer" },
      "sid" => { field: "domain_sessionid", type: "string" },
      "dtm" => { field: "dvce_created_tstamp", type: "integer" },
      "ttm" => { field: "true_tstamp", type: "integer" },
      "stm" => { field: "dvce_sent_tstamp", type: "integer" },
      "tna" => { field: "name_tracker", type: "string" },
      "tv" => { field: "v_tracker", type: "string" },
      "cv" => { field: "v_collector", type: "string" },
      "lang" => { field: "br_lang", type: "string" },
      "f_pdf" => { field: "br_features_pdf", type: "string" },
      "f_fla" => { field: "br_features_flash", type: "string" },
      "f_java" => { field: "br_features_java", type: "string" },
      "f_dir" => { field: "br_features_director", type: "string" },
      "f_qt" => { field: "br_features_quicktime", type: "string" },
      "f_realp" => { field: "br_features_realplayer", type: "string" },
      "f_wma" => { field: "br_features_windowsmedia", type: "string" },
      "f_gears" => { field: "br_features_gears", type: "string" },
      "f_ag" => { field: "br_features_silverlight", type: "string" },
      "cookie" => { field: "br_cookies", type: "string" },
      "res" => { field: "screen_res_width_x_height", type: "string" },
      "cd" => { field: "br_colordepth", type: "string" },
      "tz" => { field: "os_timezone", type: "string" },
      "refr" => { field: "page_referrer", type: "string" },
      "url" => { field: "page_url", type: "string" },
      "page" => { field: "page_title", type: "string" },
      "cs" => { field: "doc_charset", type: "string" },
      "ds" => { field: "doc_width_x_height", type: "string" },
      "vp" => { field: "browser_viewport_width_x_height", type: "string" },
      "eid" => { field: "event_id", type: "string" },
      "co" => { field: "contexts", type: "string" },
      "cx" => { field: "contexts", type: "base64" },
      "ev_ca" => { field: "se_category", type: "string" },
      "ev_ac" => { field: "se_action", type: "string" },
      "ev_la" => { field: "se_label", type: "string" },
      "ev_pr" => { field: "se_property", type: "string" },
      "ev_va" => { field: "se_value", type: "string" },
      "se_ca" => { field: "se_category", type: "string" },
      "se_ac" => { field: "se_action", type: "string" },
      "se_la" => { field: "se_label", type: "string" },
      "se_pr" => { field: "se_property", type: "string" },
      "se_va" => { field: "se_value", type: "number" },
      "ue_pr" => { field: "unstruct_event", type: "string" },
      "ue_px" => { field: "unstruct_event", type: "base64" },
      "tr_id" => { field: "tr_orderid", type: "string" },
      "tr_af" => { field: "tr_affiliation", type: "string" },
      "tr_tt" => { field: "tr_total", type: "number" },
      "tr_tx" => { field: "tr_tax", type: "number" },
      "tr_sh" => { field: "tr_shipping", type: "number" },
      "tr_ci" => { field: "tr_city", type: "string" },
      "tr_st" => { field: "tr_state", type: "string" },
      "tr_co" => { field: "tr_country", type: "string" },
      "ti_id" => { field: "ti_orderid", type: "string" },
      "ti_sk" => { field: "ti_sku", type: "string" },
      "ti_na" => { field: "ti_name", type: "string" },
      "ti_nm" => { field: "ti_name", type: "string" },
      "ti_ca" => { field: "ti_category", type: "string" },
      "ti_pr" => { field: "ti_price", type: "number" },
      "ti_qu" => { field: "ti_quantity", type: "integer" },
      "pp_mix" => { field: "pp_xoffset_min", type: "integer" },
      "pp_max" => { field: "pp_xoffset_max", type: "integer" },
      "pp_miy" => { field: "pp_yoffset_min", type: "integer" },
      "pp_may" => { field: "pp_yoffset_max", type: "integer" },
      "tr_cu" => { field: "tr_currency", type: "string" },
      "ti_cu" => { field: "ti_currency", type: "integer" }
    }
    def transform(parsed_query)
      parsed_query.inject({}) do |all, (key, value)|
        if node = MAP[key]
          field = node[:field]
          all[field] = convert(value, node[:type])
        end
        all
      end
    end

    def convert(value, type)
      begin
        case type
        when 'base64' then JSON.parse(Base64.urlsafe_decode64(value))
        when 'integer' then Integer(value)
        when 'number' then Float(value)
        else
          value.to_s
        end
      rescue ArgumentError
        value.to_s
      end
    end
    
  end
end