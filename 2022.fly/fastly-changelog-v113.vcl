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




backend shield_ssl_cache_iad_kiad7000020_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.20";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000021_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.21";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000022_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.22";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000023_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.23";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000024_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.24";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000025_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.25";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000026_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.26";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000027_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.27";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000028_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.28";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000029_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.29";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000030_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.30";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000031_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.31";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000032_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.32";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000033_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.33";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000034_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.34";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000035_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.35";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000036_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.36";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000037_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.37";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000038_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.38";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000039_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.39";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000040_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.40";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000041_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.41";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000042_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.42";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000043_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.43";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000044_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.44";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000045_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.45";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000046_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.46";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000047_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.47";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000048_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.48";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000049_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.49";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000050_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.50";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000051_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.51";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000052_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.52";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000053_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.53";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000054_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.54";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000055_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.55";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000056_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.56";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000057_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.57";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000058_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.58";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000059_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.59";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000060_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.60";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000061_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.61";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000062_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.62";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000063_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.63";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000064_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.64";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000065_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.65";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000066_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.66";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000067_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.67";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000068_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.68";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000069_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.69";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000070_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.70";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000071_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.71";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000072_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.72";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000073_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.73";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000074_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.74";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000075_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.75";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000076_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.76";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000077_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.77";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000078_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.78";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000079_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.79";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000080_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.80";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000081_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.81";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000082_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.82";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000083_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.83";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000084_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.84";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000085_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.85";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000086_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.86";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000087_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.87";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000088_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.88";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000089_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.89";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000090_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.90";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000091_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.91";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000092_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.92";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000093_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.93";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000094_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.94";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000095_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.95";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000096_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.96";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000097_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.97";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000098_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.98";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000099_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.99";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000100_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.100";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000101_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.101";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000102_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.102";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000103_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.103";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000104_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.104";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000105_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.105";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000106_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.106";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000107_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.107";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000108_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.108";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000109_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.109";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000110_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.110";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000111_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.111";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000112_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.112";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000113_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.113";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000114_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.114";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000115_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.115";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000116_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.116";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000117_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.117";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000118_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.118";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000119_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.119";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000120_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.120";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000121_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.121";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000122_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.122";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000123_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.123";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000124_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.124";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000125_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.125";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000126_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.126";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000127_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.127";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000128_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.128";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000129_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.129";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000130_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.130";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000131_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.131";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000132_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.132";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000133_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.133";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000134_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.134";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000135_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.135";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000136_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.136";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000137_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.137";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000138_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.138";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000139_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.139";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000140_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.140";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000141_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.141";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000142_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.142";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000143_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.143";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000144_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.144";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000145_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.145";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000146_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.146";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000147_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.147";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000148_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.148";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000149_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.149";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000150_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.150";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000151_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.151";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000152_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.152";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000153_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.153";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000154_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.154";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000155_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.155";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000156_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.156";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000157_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.157";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000158_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.158";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000159_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.159";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000160_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.160";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000161_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.161";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000162_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.162";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000163_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.163";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000164_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.164";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000165_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.165";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000166_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.166";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000167_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.167";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000168_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.168";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000169_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.169";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000170_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.170";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000171_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.171";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000172_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.172";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000173_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.173";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000174_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.174";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000175_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.175";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000176_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.176";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000177_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.177";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000178_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.178";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kiad7000179_IAD {
    .connect_timeout = 2s;
    .host = "167.82.233.179";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100020_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.20";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100021_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.21";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100022_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.22";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100023_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.23";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100024_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.24";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100025_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.25";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100026_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.26";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100027_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.27";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100028_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.28";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100029_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.29";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100030_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.30";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100031_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.31";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100032_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.32";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100033_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.33";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100034_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.34";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100035_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.35";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100036_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.36";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100037_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.37";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100038_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.38";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100039_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.39";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100040_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.40";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100041_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.41";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100042_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.42";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100043_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.43";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100044_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.44";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100045_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.45";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100046_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.46";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100047_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.47";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100048_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.48";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100049_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.49";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100050_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.50";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100051_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.51";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100052_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.52";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100053_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.53";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100054_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.54";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100055_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.55";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100056_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.56";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100057_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.57";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100058_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.58";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100059_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.59";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100060_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.60";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100061_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.61";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100062_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.62";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100063_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.63";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100064_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.64";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100065_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.65";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100066_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.66";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100067_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.67";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100068_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.68";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100069_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.69";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100070_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.70";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100071_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.71";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100072_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.72";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100073_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.73";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100074_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.74";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100075_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.75";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100076_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.76";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100077_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.77";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100078_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.78";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100079_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.79";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100080_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.80";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100081_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.81";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100082_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.82";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100083_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.83";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100084_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.84";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100085_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.85";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100086_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.86";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100087_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.87";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100088_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.88";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100089_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.89";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100090_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.90";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100091_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.91";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100092_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.92";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100093_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.93";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100094_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.94";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100095_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.95";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100096_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.96";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100097_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.97";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100098_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.98";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100099_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.99";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100100_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.100";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100101_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.101";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100102_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.102";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100103_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.103";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100104_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.104";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100105_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.105";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100106_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.106";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100107_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.107";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100108_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.108";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100109_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.109";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100110_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.110";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100111_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.111";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100112_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.112";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100113_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.113";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100114_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.114";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100115_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.115";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100116_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.116";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100117_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.117";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100118_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.118";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100119_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.119";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100120_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.120";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100121_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.121";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100122_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.122";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100123_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.123";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100124_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.124";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100125_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.125";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100126_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.126";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100127_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.127";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100128_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.128";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100129_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.129";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100130_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.130";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100131_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.131";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100132_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.132";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100133_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.133";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100134_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.134";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100135_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.135";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100136_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.136";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100137_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.137";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100138_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.138";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100139_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.139";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100140_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.140";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100141_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.141";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100142_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.142";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100143_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.143";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100144_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.144";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100145_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.145";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100146_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.146";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100147_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.147";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100148_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.148";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100149_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.149";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100150_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.150";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100151_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.151";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100152_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.152";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100153_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.153";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100154_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.154";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100155_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.155";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100156_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.156";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100157_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.157";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100158_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.158";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100159_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.159";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100160_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.160";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100161_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.161";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100162_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.162";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100163_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.163";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100164_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.164";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100165_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.165";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100166_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.166";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100167_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.167";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100168_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.168";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100169_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.169";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100170_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.170";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100171_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.171";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100172_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.172";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100173_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.173";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100174_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.174";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100175_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.175";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100176_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.176";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100177_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.177";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100178_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.178";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kjyo7100179_IAD {
    .connect_timeout = 2s;
    .host = "104.156.87.179";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200020_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.20";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200021_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.21";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200022_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.22";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200023_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.23";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200024_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.24";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200025_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.25";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200026_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.26";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200027_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.27";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200028_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.28";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200029_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.29";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200030_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.30";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200031_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.31";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200032_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.32";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200033_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.33";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200034_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.34";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200035_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.35";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200036_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.36";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200037_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.37";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200038_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.38";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200039_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.39";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200040_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.40";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200041_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.41";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200042_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.42";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200043_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.43";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200044_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.44";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200045_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.45";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200046_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.46";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200047_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.47";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200048_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.48";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200049_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.49";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200050_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.50";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200051_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.51";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200052_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.52";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200053_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.53";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200054_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.54";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200055_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.55";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200056_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.56";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200057_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.57";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200058_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.58";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200059_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.59";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200060_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.60";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200061_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.61";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200062_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.62";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200063_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.63";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200064_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.64";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200065_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.65";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200066_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.66";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200067_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.67";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200068_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.68";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200069_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.69";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200070_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.70";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200071_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.71";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200072_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.72";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200073_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.73";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200074_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.74";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200075_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.75";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200076_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.76";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200077_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.77";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200078_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.78";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200079_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.79";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200080_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.80";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200081_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.81";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200082_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.82";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200083_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.83";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200084_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.84";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200085_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.85";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200086_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.86";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200087_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.87";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200088_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.88";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200089_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.89";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200090_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.90";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200091_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.91";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200092_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.92";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200093_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.93";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200094_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.94";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200095_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.95";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200096_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.96";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200097_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.97";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200098_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.98";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200099_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.99";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200100_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.100";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200101_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.101";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200102_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.102";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200103_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.103";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200104_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.104";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200105_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.105";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200106_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.106";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200107_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.107";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200108_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.108";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200109_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.109";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200110_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.110";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200111_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.111";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200112_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.112";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200113_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.113";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200114_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.114";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200115_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.115";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200116_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.116";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200117_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.117";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200118_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.118";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200119_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.119";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200120_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.120";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200121_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.121";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200122_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.122";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200123_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.123";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200124_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.124";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200125_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.125";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200126_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.126";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200127_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.127";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200128_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.128";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200129_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.129";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200130_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.130";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200131_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.131";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200132_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.132";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200133_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.133";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200134_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.134";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200135_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.135";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200136_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.136";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200137_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.137";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200138_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.138";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200139_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.139";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200140_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.140";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200141_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.141";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200142_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.142";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200143_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.143";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200144_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.144";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200145_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.145";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200146_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.146";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200147_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.147";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200148_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.148";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200149_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.149";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200150_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.150";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200151_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.151";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200152_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.152";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200153_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.153";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200154_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.154";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200155_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.155";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200156_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.156";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200157_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.157";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200158_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.158";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200159_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.159";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200160_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.160";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200161_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.161";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200162_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.162";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200163_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.163";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200164_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.164";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200165_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.165";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200166_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.166";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200167_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.167";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200168_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.168";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200169_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.169";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200170_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.170";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200171_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.171";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200172_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.172";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200173_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.173";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200174_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.174";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200175_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.175";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200176_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.176";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200177_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.177";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200178_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.178";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_iad_kcgs7200179_IAD {
    .connect_timeout = 2s;
    .host = "104.156.83.179";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}

