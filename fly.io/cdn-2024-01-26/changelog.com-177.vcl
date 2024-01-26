# Noticing changes to your VCL? The event log
# (https://docs.fastly.com/en/guides/reviewing-service-activity-with-the-event-log)
# in the web interface shows changes to your service's configurations and the
# change log on developer.fastly.com (https://developer.fastly.com/reference/changes/vcl/)
# provides info on changes to the Fastly-provided VCL itself.

pragma optional_param geoip_opt_in true;
pragma optional_param max_object_size 2147483648;
pragma optional_param smiss_max_object_size 5368709120;
pragma optional_param fetchless_purge_all 1;
pragma optional_param chash_randomize_on_pass true;
pragma optional_param default_ssl_check_cert 1;
pragma optional_param can_upgrade_in_recv true;
pragma optional_param max_backends 20;
pragma optional_param customer_id "3ftsRHRYALfBKJ8uiRDUFJ";
C!
W!
##############
# Image Optimization Settings
#
# avif: 0
# jpeg_quality: 85
# jpeg_type: auto
# resize_filter: lanczos3
# upscale: 0
# webp: 1
# webp_quality: 85

# Backends

backend F_Cloudflare_R2_Asset_Host {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "changelog.place";
    .host_header = "changelog.place";
    .max_connections = 1000;
    .port = "443";
    .share_key = "7gKbcKSKGDyqU7IuDr43eG";

    .ssl = true;
    .ssl_cert_hostname = "changelog.place";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "changelog.place";

    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: changelog.place" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
      }
}
backend F_fly_2024_01_12 {
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "changelog-2024-01-12.fly.dev";
    .max_connections = 1000;
    .port = "443";
    .share_key = "7gKbcKSKGDyqU7IuDr43eG";

    .ssl = true;
    .ssl_cert_hostname = "changelog-2024-01-12.fly.dev";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "changelog-2024-01-12.fly.dev";

    .probe = {
        .expected_response = 200;
        .initial = 9;
        .interval = 2s;
        .request = "GET /health HTTP/1.1" "Host: changelog-2024-01-12.fly.dev" "Connection: close" "User-Agent: Varnish/fastly (healthcheck)";
        .threshold = 7;
        .timeout = 5s;
        .window = 10;
      }
}
backend F_Cloudflare_R2_Feeds_Host {
    .always_use_host_header = true;
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "feeds.changelog.place";
    .host_header = "feeds.changelog.place";
    .max_connections = 1000;
    .port = "443";
    .share_key = "7gKbcKSKGDyqU7IuDr43eG";

    .ssl = true;
    .ssl_cert_hostname = "feeds.changelog.place";
    .ssl_check_cert = always;
    .ssl_sni_hostname = "feeds.changelog.place";

    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: feeds.changelog.place" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
      }
}





director ssl_shield_iad_va_us shield {
   .shield = "INTER-IAD-SSL";
}










# Snippet feeds-table : 100
table feeds {
  "/feed": "/feed.xml",
  "/afk/feed": "/afk.xml",
  "/brainscience/feed": "/brainscience.xml",
  "/founderstalk/feed": "/founderstalk.xml",
  "/friends/feed": "/friends.xml",
  "/gotime/feed": "/gotime.xml",
  "/interviews/feed": "/interviews.xml",
  "/jsparty/feed": "/jsparty.xml",
  "/master/feed": "/master.xml",
  "/news/feed": "/news.xml",
  "/podcast/feed": "/podcast.xml",
  "/posts/feed": "/posts.xml",
  "/practicalai/feed": "/practicalai.xml",
  "/plusplus/xae9heiphohtupha1Ahha3aexoo0oo4W/feed": "/plusplus.xml",
  "/rfc/feed": "/rfc.xml",
  "/shipit/feed": "/shipit.xml",
  "/spotlight/feed": "/spotlight.xml"
}

