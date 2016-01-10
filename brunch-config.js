exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": [
          "node_modules/phoenix/priv/static/phoenix.js",
          "node_modules/phoenix_html/priv/static/phoenix_html.js",
          /^(web\/static\/js\/shared)/,
          /^(web\/static\/js\/app)/
        ],
        "js/admin.js": [
          "node_modules/phoenix/priv/static/phoenix.js",
          "node_modules/phoenix_html/priv/static/phoenix_html.js",
          "web/static/vendor/jquery-2.1.4.js",
          "web/static/vendor/semantic.js",
          "web/static/vendor/handlebars-v4.0.5.js",
          "web/static/vendor/sortable.js",
          /^(web\/static\/js\/shared)/,
          /^(web\/static\/js\/admin)/
        ]
      }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": /^(web\/static\/css\/app)/,
        "css/admin.css": [
          "web/static/vendor/semantic.css",
          /^(web\/static\/css\/admin)/
        ],
      }
    },
    templates: {
      joinTo: {
        "js/app.js": /^(web\/static\/js\/app\/templates)/,
        "js/admin.js": /^(web\/static\/js\/admin\/templates)/
      }
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
    enabled: true,
    whitelist: ["phoenix", "phoenix_html"]
  }
};
