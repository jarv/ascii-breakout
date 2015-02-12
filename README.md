# ascii-breakout

This all started with a tiny re-design of [my blog](http://jarv.org) and an easter egg (click on the jarv.org to see it). After that I decided to create [ascii-breakout](http://ascii-breakout.com) which is the same thing except it works for any text and
has some hacks for line wrapping.  It uses figlet fonts, you can read all about them [here](http://www.jave.de/figlet/figfont.html).

[Play the demo](http://ascii-breakout.com)

![ascii-breakout](https://raw.githubusercontent.com/jarv/ascii-breakout/master/screenshot.png)

## Browser support

Tested against recent versions of Chrome and Firefox on a desktop,
mobile support is hit-or-miss, please feel free to contribute if you
would like to help fix it!

## Issues

[Submit an issue](https://github.com/jarv/ascii-breakout/issues) and I will do my
best to fix it.


## Development

There is one large-ish coffee script file for the entire game.  On my todo list is making a library so it can be re-used easily.

1. Install [coffeescript](http://coffeescript.org/#installation)
2. Install [sass](http://sass-lang.com/install)
3. `git clone git@github.com:jarv/ascii-breakout`
4. After checking out the repo run 
  * `make cwatch` to watch for coffeescript changes
  * `make swatch` to watch for sass changes
  * `make serve` to run the dev server

