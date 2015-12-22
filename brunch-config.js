exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": [
          "deps/phoenix/web/static/js/phoenix.js",
          "deps/phoenix/web/static/js/phoenix_html.js",
          /^(web\/static\/js\/shared)/,
          /^(web\/static\/js\/app)/
        ],
        "js/admin.js": [
          "deps/phoenix/web/static/js/phoenix.js",
          "deps/phoenix/web/static/js/phoenix_html.js",
          /^(web\/static\/js\/shared)/,
          /^(web\/static\/js\/admin)/
        ]
      }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": /^(web\/static\/css\/app)/,
        "css/admin.css": /^(web\/static\/css\/admin)/,
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "deps/phoenix/web/static",
      "deps/phoenix_html/web/static",
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"],
      "js/admin.js": ["web/static/js/admin"]
    }
  },

  npm: {
    enabled: true
  }
};
