# specify the VCL syntax version to use
vcl 4.1;

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

sub vcl_recv {
  # https://varnish-cache.org/docs/trunk/users-guide/purging.html
  if (req.method == "PURGE") {
    return (purge);
  }
}

# TODOS:
# - ✅ Run in debug mode
# - ✅ Connect directly to app - not Fly.io Proxy 🤦
# - Serve stale content + background refresh
#   - We should always serve from Varnish, and only from the backend on Varnish restart
# - Serve stale content on backend error
# - Store cache on disk?
#   - https://varnish-cache.org/docs/trunk/users-guide/storage-backends.html#file
# - Add Feeds backend: /feed -> https://feeds.changelog.place/feed.xml
#
# FOLLOW-UPs:
# - Run varnishncsa as a separate process (will need a supervisor + log drain)
# - Configure health probe on the backend

# LINKS: Thanks Matt Johnson!
# - https://github.com/magento/magento2/blob/03621bbcd75cbac4ffa8266a51aa2606980f4830/app/code/Magento/PageCache/etc/varnish6.vcl
# - https://abhishekjakhotiya.medium.com/magento-internals-cache-purging-and-cache-tags-bf7772e60797
# - https://varnish-cache.org/intro/index.html#intro
