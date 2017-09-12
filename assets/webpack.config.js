var webpack = require("webpack");
var merge = require("webpack-merge");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var SpritePlugin = require('svg-sprite-loader/plugin');

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
        test: /\.svg$/,
        loader: 'svg-sprite-loader',
        exclude: /fonts/,
        options: {
          extract: true,
          spriteFilename: '/images/sprite-[hash:6].svg',
        }
      },
      {
        test: [/\.scss$/, /\.css$/],
        loader: ExtractTextPlugin.extract({use: "css-loader!sass-loader", fallback: "style-loader"})
      },
      {
        test: /\.(png|jpg|gif)$/,
        loader: "file-loader?name=/images/[name].[ext]"
      },
      {
        test: /\.(ttf|eot|woff2|svg?)$/,
        exclude: /images/,
        loader: "file-loader?name=/fonts/[name].[ext]",
      }
    ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compress: {warnings: false},
      output: {comments: false}
    }),
    new SpritePlugin(),
  ]
};

module.exports = [
  merge(common, {
    entry: [
      "normalize.css",
      __dirname + "/app/app.scss",
      __dirname + "/app/app.js"
    ],
    output: {
      path: __dirname + "/../priv/static",
      filename: "js/app.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/app"
      ]
    },
    plugins: [
      new CopyWebpackPlugin([{ from: __dirname + "/assets"}]),
      new ExtractTextPlugin("css/app.css")
    ]
  }),
  merge(common, {
    entry: [
      "normalize.css",
      __dirname + "/app/embed.scss",
      __dirname + "/app/embed.js"
    ],
    output: {
      path: __dirname + "/../priv/static",
      filename: "js/embed.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/app"
      ]
    },
    plugins: [
      new ExtractTextPlugin("css/embed.css")
    ]
  }),
  merge(common, {
    entry: [
      __dirname + "/semantic/semantic.css",
      __dirname + "/semantic/semantic.js",
      __dirname + "/semantic/calendar.css",
      __dirname + "/semantic/calendar.js",
      __dirname + "/admin/admin.css",
      __dirname + "/admin/admin.js"
    ],
    output: {
      path: __dirname + "/../priv/static",
      filename: "js/admin.js"
    },
    resolve: {
      modules: [
        "node_modules",
        __dirname + "/admin"
      ]
    },
    plugins: [
      new webpack.ProvidePlugin({$: "jquery", jQuery: "jquery"}),
      new ExtractTextPlugin("css/admin.css")
    ]
  })
];
