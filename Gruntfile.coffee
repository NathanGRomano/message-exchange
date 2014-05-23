module.exports = (g) ->
  g.initConfig
    spec:
      unit:
        options:
          specs: 'spec/**/*.{js,coffee}'

  g.loadNpmTasks 'grunt-jasmine-bundle'
  g.registerTask 'default', ['spec:unit']
