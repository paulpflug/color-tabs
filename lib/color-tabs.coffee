sep = require("path").sep
log = null
CSON = require 'season'
colorFile = atom.getConfigDirPath()+"#{sep}color-tabs.cson"
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
  cssBuilder = (oldcss="",{css, theme, active, marker, before, after}) ->
    selector = "ul.tab-bar>li.tab[data-path='#{path}'][is='tabs-tab']"
    if theme?
      selector = "atom-workspace.theme-#{theme} " + selector
    if marker
      selector = selector + " .marker"
    if active
      selector = selector + ".active"
    pureSelector = selector
    if before
      selector = selector + "," + pureSelector + ":before"
    if after
      selector = selector + "," + pureSelector + ":after"
    return "#{oldcss}#{selector}{#{css}}"
  css = ""

  switch atom.config.get("color-tabs.backgroundStyle")
    when "gradient"
      css  = cssBuilder css,
        css: "background-image:
        -webkit-linear-gradient(top, #{color} 0%, rgba(0,0,0,0) 100%);"
        before: true
        after: true
      css = cssBuilder css,
        css: "background-image:
        -webkit-linear-gradient(top, #{color} 0%, rgba(0,0,0,0) 100%);"
        theme: "isotope-ui"
        before: true
        after: true
      css = cssBuilder css,
        css: "background-image:
        -webkit-linear-gradient(top, #{color} 0%, rgba(0,0,0,0) 100%);"
        theme: "atom-light-ui"
        before: true
        after: true
        active: true
      css = cssBuilder css,
        css: "background-image:
        -webkit-linear-gradient(top, #{color} 0%, #d9d9d9 100%);"
        theme: "atom-light-ui"
        before: true
        after: true
      css = cssBuilder css,
        css: "background-image:
        -webkit-linear-gradient(top, #{color} 0%, #222222 100%);"
        theme: "atom-dark-ui"
        before: true
        after: true
        active: true
      css = cssBuilder css,
        css: "background-image:
        -webkit-linear-gradient(top, #{color} 0%, #333333 100%);"
        theme: "atom-dark-ui"
        before: true
        after: true
    when "solid"
      if parseInt(color.replace('#', ''), 16) > 0xffffff/2
        text_color = "black"
      else
        text_color = "white"
      css = cssBuilder css,
        css: "background-color: #{color}; color: #{text_color};
        background-image: none;"
        before: true
        after: true
      css = cssBuilder css,
        css: "background-color: #{color};"
        theme: "isotope-ui"
        before: true
        after: true

  border = atom.config.get("color-tabs.borderStyle")
  borderSize = atom.config.get("color-tabs.borderSize")
  unless border == "none"
    css = cssBuilder css,
      css: "box-sizing: border-box;
        border-#{border}: solid #{borderSize}px #{color};
        border-image: none;
      "
      before: border == "top" or border == "bottom"
      after: border == "top" or border == "bottom"

  marker = atom.config.get "color-tabs.markerStyle"
  unless marker == "none"
    css = cssBuilder css,
      css: "display: inline-block;
        width: 0;
        height: 0;
        right: 0;
        top: 0;
        border-style: solid;
        position: absolute;"

      marker: true
    switch marker
      when "corner"
        css = cssBuilder css,
          css: "border-color: transparent #{color} transparent transparent;
            border-width: 0 20px 20px 0;"
          marker: true
      when "round"
        css = cssBuilder css,
          css: "border-color: #{color};
            border-width: 6px;
            border-radius: 10px;"
          marker: true
      when "square"
        css = cssBuilder css,
          css: "border-color: #{color};
            border-width: 6px;
            border-radius: 3px;"
          marker: true
  cssElement.appendChild document.createTextNode css

  return cssElement
getRandomColor= ->
  letters = '0123456789ABCDEF'.split('')
  color = '#'
  for i in [0..5]
    color += letters[Math.floor(Math.random() * 16)]
  return color

processPath= (path,color,revert=false,save=false,warn=false) ->
  unless path?
    if warn
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
      marker = tabDiv.querySelector ".marker"
      unless marker?
        marker = document.createElement 'div'
        marker.className = 'marker'
        tabDiv.appendChild marker
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
            @color te.getPath(), getRandomColor(), true, true
          else
            atom.notifications.addWarning "coloring is only possible for file tabs"
        'color-tabs:uncolor-current-tab': =>
          te = atom.workspace.getActiveTextEditor()
          if te?.getPath?
            @color te.getPath(), false
      @disposables.add atom.config.observe("color-tabs.backgroundStyle",@repaint)
      @disposables.add atom.config.observe("color-tabs.borderStyle",@repaint)
      @disposables.add atom.config.observe("color-tabs.borderSize",@repaint)
      @disposables.add atom.config.observe("color-tabs.markerStyle",@repaint)
    log "loaded"
  color: (path, color, save=true, warn=false) ->
    processPath path, color, !color, save, warn
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
