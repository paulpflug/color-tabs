ColorTabs = null
log = null
reloader = null

pkgName = "color-tabs"

module.exports = new class Main
  colorTabs: null
  colorChangeCb: []
  config:
    debug:
      type: "integer"
      default: 0
      minimum: 0

  activate: ->
    setTimeout (->
      reloaderSettings = pkg:pkgName,folders:["lib","styles"]
      try
        reloader ?= require("atom-package-reloader")(reloaderSettings)
      ),500
    unless log?
      log = require("atom-simple-logger")(pkg:pkgName,nsp:"main")
      log "activating"
    unless @colorTabs?
      log "loading core"
      load = =>
        try
          ColorTabs = require "./color-tabs"
          @colorTabs = new ColorTabs
        catch
          log "loading core failed"
        if @colorTabs?
          @colorTabs.setColorChangeCb @colorChangeCb
          @color = @colorTabs.color
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
        index = @colorChangeCb.indexOf cb
        if index > -1
          @colorChangeCb.splice index,1

  deactivate: ->
    log "deactivating"
    @onceActivated?.dispose?()
    @colorTabs?.destroy?()
    @colorTabs = null
    log = null
    ColorTabs = null
    colorChangeCb = null
    reloader?.dispose()
    reloader = null
