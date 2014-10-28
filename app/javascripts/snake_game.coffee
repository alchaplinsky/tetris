class window.SnakeGame

  gridSize: 16

  inverseDirection =
    'up':'down'
    'left':'right'
    'right':'left'
    'down':'up'

  constructor: ->
    @canvas = document.getElementById("game-canvas")
    @context = @canvas.getContext("2d")
    @navigation()
    image = new Image()
    image.src = 'images/snake_chunk.png'
    image.onload = => @snakePattern = @context.createPattern(image, "repeat")

  navigation: ->
    document.addEventListener 'click', (e) =>
      if e.target.attributes['class'] && e.target.attributes['class'].value.match(/control/)
        @snake.direction = e.target.attributes['data-direction'].value
    , false

    addEventListener "keydown", (e) =>
      switch e.keyCode
        when 38 then lastKey = 'up'
        when 40 then lastKey = 'down'
        when 37 then lastKey = 'left'
        when 39 then lastKey = 'right'
      @snake.direction = lastKey if lastKey isnt inverseDirection[@snake.direction]
    , false

  start: ->
    @over = false
    @score = 0
    @fps = 5
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

  canvasCenter: ->
    x = Math.floor(@canvas.width / @gridSize / 2) * @gridSize
    y = Math.floor(@canvas.height / @gridSize / 2) * @gridSize
    [x, y]

  randomCell: ->
    max = @canvas.height/@gridSize - 1
    @randomNumber(0, max) * @gridSize

  randomNumber: (minimum, maximum) ->
    Math.round( Math.random() * (maximum - minimum) + minimum)

  drawBox: (options) ->
    if(options.color)
      @context.fillStyle = options.color
    else
      @context.fillStyle = options.image
    @context.beginPath()
    @context.rect options.x, options.y, @gridSize, @gridSize
    @context.fill()

  resetCanvas: ->
    @context.clearRect(0, 0, @canvas.width, @canvas.height)

class Snake

  size: 16

  constructor: (@game) ->
    @sections = []
    @direction = 'left'
    center = @game.canvasCenter()
    @x = center[0]
    @y = center[1]
    i = @x + (0 * @game.gridSize)
    while i >= @x
      @sections.push i + "," + @y
      i -= @game.gridSize

  move: ->
    switch @direction
      when 'up' then @y -= @game.gridSize
      when 'down' then @y+= @game.gridSize
      when 'left' then @x -= @game.gridSize
      when 'right' then @x += @game.gridSize
    @checkCollision()
    @checkGrowth()
    @sections.push(@x + ',' + @y)

  draw: ->
    @drawSection section.split(',') for section in @sections

  drawSection: (section) ->
    @game.drawBox x: parseInt(section[0]), y: parseInt(section[1]), image: @game.snakePattern

  checkCollision: ->
    @game.stop() if @isCollision(@x, @y)

  isCollision: (x, y) ->
    x < 0 || x is @game.canvas.width || y < 0 || y is @game.canvas.height || @sections.indexOf(x+','+y) >= 0

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
    @x = @game.randomCell()
    @y = @game.randomCell()

  draw: ->
    @game.drawBox x: @x, y: @y, color: @color
