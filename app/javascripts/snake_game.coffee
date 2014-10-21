class window.SnakeGame

  inverseDirection =
    'up':'down'
    'left':'right'
    'right':'left'
    'down':'up'

  keys =
    up: [38, 75, 87]
    down: [40, 74, 83]
    left: [37, 65, 72]
    right: [39, 68, 76]

  constructor: ->
    @canvas = document.getElementById("game-canvas")
    @context = @canvas.getContext("2d")
    @navigation()

  navigation: ->
    addEventListener "keydown", (e) =>
      switch e.keyCode
        when 38 then lastKey = 'up'
        when 40 then lastKey = 'down'
        when 37 then lastKey = 'left'
        when 39 then lastKey = 'right'
      @snake.direction = lastKey if lastKey != inverseDirection[@snake.direction]
    , false

  start: ->
    @over = false
    @score = 0
    @fps = 8
    @snake = new Snake(@)
    @food = new Food(@)
    @food.set()
    @resume()

  stop: ->
    @over = true
    event = new Event('gameOver')
    document.dispatchEvent(event)

  pause: ->
    clearInterval(@interval)

  resume: ->
    @interval = setInterval =>
      if @over is false
        @resetCanvas()
        @snake.move()
        @food.draw()
        @snake.draw()
    , 1000 / @fps

  drawBox: (options) ->
    if(options.color)
      @context.fillStyle = options.color
    else
      @context.fillStyle = options.image
    @context.beginPath()
    @context.moveTo(options.x - (options.size / 2), options.y - (options.size / 2))
    @context.lineTo(options.x + (options.size / 2), options.y - (options.size / 2))
    @context.lineTo(options.x + (options.size / 2), options.y + (options.size / 2))
    @context.lineTo(options.x - (options.size / 2), options.y + (options.size / 2))
    @context.closePath()
    @context.fill()


  resetCanvas: ->
    @context.clearRect(0, 0, @canvas.width, @canvas.height)

class Snake

  size: 16

  constructor: (@game) ->
    @sections = []
    @direction = 'left'
    @x = @game.canvas.width / 2 + @size / 2
    @y = @game.canvas.height / 2 + @size / 2
    i = @x + (5 * @size)
    while i >= @x
      @sections.push i + "," + @y
      i -= @size

  move: ->
    switch @direction
      when 'up' then @y -= @size
      when 'down' then @y+= @size
      when 'left' then @x -= @size
      when 'right' then @x += @size
    @checkCollision()
    @checkGrowth()
    @sections.push(@x + ',' + @y)

  draw: ->
    @drawSection(section.split(',')) for section in @sections

  drawSection: (section) ->
    image = new Image()
    image.src = '../images/snake_chunk.png'
    self = @
    image.onload = ->
      pattern = self.game.context.createPattern(@, "repeat")
      self.game.drawBox({ x: parseInt(section[0]), y: parseInt(section[1]), size: self.size, image: pattern });

  checkCollision: ->
    @game.stop() if @isCollision(@x, @y)

  isCollision: (x, y) ->
    if (x < @size/2 ||
        x > @game.canvas.width ||
        y < @size/2 ||
        y > @game.canvas.height ||
        @sections.indexOf(x+','+y) >= 0)
      return true

  checkGrowth: ->
    if @x is @game.food.x && @y is @game.food.y
      @game.score = @game.score + 10
      @game.fps++ if @game.score % 50 is 0 && @game.fps < 60
      @game.food.set()
    else
      @sections.shift()


class Food
  color: '#0FF'

  constructor: (@game) ->

  set: ->
    @size = @game.snake.size
    @x = (Math.ceil(Math.random() * 10) * @game.snake.size * 2) - @game.snake.size / 2
    @y = (Math.ceil(Math.random() * 10) * @game.snake.size * 2) - @game.snake.size / 2

  draw: ->
    @game.drawBox( x: @x, y: @y, size: @size, color: @color)
