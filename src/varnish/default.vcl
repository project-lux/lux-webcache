vcl 4.1;

import std;

backend default {
  .host = "127.0.0.1";
  .port = "8081";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .max_connections = 2000;
}

sub vcl_recv {
  # Save the cookies before the built-in vcl_recv
  # to insure the responses to be cached.
  # We are doing this only because we never need to pass any cookies
  # of our own to the backend.
  set req.http.Cookie-Backup = req.http.Cookie;
  unset req.http.Cookie;

  if (req.url ~ "^/api/_info") {
    return (pass);
  }

  if (req.url ~ "sort=random") {
    return (pass);
  }
}

sub vcl_hash {
  if (req.http.Cookie-Backup) {
    # Restore the cookies before the lookup if any
    set req.http.Cookie = req.http.Cookie-Backup;
    unset req.http.Cookie-Backup;
  }
}

sub vcl_backend_response {
  if (std.getenv("NO_CACHING") == "true") {
    set beresp.uncacheable = true;
    set beresp.ttl = 15m;
  } elseif (beresp.status >= 200 && beresp.status < 300) {
    set beresp.ttl = std.duration(std.getenv("BERESP_TTL"), 1m);
    set beresp.grace = std.duration(std.getenv("BERESP_GRACE"), 1m);
    set beresp.keep = std.duration(std.getenv("BERESP_KEEP"), 1m);
  } elseif (beresp.status == 408 || beresp.status == 504) {
    // for timeout
    set beresp.ttl = 5m;
    set beresp.grace = 10m;
    set beresp.keep = 5m;
  } else {
    set beresp.uncacheable = true;
    set beresp.ttl = 15m;
  }
}
