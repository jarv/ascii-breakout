$(() ->

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
    gen_disp_data($('input[name=str]').val())
  )

  $("input[type=range]").change(() ->
    game.font_size = +$("input[type=range]").val()
    gen_disp_data($('input[name=str]').val())
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
  get_color = (num) ->
    index = num % game.ascii_colors.length
    return game.ascii_colors[index]

  # Keyboard events
  $(document).keydown((evt) ->
    switch game.state
      when "paused"
        if  (evt.keyCode == 27) #  esc
          showRunning()
      
      when "running"
        if (evt.keyCode == 39) # ->
          game.right_down = true
        else if (evt.keyCode == 37) # <-
          game.left_down = true
        else if (evt.keyCode == 27) # esc
          showPaused()

    return
  )

  $(document).keyup((evt) ->
    switch game.state
      when "running"
        if (evt.keyCode == 39)
          game.right_down = false
        else if (evt.keyCode == 37)
          game.left_down = false
    return
  )

  # Mouse control for the paddles
  $(document).bind('touchmove mousemove', (e) ->
    switch game.state
      when "running"
        if e.originalEvent.touches
          cX = e.originalEvent.touches[0].pageX
        else
          cX = e.pageX
        if (cX > game.mouse_min_x and cX < game.mouse_max_x)
          game.paddle_x = cX - game.mouse_min_x
  )

  # input text 
  $('input[name=str]').on('input', (e) ->
    gen_disp_data($('input[name=str]').val())
    return
  )

  $("#ascii-submit").submit((e) ->
    if $('input[name=str]').val().length > 1
      showRunning()
    e.preventDefault()
    return
  )

  draw_circle = (x, y, r) ->
    ctx.beginPath()
    ctx.arc(x, y, r, 0, Math.PI*2, true)
    ctx.fillStyle = game.paddle_color
    ctx.closePath()
    ctx.fill()
    return

  draw_rect = (x, y, w, h) ->
    ctx.beginPath()
    ctx.rect(x, y, w, h)
    ctx.fillStyle = game.paddle_color
    ctx.closePath()
    ctx.fill()
    return

  clear_board = () ->
    ctx.clearRect(0, 0, game.width, game.height)
    return


  Figlet.loadFont = (name, fn) ->
    url = "fonts/#{name}.flf" # load from github - "https://api.github.com/repos/scottgonzalez/figlet-js/contents/fonts/#{name}.flf"
    $.ajax({
      url: url,
      datatype: "text", # load from github - "jsonp",
      success: fn
    })

  gen_disp_data = (str) ->
    Figlet.parsePhrase(str, game.figlet_font, (disp_data, word_boundaries, space_width) ->
      game.disp_data = disp_data
      game.word_boundaries = word_boundaries
      game.space_width = space_width
      game.line_breaks = create_line_breaks()
      encoded_str = encodeURI(str)
      encoded_font = encodeURI(game.figlet_font)
      encoded_font_size = encodeURI(game.font_size)
      if str.length > 0
        $(".share-link").html("""<a href="##{encoded_str}/#{encoded_font}/#{encoded_font_size}">Use this link to share this game with a friend!</a>""")
      else
        $(".share-link").html("")
      update_board_cfg()
    )
    return

  create_line_breaks = () ->
    line_breaks = []

    if game.disp_data.length == 0
      return line_breaks

    xpos = 0
    last_word_boundary = false

    for col, index in game.disp_data[0]
      xpos += game.char_width
  
      if xpos < game.width
        if index in game.word_boundaries
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

    return line_breaks


  collision = (brick_x, brick_y) ->

    # center brick
    c_brick_x = brick_x + Math.round(game.char_width / 2)
    c_brick_y = brick_y + Math.round(game.font_size / 2)

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
    game.aoa = Math.atan2((game.y - c_brick_y), (game.x - c_brick_x))

    switch
      when  game.aoa <=  Math.PI / 4 and game.aoa > -Math.PI / 4 # (a)
        if (game.dx <= 0)
          game.dx = -game.dx
      when  game.aoa <= -Math.PI / 4 and game.aoa > -3 * Math.PI / 4 # (b)
        if (game.dy >= 0)
          game.dy = -game.dy
      when (game.aoa <= -3 * Math.PI and game.aoa > -Math.PI) or (game.aoa <= Math.PI and game.aoa > 3 * Math.PI / 4) # (c)
        if (game.dx >= 0)
          game.dx = -game.dx
      when  game.aoa <= 3 * Math.PI / 4 and game.aoa > Math.PI / 4 # (d)
        if (game.dy <= 0)
          game.dy = -game.dy

    return

  game_loop = () ->
    switch game.state
      when "over"
        showOver()
      when "paused"
        showPaused()

    clear_board()

    ypos = game.font_size * 1.1
    line_offset = (game.disp_data.length * game.font_size)
    won = true
    for row, row_index in game.disp_data
      text_color = get_color(row_index)
      line_cnt = 0
      printed = 0
      if game.line_breaks.length > 0
        line_width = game.line_breaks[0]
      else
        line_width = row.length
      xpos = Math.round((game.width / 2) - ( line_width * game.char_width / 2))

      for column, column_index in row

        if column_index in game.line_breaks
          line_cnt += 1
          if game.line_breaks.length == line_cnt
            line_width = row.length - game.line_breaks[line_cnt - 1]
          else
            line_width = game.line_breaks[line_cnt] - game.line_breaks[line_cnt - 1]

          xpos = Math.round((game.width / 2) - ( line_width * game.char_width / 2) - (game.space_width * game.char_width))
    
        brick_x = xpos
        brick_y = ypos + (line_cnt * (game.font_size * game.disp_data.length))
        if column != " "
          won = false
          if ! ((game.x - game.ball_radius > brick_x + game.char_width) \
              or (game.x + game.ball_radius < brick_x) \
              or (game.y - game.ball_radius > brick_y + game.font_size) \
              or (game.y + game.ball_radius < brick_y))
            
            collision(brick_x, brick_y)
            game.disp_data[row_index][column_index] = " "

        ctx.fillStyle = text_color
        ctx.fillText(column, brick_x, brick_y)
        xpos += game.char_width
      ypos += game.font_size

    if game.state == "running"

      if won and game.disp_data.length > 0
        showWin()

      if not game.paddle_x
        game.paddle_x = game.width / 2

      if game.ball_locked
        ball_x = Math.floor(game.paddle_x + (cfg.paddle_width / 2))
        ball_y = Math.floor(game.height - cfg.paddle_height - game.ball_radius - 15)
        game.x = ball_x
        game.y = ball_y
      else
        ball_x = game.x
        ball_y = game.y

      draw_circle(ball_x, ball_y, game.ball_radius)

      if game.right_down
        game.paddle_x += 5
      else if game.left_down
        game.paddle_x -= 5
      draw_rect(game.paddle_x, game.height - cfg.paddle_height, cfg.paddle_width, cfg.paddle_height)

      # handle wall collisions
      if (game.x + game.ball_radius > game.width or game.x - game.ball_radius < 0)
        game.dx = -game.dx
      if (game.y - game.ball_radius < 0)
        game.dy = -game.dy
      else if (game.y + game.ball_radius > game.height - cfg.paddle_height)
        # ball is at the bottom of the board
        if (game.x + game.ball_radius > game.paddle_x and game.x - game.ball_radius < (game.paddle_x + cfg.paddle_width))
          # paddle collision
          game.dy = -game.dy
        else
          if game.state == "running"
            showOver()
          game.dy = -game.dy
          
      if not game.ball_locked
        game.x += game.dx
        game.y += game.dy

    return

  cfg_defaults = {
    # cfg have vars that remain the same
    # through a single game
    paddle_height: 10
    paddle_width: 100
    font_name: "'Courier New', Monospace"
  }

  game_defaults = {
    # initial speed
    dx: 4
    dy: -8
    # initial position
    x: 150
    y: 150
    right_down: false
    left_down: false

    state: "splash"
    paddle_color: "#c84848"

    # raw data for words on the canvas
    disp_data: []

    # list of indexes where word
    # boundaries (used for word wrapping)
    word_boundaries: []
    # with of a space character, also
    # needed for word wrappering
    space_width: 0
    # Where lines are broken which varies
    # depending on the window size
    line_breaks: []

    ball_radius: 25

    # overridden by width of fullscreen
    width: 0
    height: 0
    mouse_min_x: 0
    mouse_max_x: 0

    # angle of attack
    aoa: 0

    ascii_colors: ['#c84848', '#c66c3a', '#b47a30', '#a2a22a', '#48a048', '#4248c8']
    figlet_font: "standard"

    font_size: 20
    # ball locked on paddle
    ball_locked: true

  }

  update_board_cfg  = () ->
    $("#canvas")[0].width = Math.floor($(window).width())
    $("#canvas")[0].height = Math.floor($(window).height())
    game.width =  $("#canvas").width()
    game.height = $("#canvas").height()
    game.mouse_min_x = $("#canvas").offset().left
    game.mouse_max_x = game.mouse_min_x + game.width - cfg.paddle_width
    # move the paddle to the middle of the screen
    # after resize
    ctx.font = "#{game.font_size}px #{cfg.font_name}"
    game.char_width = Math.round(ctx.measureText(".").width)
  $(window).resize(() ->
    update_board_cfg()
  )
  ctx = $("#canvas")[0].getContext("2d")
  # update game state vars with defaults
  game = $.extend({}, game_defaults)
  # update config with defaults
  cfg = $.extend({}, cfg_defaults)
  update_board_cfg()

  routie(':str?/:font?/:size?', (str, font, font_size) ->
    if str
      decoded = decodeURI(str)
      $('input[name=str]').val(decoded)
      if font
        game.figlet_font = decodeURI(font)
        if font_size
          game.font_size = +decodeURI(font_size)

      gen_disp_data(decoded)
      showRunning()
    else
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

      canvas = $("#canvas").get(0)
      recursiveAnim = () ->
        game_loop()
        animFrame(recursiveAnim, canvas)
      animFrame(recursiveAnim, canvas)
    else
      setInterval(game_loop, 1000.0/60)
  )
  return
)
