class TrainTetris

  headerHeight: 41
  controlsHeight: 149
  gridSize: 20
  url: 'http://afternoon-reaches-8379.herokuapp.com/tetris/scores'

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

    @goHome()

  goHome: ->
    @getResults (results) =>
      html = ''
      for result in results
        html += "<li>#{result.name} <span class='highlight'>#{result.points}</span></li>"
      document.querySelector('.scoreboard ol').innerHTML = html
      @changeState('.intro')
      $('.scoreboard').height($(window).height() - 385)

  startGame: ->
    @changeState('.game')
    Tetris.install(document.getElementById('game-canvas'), 1)
    Tetris.onoff()

  confirmQuit: ->
    Tetris.onoff()
    @changeState('.confirmation')

  backToGame: ->
    @changeState('.game')
    Tetris.onoff()

  showScore: ->
    @changeState('.gameover')
    document.getElementById('score').innerText = Tetris.score

  submitResult: ->
    name = $('.username').val()
    unless name is ''
      @saveResult name, Tetris.score, (rating) =>
        @changeState '.thankyou', =>
          @setMessage(rating)

  setMessage: (rating) ->
    $("#rating").text(rating)

  changeState: (to, callback = null) ->
    $(page).removeClass('active') for page in $(@pages)
    $(to).addClass('active')
    callback() if callback
    container = $('.active .by-center')
    if container.length isnt 0
      containerHeight = $(container).height()
      viewportHeight = $('.page.active').height()
      margin = (viewportHeight - containerHeight - @headerHeight)/2
      container.css(position: 'relative', top: "#{margin}px")

  getResults: (callback) ->
    $.ajax
      type: 'GET'
      url: @url
      success: (data) ->
        callback(data)

  saveResult: (name, score, callback) ->
    $.ajax
      type: 'POST'
      url: @url
      data:  score: name: name, points: score
      success: (data) ->
        callback(data.rating)

window.onload = ->
  FastClick.attach(document.body)
  new TrainTetris()
