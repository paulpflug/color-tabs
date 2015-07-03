# color-tabs package

Adds colors to tabs..

![color-tabs](https://cloud.githubusercontent.com/assets/1881921/8267564/90525440-1767-11e5-96de-565e02a1cc67.png)


## Usage

`ctrl+alt+a` to add a random color to active tab

### Other cool packages

- Automatically colors your tabs based on regex: [color-tabs-regex](https://atom.io/packages/color-tabs-regex)


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
    @changeColor path, newColor # changes the color of a tab for a specific filepath

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
