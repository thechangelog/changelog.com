# vim: set ft=config
pragma optional_param geoip_opt_in true;
pragma optional_param max_object_size 2147483648;
pragma optional_param smiss_max_object_size 5368709120;
pragma optional_param fetchless_purge_all 1;
pragma optional_param default_ssl_check_cert 1;
pragma optional_param max_backends 5;
pragma optional_param customer_id "3ftsRHRYALfBKJ8uiRDUFJ";
C!
W!
# Backends

backend F_Changelog_Origin_Host__Linode_Kubernetes_Engine {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 2s;
    .dynamic = true;
    .first_byte_timeout = 10s;
    .host = "22.changelog.com";
    .host_header = "22.changelog.com";
    .max_connections = 200;
    .port = "443";
    .saintmode_threshold = 10;
    .share_key = "7gKbcKSKGDyqU7IuDr43eG";

    .ssl = true;
    .ssl_cert_hostname = "22.changelog.com";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "22.changelog.com";

    .probe = {
        .expected_response = 200;
        .initial = 1;
        .interval = 60s;
        .request = "GET /health HTTP/1.1" "Host: 22.changelog.com" "Connection: close" "User-Agent: Varnish/fastly (healthcheck)";
        .threshold = 1;
        .timeout = 5s;
        .window = 2;
      }
}
backend F_S3_Asset_Host {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "changelog-assets.s3.amazonaws.com";
    .host_header = "changelog-assets.s3.amazonaws.com";
    .max_connections = 200;
    .port = "443";
    .share_key = "7gKbcKSKGDyqU7IuDr43eG";

    .ssl = true;
    .ssl_cert_hostname = "changelog-assets.s3.amazonaws.com";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "changelog-assets.s3.amazonaws.com";

    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: changelog-assets.s3.amazonaws.com" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
      }
}











sub vcl_recv {
#--FASTLY RECV BEGIN
  if (req.restarts == 0) {
    if (!req.http.X-Timer) {
      set req.http.X-Timer = "S" time.start.sec "." time.start.usec_frac;
    }
    set req.http.X-Timer = req.http.X-Timer ",VS0";
  }


# Snippet do-not-cache-app-requests-when-cookie-present : 100
if (req.http.cookie) {
  if (req.http.host != "cdn.changelog.com") {
    return (pass);
  }
}

  declare local var.fastly_req_do_shield BOOL;
  set var.fastly_req_do_shield = (req.restarts == 0);

# Snippet set-auto-webp-for-all-pngs-jpgs : 100
if (req.url.ext ~ "(?i)^(png|jpe?g)$") {
        set req.url = querystring.add(req.url, "auto", "webp");
}

  # default conditions
  set req.backend = F_Changelog_Origin_Host__Linode_Kubernetes_Engine;

  if (!req.http.Fastly-SSL) {
     error 801 "Force SSL";
  }




    # end default conditions



  # Request Condition: embed.js Prio: 10
  if( req.url ~ "^/embed\.js$" ) {




    # ResponseObject: embed.js
    error 900 "Fastly Internal";
      }
  #end condition
  # Request Condition: www.changelog.com host Prio: 10
  if( req.http.host == "www.changelog.com" ) {




    # ResponseObject: 301 redirect
    error 901 "Fastly Internal";
      }
  #end condition
  # Request Condition: CDN Request Prio: 10
  if( req.http.host == "cdn.changelog.com" ) {

    set req.backend = F_S3_Asset_Host;


      }
  #end condition
  # Request Condition: Fastly Image Optimizer Request Prio: 10
  if( req.url.ext ~ "(?i)^(gif|png|jpe?g|webp)$" ) {


  # Header rewrite Fastly Image Optimizer : 1


        set req.http.x-fastly-imageopto-api = "fastly";




      }
  #end condition




#--FASTLY RECV END



    if (req.request != "HEAD" && req.request != "GET" && req.request != "FASTLYPURGE") {
      return(pass);
    }


    return(lookup);
}


