$(document).ready(() ->

  sign = (x) -> `x > 0 ? 1 : x < 0 ? -1 : 0`

  # Game states
  #  - running
  #  - paused
  #  - splash
  #  - over
  #  - win

  showWin = () ->
    game.state = "win"
    $(".title").html("You won, Congratulations!")
    $(".splash").show()
    showTwitter()
    $("#ascii-submit").show()

  showRunning = () ->
    $(".splash").hide()
    game.state = "running"

  showOver = () ->
    updateBoardCfg()
    game.state = "over"
    game.ball_locked = true
    $(".title").html("Game Over!")
    $(".splash").show()
    $("#ascii-submit").show()
    showTwitter()

  showPaused = () ->
    game.state = "paused"
    $(".title").html("Game Paused")
    $(".splash").show()
    $("#ascii-submit").hide()
    $(".twitter-share").hide()
    $(".social-links").hide()


  showSplash = () ->
    game.state = "splash"
    $("#msg-flash").hide()
    $(".title").html("ascii breakout")
    $(".splash").show()
    $("#ascii-submit").show()
    $(".twitter-share").hide()

  msgFlash = (str, pause, speed) ->
    $("#msg-flash").html(str)
    if pause
      game.flash = true
    $("#msg-flash").fadeIn(speed, () ->
      game.flash = false
      $("#msg-flash").fadeOut("slow", () ->
      )
    )

  showTwitter = () ->
    msg = "I scored #{game.points} points on http://ascii-breakout.com"
    encoded = encodeURIComponent(msg)
    $(".twitter-share").html("""<a target="_blank"  href="https://twitter.com/home?status=#{encoded}">Share your score with a link to this game on twitter!"</a>""")
    $(".twitter-share").show()



  resetPoints = () ->
    game.points = game_defaults.points
    $("td.points").html(game.points)
    return

  addPoints = (val) ->
    game.points += val * game.bonus
    $("td.points").html(game.points)
    return

  resetLives = () ->
    game.lives = game_defaults.lives
    $("td.lives").html(game.lives)
    return

  removeLives = (val) ->
    game.lives -= val
    $("td.lives").html(game.lives)
    if not game.lives
      showOver()
    else
      updateBoardCfg()
      if game.lives > 1
        l = "#{game.lives} lives remaining"
      else
        l = "One life remaining"
      msgFlash(l, false, "slow")
      game.ball_locked = true

  addBonus = (val) ->
    game.bonus += val
    $("td.bonus").html("#{game.bonus}x")
    $("td.bonuses").html("#{game.bonuses.length}")

  resetBonuses = () ->
    game.bonuses = []
    game.paddle = game_defaults.paddle
    game.ball = game_defaults.ball
    game.fall_interval = game_defaults.fall_interval
    game.fall_speed = game_defaults.fall_speed
    game.brick_bounce = true
    game.bonus = game_defaults.bonus
    $("td.bonus").html("#{game.bonus}x")
    $("td.bonuses").html("#{game.bonuses.length}")


  # Mouse click events

  $(document).click((e) ->
    switch game.state
      when "running"
        if game.ball_locked
          game.ball_locked = false
        else
          showPaused()
      when "paused"
        showRunning()

    return
  )

  # color cycle
  getColor = (num) ->
    index = num % game.ascii_colors.length
    return game.ascii_colors[index]

  # Keyboard events
  $(document).keydown((evt) ->
    switch game.state
      when "paused"
        if  (evt.keyCode == 27) #  esc
          showRunning()
      when "running"
        if (evt.keyCode == 27) # esc
          showPaused()
        if (evt.keyCode == 32) # space
          game.ball_locked = false
    if (evt.keyCode == 39) # ->
      game.right_down = true
      game.paddle_dir = 1
    else if (evt.keyCode == 37) # <-
      game.left_down = true
      game.paddle_dir = -1

    return
  )

  $(document).keyup((evt) ->
    if (evt.keyCode == 39) # ->
      game.right_down = false
      game.right_acc = 0
      game.paddle_dir = 0
    else if (evt.keyCode == 37) # <-
      game.left_down = false
      game.left_acc = 0
      game.paddle_dir = 0
    return
  )

  # Mouse control for the paddles
  $(document).bind('touchmove mousemove', (e) ->
    switch game.state
      when "running"
        if game.m_timeout != null then clearTimeout(game.m_timeout)
        game.m_timeout = setTimeout(() ->
          game.m_timeout = null
          game.paddle_dir = 0
        , 50)

        if e.originalEvent.touches
          cX = e.originalEvent.touches[0].pageX
        else
          cX = e.pageX
        if (cX > game.mouse_min_x and cX < game.mouse_max_x)
          if cX - game.mouse_min_x < game.paddle_x
            game.paddle_dir = -1
          else if cX - game.mouse_min_x > game.paddle_x
            game.paddle_dir = 1
          game.l_paddle_x = game.paddle_x
          game.paddle_x = cX - game.mouse_min_x
  )

  # input text
  $('input[name=str]').on('input', (e) ->
    genDispData($('input[name=str]').val())
    return
  )

  $("#ascii-submit").submit((e) ->
    if $('input[name=str]').val().length > 0
      resetBonuses()
      resetLives()
      resetPoints()
      genDispData($('input[name=str]').val())
      showRunning()
    e.preventDefault()
    return
  )

  drawAsciiBall = (x, y) ->
    # clear previous location of ball
    ctx_g.save()
    ctx_g.translate(game.l_x + game.ball.w_h, game.l_y + game.ball.h_h)
    ctx_g.rotate(game.l_ball_angle)
    ctx_g.clearRect(
      -game.ball.w_h - game.p_char_w, -game.ball.h_h - game.p_font_size,
      game.ball.w + game.p_char_w * 3, game.ball.h + game.p_font_size * 3)
    ctx_g.restore()

    ctx_g.fillStyle = game.paddle_color
    ctx_g.save()
    ctx_g.translate(x + game.ball.w_h, y + game.ball.h_h)
    ctx_g.rotate(game.ball_angle)

    for r in [0..(game.ball.rows - 1)]
      row = ("O" for i in [1..game.ball.cols]).join("")
      ctx_g.fillText(row, -game.ball.w_h, -game.ball.h_h + r * game.p_font_size)
    ctx_g.restore()

    if game.loop_cnt % game.ball_spin_speed == 0
      game.l_ball_angle = game.ball_angle
      game.ball_angle += game.ball_spin * game.ball_da

      # if rotation moves the ball outside of the game
      # perimeter make an adjustment


      ul = [game.x, game.y]
      ur = [game.x + game.ball.w, game.y]
      lr = [game.x + game.ball.w, game.y + game.ball.h]
      ll = [game.x, game.y + game.ball.h]
      c = getRotatedCorners(ul, ur, lr, ll)
      max_y = Math.floor(Math.max.apply(null, (corner[1] for corner in c)))
      min_y = Math.ceil(Math.min.apply(null, (corner[1] for corner in c)))
      max_x = Math.ceil(Math.max.apply(null, (corner[0] for corner in c)))
      min_x = Math.floor(Math.min.apply(null, (corner[0] for corner in c)))
      if min_x < 0
        game.x -= min_x
      if max_x > game.w
        game.x -= max_x - game.w
      if min_y < 0
        game.y -= min_y
      if max_y > game.h - game.paddle.h
        game.y -= max_y - (game.h - game.paddle.h)

    return

  inc_w_limit = (value, inc, max, min) ->
    if inc < 0
      return Math.max(min, value + inc)
    else if inc >= 0
      return Math.min(max, value + inc)

  drawPaddle = (paddle_x) ->
    # clear last paddle
    ctx_g.clearRect(0, game.h - game.paddle.h - 1, game.w, game.paddle.h)
    ctx_g.fillStyle = game.paddle_color
    paddle = "[" + ("O" for i in [1..(game.paddle.cols - 2)]).join("") + "]"
    ctx_g.fillText(paddle, paddle_x, game.h - game.paddle.h)
    return

  Figlet.loadFont = (name, fn) ->
    url = "fonts/#{name}.flf" # load from github
                              # https://api.github.com/repos/jarv/
                              # ascii-breakout/contents/fonts/#{name}.flf"
    $.ajax({
      url: url,
      datatype: "text", # load from github - "jsonp",
      success: fn
    })

  genDispData = (str) ->
    Figlet.parsePhrase(str, game.figlet_font, (disp_data, word_boundaries, space_w) ->
      game.space_w = space_w
      line_breaks = createLineBreaks(disp_data, word_boundaries)
      game.board_disp = createBoardDisp(disp_data, line_breaks, word_boundaries, space_w)
      encoded_str = encodeURIComponent(str)
      encoded_font = encodeURIComponent(game.figlet_font)
      encoded_font_size = encodeURIComponent(game.font_size)
      if str.length > 0
        $(".share-link").html("""Link to this game! <a href="##{encoded_str}/#{encoded_font}/#{encoded_font_size}">#{str.replace(/\W/g, "-")}</a>""")
      else
        $(".share-link").html("")
      updateBoardCfg()
    )
    return

  createLineBreaks = (disp_data, word_boundaries) ->

    line_breaks = []
    xpos = 0
    last_word_boundary = false
    if not disp_data or disp_data.length == 0
      return []

    for col, index in disp_data[0]
      xpos += game.char_w
      if xpos < game.w
        if index in word_boundaries
          last_word_boundary = index
      else if xpos > game.w
        if last_word_boundary
          line_breaks.push(last_word_boundary)
          xpos = 0 + game.char_w * (index - last_word_boundary)
          last_word_boundary = false
        else
          # force a line break
          line_breaks.push(index)
          xpos = 0

    if line_breaks.length == 0
      # If there are no line breaks, return the length
      # of the row
      line_breaks.push(disp_data[0].length)
    else if line_breaks[line_breaks.length - 1] < disp_data[0].length
      # add any remaining characters as the last break
      line_breaks.push(disp_data[0].length)

    return line_breaks


  pointInBrick = (x, y, brick_x, brick_y) ->
    # check if a point is inside a brick
    if ((x  > brick_x + game.char_w) \
        or (x < brick_x) \
        or (y  > brick_y + game.font_size) \
        or (y < brick_y))
      return false
    return true


  checkBallCollision = (brick_x, brick_y, handle_fn) ->
    xpos = game.x
    ypos = game.y
    for row in [1..game.ball.rows]
      for col in [1..game.ball.cols]

        ul = [xpos, ypos]
        ur = [xpos + game.p_char_w, ypos]
        lr = [xpos + game.p_char_w, ypos + game.p_font_size]
        ll = [xpos, ypos + game.p_font_size]
        c = getRotatedCorners(ul, ur, lr, ll)
        for corner, index in c
          if pointInBrick(corner[0] + game.dx, corner[1] + game.dy, brick_x, brick_y)
            addPoints(1)
            if not handle_fn
              return [corner[0], corner[1]]
            else
              return handle_fn([corner[0], corner[1]], brick_x, brick_y)
        xpos += game.p_char_w
      xpos = game.x
      ypos += game.p_font_size
    return false

  handleBallCollision = (c, brick_x, brick_y) ->
    if not game.brick_bounce
      return true
    # center brick
    c_brick_x = brick_x + game.char_w_h
    c_brick_y = brick_y + game.font_size_h

    #
    #   -------
    #  | \ b / |
    #  |c \ / a|
    #  |  / \  |
    #  | / d \ |
    #  --------
    #
    # a = PI/4 to -PI/4
    # b = -PI/4 to -3PI/4
    # c = -3PI/4 to -PI or 3PI/4 to PI
    # d = PI/4 to 3PI/4

    # angle of (brick) attack
    aoa = Math.atan2((c[1] - c_brick_y), (c[0] - c_brick_x))
    switch
      when  aoa <=  Math.PI / 4 and aoa > -Math.PI / 4 # (a)
        if (game.dx <= 0)
          game.dx = -game.dx
      when  aoa <= -Math.PI / 4 and aoa > -3 * Math.PI / 4 # (b)
        if (game.dy >= 0)
          game.dy = -game.dy
      when (aoa <= -3 * Math.PI / 4 and aoa >= -Math.PI) or (aoa <= Math.PI and aoa >= 3 * Math.PI / 4) # (c)
        if (game.dx >= 0)
          game.dx = -game.dx
      when  aoa <= 3 * Math.PI / 4 and aoa > Math.PI / 4 # (d)
        if (game.dy <= 0)
          game.dy = -game.dy

    return true

  createBoardDisp = (disp_data, line_breaks, word_boundaries, space_w) ->
    board_disp = []
    line_cnt = 0
    last_break = 0
    space_offset = 0
    for break_pos in line_breaks
      for row, row_index in disp_data
        if break_pos in word_boundaries and last_break != 0
          space_offset = space_w
        sliced_row = row.slice(last_break + space_offset, break_pos)
        board_disp[row_index + (line_cnt * disp_data.length)] = sliced_row
      last_break = break_pos
      line_cnt += 1

    return board_disp

  processBoardDisp  = () ->
    ypos = 0
    has_won = true
    xpos_c = null
    ypos_c = null
    last_c = null

    for row, row_index in game.board_disp
      xpos = game.w_h - Math.round(row.length * game.char_w / 2)
      for column, column_index in row
        if column != " "
          has_won = false
          c = checkBallCollision(xpos, ypos)
          if c
            last_c = c
            xpos_c = xpos
            ypos_c = ypos
            game.board_disp[row_index][column_index] = " "
            ctx.clearRect(xpos, ypos, game.char_w, game.font_size)

        xpos += game.char_w
      ypos += game.font_size

    if last_c
      # if there was a collision we bounce the ball
      # off of the last brick that we ran into
      handleBallCollision(last_c, xpos_c, ypos_c)
    return has_won

  doBonus = () ->
    num_bonuses = 6

    if game.bonuses.length >= num_bonuses
      resetBonuses()

    # random bonus
    while true
      bonus = Math.ceil(Math.random() * num_bonuses)
      if bonus not in game.bonuses
        break
    game.bonuses.push(bonus)

    switch bonus
      when 1
        msgFlash("Small Paddle +10!", true, "fast")
        addBonus(10)
        game.paddle.cols = 5
      when 2
        msgFlash("Double Paddle +2!")
        addBonus(2)
        game.paddle.cols = game.paddle.cols * 2
      when 3
        msgFlash("Small Ball +20!", true, "fast")
        addBonus(20)
        game.ball.cols = 1
        game.ball.rows = 1
      when 4
        msgFlash("Double Ball +5!", true, "fast")
        addBonus(5)
        game.ball.cols = game.ball.cols * 2
        game.ball.rows = game.ball.rows * 2
      when 5
        msgFlash("More falling bricks!", true, "fast")
        game.fall_interval = 100
      when 6
        msgFlash("Super ball!!", true, "fast")
        game.brick_bounce = false
        game.ball.cols = 8
        game.ball.rows = 8

    updateBoardCfg()

  fallingBlocks = () ->

    clearFallingBlock = (ypos, angle) ->
      ctx.save()
      ctx.translate(r.x + game.char_w_h, ypos + game.font_size_h)
      ctx.rotate(angle)
      ctx.clearRect(-game.char_w_h - game.char_w,
                    -game.font_size_h - game.font_size,
                    game.char_w * 3, game.font_size * 3)
      ctx.restore()

    # Display falling blocks

    for r in game.block_rotations.filter((elem) -> return elem.d == true)
      if (r.y + game.font_size > game.h - game.paddle.h) and
          (r.x + game.char_w > game.paddle_x and r.x < game.paddle_x + game.paddle.w)
        # paddle collision
        r.d = false
        doBonus()
        updateBoardCfg()
      else if checkBallCollision(r.x, r.y, handleBallCollision)
        r.d = false
        doBonus()
        updateBoardCfg()
      else
        if game.state == "running"
          if game.loop_cnt % r.s == 0
            if r.l_y
              clearFallingBlock(r.l_y, r.l_r)
            if not r.c
              console.log("UNDEFINED")
              console.log(game.block_rotations)
            ctx.save()
            ctx.translate(r.x + game.char_w_h, r.y + game.font_size_h)
            ctx.rotate(r.r)
            ctx.fillText(r.c, -game.char_w_h, -game.font_size_h)
            ctx.restore()

            r.l_y = r.y
            r.y += game.font_size
            r.l_r = r.r
            r.r += Math.PI/4
            if r.y > game.h
              r.d = false
              clearFallingBlock(r.l_y, r.l_r)

    # Add new falling blocks

    if game.state == "running"

      last_row = game.board_disp[game.l_char_row_index]
      if game.loop_cnt % game.fall_interval == 0 and last_row
        non_spaces = []
        for value, index in last_row
          if value != " "
            non_spaces.push(index)
        if non_spaces.length == 0
          return
        # random character in the last non-space row
        row_index = non_spaces[Math.floor(Math.random() * non_spaces.length)]
        xpos = game.w_h - Math.round(last_row.length * game.char_w / 2)
        if not last_row[row_index]
          console.log("Adding undefined value! #{non_spaces} #{row_index}")
        game.block_rotations.push({
          x: xpos + game.char_w * row_index
          y: game.l_char_row_index * game.font_size + game.font_size
          l_y: null
          # rotation
          l_r: null
          r: 0
          # rotation speed
          rs: Math.floor(Math.random() * 10 + 3)
          # char
          c: last_row[row_index]
          # speed
          s: game.fall_speed()
          # display?
          d: true
        })
        # remove the character from the board
        last_row[row_index] = " "
        ctx.clearRect(xpos + game.char_w * row_index,
                      game.l_char_row_index * game.font_size,
                      game.char_w, game.font_size)

    return


  dispBoard = () ->
    ypos = 0
    # track the last row contains some characters

    for row, row_index in game.board_disp
      xpos = game.w_h - Math.round(row.length * game.char_w / 2)
      text_color = getColor(row_index)
      if row.some((elem) -> return elem != " ")
        game.l_char_row_index = row_index

      ctx.fillStyle = text_color
      ctx.fillText(row.join(""), xpos, ypos)
      ypos += game.font_size


  getRotatedCorners = (ul, ur, lr, ll) ->

    # ul = upper left
    # ur = upper right
    # lr = lower right
    # ll = lower left
    #
    # ul ----- ur
    # |        |
    # |        |
    # ll ----- lr
    #

    # if the angle is a multiple of pi we don't need to worry about
    # compensating for rotation
    if Math.round(100 * game.ball_angle) % Math.round(100 * Math.PI) == 0
      return [ul, ur, lr, ll]
    else
      r_x = game.x + game.ball.w_h
      r_y = game.y + game.ball.h_h
      ball_cos = Math.cos(game.ball_angle)
      ball_sin = Math.sin(game.ball_angle)
      return [
        [r_x + (ul[0] - r_x) * ball_cos + (ul[1] - r_y) * ball_sin,
         r_y - (ul[0] - r_x) * ball_sin + (ul[1] - r_y) * ball_cos],
        [r_x + (ur[0] - r_x) * ball_cos + (ur[1] - r_y) * ball_sin,
         r_y - (ur[0] - r_x) * ball_sin + (ur[1] - r_y) * ball_cos],
        [r_x + (lr[0] - r_x) * ball_cos + (lr[1] - r_y) * ball_sin,
         r_y - (lr[0] - r_x) * ball_sin + (lr[1] - r_y) * ball_cos],
        [r_x + (ll[0] - r_x) * ball_cos + (ll[1] - r_y) * ball_sin,
         r_y - (ll[0] - r_x) * ball_sin + (ll[1] - r_y) * ball_cos]
      ]



  getBallHeight = () ->
    ul = [game.x, game.y]
    ur = [game.x + game.ball.w, game.y]
    lr = [game.x + game.ball.w, game.y + game.ball.h]
    ll = [game.x, game.y + game.ball.h]
    c = getRotatedCorners(ul, ur, lr, ll)
    return Math.max.apply(null, (corner[1] for corner in c)) - Math.min.apply(null, (corner[1] for corner in c))

  gameLoop = () ->

    if game.state == "running"
      won = processBoardDisp()

      if won and game.board_disp.length > 0
        showWin()

      if game.flash
        return

      if game.ball_locked
        game.l_x = game.x
        game.l_y = game.y
        game.ball_angle = game_defaults.ball_angle
        #game.l_ball_angle = game_defaults.l_ball_angle
        game.dx = game_defaults.dx
        game.dy = game_defaults.dy
        game.x = game.paddle_x + game.paddle.w_h - game.ball.w_h
        game.y = game.h - game.paddle.h - game.ball.h - (getBallHeight() / 2 - game.ball.h_h)

      if game.l_char_row_index != 0 and not game.ball_locked
        fallingBlocks()


      drawAsciiBall(game.x, game.y)

      if game.right_down
        if game.paddle_x + game.paddle.w < game.w
          game.l_paddle_x = game.paddle_x
          game.paddle_x += Math.floor(5 + game.right_acc)
          game.right_acc += cfg.acc_rate
      else if game.left_down
        if game.paddle_x > 0
          game.paddle_x -= Math.floor(5 + game.left_acc)
          game.left_acc += cfg.acc_rate
      drawPaddle(game.paddle_x)

      ul = [game.x, game.y]
      ur = [game.x + game.ball.w, game.y]
      lr = [game.x + game.ball.w, game.y + game.ball.h]
      ll = [game.x, game.y + game.ball.h]
      c = getRotatedCorners(ul, ur, lr, ll)
      max_y = Math.floor(Math.max.apply(null, (corner[1] for corner in c)))
      min_y = Math.ceil(Math.min.apply(null, (corner[1] for corner in c)))
      max_x = Math.ceil(Math.max.apply(null, (corner[0] for corner in c)))
      min_x = Math.floor(Math.min.apply(null, (corner[0] for corner in c)))

      # handle wall collisions
      if (max_x + game.dx > game.w)
        # if the ball is not spinning or if it is spinning in the opposite
        # direction from its motion then slow down the spin and the speed
        if not game.ball_spin or sign(game.dy) == sign(game.ball_spin)
          game.dy = inc_w_limit(game.dy, -game.ball_spin * 2, game.max_dy, -game.max_dy)
          game.ball_spin = inc_w_limit(game.ball_spin, -game.dy, game.ball_max_spin, -game.ball_max_spin)
        game.dx = -game.dx
      if (min_x + game.dx < 0)
        # if the ball is not spinning or if it is spinning in the opposite
        # direction from its motion then slow down the spin and the speed
        if not game.ball_spin or sign(game.dy) != sign(game.ball_spin)
          game.dy = inc_w_limit(game.dy, game.ball_spin * 2, game.max_dy, -game.max_dy)
          game.ball_spin = inc_w_limit(game.ball_spin, game.dy, game.ball_max_spin, -game.ball_max_spin)
        # if the ball has a slow verit speed, reset it to the default
        game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy))
        game.dx = -game.dx
      if (min_y + game.dy < 0)
        # if the ball is not spinning or if it is spinning in the opposite
        # direction from its motion then slow down the spin and the speed
        if not game.ball_spin or sign(game.dx) == sign(game.ball_spin)
          game.dx = inc_w_limit(game.dx, -game.ball_spin * 2, game.max_dx, -game.max_dx)
          game.ball_spin = inc_w_limit(game.ball_spin, -game.dx, game.ball_max_spin, -game.ball_max_spin)
        # if the ball has a slow verit speed, reset it to the default
        game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy))
        game.dy = -game.dy
      else if (max_y + game.dy > (game.h - game.paddle.h))
        # ball is at the bottom of the board
        if (max_x > game.paddle_x and min_x < (game.paddle_x + game.paddle.w))
          # if the ball is not spinning or if it is spinning in the opposite
          # direction from its motion then slow down the spin and the speed
          if not game.ball_spin or sign(game.dx) != sign(game.ball_spin)
            game.dx = inc_w_limit(game.dx, game.ball_spin * 2, game.max_dx, -game.max_dx)
            game.ball_spin = inc_w_limit(game.ball_spin, game.dx, game.ball_max_spin, -game.ball_max_spin)
          # add even more to the ball's horiz speed if the paddle is moving
          game.dx = inc_w_limit(game.dx, -game.paddle_dir * 2, game.max_dx, -game.max_dx)
          # add to the ball's spin speed if the paddle is moving
          game.ball_spin = inc_w_limit(game.ball_spin, -game.paddle_dir, game.ball_max_spin, -game.ball_max_spin)

          # CORNER SHOTS - SUSPEND ALL LAWS OF PHYSICS EVEN MORE SO !!1!
          if (game.x + game.ball.w < game.paddle_x + game.p_char_w)
            game.dx = -game.max_dx
            game.ball_spin = -game.ball_max_spin
          if (game.x > game.paddle_x + game.paddle.w - game.p_char_w)
            game.dx =  game.max_dx
            game.ball_spin = game.ball_max_spin

          game.dy = -game.dy
          # if the ball has a slow verit speed, reset it to the default
          game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy))
        else
          if game.state == "running"
            removeLives(1)
          game.dy = -game.dy

      if not game.ball_locked
        game.l_x = game.x
        game.l_y = game.y
        game.x += game.dx
        game.y += game.dy
    game.loop_cnt += 1
    return

  cfg_defaults = {
    # cfg have vars that remain the same
    # through a single game
    # font_name: "'Courier New', Monospace"
    font_name: "pressStart"
    default_str: "ASCII BREAKOUT Type whatever you want and play!"
    default_font: "standard"
    acc_rate: .5
    max_w: 800
    max_h: 600

  }

  game_defaults = {
    # initial speed
    dx: 0
    dy: -6
    # Max dx for when the ball
    # hits a moving paddle
    max_dx: 10
    max_dy: 12
    # initial position
    x: -1000
    y: -1000
    # last position
    l_x: -1
    right_down: false
    left_down: false
    right_acc: 0
    left_acc: 0

    state: "splash"
    paddle_color: "white"

    # how the characters are displayed
    # on canvas (after wrapping)
    board_disp: []

    # with of a space character, also
    # needed for word wrapping
    space_w: 0

    # ball
    # Small  O
    #  1x1
    #
    # Medium OOO
    #  3x2   OOO
    #
    # Large  OOOOO
    #  5x3   OOOOO
    #        OOOOO

    ball: {'cols': 2, 'rows': 2, 'w': 0, 'h': 0}
    # paddle
    # [OOOOOOO]
    paddle: {'cols': 9, 'rows': 1, 'w': 0, 'h': 10}
    # overridden by width of fullscreen
    width: 0
    height: 0
    mouse_min_x: 0
    mouse_max_x: 0


    ascii_colors: ['#c84848', '#c66c3a', '#b47a30', '#a2a22a', '#48a048'] # , '#4248c8']
    figlet_font: "standard"

    font_size: 9
    p_font_size: 9
    # ball locked on paddle
    ball_locked: true
    # what direction the ball is spinning
    # and its current angle
    ball_spin: 0
    ball_angle: 0
    l_ball_angle: 0
    ball_da: Math.PI / 16
    ball_spin_speed: 2
    ball_max_spin: 1

    # last row that contains blocks
    l_char_row_index: 0
    # periodic rotations
    loop_cnt: 0
    block_rotations: []
    fall_interval: 200
    fall_speed: () -> Math.floor(Math.random() * 10 + game.font_size / 3)

    # bonus items
    bonuses: []
    bonus: 1 # multiplier for bonus
    points: 0
    lives: 3
    flash: false # pause the game for msg flashes
    brick_bounce: true # bounce the brick

    # horizontal paddle location and
    # the paddle direction
    paddle_x: undefined
    paddle_dir: 0

    # for detecting an idle mouse
    m_timeout: null
  }

  updateBoardCfg  = () ->
    ctx_g.clearRect(0, 0, game.w, game.h)
    ctx.clearRect(0, 0, game.w, game.h)
    #$("#game-canvas")[0].width = Math.floor($(window).width())
    #$("#game-canvas")[0].height = Math.floor($(window).height())
    $("#game-canvas")[0].width = cfg.max_w
    $("#game-canvas")[0].height = cfg.max_h
    game.w =  $("#game-canvas").width()
    game.w_h = Math.ceil(game.w / 2)
    game.h = $("#game-canvas").height()
    game.h_h = Math.ceil(game.h / 2)
    # the canvas for the bricks sits under the canvas
    # for the game, it has the same dimensions
    $("#brick-canvas")[0].width = game.w
    $("#brick-canvas")[0].height = game.h
    game.mouse_min_x = $("#game-canvas").offset().left
    game.mouse_max_x = game.mouse_min_x + game.w - game.paddle.w
    # move the paddle to the middle of the screen
    # after resize
    ctx.textBaseline = "top"
    ctx_g.textBaseline = "top"
    ctx.font = "#{game.font_size}px #{cfg.font_name}"
    ctx_g.font = "#{game.p_font_size}px #{cfg.font_name}"
    game.char_w = ctx.measureText("]").width
    game.p_char_w = ctx_g.measureText("]").width
    game.char_w_h = Math.round(game.char_w / 2)
    game.p_char_w_h = Math.round(game.p_char_w / 2)
    game.font_size_h = Math.round(game.font_size / 2)
    game.p_font_size_h = Math.round(game.p_font_size / 2)
    game.ball.w = game.ball.cols * game.p_char_w
    game.ball.w_h = Math.round(game.ball.w / 2)
    game.ball.h = game.ball.rows * game.p_font_size
    game.ball.h_h = Math.round(game.ball.h / 2)
    game.paddle.w = game.paddle.cols * game.p_char_w
    game.paddle.w_h = Math.round(game.paddle.w / 2)
    game.paddle.h = game.paddle.rows * game.p_font_size
    game.paddle.h_h = Math.round(game.paddle.h / 2)
    if not game.paddle_x
      game.l_paddle_x = game.paddle_x
      game.paddle_x = game.w_h - game.paddle.w_h
    dispBoard()

  ctx_g = $("#game-canvas")[0].getContext("2d")
  ctx = $("#brick-canvas")[0].getContext("2d")
  # $(window).resize(() ->
  #   updateBoardCfg()
  # )


  # update game state vars with defaults
  game = $.extend(true, {}, game_defaults)
  # update config with defaults
  cfg = $.extend(true, {}, cfg_defaults)
  updateBoardCfg()

  # slider for font names
  $.ajax({
    url: '/fonts.json',
    datatype: "json",
    success: (data) ->
      $("#font-name").attr("range", 1)
      $("#font-name").attr("min", 1)
      $("#font-name").attr("max", data.length)
      $("#font-name").attr("value", data.indexOf(game_defaults.figlet_font) + 1)
      $("#font-name").rangeslider({
        polyfill: false,
        onSlide: (p, v) ->
          if v
            $("div.font-disp").html("Slide to change the font and size - #{data[v - 1]}")
            game.figlet_font = data[v - 1]
            genDispData($('input[name=str]').val())
      })

  })

  # slider for font size
  $("#font-size").rangeslider({
    polyfill: false,
    onSlide: (p, v) ->
      if v
        game.font_size = +v
        $("#js-rangeslider-0 .rangeslider__handle").html("<div style='overflow: hidden;'>#{v}</div>")
        genDispData($('input[name=str]').val())
  })


  routie(':str?/:font?/:size?', (str, font, font_size) ->
    if str
      decoded = decodeURIComponent(str)
      $('input[name=str]').val(decoded)
      if font
        game.figlet_font = decodeURIComponent(font)
        if font_size
          game.font_size = +decodeURIComponent(font_size)

      genDispData(decoded)
      showRunning()
    else
      $('input[name=str]').val(cfg.default_str)
      game.figlet_font = cfg.default_font
      genDispData(cfg.default_str)
      showSplash()

    # Setup the game loop and deal with
    # cross browser issues, what a mess!!

    animFrame = window.requestAnimationFrame ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame    ||
            window.oRequestAnimationFrame      ||
            window.msRequestAnimationFrame     ||
            null
    if animFrame != null

      canvas = $("#game-canvas").get(0)
      recursiveAnim = () ->
        gameLoop()
        animFrame(recursiveAnim, canvas)
      animFrame(recursiveAnim, canvas)
    else
      setInterval(gameLoop, 1000.0/60)
  )
  return
)
