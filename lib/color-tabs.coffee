sep = require("path").sep
log = null
CSON = require 'season'
colorFile = atom.getConfigDirPath()+"color-tabs.cson"
colors = {}
colorChangeCb = null
cssElements = {}



getCssElement = (path, color) ->
  cssElement = cssElements[path]
  unless cssElement?
    cssElement = document.createElement 'style'
    cssElement.setAttribute 'type', 'text/css'
    cssElements[path] = cssElement
  while cssElement.firstChild?
    cssElement.removeChild cssElement.firstChild
  return cssElement unless color
  path = path.replace(/\\/g,"\\\\")
  cssBuilder = (css, theme="", active="") ->
    basis = "ul.tab-bar>li.tab[data-path='#{path}'][is='tabs-tab']"
    theme = "atom-workspace.theme-#{theme}" if theme
    active = ".active" if active
    selector = "#{theme} #{basis}#{active}"
    return "#{selector},#{selector}:before,#{selector}:after{#{css}}"
  if atom.config.get("color-tabs.backgroundGradient")
    css  = cssBuilder "background-image:
     -webkit-linear-gradient(top, #{color} 0%, rgba(0,0,0,0) 100%);"
    css += cssBuilder "background-image:
     -webkit-linear-gradient(top, #{color} 0%, rgba(0,0,0,0) 100%);",
      "isotope-ui"
    css += cssBuilder "background-image:
     -webkit-linear-gradient(top, #{color} 0%, rgba(0,0,0,0) 100%);",
      "atom-light-ui", true
    css += cssBuilder "background-image:
     -webkit-linear-gradient(top, #{color} 0%, #d9d9d9 100%);",
      "atom-light-ui"
    css += cssBuilder "background-image:
     -webkit-linear-gradient(top, #{color} 0%, #222222 100%);",
      "atom-dark-ui", true
    css += cssBuilder "background-image:
     -webkit-linear-gradient(top, #{color} 0%, #333333 100%);",
      "atom-dark-ui"
  else
    markerType = 'border'
    css = "ul.tab-bar>li.tab[data-path='#{path}'][is='tabs-tab'] .marker {
      display: inline-block;
      width: 0;
      height: 0;
      border-style: solid;
      position: absolute;
      "
    if markerType == 'corner'
      css += "
        border-color: transparent #{color} transparent transparent;
        border-width: 0 20px 20px 0;
        right: 0;
        top: 0;
      }"
    else if markerType == 'round'
      css += "
          border-color: #{color};
          border-width: 6px;
          right: 20px;
          top: 50%;
          border-radius: 10px;
      }"
    else if markerType == 'square'
      css += "
          border-color: #{color};
          border-width: 6px;
          right: 20px;
          top: 50%;
          border-radius: 3px;
      }"
    else if markerType == 'border'
      side = 'bottom'
      size = 5
      css = "ul.tab-bar>li.tab[data-path='#{path}'][is='tabs-tab'] {
          box-sizing: border-box;
          border-#{side}: solid #{size}px #{color};
      }"
    tab = (document.querySelector ".title[data-path='#{path}']").parentElement
    marker = document.querySelector "ul.tab-bar>li.tab[data-path='#{path}'] .marker"
    if !marker
      marker = document.createElement 'div'
      marker.className = 'marker'
      tab.appendChild marker
  cssElement.appendChild document.createTextNode css

  return cssElement
getRandomColor= ->
  letters = '0123456789ABCDEF'.split('')
  color = '#'
  for i in [0..5]
    color += letters[Math.floor(Math.random() * 16)]
  return color

processPath= (path,color,revert=false,save=false) ->
  unless path?
    atom.notifications.addWarning "coloring a unsaved tab is not supported"
    return
  cssElement = getCssElement path, color
  unless revert
    if save
      colors[path] = color
      CSON.writeFile colorFile, colors, ->
    tabDivs = atom.views.getView(atom.workspace).querySelectorAll "ul.tab-bar>
      li.tab[data-type='TextEditor']>
      div.title[data-path='#{path.replace(/\\/g,"\\\\")}']"
    for tabDiv in tabDivs
      tabDiv.parentElement.setAttribute "data-path", path
    unless cssElement.parentElement?
      head = document.getElementsByTagName('head')[0]
      head.appendChild cssElement
  else
    if save
      delete colors[path]
      CSON.writeFile colorFile, colors, ->
    if cssElement.parentElement?
      cssElement.parentElement.removeChild(cssElement)
  if colorChangeCb?
    for cb in colorChangeCb
      unless revert
        cb path, color
      else
        cb path, false

processAllTabs= (revert=false)->
  log "processing all tabs, reverting:#{revert}"
  paths = []
  paneItems = atom.workspace.getPaneItems()
  for paneItem in paneItems
    if paneItem.getPath?
      path = paneItem.getPath()
      if path? and paths.indexOf(path) == -1 and colors[path]?
        paths.push path
  log "found #{paths.length} different paths with color of
    total #{paneItems.length} paneItems",2
  for path in paths
    processPath path, colors[path], revert
  return !revert


{CompositeDisposable} = require 'atom'
paths = {}

module.exports =
class ColorTabs
  disposables: null

  constructor: (logger) ->
    log = logger "core"
    CSON.readFile colorFile, (err, content) =>
      unless err
        colors = content
        @processed = processAllTabs()
    unless @disposables?
      @disposables = new CompositeDisposable
      @disposables.add atom.workspace.onDidAddTextEditor ->
        setTimeout processAllTabs, 10
      @disposables.add atom.workspace.onDidDestroyPaneItem ->
        setTimeout processAllTabs, 10
      @disposables.add atom.commands.add 'atom-workspace',
        'color-tabs:toggle': @toggle
        'color-tabs:color-current-tab': =>
          te = atom.workspace.getActiveTextEditor()
          if te?.getPath?
            @color te.getPath(), getRandomColor()
          else
            atom.notifications.addWarning "coloring is only possible for file tabs"
        'color-tabs:uncolor-current-tab': =>
          te = atom.workspace.getActiveTextEditor()
          if te?.getPath?
            @color te.getPath(), false
      @disposables.add atom.config.observe("color-tabs.backgroundGradient",@repaint)
    log "loaded"
  color: (path, color) ->
    processPath path, color, !color, true
  setColorChangeCb: (instance)->
    colorChangeCb = instance
  getColors: ->
    if @processed
      return colors
    else
      return {}
  repaint: =>
    if @processed
      processAllTabs()
  toggle: =>
    @processed = processAllTabs(@processed)
  destroy: =>
    @processed = processAllTabs(true)
    @disposables?.dispose()
    @disposables = null
    sep = null
    log = null
    CSON = null
