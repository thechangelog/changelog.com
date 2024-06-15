# https://varnish-cache.org/docs/7.4/reference/vcl.html#versioning
vcl 4.1;

import std;

# Thanks Matt Johnson! 👋
# - https://github.com/magento/magento2/blob/03621bbcd75cbac4ffa8266a51aa2606980f4830/app/code/Magento/PageCache/etc/varnish6.vcl
# - https://abhishekjakhotiya.medium.com/magento-internals-cache-purging-and-cache-tags-bf7772e60797

backend default {
  .host = "top1.nearest.of.changelog-2024-01-12.internal";
  .host_header = "changelog-2024-01-12.fly.dev";
  .port = "4000";
  .first_byte_timeout = 5s;
  .probe = {
    .url = "/health";
    .timeout = 2s;
    .interval = 5s;
    .window = 10;
    .threshold = 5;
  }
}

# https://varnish-cache.org/docs/7.4/users-guide/vcl-grace.html
# https://docs.varnish-software.com/tutorials/object-lifetime/
# https://www.varnish-software.com/developers/tutorials/http-caching-basics/
# https://blog.markvincze.com/how-to-gracefully-fall-back-to-cache-on-5xx-responses-with-varnish/
sub vcl_backend_response {
  # Objects within ttl are considered fresh.
  set beresp.ttl = 60s;

  # Objects within grace are considered stale.
  # Serve stale content while refreshing in the background.
  # 🤔 QUESTION: should we vary this based on backend health?
  set beresp.grace = 24h;

  if (beresp.status >= 500) {
    # Don't cache a 5xx response
    set beresp.uncacheable = true;

    # If is_bgfetch is true, it means that we've found and returned the cached
    # object to the client, and triggered an asynchoronus background update. In
    # that case, since backend returned a 5xx, we have to abandon, otherwise
    # the previously cached object would be erased from the cache (even if we
    # set uncacheable to true).
    if (bereq.is_bgfetch) {
      return (abandon);
    }
  }

  # 🤔 QUESTION: Should we configure beresp.keep?
}

# NOTE: vcl_recv is called at the beginning of a request, after the complete
# request has been received and parsed. Its purpose is to decide whether or not
# to serve the request, how to do it, and, if applicable, which backend to use.
sub vcl_recv {
  # https://varnish-cache.org/docs/7.4/users-guide/purging.html
  if (req.method == "PURGE") {
    return (purge);
  }

  # Implement a Varnish health-check
  if (req.method == "GET" && req.url == "/varnish_status") {
    return(synth(204));
  }
}

# https://gist.github.com/leotsem/1246511/824cb9027a0a65d717c83e678850021dad84688d#file-default-vcl-pl
# https://varnish-cache.org/docs/7.4/reference/vcl-var.html#obj
sub vcl_deliver {
  # What is the remaining TTL for this object?
  set resp.http.x-ttl = obj.ttl;
  # What is the max object staleness permitted?
  set resp.http.x-grace = obj.grace;

  # Did the response come from Varnish or from the backend?
  if (obj.hits > 0) {
    set resp.http.x-cache = "HIT";
  } else {
    set resp.http.x-cache = "MISS";
  }

  # Is this object stale?
  if (obj.ttl < std.duration(integer=0)) {
    set resp.http.x-cache = "STALE";
  }

  # How many times has this response been served from Varnish?
  set resp.http.x-cache-hits = obj.hits;
}

# TODOS:
# - ✅ Run in debug mode (locally)
# - ✅ Connect directly to app - not Fly.io Proxy 🤦
# - ✅ Serve stale content + background refresh
#   - QUESTION: Should the app control this via Surrogate-Control? Should we remove this header?
#   - EXPLORE: varnishstat
#   - EXPLORE: varnishtop
#   - EXPLORE: varnishncsa -c -F '%m %U %H %{x-cache}o %{x-cache-hits}o'
# - ✅ Serve stale content on backend error
#   - https://varnish-cache.org/docs/7.4/users-guide/vcl-grace.html#misbehaving-servers
# - If the backend gets restarted (e.g. new deploy), backend remains sick in Varnish
#   - https://info.varnish-software.com/blog/two-minute-tech-tuesdays-backend-health
#   - EXPLORE: varnishlog -g raw -i backend_health
# - Implement If-Modified-Since? keep
# - Expose FLY_REGION=sjc env var as a custom header
#   - https://varnish-cache.org/lists/pipermail/varnish-misc/2019-September/026656.html
# - Add Feeds backend: /feed -> https://feeds.changelog.place/feed.xml
# - Store cache on disk? A pre-requisite for static backend 
#   - https://varnish-cache.org/docs/trunk/users-guide/storage-backends.html#file
# - Add Static backend: cdn.changelog.com requests
#
# FOLLOW-UPs:
# - Run varnishncsa as a separate process (will need a supervisor + log drain)
#   - https://info.varnish-software.com/blog/varnish-and-json-logging
# - How to cache purge across all varnish instances?
