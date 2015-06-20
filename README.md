# color-tabs package

Adds colors to tabs..

![color-tabs](https://cloud.githubusercontent.com/assets/1881921/8267564/90525440-1767-11e5-96de-565e02a1cc67.png)


## Usage

`ctrl+alt+a` to add a random color to active tab

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

    @colorChangeCb (path, newColor) ->
      #is called after the color of a tab got changed
      #newColor is false if it got uncolored


```
