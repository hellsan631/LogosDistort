module.exports = (grunt)->

  ############################################################
  # Project configuration
  ############################################################

  grunt.initConfig

    imagemin:
      build:
        options:
          optimizationLevel: 3
        files: [
          expand: true
          cwd: 'demo/assets/images'
          src: ['**/*.{png,jpg,gif}']
          dest: 'demo/assets/images'
        ]

    coffee:
      build:
        options:
          bare: false
          sourceMap: true
        files:
          'dist/logosDistort.js': 'src/logosDistort.coffee'

    compass:
      build:
        options:
          sourcemap: true
          sassDir: 'demo/assets/_scss'
          cssDir: 'demo/assets/css'
          environment: 'development'
          outputStyle: 'expanded'

    uglify:
      build:
        options:
          mangle: true
          sourceMap: true
          compress:
            drop_console: true
        files: [
          expand: true
          cwd: 'src/'
          src: ['*.js', '!*.min.js']
          dest: 'dist/'
          ext: '.min.js'
        ]

    cssmin:
      build:
        options:
          sourceMap: true
          advanced: false
          compatibility: true
          processImport: false
          shorthandCompacting: false
        files: [
          expand: true
          cwd: 'demo/assets/css'
          src: ['*.css', '!*.min.css']
          dest: 'dist/css'
          ext: '.min.css'
        ]

  ##############################################################
  # Dependencies
  ###############################################################

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-compass')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-imagemin')
  grunt.loadNpmTasks('grunt-contrib-uglify')

  ############################################################
  # Alias tasks
  ############################################################

  grunt.registerTask('build', [
    'imagemin:build' # public
    'coffee:build' # tmp
    'compass:build' # tmp
    'uglify:build' # public
    'cssmin:build' # public
  ])


