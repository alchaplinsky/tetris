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

  startGame: ->
    @changeState('intro, .thankyou', 'game')
    SnakeGame()
    #@game = new Game($('.game-canvas'))

  confirmQuit: ->
    @changeState('game', 'confirmation')

  backToGame: ->
    @changeState('confirmation', 'game')

  showScore: ->
    @changeState('confirmation', 'gameover')

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
