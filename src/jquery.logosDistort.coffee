do ($ = jQuery, window, document) ->

  pluginName = "logosDistort"

  defaults =
    enable: true                #enable the effect
    effectWeight: 1             #how much the mouse movement moves the effect
    enableSmoothing: true
    smoothingMultiplier: 1
    activeOnlyInside: false
    outerBuffer: 1.10           #the outside buffer of the effect
    elementDepth: 140
    directions: [
      1
      1
      1, 1, -1
      -1, 1, 1
    ]
    weights: [
      0.0000310   #distance from center
      0.0001800   #y plane neg to left, pos to right -> rotational
      0.0000164   #distance from center axis point X and Y
      0.0000019   #1 minus distance from center axis point
      0.0001200   #relative distance from center x plane, top neg, bot pos
    ]
    container: window
    cssClasses:
      smartContainer: "ld-smart-container"
      overlapContainer: "ld-overlap-container"
      parent3d: "ld-3d-parent"
      transformTarget: "ld-transform-target"
      active: "ld-transform-active"
      object3d: "ld-3d-object"
    onInit: () ->
    onDestroy: () ->

  class Plugin
    constructor: (@element, options) ->
      @settings = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName

      @container = $(@settings.container)
      @$el = $(@element)
      @winW = @container.innerWidth()
      @winH = @container.innerHeight()
      @center = @getCenterOfContainer()
      @outerCon = null
      @outerConParent = null
      @transformTarget = null
      @objects3d = null

      @mouseX = @mouseY = 0
      @effectX = @effectY = 0

      @has3dSupport = @has3d()
      @paused = false

      @raf = null
      @init()

    init: ->
      @createEnvironment()
      @settings.onInit()
      logos = @

      $(document).on 'mousemove', (e) ->
        logos.mouseX = e.pageX
        logos.mouseY = e.pageY

        if !logos.settings.enableSmoothing and logos.has3dSupport then logos.draw()

      $(window).on 'resize', () ->
        logos.resizeHandler()

      if @has3dSupport then @draw() else console.log "Error: Browser 3d Support Not detected"


    ##Create the DOM environment
    createEnvironment: ->
      @objects3d = @$el.children()
      @$el.html ""

      $(child).addClass "#{@settings.cssClasses.object3d}" for child in @objects3d

      @outerConParent = $("<div class='#{@settings.cssClasses.smartContainer}'></div>")
      @outerCon = $("<div class='#{@settings.cssClasses.overlapContainer}'></div>")
      parent3d = $("<div class='#{@settings.cssClasses.parent3d}'></div>")
      @transformTarget = $("<div class='#{@settings.cssClasses.transformTarget} #{@settings.cssClasses.active}'></div>")

      @$el.append @outerConParent.append @outerCon.append parent3d.append @transformTarget.append @objects3d
      @calculateOuterContainer()
      @calculate3dObjects()

    setImageDefaults: (element) ->
      logos = @

      if element.is "img"
        element.one "load", () ->
          logos.calculatePerspective element
        .each () -> if this.complete
          $(this).load()
      else
        logos.calculatePerspective element

    calculateOuterContainer: ->
      width = @outerConParent.innerWidth()*@settings.outerBuffer
      height = @outerConParent.innerHeight()*@settings.outerBuffer
      @outerCon.css
        width: width.toFixed(2)
        height: height.toFixed(2)
        left: -((width-@winW)/2).toFixed(2)
        top: -((height-@winH)/2).toFixed(2)

    calculate3dObjects: ->
      @setImageDefaults $(child) for child in @objects3d

    calculatePerspective: (ele) -> #Sets the perspective (left, top, depth, height and width) of the 3d elements
      ele = $(ele)

      dIndex = ele.index()+1

      if @objects3d.length > 4
        dIndex = dIndex-(@objects3d.length/2)

      depth = dIndex*@settings.elementDepth

      aspectDevice = @getAspectRatio()
      aspectElement = @getAspectRatio ele

      if (isNaN aspectElement[0]) or ele.is "div"
        aspect = aspectDevice
      else
        aspect = aspectElement

      height = (@outerConParent.innerHeight()*@settings.outerBuffer).toFixed(2)
      width = (height*aspect[0]).toFixed(2)

      if width < @winW*@settings.outerBuffer
        difference = @winW/width
        width = (width*difference*@settings.outerBuffer).toFixed(2)
        height = (height*difference*@settings.outerBuffer).toFixed(2)

      left = -((width-@winW)/2).toFixed(2)
      top = -((height-@winH)/2).toFixed(2)

      ele.attr 'style', "transform: translate3d(#{left}px, #{top}px, #{depth}px); width:#{width}px; height:#{height}px;"

    ###
      Drawing Involved Functions
    ###

    draw: ->
      logos = @

      if !@settings.enableSmoothing
        @effectX = @mouseX
        @effectY = @mouseY

        if !@paused
          @changePerspective @transformTarget, @effectX, @effectY

          @raf = requestAnimationFrame () -> logos.draw()

      else
        setInterval (
          () ->
            logos.calculateSmoothing()
            logos.changePerspective logos.transformTarget, logos.effectX, logos.effectY
        ), 15

    start: ->
      paused = false
      @draw()

    stop: ->
      paused = true

    #Applies the style of a matrix3d transform on a specific element
    changePerspective: (element, appliedX, appliedY) ->
      logos = @
      requestAnimationFrame () -> $(element).attr 'style', (logos.calculateTransform appliedX, appliedY)

    calculateTransform: (appliedX, appliedY) ->
      transform1 = (@settings.directions[0]*(1 - (@applyTransform (@getDistanceFromCenter appliedX, appliedY), 0)*@settings.effectWeight)).toFixed(5)
      transform2 = (@settings.directions[1]*(@applyTransform (@getDistanceFromCenterY appliedX), 1)*@settings.effectWeight).toFixed(5)
      transform3 = (@settings.directions[2]*(@applyTransform (@getDistanceFromEdgeCenterAndCenter appliedX, appliedY), 2)*@settings.effectWeight).toFixed(5)
      transform4 = (@settings.directions[3]*(1 - (@applyTransform (@getDistanceFromCenter appliedX, appliedY), 3)*@settings.effectWeight)).toFixed(5)
      transform5 = (@settings.directions[4]*(@applyTransform (@getDistanceFromCenterX appliedY), 4)*@settings.effectWeight).toFixed(5)
      transform6 = (@settings.directions[5]*transform2).toFixed(5)
      transform7 = (@settings.directions[6]*transform5).toFixed(5)
      transform8 = (@settings.directions[7]*(Math.abs transform4)).toFixed(5)
      "transform: matrix3d(#{transform1}, 0, #{transform2}, 0, #{transform3}, #{transform4}, #{transform5},
          0, #{transform6}, #{transform7}, #{transform8}, 0, 0, 0, 100, 1)"

    applyTransform: (distance, effect) =>
      distance*@settings.weights[effect]

    ##Get MATHS functions
    getDistanceFromCenter: (appliedX, appliedY) ->
      @getDistance2d appliedX, appliedY, @center.x, @center.y

    getDistanceFromCenterY: (appliedX) ->
      appliedX-@center.x/2

    getDistanceFromCenterX: (appliedY) ->
      appliedY-@center.y/2

    getDistanceFromEdgeCenterAndCenter: (appliedX, appliedY) ->
      fromCenter = @getDistanceFromCenter appliedX, appliedY
      fromX = @getDistanceFromCenterX appliedY
      fromY = @getDistanceFromCenterY appliedX
      -((fromCenter/100)*(fromX/50)*(fromY/50)) #divide by 50 instead of 100 because distance is already div 2

    ###
      Smoothing Functions
    ###

    calculateSmoothing: ->
      @effectX += (@mouseX - @effectX) / (20*@settings.smoothingMultiplier)
      @effectY += (@mouseY - @effectY) / (20*@settings.smoothingMultiplier)

    ###
      Basic Support Functions
    ###

    getDistance2d: (currX, currY, targetX, targetY) ->
      Math.sqrt (Math.pow currX-targetX, 2) + (Math.pow currY-targetY, 2)

    getCenterOfContainer: -> #needs to be patched to account for offset elements
      {
        x: @winW/2
        y: @winH/2
      }

    getAspectRatio: (ele = window) ->
      ele = $(ele)
      [ele.innerWidth()/ele.innerHeight(), ele.innerHeight()/ele.innerWidth()]

    ##Default Handler Functions
    resizeHandler: ->
      @container = $(@settings.container)
      @winW = @container.innerWidth()
      @winH = @container.innerHeight()
      @center = @getCenterOfContainer()
      @calculateOuterContainer()
      @calculate3dObjects()

    ###
      Checks for browser compatibility of 'transform: Matrix3d'
      Based on a Gist by Tiffany B. Brown
      http://tiffanybbrown.com/2012/09/04/testing-for-css-3d-transforms-support/
    ###
    has3d: ->
      el = document.createElement 'p'
      transforms =
        'WebkitTransform': '-webkit-transform'
        'OTransform': '-o-transform'
        'MSTransform': '-ms-transform'
        'MozTransform': '-moz-transform'
        'transform': 'transform'
      support3d = undefined

      document.body.insertBefore el, document.body.lastChild

      for t of transforms
        if el.style[t] isnt undefined
          el.style[t] = 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)'
          support3d = window.getComputedStyle el
          support3d = support3d.getPropertyValue transforms[t]

      if support3d? then support3d isnt 'none' else false

    destroy: ->
      @$el.remove()
      @hook 'onDestroy'
      @$el.removeData "plugin_#{pluginName}";

    hook: (hookName) ->
      if options[hookName]?
        options[hookName].call @element

  $.fn[pluginName] = (options) ->
    @each ->
      unless $.data @, "plugin_#{pluginName}"
        $.data @, "plugin_#{pluginName}", new Plugin @, options

###
http://paulirish.com/2011/requestanimationframe-for-smart-animating/
http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
CoffeeScript implementation by Mathew Kleppin
MIT license
###

() ->
  lastTime = 0
  vendors = ['ms','moz','webkit','o']

  vendorSetup = (vendor) ->
    window.requestAnimationFrame = window[vendor+'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendor+'CancelAnimationFrame'] || window[vendor+'CancelRequestAnimationFrame']

  vendorSetup vendor for vendor in vendors

  if !window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max 0, 16 - (currTime - lastTime)
      id = window.setTimeout (() -> callback currTime + timeToCall), timeToCall

      lastTime = currTime + timeToCall

      id

  if !window.cancelAnimationFrame
    window.cancelAnimationFrame = (id) ->
      clearTimeout(id)