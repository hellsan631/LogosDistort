// --------------------------------------------------------------------
// Plugins
// --------------------------------------------------------------------

var gulp        = require('gulp');
var concat      = require('gulp-concat');
var plumber     = require('gulp-plumber');
var uglify      = require('gulp-uglify');
var webserver   = require('gulp-webserver');

// --------------------------------------------------------------------
// Settings
// --------------------------------------------------------------------

var src = 'src/jquery.logosDistort.js';

var output = {
  build: 'dist/jquery.logosDistort.min.js'
};

// --------------------------------------------------------------------
// Error Handler
// --------------------------------------------------------------------

var onError = function(err) {
    console.log(err);
    this.emit('end');
};

// --------------------------------------------------------------------
// Task: build
// --------------------------------------------------------------------

gulp.task('build', function() {
  gulp.src('src/*.css')
    .pipe(gulp.dest('dist/css'));

  gulp.src('src/*.css')
    .pipe(gulp.dest('demo/assets/css'));

  gulp.src(src)
    .pipe(gulp.dest('dist'));

  return gulp.src(src)
    .pipe(plumber({
        errorHandler: onError
    }))
    .pipe(uglify())
    .pipe(concat(output.build))
    .pipe(gulp.dest(''));
});

// --------------------------------------------------------------------
// Task: serve
// --------------------------------------------------------------------

gulp.task('serve', ['serve-watch-js'], function() {

  //watch files for changes
	gulp.watch(src, ['serve-watch-js']);
  gulp.watch('src/*.css', ['serve-watch-css']);

  return gulp.src('demo')
    .pipe(webserver({
      livereload: true,
      open: true
    }));

});

gulp.task('serve-watch-css', function(){
  gulp.src('src/*.css')
    .pipe(gulp.dest('dist/css'));

  return gulp.src('src/*.css')
    .pipe(gulp.dest('demo/assets/css'));
});

gulp.task('serve-watch-js', function(){
  return gulp.src(src)
    .pipe(gulp.dest('demo'));
});