sub vcl_fetch {


#--FASTLY FETCH BEGIN

  if (beresp.status >= 500 && beresp.status < 600) {

    if (stale.exists) {
      return(deliver_stale);
    }

    if (req.restarts < 1 && (req.request == "GET" || req.request == "HEAD")) {
      restart;
    }

  }
  set beresp.stale_if_error = 43200s;


# record which cache ran vcl_fetch for this object and when
  set beresp.http.Fastly-Debug-Path = "(F " server.identity " " now.sec ") " if(beresp.http.Fastly-Debug-Path, beresp.http.Fastly-Debug-Path, "");

# generic mechanism to vary on something
  if (req.http.Fastly-Vary-String) {
    if (beresp.http.Vary) {
      set beresp.http.Vary = "Fastly-Vary-String, "  beresp.http.Vary;
    } else {
      set beresp.http.Vary = "Fastly-Vary-String, ";
    }
  }



 # priority: 0



  # Header rewrite CORS Allow * : 10


        set beresp.http.Access-Control-Allow-Origin = "*";



  # Header rewrite Set Surrogate Control from S3 : 10


        set beresp.http.Surrogate-Control = beresp.http.x-amz-meta-surrogate-control;



  # Header rewrite Set Surrogate Key from S3 : 10


        set beresp.http.Surrogate-Key = beresp.http.x-amz-meta-surrogate-key;



  # Header rewrite Stream mp3s directly if they are not in caches - Streaming Miss : 10


        set beresp.do_stream = true;




  # Gzip Default Gzip Policy
  if ((beresp.status == 200 || beresp.status == 404) && (beresp.http.content-type ~ "^(text/html|application/x-javascript|text/css|application/javascript|text/javascript|application/json|application/vnd\.ms-fontobject|application/x-font-opentype|application/x-font-truetype|application/x-font-ttf|application/xml|font/eot|font/opentype|font/otf|image/svg\+xml|image/vnd\.microsoft\.icon|text/plain|text/xml)\s*($|;)" || req.url ~ "\.(css|js|html|eot|ico|otf|ttf|json|svg)($|\?)" ) ) {

    # always set vary to make sure uncompressed versions dont always win
    if (!beresp.http.Vary ~ "Accept-Encoding") {
      if (beresp.http.Vary) {
        set beresp.http.Vary = beresp.http.Vary ", Accept-Encoding";
      } else {
         set beresp.http.Vary = "Accept-Encoding";
      }
    }
    if (req.http.Accept-Encoding == "gzip") {
      set beresp.gzip = true;
    }
  }


#--FASTLY FETCH END



  if(req.restarts > 0 ) {
    set beresp.http.Fastly-Restarts = req.restarts;
  }

  if (beresp.http.Set-Cookie) {
    set req.http.Fastly-Cachetype = "SETCOOKIE";
    return (pass);
  }

  if (beresp.http.Cache-Control ~ "private") {
    set req.http.Fastly-Cachetype = "PRIVATE";
    return (pass);
  }

  if (beresp.status == 500 || beresp.status == 503) {
    set req.http.Fastly-Cachetype = "ERROR";
    set beresp.ttl = 1s;
    set beresp.grace = 5s;
    return (deliver);
  }


  if (beresp.http.Expires || beresp.http.Surrogate-Control ~ "max-age" || beresp.http.Cache-Control ~"(s-maxage|max-age)") {
    # keep the ttl here
  } else {
        # apply the default ttl
    set beresp.ttl = 3600s;

  }

  return(deliver);
}

sub vcl_hit {
#--FASTLY HIT BEGIN

# we cannot reach obj.ttl and obj.grace in deliver, save them when we can in vcl_hit
  set req.http.Fastly-Tmp-Obj-TTL = obj.ttl;
  set req.http.Fastly-Tmp-Obj-Grace = obj.grace;

  {
    set req.http.Fastly-Cachetype = "HIT";
  }

#--FASTLY HIT END
  if (!obj.cacheable) {
    return(pass);
  }
  return(deliver);
}

sub vcl_miss {
#--FASTLY MISS BEGIN


# this is not a hit after all, clean up these set in vcl_hit
  unset req.http.Fastly-Tmp-Obj-TTL;
  unset req.http.Fastly-Tmp-Obj-Grace;

  {
    if (req.http.Fastly-Check-SHA1) {
       error 550 "Doesnt exist";
    }

#--FASTLY BEREQ BEGIN
    {
      {
        if (req.http.Fastly-FF) {
          set bereq.http.Fastly-Client = "1";
        }
      }
      {
        # do not send this to the backend
        unset bereq.http.Fastly-Original-Cookie;
        unset bereq.http.Fastly-Original-URL;
        unset bereq.http.Fastly-Vary-String;
        unset bereq.http.X-Varnish-Client;
      }
      if (req.http.Fastly-Temp-XFF) {
         if (req.http.Fastly-Temp-XFF == "") {
           unset bereq.http.X-Forwarded-For;
         } else {
           set bereq.http.X-Forwarded-For = req.http.Fastly-Temp-XFF;
         }
         # unset bereq.http.Fastly-Temp-XFF;
      }
    }
#--FASTLY BEREQ END


 #;

    set req.http.Fastly-Cachetype = "MISS";

  }

#--FASTLY MISS END
  return(fetch);
}

