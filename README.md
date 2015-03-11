# Advanced 3d Perspective Distortion

### Create a unique parallax environment to show off your work.
#### Inspired by http://hellomonday.com/

I've always been a big fan of using subtitle 3d effects to give depth to UI and images. Ever since laying my eyes on the [26000 Vodka] (http://26000.resn.co.nz/flash.html) website many years ago, I've wanted to create something that can emulate that same kind of depth, without using cumbersome flash to do it. (Also, I didn't know flash, so there's that)

This plugin allows you to (currently) do full-page 3d perspective transforms base on mouse position. There are a lot of options you can tweak to your liking, and I'm looking to develop the application of this effect further.

Check out the demo's to see whats possible

[^Demo 1] (http://mathew-kleppin.com/dev/logosdistort/demo/demo1.html) - [Demo 2] (http://mathew-kleppin.com/dev/logosdistort/demo/demo2.html) - [^Demo 3] (http://mathew-kleppin.com/dev/logosdistort/demo/demo3.html)

^Demo's Work Optimally in Chrome

## Usage

There are two ways of using LogosDistort. By Using bower:
```   
bower install logos-distort
```
Or by downloading the repo and using the files there

1. Include jQuery:

	```html
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
	```

2. Include plugin's code:

	```html
	<script src="dist/jquery.logosDistort.min.js"></script>
	```

3. Add the HTML Structure:

	```html
	<div id="demo1">
        <img alt="background" src="assets/images/background.png" />
        <div id="particle-target" ></div>
        <img alt="logo" src="assets/images/logo.png" />
    </div>
	```

> The structure can include any element, but currently only has support for full screen elements. If you'd like to make non-full screen elements respond to the matrix transform, then simply place the elements inside of a full screen div container. An example of this can be seen in demo4.html


4. Call the plugin:

	```javascript
	$("#demo1").logosDistort();
	```

> You can customize a number of options and send them in when starting the plugin. See "Options" for more info.

## Options

Coming Soon.
