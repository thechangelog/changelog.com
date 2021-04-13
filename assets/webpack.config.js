let webpack = require("webpack");
let { merge } = require("webpack-merge");
let TerserPlugin = require("terser-webpack-plugin");
let CopyWebpackPlugin = require("copy-webpack-plugin");
let MiniCssExtractPlugin = require("mini-css-extract-plugin");
let OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");

let common = {
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: [/node_modules/, /semantic/, /uploads/],
        loader: "babel-loader"
      },
      {
        test: /\.hbs$/,
        loader: "handlebars-loader"
      },
      {
        test: [/\.scss$/, /\.css$/],
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          "postcss-loader",
          "sass-loader"
        ]
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        exclude: /fonts/,
        loader: "file-loader?name=/images/[name].[ext]"
      },
      {
        test: /\.(ttf|eot|svg|woff2?)$/,
        exclude: /images/,
        loader: "file-loader?name=/fonts/[name].[ext]",
      }
    ]
  },
  optimization: {
    minimizer: [
    new TerserPlugin(),
      new OptimizeCSSAssetsPlugin({})
    ]
  }
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
      new CopyWebpackPlugin({patterns: [{from: __dirname + "/static"}]}),
      new MiniCssExtractPlugin({filename: "css/app.css"})
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
      new MiniCssExtractPlugin({filename: "css/embed.css"})
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
      new MiniCssExtractPlugin({filename: "css/admin.css"})
    ]
  }),
  {
    entry: [__dirname + "/embedder.js"],
    output: {
      path: __dirname + "/../priv/static",
      filename: "embed.js"
    }
  }
];
