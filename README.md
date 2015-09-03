# Advanced 3d Perspective Distortion

### Create a unique parallax environment to show off your work.
#### Inspired by http://hellomonday.com/

![Demo 1](demo/demo1.gif)

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

![Demo 3](demo/demo3.gif)

## Options

> __EffectName:__ "default" _(type)_<br/>
>	Description

1. __enable:__ true _(boolean)_ <br/>
	Enable/disable the effect

2. __effectWeight:__ 1 _(number)_ <br/>
 	The weight of how much the background parallaxes based on mouse movement. Lower means a smaller
	window of movement, higher means more. Higher values also may introduce clipping depending on the
	depth of your scene.

3. __enableSmoothing:__ true _(boolean)_ <br/>
	Enables smoothing of the mouse so that the perspective change on mouse movement isnt exactly 1:1

4. __smoothingMultiplier:__ 1 _(number)_ <br/>
	A multipler for the time it takes for the parallax effect to center on the mouse cursor. Higher
	means more time, lower means the animation is faster.

5. __outerBuffer:__ 1.10 _(number)_ <br/>
	A size multiplier for the backgrounds, so that the 3d parallax effect doesn't clip to show a
	static background. If you see move your mouse to the corner of the window, and you see a white
	background clip on the opposite corner, this value should be higher. That, or your elementDepth
	is set too high.

6. __elementDepth:__ 140 _(number)_ <br/>
	The difference of depth between each element in px. A higher depth means a better parallax effect,
	but also means a higher chance that the further elements will clip. More elements means more
	overall scene depth, meaning that if you have more then 4-5 elements in a scene, consider leaving
	this setting at its default value, or making it lower.

7. __directions:__ [ 1, 1, 1, 1, -1, -1, 1, 1 ] _(array of numbers)_ <br/>
	Weights for the directions of the parallax effect based on mouse movement. Default is set so that
	the "center" of the effect moves opposite to the mouse in all directions. Changes in this can break
	the effect. See the Demo3 for an example on how to set these directions.

8: __weights:__ [ 0.0000310, 0.0001800, 0.0000164, 0.0000019, 0.0001200 ] _(array of numbers)_ <br/>
	Effect weights for how much the effect will move in a given direction based on mouse movement.
	Here is each number and what they do (about).

	```js
	[
		"distance from center",
		"y plane neg to left, pos to right -> rotational",
		"distance from center axis point X and Y",
		"1 minus distance from center axis point",
		"relative distance from center x plane, top neg, bot pos"
	]
	```

9: __container:__ window _(variable)_<br/>
	The container for which the effect will be bound. Changing this option may cause unintended
	side-effects, as I havn't debugged this functionality. But your welcome to try it and submit a PR :)

10: __cssClasses:__ _(object)_ <br/>
	Overrides for the class names incase you want to use a similar class name for a specific element.

	```js
	{
		smartContainer: "ld-smart-container",
		overlapContainer: "ld-overlap-container",
		parent3d: "ld-3d-parent",
		transformTarget: "ld-transform-target",
		active: "ld-transform-active",
		object3d: "ld-3d-object"
	}
	```