# Snippet news-redirects-table : 100
table news_redirects {
  "/uploads/podcast/news-2022-06-27/the-changelog-news-2022-06-27.mp3": "/uploads/news/1/changelog-news-1.mp3",
  "/uploads/podcast/news-2022-07-04/the-changelog-news-2022-07-04.mp3": "/uploads/news/2/changelog-news-2.mp3",
  "/uploads/podcast/news-2022-07-11/the-changelog-news-2022-07-11.mp3": "/uploads/news/3/changelog-news-3.mp3",
  "/uploads/podcast/news-2022-07-18/the-changelog-news-2022-07-18.mp3": "/uploads/news/4/changelog-news-4.mp3",
  "/uploads/podcast/news-2022-07-25/the-changelog-news-2022-07-25.mp3": "/uploads/news/5/changelog-news-5.mp3",
  "/uploads/podcast/news-2022-08-01/the-changelog-news-2022-08-01.mp3": "/uploads/news/6/changelog-news-6.mp3",
  "/uploads/podcast/news-2022-08-08/the-changelog-news-2022-08-08.mp3": "/uploads/news/7/changelog-news-7.mp3",
  "/uploads/podcast/news-2022-08-15/the-changelog-news-2022-08-15.mp3": "/uploads/news/8/changelog-news-8.mp3",
  "/uploads/podcast/news-2022-08-22/the-changelog-news-2022-08-22.mp3": "/uploads/news/9/changelog-news-9.mp3",
  "/uploads/podcast/news-2022-08-22/the-changelog-news-2022-08-22-j2g.mp3": "/uploads/news/9/changelog-news-9-j2g.mp3",
  "/uploads/podcast/news-2022-08-29/the-changelog-news-2022-08-29.mp3": "/uploads/news/10/changelog-news-10.mp3",
  "/uploads/podcast/news-2022-09-05/the-changelog-news-2022-09-05.mp3": "/uploads/news/11/changelog-news-11.mp3",
  "/uploads/podcast/news-2022-09-12/the-changelog-news-2022-09-12.mp3": "/uploads/news/12/changelog-news-12.mp3",
  "/uploads/podcast/news-2022-09-19/the-changelog-news-2022-09-19.mp3": "/uploads/news/13/changelog-news-13.mp3",
  "/uploads/podcast/news-2022-09-26/the-changelog-news-2022-09-26.mp3": "/uploads/news/14/changelog-news-14.mp3",
  "/uploads/podcast/news-2022-10-03/the-changelog-news-2022-10-03.mp3": "/uploads/news/15/changelog-news-15.mp3",
  "/uploads/podcast/news-2022-10-10/the-changelog-news-2022-10-10.mp3": "/uploads/news/16/changelog-news-16.mp3",
  "/uploads/podcast/news-2022-10-17/the-changelog-news-2022-10-17.mp3": "/uploads/news/17/changelog-news-17.mp3",
  "/uploads/podcast/news-2022-10-24/the-changelog-news-2022-10-24.mp3": "/uploads/news/18/changelog-news-18.mp3",
  "/uploads/podcast/news-2022-11-07/the-changelog-news-2022-11-07.mp3": "/uploads/news/19/changelog-news-19.mp3",
  "/uploads/podcast/news-2022-11-14/the-changelog-news-2022-11-14.mp3": "/uploads/news/20/changelog-news-20.mp3",
  "/uploads/podcast/news-2022-11-21/the-changelog-news-2022-11-21.mp3": "/uploads/news/21/changelog-news-21.mp3",
  "/uploads/podcast/news-2022-11-28/the-changelog-news-2022-11-28.mp3": "/uploads/news/22/changelog-news-22.mp3",
  "/uploads/podcast/news-2022-12-05/the-changelog-news-2022-12-05.mp3": "/uploads/news/23/changelog-news-23.mp3",
  "/uploads/podcast/news-2022-12-12/the-changelog-news-2022-12-12.mp3": "/uploads/news/24/changelog-news-24.mp3",
  "/uploads/podcast/news-2023-01-02/the-changelog-news-2023-01-02.mp3": "/uploads/news/25/changelog-news-25.mp3",
  "/uploads/podcast/news-2023-01-09/the-changelog-news-2023-01-09.mp3": "/uploads/news/26/changelog-news-26.mp3",
  "/uploads/podcast/news-2023-01-16/the-changelog-news-2023-01-16.mp3": "/uploads/news/27/changelog-news-27.mp3",
  "/uploads/podcast/news-2023-01-23/the-changelog-news-2023-01-23.mp3": "/uploads/news/28/changelog-news-28.mp3",
  "/uploads/podcast/news-2023-01-30/the-changelog-news-2023-01-30.mp3": "/uploads/news/29/changelog-news-29.mp3",
  "/uploads/podcast/news-2023-02-06/the-changelog-news-2023-02-06.mp3": "/uploads/news/30/changelog-news-30.mp3",
  "/uploads/podcast/news-2023-02-13/the-changelog-news-2023-02-13.mp3": "/uploads/news/31/changelog-news-31.mp3",
  "/uploads/podcast/news-2023-02-20/the-changelog-news-2023-02-20.mp3": "/uploads/news/32/changelog-news-32.mp3",
  "/uploads/podcast/news-2023-02-20/the-changelog-news-2023-02-20-p883.mp3": "/uploads/news/32/changelog-news-32p883.mp3",
  "/uploads/podcast/news-2023-02-27/the-changelog-news-2023-02-27.mp3": "/uploads/news/33/changelog-news-33.mp3",
  "/uploads/podcast/news-2023-03-06/the-changelog-news-2023-03-06.mp3": "/uploads/news/34/changelog-news-34.mp3",
  "/uploads/podcast/news-2023-03-06/the-changelog-news-2023-03-06-XXXL.mp3": "/uploads/news/34/changelog-news-34-XXXL.mp3",
  "/uploads/podcast/news-2023-03-13/the-changelog-news-2023-03-13.mp3": "/uploads/news/35/changelog-news-35.mp3",
  "/uploads/podcast/news-2023-03-20/the-changelog-news-2023-03-20.mp3": "/uploads/news/36/changelog-news-36.mp3",
  "/uploads/podcast/news-2023-03-27/the-changelog-news-2023-03-27.mp3": "/uploads/news/37/changelog-news-37.mp3",
  "/uploads/podcast/news-2023-04-03/the-changelog-news-2023-04-03.mp3": "/uploads/news/38/changelog-news-38.mp3"
}



