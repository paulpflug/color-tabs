# color-tabs package

Adds colors to tabs..

![seti](https://cloud.githubusercontent.com/assets/1881921/8502970/cf0522b2-21b7-11e5-919d-6d66f236de7a.png) -- backgroundStyle: solid, markerStyle: none, borderStyle: none

![color-tabs](https://cloud.githubusercontent.com/assets/1881921/8267564/90525440-1767-11e5-96de-565e02a1cc67.png) -- backgroundStyle: gradient, markerStyle: none, borderStyle: none

![atom](https://cloud.githubusercontent.com/assets/1881921/8502967/ced57ddc-21b7-11e5-9782-7fbc733d40b1.png) -- backgroundStyle: none, markerStyle: none, borderStyle: bottom

![darkone](https://cloud.githubusercontent.com/assets/1881921/8502968/cef22932-21b7-11e5-8619-349fa1182b0a.png) -- backgroundStyle: none, markerStyle: corner, borderStyle: none

![isotope](https://cloud.githubusercontent.com/assets/1881921/8502969/cefee492-21b7-11e5-9d5b-447df17ab4be.png) -- backgroundStyle: none, markerStyle: corner, borderStyle: bottom



Not all styles are working with all themes!


## Usage

`ctrl+alt+a` to add a random color to active tab

`ctrl+alt+x` to remove the color from active tab

### Other cool packages

- Automatically colors your tabs based on regex: [color-tabs-regex](https://atom.io/packages/color-tabs-regex)

### Where to set style

![settings](https://cloud.githubusercontent.com/assets/1881921/8529066/df3c337a-2417-11e5-8e73-fecbf0ce2379.png)

### Services

This package also provides two services

package.json
```json
{
  "otherStuff": "otherData",
  "consumedServices": {
    "color-change-cb": {
      "versions": {
        "^0.0.1": "consumeColorChangeCb"
      }
    },
    "change-color": {
      "versions": {
        "^0.0.1": "consumeChangeColor"
      }
    }
  }
}
```

your package:
```coffee
  #in main module
  consumeChangeColor: (changeColor) =>
    @changeColor = changeColor
  consumeColorChangeCb: (colorChangeCb) =>
    @colorChangeCb = colorChangeCb

  #Wherever you want to use it
    @changeColor path, newColor # changes the color of a tab for a specific file path
    @changeColor path, false # removes the color
    @changeColor path, newColor, false # prevents saving, colors will not be persistent
    @changeColor path, newColor, false, true # will show a warning if path is undefined

    @cbHandler = @colorChangeCb (path, newColor) ->
      #is called after the color of a tab got changed
      #newColor is false if it got uncolored

  #cleanup cb
  deactivate: ->
    @cbHandler?.dispose?()
```

## Developing

Run `npm install` in the package directory.

Open it in atom in dev mode.

For debugging set the debug field in package settings to the needed debug level.

Should autoreload the package on changes in `lib` and `styles` folders
