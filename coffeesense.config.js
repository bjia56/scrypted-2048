// coffeesense.config.js
module.exports = {
    // **optional** default: `{}`
    // override vscode settings
    // Notice: It only affects the settings used by CoffeeSense.
    settings: {
      "coffeesense.useWorkspaceDependencies": false,
    },
    // **optional** default: `[{ root: './' }]`
    // support monorepos
    projects: [
      {
        // **required**
        // Where is your project?
        // It is relative to `coffeesense.config.js`.
        root: '.',
        // **optional** default: `'package.json'`
        // Where is `package.json` in the project?
        // It is relative to root property.
        package: './package.json',
        // **optional**
        // Where is TypeScript config file in the project?
        // It is relative to root property.
        tsconfig: './tsconfig.json'
      }
    ]
  }