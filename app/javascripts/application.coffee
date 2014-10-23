class TrainSnake

  headerHeight: 41
  controlsHeight: 149
  gridSize: 16

  pages: '.intro, .game, .confirmation, .gameover, .thankyou'

  constructor: ->
    document.getElementById('start').addEventListener 'click', => @startGame()
    document.getElementById('restart').addEventListener 'click', => @startGame()
    document.getElementById('quit').addEventListener 'click', => @confirmQuit()
    document.getElementById('back').addEventListener 'click', => @backToGame()
    document.getElementById('confirm').addEventListener 'click', => @goHome()
    document.getElementById('submit').addEventListener 'click', => @submitResult()
    document.addEventListener 'click', (e) =>
      if e.target.attributes['class'] && e.target.attributes['class'].value.match /home/
        @goHome()

    document.addEventListener 'gameOver', =>
      setTimeout =>
        @showScore()
      , 500
    @changeState('.intro')

  goHome: ->
    @changeState('.intro')

  startGame: ->
    @changeState('.game')
    @calculateGameArea()
    @game = new SnakeGame()
    @game.start()

  confirmQuit: ->
    @game.pause()
    @changeState('.confirmation')

  backToGame: ->
    @changeState('.game')
    @game.resume()

  showScore: ->
    @changeState('.gameover')
    document.getElementById('score').innerText = @game.score

  submitResult: ->
    unless document.querySelector('.username').value is ''
      @changeState('.thankyou')

  calculateGameArea: ->
    gameCanvas = document.getElementById('game-canvas')
    gameCanvas.attributes.height.value = @availableHeight()
    gameCanvas.attributes.width.value = @availableWidth()

  availableWidth: ->
    Math.floor(screen.width/@gridSize) * @gridSize

  availableHeight: ->
    height = document.querySelector('.game').offsetHeight - @headerHeight - @controlsHeight
    Math.floor(height/@gridSize) * @gridSize

  changeState: (to) ->
    for page in document.querySelectorAll(@pages)
      page.classList.remove('active')
    target = document.querySelector(to)
    target.classList.add('active')
    container = document.querySelector('.active .by-center')
    if container isnt null
      containerHeight = container.offsetHeight
      viewportHeight = document.querySelector('.game').offsetHeight
      margin = (viewportHeight - containerHeight - @headerHeight - 60)/2
      container.style.position = 'relative'
      container.style.top = "#{margin}px"

window.onload = ->
  FastClick.attach(document.body)
  new TrainSnake()
