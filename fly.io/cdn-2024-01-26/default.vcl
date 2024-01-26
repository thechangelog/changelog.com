# specify the VCL syntax version to use
vcl 4.1;

# import vmod_dynamic for better backend name resolution
import dynamic;

# we won't use any static backend, but Varnish still need a default one
backend default none;

# set up a dynamic director
# for more info, see https://github.com/nigoroll/libvmod-dynamic/blob/master/src/vmod_dynamic.vcc
sub vcl_init {
        new d = dynamic.director(port = "80");
}

sub vcl_recv {
	# force the host header to match the backend (not all backends need it,
	# but example.com does)
	set req.http.host = "changelog-2024-01-12.fly.dev";
	# set the backend
	set req.backend_hint = d.backend("changelog-2024-01-12.fly.dev");
}

# TODOS:
# - Run in debug mode
# - Configure HTTPS for app backend
# - Store cache on disk: https://varnish-cache.org/docs/trunk/users-guide/storage-backends.html#file
# - Add Feeds backend: /feed -> https://feeds.changelog.place/feed.xml

# LINKS: Thanks Matt Johnson!
# - https://github.com/magento/magento2/blob/03621bbcd75cbac4ffa8266a51aa2606980f4830/app/code/Magento/PageCache/etc/varnish6.vcl
# - https://abhishekjakhotiya.medium.com/magento-internals-cache-purging-and-cache-tags-bf7772e60797
# - https://varnish-cache.org/intro/index.html#intro
