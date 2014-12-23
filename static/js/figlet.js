/**
 * Figlet JS
 * 
 * Copyright (c) 2010 Scott González
 * Copyright (c) 2014 John Jarvis
 * Orginal library written by Scott González http://github.com/scottgonzalez/figlet-js
 * Modifications for ascii-breakout made by jarv http://github.com/jarv/ascii-breakout
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 * 
 */

(function() {

var Figlet = (typeof exports !== "undefined" ? exports : window).Figlet = {
	fonts: {},
	
	parseFont: function(name, fn) {
		if (Figlet.fonts.hasOwnProperty(name)) {
			fn();
			return;
		}
		
		Figlet.loadFont(name, function(defn) {
			Figlet._parseFont(name, defn, fn);
		});
	},
	
	_parseFont: function(name, defn, fn) {
//    if (typeof defn === 'object' && defn.hasOwnProperty('data')) {
//      /* for github */
//      if (defn.data.hasOwnProperty('content')) {
//        defn = atob(defn.data.content);
//      }
//    }
		var lines = defn.split("\n"),
			header = lines[0].split(" "),
			hardblank = header[0].charAt(header[0].length - 1),
			height = +header[1],
			comments = +header[5];
		
		Figlet.fonts[name] = {
			defn: lines.slice(comments + 1),
			hardblank: hardblank,
			height: height,
			char_obj: {}
		};
		fn();
	},
	
	parseChar: function(s_char, font) {
		var fontDefn = Figlet.fonts[font];
		if (fontDefn.char_obj.hasOwnProperty(s_char)) {
			return fontDefn.char_obj[s_char];
		}
		var height = fontDefn.height,
			start = (s_char - 32) * height,
			charDefn = [],
			i, begin, regex;
        if (s_char >= 160) {
            begin = s_char;
            if (s_char > 255) {
                begin = '0x0*' + s_char.toString(16);
            }
            regex = new RegExp('^' + begin, 'i');
            for (i=0; i<fontDefn.defn.length; ++i) {
                if (fontDefn.defn[i].match(regex)) {
                    start = i+1;
                    break;
                }
            }
        }
	    for (i = 0; i < height; i++) {
		    charDefn[i] = fontDefn.defn[start + i]
			    .replace(/@/g, "")
			    .replace(RegExp("\\" + fontDefn.hardblank, "g"), " ");
	    }
		return fontDefn.char_obj[s_char] = charDefn;
	},


  parsePhrase: function(str, font, fn) {
    var disp_data = [], word_boundaries = [],
        _i, _j, _k, len, space_width;

    if (! str) {
      fn(disp_data);
      return;
    }  

    len = str.length;

		Figlet.parseFont(font, function() {
      var chars = [], spaces = [],
        height, line;

      for (_i = 0; _i < len; _i++) {
				chars[_i] = Figlet.parseChar(str.charCodeAt(_i), font);
        if (str.charCodeAt(_i) === 32) {
          spaces.push(_i);
          space_width = chars[_i][0].length;
        }
			}
      height = chars[0].length;
			for (_j = 0; _j < height; _j++) {
        line = [];
				for (_k = 0; _k < len; _k++) {
          if (_j === 0 && spaces.indexOf(_k) > -1) {
            word_boundaries.push(line.length);
          }
					line = line.concat(chars[_k][_j].split(""));
				}
        // auto trim
        if (! line.every(function(elem) { return elem == " " })) {
				  disp_data.push(line);
        }
			}
      fn(disp_data, word_boundaries, space_width);
    });
  }
};

})();