director ssl_shield_iad_va_us random {

   .retries = 2;
   {
    .backend = shield_ssl_cache_iad_kiad7000020_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000021_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000022_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000023_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000024_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000025_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000026_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000027_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000028_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000029_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000030_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000031_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000032_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000033_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000034_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000035_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000036_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000037_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000038_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000039_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000040_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000041_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000042_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000043_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000044_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000045_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000046_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000047_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000048_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000049_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000050_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000051_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000052_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000053_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000054_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000055_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000056_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000057_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000058_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000059_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000060_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000061_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000062_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000063_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000064_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000065_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000066_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000067_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000068_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000069_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000070_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000071_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000072_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000073_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000074_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000075_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000076_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000077_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000078_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000079_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000080_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000081_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000082_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000083_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000084_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000085_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000086_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000087_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000088_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000089_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000090_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000091_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000092_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000093_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000094_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000095_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000096_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000097_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000098_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000099_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000100_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000101_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000102_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000103_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000104_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000105_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000106_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000107_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000108_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000109_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000110_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000111_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000112_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000113_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000114_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000115_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000116_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000117_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000118_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000119_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000120_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000121_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000122_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000123_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000124_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000125_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000126_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000127_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000128_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000129_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000130_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000131_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000132_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000133_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000134_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000135_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000136_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000137_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000138_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000139_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000140_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000141_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000142_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000143_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000144_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000145_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000146_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000147_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000148_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000149_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000150_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000151_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000152_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000153_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000154_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000155_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000156_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000157_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000158_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000159_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000160_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000161_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000162_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000163_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000164_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000165_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000166_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000167_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000168_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000169_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000170_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000171_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000172_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000173_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000174_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000175_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000176_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000177_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000178_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kiad7000179_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100020_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100021_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100022_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100023_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100024_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100025_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100026_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100027_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100028_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100029_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100030_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100031_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100032_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100033_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100034_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100035_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100036_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100037_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100038_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100039_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100040_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100041_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100042_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100043_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100044_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100045_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100046_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100047_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100048_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100049_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100050_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100051_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100052_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100053_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100054_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100055_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100056_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100057_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100058_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100059_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100060_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100061_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100062_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100063_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100064_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100065_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100066_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100067_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100068_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100069_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100070_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100071_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100072_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100073_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100074_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100075_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100076_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100077_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100078_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100079_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100080_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100081_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100082_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100083_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100084_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100085_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100086_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100087_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100088_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100089_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100090_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100091_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100092_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100093_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100094_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100095_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100096_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100097_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100098_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100099_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100100_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100101_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100102_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100103_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100104_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100105_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100106_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100107_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100108_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100109_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100110_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100111_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100112_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100113_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100114_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100115_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100116_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100117_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100118_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100119_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100120_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100121_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100122_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100123_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100124_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100125_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100126_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100127_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100128_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100129_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100130_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100131_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100132_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100133_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100134_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100135_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100136_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100137_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100138_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100139_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100140_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100141_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100142_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100143_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100144_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100145_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100146_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100147_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100148_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100149_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100150_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100151_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100152_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100153_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100154_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100155_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100156_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100157_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100158_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100159_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100160_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100161_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100162_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100163_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100164_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100165_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100166_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100167_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100168_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100169_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100170_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100171_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100172_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100173_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100174_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100175_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100176_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100177_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100178_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kjyo7100179_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200020_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200021_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200022_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200023_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200024_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200025_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200026_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200027_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200028_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200029_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200030_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200031_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200032_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200033_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200034_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200035_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200036_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200037_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200038_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200039_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200040_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200041_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200042_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200043_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200044_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200045_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200046_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200047_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200048_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200049_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200050_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200051_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200052_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200053_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200054_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200055_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200056_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200057_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200058_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200059_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200060_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200061_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200062_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200063_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200064_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200065_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200066_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200067_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200068_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200069_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200070_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200071_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200072_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200073_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200074_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200075_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200076_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200077_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200078_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200079_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200080_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200081_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200082_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200083_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200084_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200085_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200086_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200087_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200088_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200089_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200090_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200091_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200092_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200093_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200094_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200095_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200096_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200097_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200098_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200099_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200100_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200101_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200102_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200103_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200104_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200105_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200106_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200107_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200108_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200109_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200110_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200111_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200112_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200113_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200114_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200115_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200116_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200117_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200118_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200119_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200120_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200121_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200122_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200123_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200124_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200125_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200126_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200127_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200128_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200129_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200130_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200131_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200132_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200133_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200134_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200135_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200136_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200137_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200138_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200139_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200140_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200141_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200142_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200143_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200144_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200145_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200146_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200147_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200148_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200149_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200150_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200151_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200152_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200153_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200154_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200155_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200156_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200157_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200158_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200159_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200160_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200161_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200162_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200163_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200164_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200165_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200166_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200167_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200168_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200169_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200170_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200171_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200172_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200173_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200174_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200175_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200176_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200177_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200178_IAD;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_iad_kcgs7200179_IAD;
    .weight  = 100;
   }
}

