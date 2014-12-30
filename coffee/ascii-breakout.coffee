$(() ->

  sign = (x) -> `x > 0 ? 1 : x < 0 ? -1 : 0`

  $(".select-box label").hover(
    () ->

      $(this).closest("label").css("z-index", 1)
      $(this).animate({height: "30", width: "90", left: "-=10", top: "-=5", "padding-top": "+=5", "font-size": "+=0" }, "fast")
      return
    () ->
      $(this).closest("label").css("z-index", 0)
      $(this).animate({height: "20", width: "70", left: "+=10", top: "+=5","padding-top": "-=5",  "font-size": "-=0" }, "fast")
      return
  )

  $("input[name=font]:radio").change(() ->
    font = $('input[name=font]:checked').val()
    game.figlet_font = font
    genDispData($('input[name=str]').val())
  )

  $("input[type=range]").change(() ->
    game.font_size = +$("input[type=range]").val()
    genDispData($('input[name=str]').val())
  )
  # Game states
  #  - running
  #  - paused
  #  - splash
  #  - over
  #  - win

  showWin = () ->
    game.state = "win"
    $(".title").html("Hey, looks like you won. Congratulations!")
    $(".actions-paused").hide()
    $(".actions-splash").show()
    $(".splash").show()

  showRunning = () ->
    $(".splash").hide()
    game.state = "running"

  showOver = () ->
    game.state = "over"
    game.ball_locked = true
    $(".title").html("Game Over!")
    $(".actions-paused").hide()
    $(".actions-splash").show()
    $(".splash").show()

  showPaused = () ->
    game.state = "paused"
    $(".title").html("Game Paused")
    $(".actions-splash").hide()
    $(".actions-paused").show()
    $(".splash").show()

  showSplash = () ->
    game.state = "splash"
    $(".title").html("Ascii Breakout!")
    $(".actions-paused").hide()
    $(".actions-splash").show()
    $(".splash").show()

  # Mouse click events

  $(document).click((e) ->
    switch game.state
      when "running"
        if game.ball_locked
          game.ball_locked = false
        else
          showPaused()
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
    if $('input[name=str]').val().length > 1
      showRunning()
    e.preventDefault()
    return
  )

  drawAsciiBall = (x, y) ->
    # clear previous location of ball
    ctx_g.save()
    ctx_g.translate(game.l_x + game.ball.w_h, game.l_y + game.ball.h_h)
    ctx_g.rotate(game.l_ball_angle)
    ctx_g.clearRect(-game.ball.w_h - game.char_width, -game.ball.h_h - game.font_size,
                    game.ball.w + game.char_width * 2, game.ball.h + game.font_size * 2)
    # without slop # ctx_g.clearRect(-game.ball.w_h, -game.ball.h_h, game.ball.w , game.ball.h )
    ctx_g.restore()

    ctx_g.fillStyle = game.paddle_color
    ctx_g.save()
    ctx_g.translate(x + game.ball.w_h, y + game.ball.h_h)
    ctx_g.rotate(game.ball_angle)
    for r in [0..(game.ball.rows - 1)]
      row = ("O" for i in [1..game.ball.cols]).join("")
      ctx_g.fillText(row, -game.ball.w_h, -game.ball.h_h + r * game.font_size)
    ctx_g.restore()
    if game.loop_cnt % game.ball_spin_speed == 0
      game.l_ball_angle = game.ball_angle
      game.ball_angle += game.ball_spin * game.ball_da
    return

  inc_w_limit = (value, inc, max, min) ->
    if inc < 0
      return Math.max(min, value + inc)
    else if inc >= 0
      return Math.min(max, value + inc)

  drawPaddle = (paddle_x) ->
    # clear last paddle
    ctx_g.clearRect(0, game.height - game.paddle.h, game.width, game.paddle.h)
    ctx_g.fillStyle = game.paddle_color
    paddle = "[" + ("O" for i in [1..(game.paddle.cols - 2)]).join("") + "]"
    ctx_g.fillText(paddle, paddle_x, game.height - game.paddle.h)
    return

  Figlet.loadFont = (name, fn) ->
    url = "fonts/#{name}.flf" # load from github - "https://api.github.com/repos/scottgonzalez/figlet-js/contents/fonts/#{name}.flf"
    $.ajax({
      url: url,
      datatype: "text", # load from github - "jsonp",
      success: fn
    })

  genDispData = (str) ->
    Figlet.parsePhrase(str, game.figlet_font, (disp_data, word_boundaries, space_width) ->
      game.space_width = space_width
      line_breaks = createLineBreaks(disp_data, word_boundaries)
      game.board_disp = createBoardDisp(disp_data, line_breaks)

      encoded_str = encodeURI(str)
      encoded_font = encodeURI(game.figlet_font)
      encoded_font_size = encodeURI(game.font_size)
      if str.length > 0
        $(".share-link").html("""<a href="##{encoded_str}/#{encoded_font}/#{encoded_font_size}">Use this link to share this game with a friend!</a>""")
      else
        $(".share-link").html("")
      updateBoardCfg()
    )
    return

  createLineBreaks = (disp_data, word_boundaries) ->

    line_breaks = []
    xpos = 0
    last_word_boundary = false

    for col, index in disp_data[0]
      xpos += game.char_width

      if xpos < game.width
        if index in word_boundaries
          last_word_boundary = index
      else if xpos > game.width
        if last_word_boundary
          line_breaks.push(last_word_boundary)
          xpos = 0 + game.char_width * (index - last_word_boundary)
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


  checkCollision = (brick_x, brick_y) ->

    # check if there is a collision,
    # if not return false
    if ((game.x  > brick_x + game.char_width) \
        or (game.x + game.ball.w < brick_x) \
        or (game.y  > brick_y + game.font_size) \
        or (game.y + game.ball.h < brick_y))
      return false

    # center brick
    c_brick_x = brick_x + game.char_width_h
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
    aoa = Math.atan2((game.y - c_brick_y), (game.x - c_brick_x))

    switch
      when  aoa <=  Math.PI / 4 and aoa > -Math.PI / 4 # (a)
        if (game.dx <= 0)
          game.dx = -game.dx
      when  aoa <= -Math.PI / 4 and aoa > -3 * Math.PI / 4 # (b)
        if (game.dy >= 0)
          game.dy = -game.dy
      when (aoa <= -3 * Math.PI and aoa > -Math.PI) or (aoa <= Math.PI and aoa > 3 * Math.PI / 4) # (c)
        if (game.dx >= 0)
          game.dx = -game.dx
      when  aoa <= 3 * Math.PI / 4 and aoa > Math.PI / 4 # (d)
        if (game.dy <= 0)
          game.dy = -game.dy

    ctx.clearRect(0, brick_y - game.font_size, game.width, game.font_size * 3)
    # ctx.clearRect(brick_x - game.char_width, brick_y - game.font_size, game.width * 3, game.font_size * 3)
    return true

  createBoardDisp = (disp_data, line_breaks) ->
    board_disp = []
    line_cnt = 0
    last_break = 0
    for break_pos in line_breaks
      for row, row_index in disp_data
        sliced_row = row.slice(last_break, break_pos)
        board_disp[row_index + (line_cnt * disp_data.length)] = sliced_row
      last_break = break_pos
      line_cnt += 1

    return board_disp

  processBoardDisp  = () ->
    ypos = 0
    has_won = true
    for row, row_index in game.board_disp
      xpos = game.width_h -  row.length * game.char_width_h
      for column, column_index in row
        if column != " "
          has_won = false
          if checkCollision(xpos, ypos)
            game.board_disp[row_index][column_index] = " "

        xpos += game.char_width
      ypos += game.font_size
    return has_won

  doBonus = () ->
    num_bonuses = 6

    if game.bonuses.length >= num_bonuses
      # reset bonuses
      game.bonuses = []
      game.paddle = game_defaults.paddle
      game.ball = game_defaults.ball
      game.fall_interval = game_defaults.fall_interval
      game.fall_speed = game_defaults.fall_speed

    # random bonus
    while true
      bonus = Math.ceil(Math.random() * num_bonuses)
      if bonus not in game.bonuses
        break

    switch bonus
      when 1
        game.paddle.cols = 3
      when 2
        game.paddle.cols = game_defaults.paddle.cols * 2
      when 3
        game.ball.cols = 1
        game.ball.rows = 1
      when 4
        game.ball.cols = game_defaults.ball.cols * 2
        game.ball.rows = game_defaults.ball.rows * 2
      when 5
        game.fall_interval = 100
      when 6
        game.fall_speed = () -> 3

    game.bonuses.push(bonus)
    updateBoardCfg()

  fallingBlocks = (l_char_row_index) ->

    # Display falling blocks

    for r in game.block_rotations.filter((elem) -> return elem.d == true)
      if (r.y + game.font_size > game.height - game.paddle.h) and
          (r.x + game.char_width > game.paddle_x and r.x < game.paddle_x + game.paddle.w)
        # paddle collision
        r.d = false
        doBonus()
      else if checkCollision(r.x, r.y)
        r.d = false
        updateBoardCfg()
      else
        if game.state == "running"
          if game.loop_cnt % r.s == 0
            if r.l_y
              ctx.save()
              ctx.translate(r.x + game.char_width_h, r.l_y + game.font_size_h)
              ctx.rotate(r.l_r)
              ctx.clearRect(-game.char_width_h - game.char_width, -game.font_size_h - game.font_size, game.char_width * 3, game.font_size * 3)
              ctx.restore()

            ctx.save()
            ctx.translate(r.x + game.char_width_h, r.y + game.font_size_h)
            ctx.rotate(r.r)
            ctx.fillText(r.c, -game.char_width_h, -game.font_size_h)
            ctx.restore()

            r.l_y = r.y
            r.y += game.font_size
            r.l_r = r.r
            r.r += Math.PI/4
            if r.y > game.height
              r.d = false

    # Add new falling blocks

    if game.state == "running"

      if game.loop_cnt % game.fall_interval == 0 and game.board_disp[l_char_row_index]
        non_spaces = []
        last_row = game.board_disp[l_char_row_index]
        for value, index in last_row
          if value != " "
            non_spaces.push(index)

        # random character in the last non-space row
        row_index = non_spaces[Math.floor(Math.random() * non_spaces.length)]
        # add the character to the block rotations
        xpos = game.width_h - last_row.length * game.char_width_h
        game.block_rotations.push({
          x: xpos + game.char_width * row_index
          y: l_char_row_index * game.font_size + game.font_size
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

    return


  dispBoard = () ->
    ypos = 0
    # track the last row contains some characters
    l_char_row_index = 0

    for row, row_index in game.board_disp
      xpos = game.width_h - row.length * game.char_width_h
      text_color = getColor(row_index)
      if row.some((elem) -> return elem != " ")
        l_char_row_index = row_index

      ctx.fillStyle = text_color
      ctx.fillText(row.join(""), xpos, ypos)
      ypos += game.font_size

    fallingBlocks(l_char_row_index)


  gameLoop = () ->
    # set to false in process_disp_data()
    # if a brick is found
    switch game.state
      when "over"
        showOver()
      when "paused"
        showPaused()

    won = processBoardDisp()
    dispBoard()

    if game.state == "running"

      if won and game.board_disp.length > 0
        showWin()

      if game.ball_locked
        game.l_x = game.x
        game.l_y = game.y
        game.x = game.paddle_x + game.paddle.w_h - game.ball.w_h
        game.y = game.height - game.paddle.h - game.ball.h

      drawAsciiBall(game.x, game.y)

      if game.right_down
        if game.paddle_x + game.paddle.w < game.width
          game.l_paddle_x = game.paddle_x
          game.paddle_x += Math.floor(5 + game.right_acc)
          game.right_acc += cfg.acc_rate
      else if game.left_down
        if game.paddle_x > 0
          game.paddle_x -= Math.floor(5 + game.left_acc)
          game.left_acc += cfg.acc_rate
      drawPaddle(game.paddle_x)

      # handle wall collisions
      if (game.x + game.ball.w > game.width)
        # if the ball is not spinning or if it is spinning in the opposite
        # direction from its motion then slow down the spin and the speed
        if not game.ball_spin or sign(game.dy) == sign(game.ball_spin)
          game.dy = inc_w_limit(game.dy, -game.ball_spin * 2, game.max_dy, -game.max_dy)
          game.ball_spin = inc_w_limit(game.ball_spin, -game.dy, game.ball_max_spin, -game.ball_max_spin)
        game.dx = -game.dx
      if (game.x < 0)
        # if the ball is not spinning or if it is spinning in the opposite
        # direction from its motion then slow down the spin and the speed
        if not game.ball_spin or sign(game.dy) != sign(game.ball_spin)
          game.dy = inc_w_limit(game.dy, game.ball_spin * 2, game.max_dy, -game.max_dy)
          game.ball_spin = inc_w_limit(game.ball_spin, game.dy, game.ball_max_spin, -game.ball_max_spin)
        game.dx = -game.dx
      if (game.y < 0)
        # if the ball is not spinning or if it is spinning in the opposite
        # direction from its motion then slow down the spin and the speed
        if not game.ball_spin or sign(game.dx) == sign(game.ball_spin)
          game.dx = inc_w_limit(game.dx, -game.ball_spin * 2, game.max_dx, -game.max_dx)
          game.ball_spin = inc_w_limit(game.ball_spin, -game.dx, game.ball_max_spin, -game.ball_max_spin)
        game.dy = -game.dy
      else if (game.y + game.ball.h > (game.height - game.paddle.h))
        # ball is at the bottom of the board
        if (game.x + game.ball.w > game.paddle_x and game.x < (game.paddle_x + game.paddle.w))
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
          if (game.x + game.ball.w < game.paddle_x + game.char_width)
            game.dx = -game.max_dx
            game.ball_spin = -game.ball_max_spin
          if (game.x > game.paddle_x + game.paddle.w - game.char_width)
            game.dx =  game.max_dx
            game.ball_spin = game.ball_max_spin

          game.dy = -game.dy
          # if the ball has a slow verit speed, reset it to the default
          game.dy = sign(game.dy) * Math.max(Math.abs(game.dy), Math.abs(game_defaults.dy))
        else
          if game.state == "running"
            showOver()
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
    font_name: "'Courier New', Monospace"
    default_str: "ascii breakout!!!"
    default_font: "standard"
    acc_rate: .5

  }

  game_defaults = {
    # initial speed
    dx: 4
    dy: -8
    # Max dx for when the ball
    # hits a moving paddle
    max_dx: 10
    max_dy: 12
    # initial position
    x: -1000
    y: -1000
    # last position
    l_x: -1
    l_x: -1
    right_down: false
    left_down: false
    right_acc: 0
    left_acc: 0

    state: "splash"
    paddle_color: "#c84848"

    # how the characters are displayed
    # on canvas (after wrapping)
    board_disp: []

    # with of a space character, also
    # needed for word wrapping
    space_width: 0

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

    ball: {'cols': 16, 'rows': 8, 'w': 0, 'h': 0}
    # paddle
    # [OOOOOOO]
    paddle: {'cols': 9, 'rows': 1, 'w': 0, 'h': 10}
    # overridden by width of fullscreen
    width: 0
    height: 0
    mouse_min_x: 0
    mouse_max_x: 0


    ascii_colors: ['#c84848', '#c66c3a', '#b47a30', '#a2a22a', '#48a048', '#4248c8']
    figlet_font: "standard"

    font_size: 14
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

    # periodic rotations
    loop_cnt: 0
    block_rotations: []
    fall_interval: 400
    fall_speed: () -> Math.floor(Math.random() * 10 + 3)

    # bonus items
    bonuses: []

    # horizontal paddle location and
    # the paddle direction
    paddle_x: undefined
    paddle_dir: 0

    # for detecting an idle mouse
    m_timeout: null
  }

  updateBoardCfg  = () ->
    #$("#game-canvas")[0].width = Math.floor($(window).width())
    #$("#game-canvas")[0].height = Math.floor($(window).height())
    $("#game-canvas")[0].width = 800
    $("#game-canvas")[0].height = 600
    game.width =  $("#game-canvas").width()
    game.width_h = Math.ceil(game.width / 2)
    game.height = $("#game-canvas").height()
    game.height_h = Math.ceil(game.height / 2)
    # the canvas for the bricks sits under the canvas
    # for the game, it has the same dimensions
    $("#brick-canvas")[0].width = game.width
    $("#brick-canvas")[0].height = game.height
    game.mouse_min_x = $("#game-canvas").offset().left
    game.mouse_max_x = game.mouse_min_x + game.width - game.paddle.w
    # move the paddle to the middle of the screen
    # after resize
    ctx.textBaseline = "top"
    ctx_g.textBaseline = "top"
    ctx.font = "#{game.font_size}px #{cfg.font_name}"
    ctx_g.font = "#{game.font_size}px #{cfg.font_name}"
    game.char_width = Math.round(ctx.measureText(".").width)
    game.char_width_h = Math.round(game.char_width / 2)
    game.font_size_h = Math.round(game.font_size / 2)
    game.ball.w = game.ball.cols * game.char_width
    game.ball.w_h = Math.round(game.ball.w / 2)
    game.ball.h = game.ball.rows * game.font_size
    game.ball.h_h = Math.round(game.ball.h / 2)
    game.paddle.w = game.paddle.cols * game.char_width
    game.paddle.w_h = Math.round(game.paddle.w / 2)
    game.paddle.h = game.paddle.rows * game.font_size
    game.paddle.h_h = Math.round(game.paddle.h / 2)
    if not game.paddle_x
      game.l_paddle_x = game.paddle_x
      game.paddle_x = game.width_h - game.paddle.w_h


  $(window).resize(() ->
    updateBoardCfg()
  )

  ctx_g = $("#game-canvas")[0].getContext("2d")
  ctx = $("#brick-canvas")[0].getContext("2d")

  # update game state vars with defaults
  game = $.extend(true, {}, game_defaults)
  # update config with defaults
  cfg = $.extend(true, {}, cfg_defaults)
  updateBoardCfg()

  routie(':str?/:font?/:size?', (str, font, font_size) ->
    if str
      decoded = decodeURI(str)
      $('input[name=str]').val(decoded)
      if font
        game.figlet_font = decodeURI(font)
        if font_size
          game.font_size = +decodeURI(font_size)

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
