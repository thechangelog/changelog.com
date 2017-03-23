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
        loader: ExtractTextPlugin.extract({use: "css-loader!sass-loader", fallback: "style-loader"})
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
      __dirname + "/web/static/app/app.sass",
      __dirname + "/web/static/app/app.js"
    ],
    output: {
      path: __dirname + "/priv/static",
      filename: "js/app.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/web/static/app"
      ]
    },
    plugins: [
      new CopyWebpackPlugin([{ from: __dirname + "/web/static/assets"}]),
      new ExtractTextPlugin("css/app.css")
    ]
  }),
  merge(common, {
    entry: [
      "normalize.css",
      __dirname + "/web/static/app/embed.sass",
      __dirname + "/web/static/app/embed.js"
    ],
    output: {
      path: __dirname + "/priv/static",
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
      __dirname + "/web/static/semantic/semantic.css",
      __dirname + "/web/static/semantic/semantic.js",
      __dirname + "/web/static/semantic/calendar.css",
      __dirname + "/web/static/semantic/calendar.js",
      __dirname + "/web/static/admin/admin.css",
      __dirname + "/web/static/admin/admin.js"
    ],
    output: {
      path: __dirname + "/priv/static",
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
    entry: __dirname + "/web/static/email/email.css",
    output: {
      path: __dirname + "/priv/static",
      filename: "css/email.css"
    },
    plugins: [
      new ExtractTextPlugin("css/email.css")
    ]
  })
];