backend shield_ssl_cache_lga13620_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.20";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13621_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.21";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13622_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.22";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13623_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.23";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13624_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.24";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13625_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.25";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13626_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.26";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13627_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.27";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13628_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.28";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga13629_LGA {
    .connect_timeout = 2s;
    .host = "167.82.174.29";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21920_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.20";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21921_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.21";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21922_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.22";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21923_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.23";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21924_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.24";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21925_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.25";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21926_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.26";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21927_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.27";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21928_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.28";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21929_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.29";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21930_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.30";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21931_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.31";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21932_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.32";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21933_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.33";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21934_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.34";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21935_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.35";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21936_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.36";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21937_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.37";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21938_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.38";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21939_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.39";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21940_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.40";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21941_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.41";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21942_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.42";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21943_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.43";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21944_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.44";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21945_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.45";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21946_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.46";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21947_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.47";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21948_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.48";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21949_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.49";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21950_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.50";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21951_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.51";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21952_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.52";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21953_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.53";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21954_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.54";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21955_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.55";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21956_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.56";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21957_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.57";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21958_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.58";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21959_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.59";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21960_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.60";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21961_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.61";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21962_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.62";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21963_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.63";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21964_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.64";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21965_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.65";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21966_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.66";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21967_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.67";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21968_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.68";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21969_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.69";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21970_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.70";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21971_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.71";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21972_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.72";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21973_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.73";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21974_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.74";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21975_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.75";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21976_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.76";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21977_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.77";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21978_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.78";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21979_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.79";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21980_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.80";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21981_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.81";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21982_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.82";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}
