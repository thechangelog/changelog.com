let webpack = require("webpack");
let { merge } = require("webpack-merge");
let TerserPlugin = require("terser-webpack-plugin");
let CopyWebpackPlugin = require("copy-webpack-plugin");
let MiniCssExtractPlugin = require("mini-css-extract-plugin");
let CssMinimizerPlugin = require("css-minimizer-webpack-plugin");

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
        test: /\.s?css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
            options: { publicPath: "/" }
          },
          {
            loader: "css-loader",
            options: { url: false }
          },
          "postcss-loader",
          "sass-loader"
        ]
      },
      {
        test: /\.(png|jpg|jpeg|gif|svg)$/i,
        exclude: "/fonts/",
        type: "asset/resource"
      },
      {
        test: /\.(woff|woff2|ttf|eot|otf)$/,
        exclude: "/images/",
        type: "asset/resource"
      }
    ]
  },
  optimization: {
    minimizer: [new TerserPlugin(), new CssMinimizerPlugin({})]
  },
  devServer: {
    watchOptions: {
      ignored: /node_modules/
    }
  }
};

module.exports = [
  merge(common, {
    entry: [
      "normalize.css",
      __dirname + "/app/fonts.css",
      __dirname + "/app/app.scss",
      __dirname + "/app/app.js"
    ],
    output: {
      path: __dirname + "/../priv/static",
      filename: "js/app.js"
    },
    resolve: {
      modules: ["node_modules", __dirname + "/app"]
    },
    plugins: [
      new CopyWebpackPlugin({ patterns: [{ from: __dirname + "/static" }] }),
      new MiniCssExtractPlugin({ filename: "css/app.css" })
    ]
  }),
  merge(common, {
    entry: [__dirname + "/email/email.scss"],
    output: {
      path: __dirname + "/../priv/static"
    },
    plugins: [new MiniCssExtractPlugin({ filename: "css/email.css" })]
  }),
  merge(common, {
    entry: [
      __dirname + "/app/fonts.css",
      __dirname + "/app/news.css",
      __dirname + "/app/news.js"
    ],
    output: {
      path: __dirname + "/../priv/static",
      filename: "js/news.js"
    },
    resolve: {
      modules: ["node_modules", __dirname + "/app"]
    },
    plugins: [new MiniCssExtractPlugin({ filename: "css/news.css" })]
  }),
  merge(common, {
    entry: [__dirname + "/app/fonts.css", __dirname + "/app/img.css"],
    output: {
      path: __dirname + "/../priv/static"
    },
    plugins: [new MiniCssExtractPlugin({ filename: "css/img.css" })]
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
      modules: ["node_modules", __dirname + "/app"]
    },
    plugins: [new MiniCssExtractPlugin({ filename: "css/embed.css" })]
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
      modules: ["node_modules", __dirname + "/admin"]
    },
    plugins: [
      new webpack.ProvidePlugin({ $: "jquery", jQuery: "jquery" }),
      new CopyWebpackPlugin({
        patterns: [{ from: __dirname + "/semantic/themes", to: "css/themes" }]
      }),
      new MiniCssExtractPlugin({ filename: "css/admin.css" })
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