sub vcl_deliver {


#--FASTLY DELIVER BEGIN

# record the journey of the object, expose it only if req.http.Fastly-Debug.
  if (req.http.Fastly-Debug || req.http.Fastly-FF) {
    set resp.http.Fastly-Debug-Path = "(D " server.identity " " now.sec ") "
       if(resp.http.Fastly-Debug-Path, resp.http.Fastly-Debug-Path, "");

    set resp.http.Fastly-Debug-TTL = if(obj.hits > 0, "(H ", "(M ")
       server.identity
       if(req.http.Fastly-Tmp-Obj-TTL && req.http.Fastly-Tmp-Obj-Grace, " " req.http.Fastly-Tmp-Obj-TTL " " req.http.Fastly-Tmp-Obj-Grace " ", " - - ")
       if(resp.http.Age, resp.http.Age, "-")
       ") "
       if(resp.http.Fastly-Debug-TTL, resp.http.Fastly-Debug-TTL, "");

    set resp.http.Fastly-Debug-Digest = digest.hash_sha256(req.digest);
  } else {
    unset resp.http.Fastly-Debug-Path;
    unset resp.http.Fastly-Debug-TTL;
    unset resp.http.Fastly-Debug-Digest;
  }

  # add or append X-Served-By/X-Cache(-Hits)
  {

    if(!resp.http.X-Served-By) {
      set resp.http.X-Served-By  = server.identity;
    } else {
      set resp.http.X-Served-By = resp.http.X-Served-By ", " server.identity;
    }

    set resp.http.X-Cache = if(resp.http.X-Cache, resp.http.X-Cache ", ","") if(fastly_info.state ~ "HIT($|-)", "HIT", "MISS");

    if(!resp.http.X-Cache-Hits) {
      set resp.http.X-Cache-Hits = obj.hits;
    } else {
      set resp.http.X-Cache-Hits = resp.http.X-Cache-Hits ", " obj.hits;
    }

  }

  if (req.http.X-Timer) {
    set resp.http.X-Timer = req.http.X-Timer ",VE" time.elapsed.msec;
  }

  # VARY FIXUP
  {
    # remove before sending to client
    set resp.http.Vary = regsub(resp.http.Vary, "Fastly-Vary-String, ", "");
    if (resp.http.Vary ~ "^\s*$") {
      unset resp.http.Vary;
    }
  }
  unset resp.http.X-Varnish;


  # Pop the surrogate headers into the request object so we can reference them later
  set req.http.Surrogate-Key = resp.http.Surrogate-Key;
  set req.http.Surrogate-Control = resp.http.Surrogate-Control;

  # If we are not forwarding or debugging unset the surrogate headers so they are not present in the response
  if (!req.http.Fastly-FF && !req.http.Fastly-Debug) {
    unset resp.http.Surrogate-Key;
    unset resp.http.Surrogate-Control;
  }

  if(resp.status == 550) {
    return(deliver);
  }
  #default response conditions


# Header rewrite Generated by force TLS and enable HSTS : 100


      set resp.http.Strict-Transport-Security = "max-age=31557600";



    # Request Condition: embed.js Prio: 10    
  if (resp.status == 900 ) {
     set resp.status = 200;
     set resp.response = "OK";
  }      # Request Condition: www.changelog.com host Prio: 10    
  if (resp.status == 901 ) {
     set resp.status = 301;
     set resp.response = "Moved Permanently";
  }


  # Response Condition: www 301 redirect is happening Prio: 10
  if( req.http.host == "www.changelog.com" && resp.status == 301 ) {

# Header rewrite Set Location for www 301 redirect : 10


  if (!resp.http.Location) {
      set resp.http.Location = "https://changelog.com" req.url;
              }



  }

#--FASTLY DELIVER END
  return(deliver);
}

