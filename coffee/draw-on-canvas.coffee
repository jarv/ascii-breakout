$(() ->

  $("#canvas")[0].width = document.body.clientWidth
  $("#canvas")[0].height = document.body.clientHeight
  console.log(document.body.clientWidth)
  ctx = $("#canvas")[0].getContext("2d")
  width = $("#canvas").width()
  height = $("#canvas").height()
  font_size = 20
  figlet_font = "doh"

  ctx.font = "#{font_size}px 'Courier New',Monospace"
  # single character monospace width
  char_width = Math.round(ctx.measureText(".").width)

  txt = "f"
  ctx.fillText("width:#{char_width}", 10, 50)
  for num in [12..(char_width * 100)] by char_width
    ctx.fillText(txt, num, 100)

  clear_board = () ->
    ctx.clearRect(0, 0, width, height)
    return
 

  $( "#ascii-submit" ).submit((evt)->

    clear_board()
    Figlet.loadFont = (name, fn) ->
      url = "fonts/#{name}.flf" # load from github - "https://api.github.com/repos/scottgonzalez/figlet-js/contents/fonts/#{name}.flf"
      $.ajax({
        url: url,
        datatype: "text", # load from github - "jsonp",
        success: fn
      })

    Figlet.parseFont(figlet_font, () ->
      input_string = $('input[name=gentext]').val()
      x_start_pos = 0
      for char in input_string.split("")
        char_data = Figlet.parseChar(char.charCodeAt(), figlet_font)
        ypos = 0
        for row, row_index in char_data
          xpos = x_start_pos
          for column, column_index in row
            ctx.fillText(column, xpos, ypos)
            xpos += char_width
          ypos += font_size
        x_start_pos += char_width * (char_data[0].length)
    )

    evt.preventDefault()
  )
)
