//@ts-check

'use strict';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const path = require('path');

const conf = {
  node: {
    __dirname: false,
    __filename: false,
  },

  devtool: 'source-map',

  module: {
    rules: [
      {
        test: /\.ts$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              compilerOptions: {
                sourceMap: true,
              },
            },
          },
        ],
      },
    ],
  },
};

const serverConf = {
  ...conf,
  target: 'node',
  entry: {
    server: './src/server.ts',
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'server.js',
    libraryTarget: 'commonjs2',
  },
  externals: {
    vscode: 'commonjs vscode',
  },
  resolve: {
    extensions: ['.ts', '.js'],
  },
};

module.exports = [serverConf];