sub vcl_error {
#--FASTLY ERROR BEGIN

  if (obj.status >= 500 && obj.status < 600) {
    if (stale.exists) {
      return(deliver_stale);
    }
  }

  if (obj.status == 801) {
     set obj.status = 301;
     set obj.response = "Moved Permanently";
     set obj.http.Location = "https://" req.http.host req.url;
     synthetic {""};
     return (deliver);
  }


    # Response Condition: embed.js Prio: 10  

if (obj.status == 900 ) {
   set obj.http.Content-Type = "application/javascript";
   synthetic {"!function(e){function t(t){var r=t.getAttribute('data-src'),i=t.getAttribute('data-theme')||'night',n=e.createElement('iframe');n.setAttribute('src',r+'?theme='+i+'&referrer='+e.location.href),n.setAttribute('width','100%'),n.setAttribute('height','220'),n.setAttribute('scrolling','no'),n.setAttribute('frameborder','no'),n.setAttribute('title','Changelog Podcast'),t.parentNode.replaceChild(n,t),this.id=+new Date,this.src=n.src,this.iframe=n}var r='https://changelog.com',i=e.getElementsByClassName('changelog-episode'),n=[],a=function(e,t){t.context='player.js',t.version='0.0.11',t.listener=e.id;try{e.iframe.contentWindow.postMessage(JSON.stringify(t),r)}catch(e){}},s=function(e){if(e.origin!==r)return!1;var t=JSON.parse(e.data);if('player.js'!==t.context)return!1;if('ready'===t.event)for(var i=n.length-1;i>=0;i--)n[i].src===t.value.src&&a(n[i],{method:'addEventListener',value:'play'});if('play'===t.event)for(var i=n.length-1;i>=0;i--)n[i].id!==t.listener&&a(n[i],{method:'pause'})};window.addEventListener('message',s);for(var o=i.length-1;o>-1;o--)n.push(new t(i[o]))}(document);"};
   return(deliver);
}
      # Response Condition: www.changelog.com host Prio: 10  

if (obj.status == 901 ) {
   return(deliver);
}


  if (req.http.Fastly-Restart-On-Error) {
    if (obj.status == 503 && req.restarts == 0) {
      restart;
    }
  }

  {
    if (obj.status == 550) {
      return(deliver);
    }
  }
#--FASTLY ERROR END



}

sub vcl_pipe {
#--FASTLY PIPE BEGIN
  {


#--FASTLY BEREQ BEGIN
    {
      {
        if (req.http.Fastly-FF) {
          set bereq.http.Fastly-Client = "1";
        }
      }
      {
        # do not send this to the backend
        unset bereq.http.Fastly-Original-Cookie;
        unset bereq.http.Fastly-Original-URL;
        unset bereq.http.Fastly-Vary-String;
        unset bereq.http.X-Varnish-Client;
      }
      if (req.http.Fastly-Temp-XFF) {
         if (req.http.Fastly-Temp-XFF == "") {
           unset bereq.http.X-Forwarded-For;
         } else {
           set bereq.http.X-Forwarded-For = req.http.Fastly-Temp-XFF;
         }
         # unset bereq.http.Fastly-Temp-XFF;
      }
    }
#--FASTLY BEREQ END


    #;
    set req.http.Fastly-Cachetype = "PIPE";
    set bereq.http.connection = "close";
  }
#--FASTLY PIPE END

}

sub vcl_pass {
#--FASTLY PASS BEGIN


  {

#--FASTLY BEREQ BEGIN
    {
      {
        if (req.http.Fastly-FF) {
          set bereq.http.Fastly-Client = "1";
        }
      }
      {
        # do not send this to the backend
        unset bereq.http.Fastly-Original-Cookie;
        unset bereq.http.Fastly-Original-URL;
        unset bereq.http.Fastly-Vary-String;
        unset bereq.http.X-Varnish-Client;
      }
      if (req.http.Fastly-Temp-XFF) {
         if (req.http.Fastly-Temp-XFF == "") {
           unset bereq.http.X-Forwarded-For;
         } else {
           set bereq.http.X-Forwarded-For = req.http.Fastly-Temp-XFF;
         }
         # unset bereq.http.Fastly-Temp-XFF;
      }
    }
#--FASTLY BEREQ END


 #;
    set req.http.Fastly-Cachetype = "PASS";
  }

#--FASTLY PASS END

}

