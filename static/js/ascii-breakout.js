// Generated by CoffeeScript 1.9.0
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $(document).ready(function() {
    var addBonus, addPoints, cfg, cfg_defaults, checkBallCollision, createBoardDisp, createLineBreaks, ctx, ctx_g, dispBoard, doBonus, drawAsciiBall, drawPaddle, fallingBlocks, game, gameLoop, game_defaults, genDispData, getBallHeight, getColor, getRotatedCorners, handleBallCollision, inc_w_limit, msgFlash, playSound, pointInBrick, processBoardDisp, removeLives, resetBonuses, resetLives, resetPoints, showOver, showPaused, showRunning, showSplash, showTwitter, showWin, sign, updateBoardCfg;
    sign = function(x) {
      return x > 0 ? 1 : x < 0 ? -1 : 0;
    };
    showWin = function() {
      game.state = "win";
      $(".title").html("You won, Congratulations!");
      $(".splash").show();
      showTwitter();
      return $("#ascii-submit").show();
    };
    showRunning = function() {
      playSound('unpause');
      $(".splash").hide();
      return game.state = "running";
    };
    showOver = function() {
      updateBoardCfg();
      game.state = "over";
      game.ball_locked = true;
      $(".title").html("Game Over!");
      $(".splash").show();
      $("#ascii-submit").show();
      return showTwitter();
    };
    showPaused = function() {
      playSound('pause');
      game.state = "paused";
      $(".title").html("Game Paused");
      $(".splash").show();
      $("#ascii-submit").hide();
      $(".twitter-share").hide();
      return $(".social-links").hide();
    };
    showSplash = function() {
      game.state = "splash";
      $("#msg-flash").hide();
      $(".title").html("ascii breakout");
      $(".splash").show();
      $("#ascii-submit").show();
      return $(".twitter-share").hide();
    };
    msgFlash = function(str, pause, speed) {
      $("#msg-flash").html(str);
      if (pause) {
        game.flash = true;
      }
      return $("#msg-flash").fadeIn(speed, function() {
        game.flash = false;
        return $("#msg-flash").fadeOut("slow", function() {});
      });
    };
    showTwitter = function() {
      var encoded, msg;
      msg = "I scored " + game.points + " points on http://ascii-breakout.com";
      encoded = encodeURIComponent(msg);
      $(".twitter-share").html("<a target=\"_blank\"  href=\"https://twitter.com/home?status=" + encoded + "\">Share your score with a link to this game on twitter!\"</a>");
      return $(".twitter-share").show();
    };
    resetPoints = function() {
      game.points = game_defaults.points;
      $("td.points").html(game.points);
    };
    addPoints = function(val) {
      game.points += val * game.bonus;
      $("td.points").html(game.points);
    };
    resetLives = function() {
      game.lives = game_defaults.lives;
      $("td.lives").html(game.lives);
    };
    removeLives = function(val) {
      var l;
      game.lives -= val;
      $("td.lives").html(game.lives);
      if (!game.lives) {
        return showOver();
      } else {
        updateBoardCfg();
        if (game.lives > 1) {
          l = game.lives + " lives remaining";
        } else {
          l = "One life remaining";
        }
        msgFlash(l, false, "slow");
        return game.ball_locked = true;
      }
    };
    addBonus = function(val) {
      game.bonus += val;
      $("td.bonus").html(game.bonus + "x");
      return $("td.bonuses").html("" + game.bonuses.length);
    };
    resetBonuses = function() {
      game.bonuses = [];
      game.paddle = game_defaults.paddle;
      game.ball = game_defaults.ball;
      game.fall_interval = game_defaults.fall_interval;
      game.fall_speed = game_defaults.fall_speed;
      game.brick_bounce = true;
      $("td.bonus").html(game.bonus + "x");
      return $("td.bonuses").html("" + game.bonuses.length);
    };
    $(document).click(function(e) {
      switch (game.state) {
        case "running":
          if (game.ball_locked) {
            game.ball_locked = false;
          } else {
            showPaused();
          }
          break;
        case "paused":
          showRunning();
      }
    });
    getColor = function(num) {
      var index;
      index = num % game.ascii_colors.length;
      return game.ascii_colors[index];
    };
    $(document).keydown(function(evt) {
      switch (game.state) {
        case "paused":
          if (evt.keyCode === 27) {
            showRunning();
          }
          break;
        case "running":
          if (evt.keyCode === 27) {
            showPaused();
          }
          if (evt.keyCode === 32) {
            game.ball_locked = false;
          }
      }
      if (evt.keyCode === 39) {
        game.right_down = true;
        game.paddle_dir = 1;
      } else if (evt.keyCode === 37) {
        game.left_down = true;
        game.paddle_dir = -1;
      } else if (evt.keyCode === 83) {
        game.sound_enabled = !game.sound_enabled;
        if (game.sound_enabled) {
          $(".sound-toggle").text("ON");
        } else {
          $(".sound-toggle").text("OFF");
        }
      }
      alert(evt.keyCode);
    });
    $(document).keyup(function(evt) {
      if (evt.keyCode === 39) {
        game.right_down = false;
        game.right_acc = 0;
        game.paddle_dir = 0;
      } else if (evt.keyCode === 37) {
        game.left_down = false;
        game.left_acc = 0;
        game.paddle_dir = 0;
      }
    });
    $(document).bind('touchmove mousemove', function(e) {
      var cX;
      switch (game.state) {
        case "running":
          if (game.m_timeout !== null) {
            clearTimeout(game.m_timeout);
          }
          game.m_timeout = setTimeout(function() {
            game.m_timeout = null;
            return game.paddle_dir = 0;
          }, 50);
          if (e.originalEvent.touches) {
            cX = e.originalEvent.touches[0].pageX;
          } else {
            cX = e.pageX;
          }
          if (cX > game.mouse_min_x && cX < game.mouse_max_x) {
            if (cX - game.mouse_min_x < game.paddle_x) {
              game.paddle_dir = -1;
            } else if (cX - game.mouse_min_x > game.paddle_x) {
              game.paddle_dir = 1;
            }
            game.l_paddle_x = game.paddle_x;
            return game.paddle_x = cX - game.mouse_min_x;
          }
      }
    });
    $('input[name=str]').on('input', function(e) {
      genDispData($('input[name=str]').val());
    });
    $("#ascii-submit").submit(function(e) {
      if ($('input[name=str]').val().length > 0) {
        game.bonus = game_defaults.bonus;
        resetBonuses();
        resetLives();
        resetPoints();
        genDispData($('input[name=str]').val());
        showRunning();
      }
      e.preventDefault();
    });
    drawAsciiBall = function(x, y) {
      var c, corner, i, ll, lr, max_x, max_y, min_x, min_y, r, row, ul, ur, _i, _ref;
      ctx_g.save();
      ctx_g.translate(game.l_x + game.ball.w_h, game.l_y + game.ball.h_h);
      ctx_g.rotate(game.l_ball_angle);
      ctx_g.clearRect(-game.ball.w_h - game.p_char_w, -game.ball.h_h - game.p_font_size, game.ball.w + game.p_char_w * 3, game.ball.h + game.p_font_size * 3);
      ctx_g.restore();
      ctx_g.fillStyle = game.paddle_color;
      ctx_g.save();
      ctx_g.translate(x + game.ball.w_h, y + game.ball.h_h);
      ctx_g.rotate(game.ball_angle);
      for (r = _i = 0, _ref = game.ball.rows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; r = 0 <= _ref ? ++_i : --_i) {
        row = ((function() {
          var _j, _ref1, _results;
          _results = [];
          for (i = _j = 1, _ref1 = game.ball.cols; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
            _results.push("O");
          }
          return _results;
        })()).join("");
        ctx_g.fillText(row, -game.ball.w_h, -game.ball.h_h + r * game.p_font_size);
      }
      ctx_g.restore();
      if (game.loop_cnt % game.ball_spin_speed === 0) {
        game.l_ball_angle = game.ball_angle;
        game.ball_angle += game.ball_spin * game.ball_da;
        ul = [game.x, game.y];
        ur = [game.x + game.ball.w, game.y];
        lr = [game.x + game.ball.w, game.y + game.ball.h];
        ll = [game.x, game.y + game.ball.h];
        c = getRotatedCorners(ul, ur, lr, ll);
        max_y = Math.floor(Math.max.apply(null, (function() {
          var _j, _len, _results;
          _results = [];
          for (_j = 0, _len = c.length; _j < _len; _j++) {
            corner = c[_j];
            _results.push(corner[1]);
          }
          return _results;
        })()));
        min_y = Math.ceil(Math.min.apply(null, (function() {
          var _j, _len, _results;
          _results = [];
          for (_j = 0, _len = c.length; _j < _len; _j++) {
            corner = c[_j];
            _results.push(corner[1]);
          }
          return _results;
        })()));
        max_x = Math.ceil(Math.max.apply(null, (function() {
          var _j, _len, _results;
          _results = [];
          for (_j = 0, _len = c.length; _j < _len; _j++) {
            corner = c[_j];
            _results.push(corner[0]);
          }
          return _results;
        })()));
        min_x = Math.floor(Math.min.apply(null, (function() {
          var _j, _len, _results;
          _results = [];
          for (_j = 0, _len = c.length; _j < _len; _j++) {
            corner = c[_j];
            _results.push(corner[0]);
          }
          return _results;
        })()));
        if (min_x < 0) {
          game.x -= min_x;
        }
        if (max_x > game.w) {
          game.x -= max_x - game.w;
        }
        if (min_y < 0) {
          game.y -= min_y;
        }
        if (max_y > game.h - game.paddle.h) {
          game.y -= max_y - (game.h - game.paddle.h);
        }
      }
    };
    inc_w_limit = function(value, inc, max, min) {
      if (inc < 0) {
        return Math.max(min, value + inc);
      } else if (inc >= 0) {
        return Math.min(max, value + inc);
      }
    };
    drawPaddle = function(paddle_x) {
      var i, paddle;
      ctx_g.clearRect(0, game.h - game.paddle.h - 1, game.w, game.paddle.h);
      ctx_g.fillStyle = game.paddle_color;
      paddle = "[" + ((function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 1, _ref = game.paddle.cols - 2; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          _results.push("O");
        }
        return _results;
      })()).join("") + "]";
      ctx_g.fillText(paddle, paddle_x, game.h - game.paddle.h);
    };
    Figlet.loadFont = function(name, fn) {
      var url;
      url = "fonts/" + name + ".flf";
      return $.ajax({
        url: url,
        datatype: "text",
        success: fn
      });
    };
    genDispData = function(str) {
      Figlet.parsePhrase(str, game.figlet_font, function(disp_data, word_boundaries, space_w) {
        var encoded_font, encoded_font_size, encoded_str, line_breaks;
        game.space_w = space_w;
        line_breaks = createLineBreaks(disp_data, word_boundaries);
        game.board_disp = createBoardDisp(disp_data, line_breaks, word_boundaries, space_w);
        encoded_str = encodeURIComponent(str);
        encoded_font = encodeURIComponent(game.figlet_font);
        encoded_font_size = encodeURIComponent(game.font_size);
        if (str.length > 0) {
          $(".share-link").html("Link to this game! <a href=\"#" + encoded_str + "/" + encoded_font + "/" + encoded_font_size + "\">" + (str.replace(/\W/g, "-")) + "</a>");
        } else {
          $(".share-link").html("");
        }
        return updateBoardCfg();
      });
    };
    createLineBreaks = function(disp_data, word_boundaries) {
      var col, index, last_word_boundary, line_breaks, xpos, _i, _len, _ref;
      line_breaks = [];
      xpos = 0;
      last_word_boundary = false;
      if (!disp_data || disp_data.length === 0) {
        return [];
      }
      _ref = disp_data[0];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        col = _ref[index];
        xpos += game.char_w;
        if (xpos < game.w) {
          if (__indexOf.call(word_boundaries, index) >= 0) {
            last_word_boundary = index;
          }
        } else if (xpos > game.w) {
          if (last_word_boundary) {
            line_breaks.push(last_word_boundary);
            xpos = 0 + game.char_w * (index - last_word_boundary);
            last_word_boundary = false;
          } else {
            line_breaks.push(index);
            xpos = 0;
          }
        }
      }
      if (line_breaks.length === 0) {
        line_breaks.push(disp_data[0].length);
      } else if (line_breaks[line_breaks.length - 1] < disp_data[0].length) {
        line_breaks.push(disp_data[0].length);
      }
      return line_breaks;
    };
    pointInBrick = function(x, y, brick_x, brick_y) {
      if ((x > brick_x + game.char_w) || (x < brick_x) || (y > brick_y + game.font_size) || (y < brick_y)) {
        return false;
      }
      return true;
    };
    checkBallCollision = function(brick_x, brick_y, handle_fn) {
      var c, col, corner, index, ll, lr, row, ul, ur, xpos, ypos, _i, _j, _k, _len, _ref, _ref1;
      xpos = game.x;
      ypos = game.y;
      for (row = _i = 1, _ref = game.ball.rows; 1 <= _ref ? _i <= _ref : _i >= _ref; row = 1 <= _ref ? ++_i : --_i) {
        for (col = _j = 1, _ref1 = game.ball.cols; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; col = 1 <= _ref1 ? ++_j : --_j) {
          ul = [xpos, ypos];
          ur = [xpos + game.p_char_w, ypos];
          lr = [xpos + game.p_char_w, ypos + game.p_font_size];
          ll = [xpos, ypos + game.p_font_size];
          c = getRotatedCorners(ul, ur, lr, ll);
          for (index = _k = 0, _len = c.length; _k < _len; index = ++_k) {
            corner = c[index];
            if (pointInBrick(corner[0] + game.dx, corner[1] + game.dy, brick_x, brick_y)) {
              addPoints(1);
              if (!handle_fn) {
                return [corner[0], corner[1]];
              } else {
                return handle_fn([corner[0], corner[1]], brick_x, brick_y);
              }
            }
          }
          xpos += game.p_char_w;
        }
        xpos = game.x;
        ypos += game.p_font_size;
      }
      return false;
    };
    handleBallCollision = function(c, brick_x, brick_y) {
      var aoa, c_brick_x, c_brick_y;
      if (!game.brick_bounce) {
        return true;
      }
      c_brick_x = brick_x + game.char_w_h;
      c_brick_y = brick_y + game.font_size_h;
      aoa = Math.atan2(c[1] - c_brick_y, c[0] - c_brick_x);
      switch (false) {
        case !(aoa <= Math.PI / 4 && aoa > -Math.PI / 4):
          if (game.dx <= 0) {
            game.dx = -game.dx;
          }
          break;
        case !(aoa <= -Math.PI / 4 && aoa > -3 * Math.PI / 4):
          if (game.dy >= 0) {
            game.dy = -game.dy;
          }
          break;
        case !((aoa <= -3 * Math.PI / 4 && aoa >= -Math.PI) || (aoa <= Math.PI && aoa >= 3 * Math.PI / 4)):
          if (game.dx >= 0) {
            game.dx = -game.dx;
          }
          break;
        case !(aoa <= 3 * Math.PI / 4 && aoa > Math.PI / 4):
          if (game.dy <= 0) {
            game.dy = -game.dy;
          }
      }
      return true;
    };
    createBoardDisp = function(disp_data, line_breaks, word_boundaries, space_w) {
      var board_disp, break_pos, last_break, line_cnt, row, row_index, sliced_row, space_offset, _i, _j, _len, _len1;
      board_disp = [];
      line_cnt = 0;
      last_break = 0;
      space_offset = 0;
      for (_i = 0, _len = line_breaks.length; _i < _len; _i++) {
        break_pos = line_breaks[_i];
        for (row_index = _j = 0, _len1 = disp_data.length; _j < _len1; row_index = ++_j) {
          row = disp_data[row_index];
          if (__indexOf.call(word_boundaries, break_pos) >= 0 && last_break !== 0) {
            space_offset = space_w;
          }
          sliced_row = row.slice(last_break + space_offset, break_pos);
          board_disp[row_index + (line_cnt * disp_data.length)] = sliced_row;
        }
        last_break = break_pos;
        line_cnt += 1;
      }
      return board_disp;
    };
    processBoardDisp = function() {
      var c, column, column_index, has_won, last_c, row, row_index, xpos, xpos_c, ypos, ypos_c, _i, _j, _len, _len1, _ref;
      ypos = 0;
      has_won = true;
      xpos_c = null;
      ypos_c = null;
      last_c = null;
      _ref = game.board_disp;
      for (row_index = _i = 0, _len = _ref.length; _i < _len; row_index = ++_i) {
        row = _ref[row_index];
        xpos = game.w_h - Math.round(row.length * game.char_w / 2);
        for (column_index = _j = 0, _len1 = row.length; _j < _len1; column_index = ++_j) {
          column = row[column_index];
          if (column !== " ") {
            has_won = false;
            c = checkBallCollision(xpos, ypos);
            if (c) {
              last_c = c;
              xpos_c = xpos;
              ypos_c = ypos;
              game.board_disp[row_index][column_index] = " ";
              ctx.clearRect(xpos, ypos, game.char_w, game.font_size);
            }
          }
          xpos += game.char_w;
        }
        ypos += game.font_size;
      }
      if (last_c) {
        playSound('hit');
        handleBallCollision(last_c, xpos_c, ypos_c);
      }
      return has_won;
    };
    doBonus = function() {
      var bonus, num_bonuses;
      playSound('upgrade');
      num_bonuses = 5;
      if (game.bonuses.length >= num_bonuses) {
        resetBonuses();
      }
      while (true) {
        bonus = Math.ceil(Math.random() * num_bonuses);
        if (__indexOf.call(game.bonuses, bonus) < 0) {
          break;
        }
      }
      game.bonuses.push(bonus);
      switch (bonus) {
        case 1:
          msgFlash("Small Paddle +10!", true, "fast");
          addBonus(10);
          game.paddle.cols = 5;
          break;
        case 2:
          msgFlash("Double Paddle +2!");
          addBonus(2);
          game.paddle.cols = game.paddle.cols * 2;
          break;
        case 3:
          msgFlash("Small ball", true, "fast");
          addBonus(20);
          game.ball.cols = 1;
          game.ball.rows = 1;
          break;
        case 4:
          msgFlash("More falling bricks!", true, "fast");
          game.fall_interval = 100;
          break;
        case 5:
          msgFlash("Super ball!!", true, "fast");
          game.brick_bounce = false;
          game.ball.cols = 5;
          game.ball.rows = 5;
      }
      return updateBoardCfg();
    };
    fallingBlocks = function() {
      var clearFallingBlock, index, last_row, non_spaces, r, row_index, value, xpos, _i, _j, _len, _len1, _ref;
      clearFallingBlock = function(ypos, angle) {
        ctx.save();
        ctx.translate(r.x + game.char_w_h, ypos + game.font_size_h);
        ctx.rotate(angle);
        ctx.clearRect(-game.char_w_h - game.char_w, -game.font_size_h - game.font_size, game.char_w * 3, game.font_size * 3);
        return ctx.restore();
      };
      _ref = game.block_rotations.filter(function(elem) {
        return elem.d === true;
      });
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        r = _ref[_i];
        if ((r.y + game.font_size > game.h - game.paddle.h) && (r.x + game.char_w > game.paddle_x && r.x < game.paddle_x + game.paddle.w)) {
          r.d = false;
          doBonus();
          updateBoardCfg();
        } else if (checkBallCollision(r.x, r.y, handleBallCollision)) {
          r.d = false;
          doBonus();
          updateBoardCfg();
        } else {
          if (game.state === "running") {
            if (game.loop_cnt % r.s === 0) {
              if (r.l_y) {
                clearFallingBlock(r.l_y, r.l_r);
              }
              if (!r.c) {
                console.log("UNDEFINED");
                console.log(game.block_rotations);
              }
              ctx.save();
              ctx.translate(r.x + game.char_w_h, r.y + game.font_size_h);
              ctx.rotate(r.r);
              ctx.fillText(r.c, -game.char_w_h, -game.font_size_h);
              ctx.restore();
              r.l_y = r.y;
              r.y += game.font_size;
              r.l_r = r.r;
              r.r += Math.PI / 4;
              if (r.y > game.h) {
                r.d = false;
                clearFallingBlock(r.l_y, r.l_r);
              }
            }
          }
        }
      }
      if (game.state === "running") {
        last_row = game.board_disp[game.l_char_row_index];
        if (game.loop_cnt % game.fall_interval === 0 && last_row) {
          non_spaces = [];
          for (index = _j = 0, _len1 = last_row.length; _j < _len1; index = ++_j) {
            value = last_row[index];
            if (value !== " ") {
              non_spaces.push(index);
            }
          }
          if (non_spaces.length === 0) {
            return;
          }
          row_index = non_spaces[Math.floor(Math.random() * non_spaces.length)];
          xpos = game.w_h - Math.round(last_row.length * game.char_w / 2);
          if (!last_row[row_index]) {
            console.log("Adding undefined value! " + non_spaces + " " + row_index);
          }
          game.block_rotations.push({
            x: xpos + game.char_w * row_index,
            y: game.l_char_row_index * game.font_size + game.font_size,
            l_y: null,
            l_r: null,
            r: 0,
            rs: Math.floor(Math.random() * 10 + 3),
            c: last_row[row_index],
            s: game.fall_speed(),
            d: true
          });
          last_row[row_index] = " ";
          ctx.clearRect(xpos + game.char_w * row_index, game.l_char_row_index * game.font_size, game.char_w, game.font_size);
        }
      }
    };
    dispBoard = function() {
      var row, row_index, text_color, xpos, ypos, _i, _len, _ref, _results;
      ypos = 0;
      _ref = game.board_disp;
      _results = [];
      for (row_index = _i = 0, _len = _ref.length; _i < _len; row_index = ++_i) {
        row = _ref[row_index];
        xpos = game.w_h - Math.round(row.length * game.char_w / 2);
        text_color = getColor(row_index);
        if (row.some(function(elem) {
          return elem !== " ";
        })) {
          game.l_char_row_index = row_index;
        }
        ctx.fillStyle = text_color;
        ctx.fillText(row.join(""), xpos, ypos);
        _results.push(ypos += game.font_size);
      }
      return _results;
    };
    getRotatedCorners = function(ul, ur, lr, ll) {
      var ball_cos, ball_sin, r_x, r_y;
      if (Math.round(100 * game.ball_angle) % Math.round(100 * Math.PI) === 0) {
        return [ul, ur, lr, ll];
      } else {
        r_x = game.x + game.ball.w_h;
        r_y = game.y + game.ball.h_h;
        ball_cos = Math.cos(game.ball_angle);
        ball_sin = Math.sin(game.ball_angle);
        return [[r_x + (ul[0] - r_x) * ball_cos + (ul[1] - r_y) * ball_sin, r_y - (ul[0] - r_x) * ball_sin + (ul[1] - r_y) * ball_cos], [r_x + (ur[0] - r_x) * ball_cos + (ur[1] - r_y) * ball_sin, r_y - (ur[0] - r_x) * ball_sin + (ur[1] - r_y) * ball_cos], [r_x + (lr[0] - r_x) * ball_cos + (lr[1] - r_y) * ball_sin, r_y - (lr[0] - r_x) * ball_sin + (lr[1] - r_y) * ball_cos], [r_x + (ll[0] - r_x) * ball_cos + (ll[1] - r_y) * ball_sin, r_y - (ll[0] - r_x) * ball_sin + (ll[1] - r_y) * ball_cos]];
      }
    };
    getBallHeight = function() {
      var c, corner, ll, lr, ul, ur;
      ul = [game.x, game.y];
      ur = [game.x + game.ball.w, game.y];
      lr = [game.x + game.ball.w, game.y + game.ball.h];
      ll = [game.x, game.y + game.ball.h];
      c = getRotatedCorners(ul, ur, lr, ll);
      return Math.max.apply(null, (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = c.length; _i < _len; _i++) {
          corner = c[_i];
          _results.push(corner[1]);
        }
        return _results;
      })()) - Math.min.apply(null, (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = c.length; _i < _len; _i++) {
          corner = c[_i];
          _results.push(corner[1]);
        }
        return _results;
      })());
    };
    gameLoop = function() {
      var c, corner, ll, lr, max_x, max_y, min_x, min_y, ul, ur, won;
      if (game.state === "running") {
        won = processBoardDisp();
        if (won && game.board_disp.length > 0) {
          showWin();
        }
        if (game.flash) {
          return;
        }
        if (game.ball_locked) {
          game.l_x = game.x;
          game.l_y = game.y;
          game.ball_angle = game_defaults.ball_angle;
          game.ball_spin = game_defaults.ball_spin;
          game.dx = game_defaults.dx;
          game.dy = game_defaults.dy;
          game.x = game.paddle_x + game.paddle.w_h - game.ball.w_h;
          game.y = game.h - game.paddle.h - game.ball.h - (getBallHeight() / 2 - game.ball.h_h);
        }
        if (game.l_char_row_index !== 0 && !game.ball_locked) {
          fallingBlocks();
        }
        drawAsciiBall(game.x, game.y);
        if (game.right_down) {
          if (game.paddle_x + game.paddle.w < game.w) {
            game.l_paddle_x = game.paddle_x;
            game.paddle_x += Math.floor(5 + game.right_acc);
            game.right_acc += cfg.acc_rate;
          }
        } else if (game.left_down) {
          if (game.paddle_x > 0) {
            game.paddle_x -= Math.floor(5 + game.left_acc);
            game.left_acc += cfg.acc_rate;
          }
        }
        drawPaddle(game.paddle_x);
        ul = [game.x, game.y];
        ur = [game.x + game.ball.w, game.y];
        lr = [game.x + game.ball.w, game.y + game.ball.h];
        ll = [game.x, game.y + game.ball.h];
        c = getRotatedCorners(ul, ur, lr, ll);
        max_y = Math.floor(Math.max.apply(null, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = c.length; _i < _len; _i++) {
            corner = c[_i];
            _results.push(corner[1]);
          }
          return _results;
        })()));
        min_y = Math.ceil(Math.min.apply(null, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = c.length; _i < _len; _i++) {
            corner = c[_i];
            _results.push(corner[1]);
          }
          return _results;
        })()));
        max_x = Math.ceil(Math.max.apply(null, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = c.length; _i < _len; _i++) {
            corner = c[_i];
            _results.push(corner[0]);
          }
          return _results;
        })()));
        min_x = Math.floor(Math.min.apply(null, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = c.length; _i < _len; _i++) {
            corner = c[_i];
            _results.push(corner[0]);
          }
          return _results;
        })()));
        if (max_x + game.dx > game.w) {
          playSound('bounce');
          if (!game.ball_spin || sign(game.dy) === sign(game.ball_spin)) {
            game.dy = inc_w_limit(game.dy, -game.ball_spin * 2, game.max_dy, -game.max_dy);
            game.ball_spin = inc_w_limit(game.ball_spin, -game.dy, game.ball_max_spin, -game.ball_max_spin);
          }
          game.dx = -game.dx;
        }
        if (min_x + game.dx < 0) {
          playSound('bounce');
          if (!game.ball_spin || sign(game.dy) !== sign(game.ball_spin)) {
            game.dy = inc_w_limit(game.dy, game.ball_spin * 2, game.max_dy, -game.max_dy);
            game.ball_spin = inc_w_limit(game.ball_spin, game.dy, game.ball_max_spin, -game.ball_max_spin);
          }
          game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy));
          game.dx = -game.dx;
        }
        if (min_y + game.dy < 0) {
          playSound('bounce');
          if (!game.ball_spin || sign(game.dx) === sign(game.ball_spin)) {
            game.dx = inc_w_limit(game.dx, -game.ball_spin * 2, game.max_dx, -game.max_dx);
            game.ball_spin = inc_w_limit(game.ball_spin, -game.dx, game.ball_max_spin, -game.ball_max_spin);
          }
          game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy));
          game.dy = -game.dy;
        } else if (max_y + game.dy > (game.h - game.paddle.h)) {
          if (max_x > game.paddle_x - game.char_w && min_x < (game.paddle_x + game.paddle.w + game.char_w)) {
            playSound('paddle');
            if (!game.ball_spin || sign(game.dx) !== sign(game.ball_spin)) {
              game.dx = inc_w_limit(game.dx, game.ball_spin * 2, game.max_dx, -game.max_dx);
              game.ball_spin = inc_w_limit(game.ball_spin, game.dx, game.ball_max_spin, -game.ball_max_spin);
            }
            game.dx = inc_w_limit(game.dx, -game.paddle_dir * 2, game.max_dx, -game.max_dx);
            game.ball_spin = inc_w_limit(game.ball_spin, -game.paddle_dir, game.ball_max_spin, -game.ball_max_spin);
            if (game.x + game.ball.w < game.paddle_x + game.p_char_w) {
              game.dx = -game.max_dx;
              game.ball_spin = -game.ball_max_spin;
            }
            if (game.x > game.paddle_x + game.paddle.w - game.p_char_w) {
              game.dx = game.max_dx;
              game.ball_spin = game.ball_max_spin;
            }
            game.dy = -game.dy;
            game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy));
          } else {
            playSound('death');
            if (game.state === "running") {
              removeLives(1);
            }
            game.dy = -game.dy;
          }
        }
        if (!game.ball_locked) {
          game.l_x = game.x;
          game.l_y = game.y;
          game.x += game.dx;
          game.y += game.dy;
        }
      }
      game.loop_cnt += 1;
    };
    cfg_defaults = {
      font_name: "pressStart",
      default_str: "ASCII BREAKOUT Type whatever you want and play!",
      default_font: "standard",
      acc_rate: .5,
      max_w: 800,
      max_h: 600
    };
    game_defaults = {
      dx: 0,
      dy: -6,
      max_dx: 6,
      max_dy: 8,
      x: -1000,
      y: -1000,
      l_x: -1,
      right_down: false,
      left_down: false,
      right_acc: 0,
      left_acc: 0,
      state: "splash",
      paddle_color: "white",
      board_disp: [],
      space_w: 0,
      ball: {
        'cols': 2,
        'rows': 2,
        'w': 0,
        'h': 0
      },
      paddle: {
        'cols': 9,
        'rows': 1,
        'w': 0,
        'h': 10
      },
      width: 0,
      height: 0,
      mouse_min_x: 0,
      mouse_max_x: 0,
      ascii_colors: ['#c84848', '#c66c3a', '#b47a30', '#a2a22a', '#48a048'],
      figlet_font: "standard",
      font_size: 9,
      p_font_size: 9,
      ball_locked: true,
      ball_spin: 0,
      ball_angle: 0,
      l_ball_angle: 0,
      ball_da: Math.PI / 16,
      ball_spin_speed: 2,
      ball_max_spin: 1,
      l_char_row_index: 0,
      loop_cnt: 0,
      block_rotations: [],
      fall_interval: 200,
      fall_speed: function() {
        return Math.floor(Math.random() * 10 + game.font_size / 3);
      },
      bonuses: [],
      bonus: 1,
      points: 0,
      lives: 3,
      flash: false,
      brick_bounce: true,
      paddle_x: void 0,
      paddle_dir: 0,
      m_timeout: null,
      sound_enabled: true
    };
    updateBoardCfg = function() {
      ctx_g.clearRect(0, 0, game.w, game.h);
      ctx.clearRect(0, 0, game.w, game.h);
      $("#game-canvas")[0].width = cfg.max_w;
      $("#game-canvas")[0].height = cfg.max_h;
      game.w = $("#game-canvas").width();
      game.w_h = Math.ceil(game.w / 2);
      game.h = $("#game-canvas").height();
      game.h_h = Math.ceil(game.h / 2);
      $("#brick-canvas")[0].width = game.w;
      $("#brick-canvas")[0].height = game.h;
      game.mouse_min_x = $("#game-canvas").offset().left;
      game.mouse_max_x = game.mouse_min_x + game.w - game.paddle.w;
      ctx.textBaseline = "top";
      ctx_g.textBaseline = "top";
      ctx.font = game.font_size + "px " + cfg.font_name;
      ctx_g.font = game.p_font_size + "px " + cfg.font_name;
      game.char_w = ctx.measureText("]").width;
      game.p_char_w = ctx_g.measureText("]").width;
      game.char_w_h = Math.round(game.char_w / 2);
      game.p_char_w_h = Math.round(game.p_char_w / 2);
      game.font_size_h = Math.round(game.font_size / 2);
      game.p_font_size_h = Math.round(game.p_font_size / 2);
      game.ball.w = game.ball.cols * game.p_char_w;
      game.ball.w_h = Math.round(game.ball.w / 2);
      game.ball.h = game.ball.rows * game.p_font_size;
      game.ball.h_h = Math.round(game.ball.h / 2);
      game.paddle.w = game.paddle.cols * game.p_char_w;
      game.paddle.w_h = Math.round(game.paddle.w / 2);
      game.paddle.h = game.paddle.rows * game.p_font_size;
      game.paddle.h_h = Math.round(game.paddle.h / 2);
      if (!game.paddle_x) {
        game.l_paddle_x = game.paddle_x;
        game.paddle_x = game.w_h - game.paddle.w_h;
      }
      return dispBoard();
    };
    ctx_g = $("#game-canvas")[0].getContext("2d");
    ctx = $("#brick-canvas")[0].getContext("2d");
    game = $.extend(true, {}, game_defaults);
    game.sound = new Howl({
      "urls": ["../sounds/mygameaudio.ogg", "../sounds/mygameaudio.m4a", "../sounds/mygameaudio.mp3", "../sounds/mygameaudio.ac3"],
      "sprite": {
        "bounce": [0, 636.054421768707],
        "death": [2000, 597.1655328798184],
        "hit": [4000, 33.922902494331],
        "paddle": [6000, 81.541950113379],
        "pause": [8000, 439.818594104308],
        "unpause": [10000, 439.818594104308],
        "upgrade": [12000, 297.142857142857]
      }
    });
    playSound = function(sound) {
      if (game.sound_enabled) {
        game.sound.play(sound);
      }
    };
    cfg = $.extend(true, {}, cfg_defaults);
    updateBoardCfg();
    $.ajax({
      url: '/fonts.json',
      datatype: "json",
      success: function(data) {
        $("#font-name").attr("range", 1);
        $("#font-name").attr("min", 1);
        $("#font-name").attr("max", data.length);
        $("#font-name").attr("value", data.indexOf(game_defaults.figlet_font) + 1);
        return $("#font-name").rangeslider({
          polyfill: false,
          onSlide: function(p, v) {
            if (v) {
              $("div.font-disp").html("Slide to change the font and size - " + data[v - 1]);
              game.figlet_font = data[v - 1];
              return genDispData($('input[name=str]').val());
            }
          }
        });
      }
    });
    $("#font-size").rangeslider({
      polyfill: false,
      onSlide: function(p, v) {
        if (v) {
          game.font_size = +v;
          $("#js-rangeslider-0 .rangeslider__handle").html("<div style='overflow: hidden;'>" + v + "</div>");
          return genDispData($('input[name=str]').val());
        }
      }
    });
    routie(':str?/:font?/:size?', function(str, font, font_size) {
      var animFrame, canvas, decoded, recursiveAnim;
      if (str) {
        decoded = decodeURIComponent(str);
        $('input[name=str]').val(decoded);
        if (font) {
          game.figlet_font = decodeURIComponent(font);
          if (font_size) {
            game.font_size = +decodeURIComponent(font_size);
          }
        }
        genDispData(decoded);
        showRunning();
      } else {
        $('input[name=str]').val(cfg.default_str);
        game.figlet_font = cfg.default_font;
        genDispData(cfg.default_str);
        showSplash();
      }
      animFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || null;
      if (animFrame !== null) {
        canvas = $("#game-canvas").get(0);
        recursiveAnim = function() {
          gameLoop();
          return animFrame(recursiveAnim, canvas);
        };
        return animFrame(recursiveAnim, canvas);
      } else {
        return setInterval(gameLoop, 1000.0 / 60);
      }
    });
  });

}).call(this);
