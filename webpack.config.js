var webpack = require("webpack");
var merge = require("webpack-merge");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var common = {
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: [/node_modules/, /semantic/],
        loader: "babel",
        query: {
          presets: ["es2015"]
        }
      },
      {
        test: /\.hbs$/,
        loader: "handlebars-loader"
      },
      {
        test: [/\.sass$/, /\.css$/],
        loader: ExtractTextPlugin.extract("style", "css!sass")
      },
      {
        test: /\.(png|jpg)$/,
        loader: "file?name=/images/[name].[ext]"
      },
      {
        test: /\.(ttf|eot|svg|woff2?)$/,
        loader: "file?name=/fonts/[name].[ext]",
      }
    ]
  },
  resolve: {
    modulesDirectories: [ "node_modules", __dirname + "/web/static/js" ]
  }
};

module.exports = [
  merge(common, {
    entry: [
      "./web/static/css/app.css",
      "./web/static/js/app.js"
    ],
    output: {
      path: "./priv/static",
      filename: "js/app.js"
    },
    plugins: [
      new CopyWebpackPlugin([{ from: "./web/static/assets"}]),
      new ExtractTextPlugin("css/app.css")
    ]
  }),
  merge(common, {
    entry: [
      "./web/static/semantic/semantic.css",
      "./web/static/semantic/semantic.js",
      "./web/static/css/admin.css",
      "./web/static/js/admin.js"
    ],
    output: {
      path: "./priv/static",
      filename: "js/admin.js"
    },
    plugins: [
      new webpack.ProvidePlugin({$: "jquery", jQuery: "jquery"}),
      new ExtractTextPlugin("css/admin.css")
    ]
  })
];