sub vcl_log {
#--FASTLY LOG BEGIN

  # default response conditions

  # honeycomb honeycomb_gerhard_2021_10_27
  log {"syslog "} req.service_id {" honeycomb-gerhard-2021-10-27 :: "} {"{     "time":""} strftime({"%Y-%m-%dT%H:%M:%SZ"}, time.start) {"",     "data":  {       "service_id":""} req.service_id {"",       "time_elapsed":"} time.elapsed.usec {",       "request":""} req.request {"",       "origin":""} req.backend {"",       "host":""} if(req.http.Fastly-Orig-Host, req.http.Fastly-Orig-Host, req.http.Host) {"",       "url":""} cstr_escape(req.url) {"",       "protocol":""} req.proto {"",       "is_ipv6":"} if(req.is_ipv6, "true", "false") {",       "is_tls":"} if(req.is_ssl, "true", "false") {",       "is_h2":"} if(fastly_info.is_h2, "true", "false") {",       "client_ip":""} req.http.Fastly-Client-IP {"",       "geo_city":""} client.geo.city.utf8 {"",       "geo_country_code":""} client.geo.country_code {"",       "server_datacenter":""} server.datacenter {"",       "request_referer":""} cstr_escape(req.http.referer) {"",       "request_user_agent":""} cstr_escape(req.http.user-agent) {"",       "request_accept_content":""} cstr_escape(req.http.accept) {"",       "request_accept_language":""} cstr_escape(req.http.accept-language) {"",       "request_accept_charset":""} cstr_escape(req.http.accept-charset) {"",       "cache_status":""} regsub(fastly_info.state, "^(HIT-(SYNTH)|(HITPASS|HIT|MISS|PASS|ERROR|PIPE)).*", "\2\3")  {"",       "hits":""} obj.hits {"",       "lastuse":""} obj.lastuse {"",       "status":""} resp.status {"",       "content_type":""} cstr_escape(resp.http.content-type) {"",       "req_header_size":"} req.header_bytes_read {",       "req_body_size":"} req.body_bytes_read {",       "resp_header_size":"} resp.header_bytes_written {",       "resp_body_size":"} resp.body_bytes_written "     }   }";

  # Response Condition: The Changelog Prio: 10
  if( req.url ~ "^/uploads/podcast/" && !req.http.Fastly-FF ) {

    # s3 S3_The_Changelog
    log {"syslog "} req.service_id {" S3 The Changelog :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Go Time Prio: 10
  if( req.url ~ "^/uploads/gotime/" && !req.http.Fastly-FF ) {

    # s3 S3_Go_Time
    log {"syslog "} req.service_id {" S3 Go Time :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: RFC Prio: 10
  if( req.url ~ "^/uploads/rfc/" && !req.http.Fastly-FF ) {

    # s3 S3_RFC
    log {"syslog "} req.service_id {" S3 RFC :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Founders Talk Prio: 10
  if( req.url ~ "^/uploads/founderstalk/" && !req.http.Fastly-FF ) {

    # s3 S3_Founders_Talk
    log {"syslog "} req.service_id {" S3 Founders Talk :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Spotlight Prio: 10
  if( req.url ~ "^/uploads/spotlight/" && !req.http.Fastly-FF ) {

    # s3 S3_Spotlight
    log {"syslog "} req.service_id {" S3 Spotlight :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: JS Party Prio: 10
  if( req.url ~ "^/uploads/jsparty/" && !req.http.Fastly-FF ) {

    # s3 S3_JS_Party
    log {"syslog "} req.service_id {" S3 JS Party :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Practical AI Prio: 10
  if( req.url ~ "^/uploads/practicalai/" && !req.http.Fastly-FF ) {

    # s3 S3_Practical_AI
    log {"syslog "} req.service_id {" S3 Practical AI :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: The React Podcast Prio: 10
  if( req.url ~ "^/uploads/reactpodcast/" && !req.http.Fastly-FF ) {

    # s3 The_React_Podcast
    log {"syslog "} req.service_id {" The React Podcast :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: AFK Prio: 10
  if( req.url ~ "^/uploads/afk/" && !req.http.Fastly-FF ) {

    # s3 S3_AFK
    log {"syslog "} req.service_id {" S3 AFK :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Backstage Prio: 10
  if( req.url ~ "^/uploads/backstage/" && !req.http.Fastly-FF ) {

    # s3 S3_Backstage
    log {"syslog "} req.service_id {" S3 Backstage :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Brain Science Prio: 10
  if( req.url ~ "^/uploads/brainscience/" && !req.http.Fastly-FF ) {

    # s3 S3_Brain_Science
    log {"syslog "} req.service_id {" S3 Brain Science :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Ship It Prio: 10
  if( req.url ~ "^/uploads/shipit/" && !req.http.Fastly-FF ) {

    # s3 S3_Ship_It
    log {"syslog "} req.service_id {" S3 Ship It :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }


#--FASTLY LOG END

}

sub vcl_hash {

#--FASTLY HASH BEGIN



  #if unspecified fall back to normal
  {


    set req.hash += req.url;
    set req.hash += req.http.host;
    set req.hash += req.vcl.generation;
    return (hash);
  }
#--FASTLY HASH END


}

