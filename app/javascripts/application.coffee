# Main CoffeeScript File

class TrainSnake

  constructor: ->
    $('.intro').fadeIn(400)
    $('.start').click =>
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

  confirmQuit: ->
    @changeState('game', 'confirmation')

  backToGame: ->
    @changeState('confirmation', 'game')

  showScore: ->
    @changeState('confirmation', 'gameover')

  submitResult: ->
    @changeState('gameover', 'thankyou')

  changeState: (from, to) ->
    $(".#{from}").fadeOut()
    $(".#{to}").fadeIn(200)


$ ->
  new TrainSnake()
