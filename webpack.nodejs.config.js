const path = require('path');
var webpackConfig = require(path.resolve(require.resolve("@scrypted/sdk"), "..", "..", "..", "webpack.nodejs.config.js"));

webpackConfig.resolve.extensions.push(".coffee");
webpackConfig.module.rules.push({
    test: /\.(coffee)$/,
    include: [/src/],
    exclude: /node_modules/,
    use: [
        {
            loader: 'coffee-loader',
        },
    ],
});
webpackConfig.entry = {
    main: 'src/main.coffee'
};

module.exports = webpackConfig;