;(function(win, doc) {

  /**
   * Main function to create distortion effect.
   * @param element - The element(s) to apply the distortion effect
   * @param option - a set of options to override the default settings
   */
  function logosDistort(elements, options) {
    if (!element) {
      throw new Error('No element provided.');
    }

    this.options = options;
    this.elements = elements;
    var _this = this;

    if (this.elements[0]) {

      //Turn our HTMLCollection into an array so we can iterate through it.
      this.elements = [].slice.call(this.elements);

      this.elements.forEach(function(element){
        element.distort = new Distortion(element, _this.options);
      });
    } else {
      this.elements.distort = new Distortion(elements, _this.options);
    }
  }

  function Distortion(element, options) {
    this._name = 'logosDistort';

    this.options = {
      enable: true,
      effectWeight: 1,
      enableSmoothing: true,
      smoothingMultiplier: 1,
      activeOnlyInside: false,
      outerBuffer: 1.10,
      elementDepth: 140,
      directions: [1, 1, 1, 1, -1, -1, 1, 1],
      weights: [0.0000310, 0.0001800, 0.0000164, 0.0000019, 0.0001200],
      container: window,
      depthOverride: false,
      cssClasses: {
        smartContainer: 'ld-smart-container',
        overlapContainer: 'ld-overlap-container',
        parent3d: 'ld-3d-parent',
        transformTarget: 'ld-transform-target',
        active: 'ld-transform-active',
        object3d: 'ld-3d-object'
      }
    };

    this.options.extend(options);
    this.element = element;

    this.container = this.options.container;

    this.width    = this.container.offsetWidth;
    this.height   = this.container.offsetHeight;
    this.center   = this.getCenterOfContainer();

    this.outerCon         = null;
    this.outerConParent   = null;
    this.transformTarget  = null;
    this.objects3d        = null;

    this.mouseX   = this.mouseY   = 0;
    this.effectX  = this.effectY  = 0;

    this.has3dSupport = this._has3d();

    this.paused = false;
    this.raf = null;

    this.init();
  }

  Distortion.prototype.init = function(){

  };

  Distortion.prototype.createEnvironment = function() {
    this.objects3d = this.element.childNodes;
    this.element.innerHTML = '';

    this.objects3d = [].slice.call(this.objects3d);

    this.objects3d.forEach(function(child){
     child.classList.add(this.settings.cssClasses.object3d);
    });

    this.outerConParent  = doc.createElement('div');
    this.outerCon        = doc.createElement('div');
    this.parent3d        = doc.createElement('div');
    this.transformTarget = doc.createElement('div');

    this.outerConParent.classList.add(this.options.cssClasses.smartContainer);
    this.outerCon.classList.add(this.options.cssClasses.overlapContainer);
    this.parent3d.classList.add(this.options.cssClasses.parent3d);
    this.transformTarget.classList.add(this.options.cssClasses.transformTarget, this.options.cssClasses.active);

            this.transformTarget.appendChild(this.objects3d);
          this.parent3d.appendChild(this.transformTarget);
        this.outerCon.appendChild(this.parent3d);
      this.outerConParent.appendChild(this.outerCon);
    this.element.appendChild(this.outerConParent);

    this.calculateOuterContainer();
    this.calculate3dObjects();
  };

  Distortion.prototype.calculateOuterContainer = function() {
    var width   = this.outerConParent.offsetWidth * this.options.outerBuffer;
    var height  = this.outerConParent.offsetHeight * this.options.outerBuffer;

    this.outerCon.setAttribute('style',
      'width:' + width.toFixed(2) + '; ' +
      'height:' + height.toFixed(2) + '; ' +
      'left:' + -((width-this.width)/2).toFixed(2) + '; ' +
      'top:' + -((height-this.height)/2).toFixed(2) + ';'
    );
  };

  Distortion.prototype.calculate3dObjects = function() {
    var _this = this;

    this.objects3d.forEach(function(node){
      _this.setImageDefaults(node);
    });
  };

  Distortion.prototype.setImageDefaults = function (element) {
    var _this = this;

    if (element.tagName.toLowerCase() === 'img') {
      element.onload(function() {
        return _this.calculatePerspective(element);
      });

      if (element.complete) {
        _this.calculatePerspective(element);
      }
    } else {
      _this.calculatePerspective(element);
    }
  };

  Distortion.prototype.calculatePerspective = function(node) {
    var index = Array.prototype.indexOf.call(node.parentNode.childNodes, node);
    var aspect;

    /*
      If we have a lot of elements in the array, for performance considerations,
      we want to halve the depth. There is an override to stop this, but caution,
      performance will be much worse.
    */
    if(this.objects3d.length > 4 && !depthOverride) {
      index = index - (this.objects3d.length / 2);
    }

    var depth = index * this.options.elementDepth;

    var aspectDevice  = this.getAspectRatio();
    var aspectElement = this.getAspectRatio(node);

    if (isNaN(aspectElement[0]) || ele.tagName.toLowerCase() === "div") {
      aspect = aspectDevice;
    } else {
      aspect = aspectElement;
    }

    var height  = (this.outerConParent.offsetHeight*this.options.outerBuffer).toFixed(2);
    var width   = (height * aspect[0]).toFixed(2);

    /*
      If calculated width is greater then the outerBuffer width,
      i.e. element uses a height heavy aspect ratio, like on mobile,
      we want to re-calculate everything using some more height-friendly maths.
    */
    if (width < (this.width * this.options.outerBuffer)) {
      difference  = this.width / width;
      width       = (width  *difference * this.options.outerBuffer).toFixed(2);
      height      = (height *difference * this.options.outerBuffer).toFixed(2);
    }

    var left  = -((width  - this.width )/2).toFixed(2);
    var top   = -((height - this.height)/2).toFixed(2);

    node.setAttribute('style',
      'transform: translate3d(' +
      left  + 'px, ' +
      top   + 'px, ' +
      depth + 'px);' +
      'width: '  + width  + '; ' +
      'height: ' + height + '; '
    );
  };

  Distortion.prototype.getCenterOfContainer = function() {
    return { x: this.width/2, y: this.height/2 };
  };

  Distortion.prototype.getAspectRatio = function(ele) {

    // Fixes bug where content was always sized to window, use container instead!
    if (!ele) {
      ele = this.options.container;
    }

    return [
      ele.offsetWidth  / ele.offsetHeight,
      ele.offsetHeight / ele.offsetWidth
    ];
  };

  Distortion.prototype.getDistance2d = function (currX, currY, targetX, targetY) {
    return Math.sqrt(
      (Math.pow(currX - targetX, 2)) + (Math.pow(currY - targetY, 2))
    );
  };

  Distortion.prototype._has3d = function(){
    var el = document.createElement('p');
    var transforms = {
      'WebkitTransform':'-webkit-transform',
      'OTransform':'-o-transform',
      'MSTransform':'-ms-transform',
      'MozTransform':'-moz-transform',
      'transform':'transform'
    };
    var has3d;
    var t;

    /* Add it to the body to get the computed style. */
    document.body.insertBefore(el, document.body.lastChild);

    for(t in transforms){
      if( el.style[t] !== undefined ){
        el.style[t] = 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)';
        has3d = window.getComputedStyle(el).getPropertyValue( transforms[t] );
      }
    }

    /* Remove used element from body. */
    el.parentNode.removeChild(el);

    if( has3d !== undefined ){
      return has3d !== 'none';
    } else {
      return false;
    }
  };

  Object.prototype.extend = function(obj) {
    for (var i in obj) {
      if (obj.hasOwnProperty(i)) {
         this[i] = obj[i];
      }
    }
  };

  // export
  win.logosDistort  = logosDistort;

  if (jQuery && jQuery.fn) {
    jQuery.fn.logosDistort = function(options) {
      return this.each(function() {
        if (!jQuery.data(this, 'plugin_logosDistort')) {
          jQuery.data(this, 'plugin_logosDistort', new logosDistort(this, options));
        }
      });
    };
  }

})(window, document);

(function() {
  var lastTime = 0;
  var vendors = ['webkit', 'moz'];
  for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
      window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
      window.cancelAnimationFrame =
        window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
  }

  if (!window.requestAnimationFrame)
      window.requestAnimationFrame = function(callback, element) {
          var currTime = new Date().getTime();
          var timeToCall = Math.max(0, 16 - (currTime - lastTime));
          var id = window.setTimeout(function() { callback(currTime + timeToCall); },
            timeToCall);
          lastTime = currTime + timeToCall;
          return id;
      };

  if (!window.cancelAnimationFrame)
      window.cancelAnimationFrame = function(id) {
          clearTimeout(id);
      };
}());
