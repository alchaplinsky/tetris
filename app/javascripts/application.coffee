class TrainSnake

  headerHeight: 41
  pages: '.intro, .game, .confirmation, .gameover, .thankyou'

  constructor: ->
    document.getElementById('start').addEventListener 'click', => @startGame()
    document.getElementById('restart').addEventListener 'click', => @startGame()
    document.getElementById('quit').addEventListener 'click', => @confirmQuit()
    document.getElementById('back').addEventListener 'click', => @backToGame()
    document.getElementById('confirm').addEventListener 'click', => @goHome()
    document.getElementById('submit').addEventListener 'click', => @submitResult()
    document.addEventListener 'click', (e) =>
      if e.target.attributes['class'] && e.target.attributes['class'].value is 'home'
        @goHome()

    document.addEventListener 'gameOver', => @showScore()
    @changeState('.intro')

  goHome: ->
    @changeState('.intro')

  startGame: ->
    @changeState('.game')
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
    unless $('[name=username]').val() is ''
      @changeState('.thankyou')

  changeState: (to) ->
    for page in document.querySelectorAll(@pages)
      page.classList.remove('active')
    target = document.querySelector(to)
    target.classList.add('active')
    container = document.querySelector('.active .by-center')
    if container isnt null
      containerHeight = container.offsetHeight
      viewportHeight = screen.height
      margin = (viewportHeight - containerHeight - @headerHeight)/2
      container.style.position = 'relative'
      container.style.top = "#{margin}px"

window.onload = ->
  FastClick.attach(document.body)
  new TrainSnake()