sub vcl_recv {
#--FASTLY RECV BEGIN
  if (req.restarts == 0) {
    if (!req.http.X-Timer) {
      set req.http.X-Timer = "S" time.start.sec "." time.start.usec_frac;
    }
    set req.http.X-Timer = req.http.X-Timer ",VS0";
  }

  if (req.http.Fastly-Orig-Accept-Encoding) {
    if (req.http.Fastly-Orig-Accept-Encoding ~ "\bbr\b") {
      set req.http.Accept-Encoding = "br";
    }
  }



  declare local var.fastly_req_do_shield BOOL;
  set var.fastly_req_do_shield = (req.restarts == 0);

# Snippet only-send-allowed-requests-methods-to-cdn : 90
if (req.http.host == "cdn.changelog.com" && req.request !~ "GET|HEAD|PURGE") {
  error 905 "Method Not Allowed";
}

# Snippet websockets-upgrade : 90
if (req.http.Upgrade) {
  set req.backend = F_fly_2024_01_12;
  return (upgrade);
}

# Snippet do-not-cache-app-requests-when-cookie-present : 100
if (req.http.cookie) {
  set req.backend = F_fly_2024_01_12;
  if (req.http.host != "cdn.changelog.com") {
    return (pass);
  }
}

# Snippet http3-quic-v1-3Gy8OySrF30XVKj2v5iBbU-recv-recv : 100
# Begin http3-quic recv
  h3.alt_svc();
# End http3-quic recv


# Snippet news-redirects-match : 100
if (table.contains(news_redirects, req.url.path)) {
  error 618 "redirect";
}

# Snippet required-by-shielding : 100
  /* if shielding is enabled, the below code is required */
  if (fastly.ff.visits_this_service != 0) {
    set req.max_stale_while_revalidate = 0s;
  }

# Snippet rss-request : 100
if (req.http.host == "changelog.com" && req.url == "/rss") {
  error 902 "Found /feed";
}

# Snippet set-auto-webp-for-all-pngs-jpgs : 100
if (req.url.ext ~ "(?i)^(png|jpe?g)$") {
        set req.url = querystring.add(req.url, "auto", "webp");
}

  # default conditions

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
  # Request Condition: Fastly Image Optimizer Request Prio: 10
  if( req.url.ext ~ "(?i)^(gif|png|jpe?g|webp)$" ) {


  # Header rewrite Fastly Image Optimizer : 1


        set req.http.x-fastly-imageopto-api = "fastly";




      }
  #end condition
  # Request Condition: CDN Request Prio: 10
  if( req.http.host == "cdn.changelog.com" ) {

    set req.backend = F_Cloudflare_R2_Asset_Host;


      }
  #end condition
  # Request Condition: Feed Request Prio: 10
  if( req.http.host == "changelog.com" && table.contains(feeds, req.url.path) ) {

    set req.backend = F_Cloudflare_R2_Feeds_Host;


      }
  #end condition
  # Request Condition: Changelog Request Prio: 10
  if( req.http.host == "changelog.com" && !table.contains(feeds, req.url.path) ) {

    set req.backend = F_fly_2024_01_12;


      }
  #end condition
  # Request Condition: Purge Prio: 10
  if( req.request == "FASTLYPURGE" ) {


  # Header rewrite Fastly Purge : 10


        set req.http.Fastly-Purge-Requires-Auth = "1";




      }
  #end condition

      #do shield here F_Cloudflare_R2_Asset_Host > ssl_shield_iad_va_us;




  {
    if (req.backend == F_Cloudflare_R2_Asset_Host && var.fastly_req_do_shield) {
      if (server.datacenter != "IAD" && req.http.Fastly-FF !~ "-IAD") {
        set req.backend = ssl_shield_iad_va_us;
      }
      if (!req.backend.healthy) {
        # the shield POP seems unhealthy, so fetch from origin
        set req.backend = F_Cloudflare_R2_Asset_Host;
      }
    }
  }



#--FASTLY RECV END



    if (req.request != "HEAD" && req.request != "GET" && req.request != "FASTLYPURGE") {
      return(pass);
    }


    return(lookup);
}


