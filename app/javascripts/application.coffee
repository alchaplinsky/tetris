# Main CoffeeScript File

class TrainSnake

  headerHeight: 41

  constructor: ->
    $('.intro').fadeIn(400)
    $('.start, .restart').click =>
      @startGame()

    $('#quit').click =>
      @confirmQuit()

    $('#back').click =>
      @backToGame()

    $('#confirm').click =>
      @showScore()

    $('#submit').click =>
      @submitResult()

    document.addEventListener 'gameOver', =>
      @showScore()

  startGame: ->
    @changeState('intro, .thankyou', 'game')
    @game = new SnakeGame()
    @game.start()

  confirmQuit: ->
    @game.pause()
    @changeState('game', 'confirmation')

  backToGame: ->
    @changeState('confirmation', 'game')
    @game.resume()

  showScore: ->
    @changeState('confirmation, .game', 'gameover')
    $('#score').text(@game.score)

  submitResult: ->
    unless $('[name=username]').val() is ''
      @changeState('gameover', 'thankyou')

  changeState: (from, to) ->
    page = $(".#{to}")
    $(".#{from}").fadeOut()
    $(page).fadeIn(200)
    container = $('.by-center', page)
    if $(container).length isnt 0
      containerHeight = $(container).innerHeight()
      viewportHeight = $(window).height()
      margin = (viewportHeight - containerHeight - @headerHeight)/2
      $(container).css('position': 'relative', 'top': "#{margin}px")


$ ->
  new TrainSnake()
