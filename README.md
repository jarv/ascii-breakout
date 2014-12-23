# ascii-breakout


Weekend Christmas hack to create a breakout game using
ascii fonts. Why? No reason, I thought maybe it would be
fun to add an easter egg to the ascii header of [jarv.org](jarv.org).

[Play the demo](http://ascii-breakout.com)

![ascii-breakout](https://raw.githubusercontent.com/jarv/ascii-breakout/master/screenshot.png)

## Browser support

Tested against recent versions of Chrome and Firefox on a desktop,
mobile support is hit-or-miss, please feel free to contribute if you
would like to help fix it!

## Issues

[Submit an issue](https://github.com/jarv/ascii-breakout/issues) and I will do my
best to fix it.

## Running locally

```
$ git clone git@github.com:jarv/ascii-breakout
$ make serve
```

## Development

There is one large-ish coffee script file for the entire game.  On my todo list is making a library so it can be re-used easily.

1. Install [coffeescript](http://coffeescript.org/#installation)
2. After checking out the repo run `make cwatch` to watch for coffeescript changes