sub vcl_fetch {
  declare local var.fastly_disable_restart_on_error BOOL;



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

# Snippet requested-by-pawel-from-fastly-support : 100
# If it's possible, could you add a snippet below in VCL_fetch and let me know if you see any improvements?
# https://support.fastly.com/hc/en-us/requests/707586
if (beresp.http.Surrogate-Key == "") {
  unset beresp.http.Surrogate-Key;
}



 # priority: 0



  # Header rewrite CORS Allow * : 10


        set beresp.http.Access-Control-Allow-Origin = "*";



  # Header rewrite Stream mp3s directly if they are not in caches - Streaming Miss : 10


        set beresp.do_stream = true;




  # Gzip Generated by default compression policy
  if ((beresp.status == 200 || beresp.status == 404) && (beresp.http.content-type ~ "^(?:text/html|application/x-javascript|text/css|application/javascript|text/javascript|application/json|application/vnd\.ms-fontobject|application/x-font-opentype|application/x-font-truetype|application/x-font-ttf|application/xml|font/eot|font/opentype|font/otf|image/svg\+xml|image/vnd\.microsoft\.icon|text/plain|text/xml)\s*(?:$|;)" || req.url ~ "\.(?:css|js|html|eot|ico|otf|ttf|json|svg)(?:$|\?)" ) ) {

    # always set vary to make sure uncompressed versions dont always win
    if (!beresp.http.Vary ~ "Accept-Encoding") {
      if (beresp.http.Vary) {
        set beresp.http.Vary = beresp.http.Vary ", Accept-Encoding";
      } else {
         set beresp.http.Vary = "Accept-Encoding";
      }
    }
    if (req.http.Accept-Encoding == "br") {
      set beresp.brotli = true;
    } elsif (req.http.Accept-Encoding == "gzip") {
      set beresp.gzip = true;
    }
  }


#--FASTLY FETCH END


  set var.fastly_disable_restart_on_error = true; # not compatible with Image Optimizer
  if (!var.fastly_disable_restart_on_error) {
    if ((beresp.status == 500 || beresp.status == 503) && req.restarts < 1 && (req.request == "GET" || req.request == "HEAD")) {
      restart;
    }
  }

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


  if (beresp.http.Expires || beresp.http.Surrogate-Control ~ "max-age" || beresp.http.Cache-Control ~"(?:s-maxage|max-age)") {
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

# Snippet feeds-request-rewrite : 100
if (table.contains(feeds, req.url.path)) {
  set bereq.url = table.lookup(feeds, req.url.path);
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

    set resp.http.X-Cache = if(resp.http.X-Cache, resp.http.X-Cache ", ","") if(fastly_info.state ~ "HIT(?:-|\z)", "HIT", "MISS");

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

# Snippet error-found-feed : 100
if (obj.status == 902) {
  set obj.status = 302;
  set obj.http.location = "https://changelog.com/feed";
  return(deliver);
}

# Snippet error-method-not-allowed : 100
if (obj.status == 905) {
  set obj.status = 405;
  set obj.response = "Method Not Allowed";
  return(deliver);
}

# Snippet news-redirects-response : 100
if (obj.status == 618 && obj.response == "redirect") {
  set obj.status = 308;
  set obj.http.Location = "https://" + req.http.host + table.lookup(news_redirects, req.url.path) + if (std.strlen(req.url.qs) > 0, "?" req.url.qs, "");
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
  # Response Condition: Changelog News Prio: 10
  if( req.url ~ "^/uploads/news/" && !req.http.Fastly-FF ) {

    # s3 S3_Changelog_News
    log {"syslog "} req.service_id {" S3 Changelog News :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

  }
  # Response Condition: Changelog & Friends Prio: 10
  if( req.url ~ "^/uploads/friends/" && !req.http.Fastly-FF ) {

    # s3 Changelog___Friends
    log {"syslog "} req.service_id {" Changelog & Friends :: "} req.http.Fastly-Client-IP "," "[" strftime({"%d/%b/%Y:%H:%M:%S %z"}, time.start) "]" "," regsub(req.url, "\?.*$", "") "," resp.body_bytes_written "," resp.status {",""} req.http.User-Agent {"","} client.geo.latitude "," client.geo.longitude {",""} client.geo.city.utf8 {"","} client.geo.continent_code "," client.geo.country_code {",""} client.geo.country_name.utf8 {"""};

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