backend shield_ssl_cache_lga21983_LGA {
    .connect_timeout = 2s;
    .host = "157.52.117.83";
    .is_shield = true;
    .max_connections = 1000;
    .port = "443";
    .share_key = "fastlyshield";
    .ssl_cert_hostname = "www.fastly.com";


    .probe = {
        .initial = 2;
        .interval = 1s;
        .request = "HEAD /__varnish_shield_check HTTP/1.1" "Host: www.fastly.com" "Connection: close";
        .threshold = 3;
        .timeout = 2s;
        .window = 5;
      }
}

director ssl_shield_lga_ny_us random {

   .retries = 2;
   {
    .backend = shield_ssl_cache_lga13620_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13621_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13622_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13623_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13624_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13625_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13626_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13627_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13628_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga13629_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21920_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21921_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21922_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21923_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21924_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21925_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21926_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21927_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21928_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21929_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21930_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21931_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21932_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21933_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21934_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21935_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21936_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21937_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21938_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21939_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21940_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21941_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21942_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21943_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21944_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21945_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21946_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21947_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21948_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21949_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21950_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21951_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21952_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21953_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21954_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21955_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21956_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21957_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21958_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21959_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21960_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21961_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21962_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21963_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21964_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21965_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21966_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21967_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21968_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21969_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21970_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21971_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21972_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21973_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21974_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21975_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21976_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21977_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21978_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21979_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21980_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21981_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21982_LGA;
    .weight  = 100;
   }{
    .backend = shield_ssl_cache_lga21983_LGA;
    .weight  = 100;
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



  declare local var.fastly_req_do_shield BOOL;
  set var.fastly_req_do_shield = (req.restarts == 0);

# Snippet do-not-cache-app-requests-when-cookie-present : 100
if (req.http.cookie) {
  if (req.http.host != "cdn.changelog.com") {
    return (pass);
  }
}

# Snippet required-by-shielding : 100
  /* if shielding is enabled, the below code is required */
  if (fastly.ff.visits_this_service != 0) {
    set req.max_stale_while_revalidate = 0s;
  }

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

      #do shield here F_Changelog_Origin_Host__Linode_Kubernetes_Engine > ssl_shield_lga_ny_us;




  {
    if (req.backend == F_Changelog_Origin_Host__Linode_Kubernetes_Engine && var.fastly_req_do_shield) {
      if (server.datacenter != "LGA" && req.http.Fastly-FF !~ "-LGA") {
        set req.backend = ssl_shield_lga_ny_us;
      }
      if (!req.backend.healthy) {
        # the shield datacenter is broken so dont go to it
        set req.backend = F_Changelog_Origin_Host__Linode_Kubernetes_Engine;
      }
    }
  }
        #do shield here F_S3_Asset_Host > ssl_shield_iad_va_us;




  {
    if (req.backend == F_S3_Asset_Host && var.fastly_req_do_shield) {
      if (server.datacenter != "IAD" && req.http.Fastly-FF !~ "-IAD") {
        set req.backend = ssl_shield_iad_va_us;
      }
      if (!req.backend.healthy) {
        # the shield datacenter is broken so dont go to it
        set req.backend = F_S3_Asset_Host;
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

