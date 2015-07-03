# color-tabs package

Adds colors to tabs..

![seti](https://cloud.githubusercontent.com/assets/1881921/8502970/cf0522b2-21b7-11e5-919d-6d66f236de7a.png)

![color-tabs](https://cloud.githubusercontent.com/assets/1881921/8267564/90525440-1767-11e5-96de-565e02a1cc67.png)

![atom](https://cloud.githubusercontent.com/assets/1881921/8502967/ced57ddc-21b7-11e5-9782-7fbc733d40b1.png)

![darkone](https://cloud.githubusercontent.com/assets/1881921/8502968/cef22932-21b7-11e5-8619-349fa1182b0a.png)

![isotope](https://cloud.githubusercontent.com/assets/1881921/8502969/cefee492-21b7-11e5-9d5b-447df17ab4be.png)



Not all styles are working with all themes!


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
