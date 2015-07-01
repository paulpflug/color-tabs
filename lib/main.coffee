ColorTabs = null
logger = null
log = null
reloader = null

pkgName = "color-tabs"

module.exports = new class Main
  colorTabs: null
  colorChangeCb: []
  config:
    backgroundGradient:
      type: "boolean"
      default: true
    debug:
      type: "integer"
      default: 0
      minimum: 0

  activate: ->
    if atom.inDevMode()
      setTimeout (->
        reloaderSettings = pkg:pkgName,folders:["lib","styles"]
        try
          reloader ?= require("atom-package-reloader")(reloaderSettings)
        ),500
    unless log?
      logger = require("atom-simple-logger")(pkg:pkgName)
      log = logger("main")
      log "activating"
    unless @colorTabs?
      log "loading core"
      load = =>
        try
          ColorTabs ?= require "./color-tabs"
          @colorTabs = new ColorTabs(logger)
        catch
          log "loading core failed"
        if @colorTabs?
          @colorTabs.setColorChangeCb @colorChangeCb
          @color = @colorTabs.color
      # make sure it activates only after the tabs package
      if atom.packages.isPackageActive("tabs")
        load()
      else
        @onceActivated = atom.packages.onDidActivatePackage (p) =>
          if p.name == "tabs"
            load()
            @onceActivated.dispose()

  provideChangeColor: ->
    return (path,color) =>
      @color? path, color

  provideColorChangeCb: ->
    return (cb, add=true) =>
      @colorChangeCb.push cb
      for path, color of @colorTabs.getColors()
        cb path, color
      return dispose: =>
        if @colorChangeCb?
          index = @colorChangeCb.indexOf cb
          if index > -1
            @colorChangeCb.splice index,1

  deactivate: ->
    log "deactivating"
    @onceActivated?.dispose?()
    @colorTabs?.destroy?()
    @colorTabs = null
    if atom.inDevMode()
      log = null
      ColorTabs = null
      colorChangeCb = null
      reloader?.dispose()
      reloader = null
