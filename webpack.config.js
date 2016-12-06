var webpack = require("webpack");
var merge = require("webpack-merge");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var common = {
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: [/node_modules/, /semantic/, /uploads/],
        loader: "babel-loader",
        options: {
          presets: ["es2015"]
        }
      },
      {
        test: /\.hbs$/,
        loader: "handlebars-loader"
      },
      {
        test: [/\.sass$/, /\.css$/],
        loader: ExtractTextPlugin.extract({fallbackLoader: "style-loader", loader: "css-loader!sass-loader"})
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        loader: "file-loader?name=/images/[name].[ext]"
      },
      {
        test: /\.(ttf|eot|svg|woff2?)$/,
        loader: "file-loader?name=/fonts/[name].[ext]",
      }
    ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compress: {warnings: false},
      output: {comments: false}
    })
  ]
};

module.exports = [
  merge(common, {
    entry: [
      "normalize.css",
      "./web/static/app/app.sass",
      "./web/static/app/app.js"
    ],
    output: {
      path: "./priv/static",
      filename: "js/app.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/web/static/app"
      ]
    },
    plugins: [
      new CopyWebpackPlugin([{ from: "./web/static/assets"}]),
      new ExtractTextPlugin("css/app.css")
    ]
  }),
  merge(common, {
    entry: [
      "normalize.css",
      "./web/static/app/embed.sass",
      "./web/static/app/embed.js"
    ],
    output: {
      path: "./priv/static",
      filename: "js/embed.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/web/static/app"
      ]
    },
    plugins: [
      new ExtractTextPlugin("css/embed.css")
    ]
  }),
  merge(common, {
    entry: [
      "./web/static/semantic/semantic.css",
      "./web/static/semantic/semantic.js",
      "./web/static/semantic/calendar.css",
      "./web/static/semantic/calendar.js",
      "./web/static/admin/admin.css",
      "./web/static/admin/admin.js"
    ],
    output: {
      path: "./priv/static",
      filename: "js/admin.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/web/static/admin"
      ]
    },
    plugins: [
      new webpack.ProvidePlugin({$: "jquery", jQuery: "jquery"}),
      new ExtractTextPlugin("css/admin.css")
    ]
  }),
  merge(common, {
    entry: "./web/static/email/email.css",
    output: {
      path: "./priv/static",
      filename: "css/email.css"
    },
    plugins: [
      new ExtractTextPlugin("css/email.css")
    ]
  })
];
