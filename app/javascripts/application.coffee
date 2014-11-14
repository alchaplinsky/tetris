class TrainSnake

  headerHeight: 41
  controlsHeight: 149
  gridSize: 20
  url: 'http://afternoon-reaches-8379.herokuapp.com/snake/scores'

  pages: '.intro, .game, .confirmation, .gameover, .thankyou'

  messages: [
      title: 'Congratulations!!'
      text: 'You\'ve got the longest snake in the North!'
    ,
      title: 'My what a big snake!'
      text: ''
    ,
      title: ''
      text: 'You\'ve got a real long snake but there\'s bigger on this train!'
    ,
      title: 'Pretty good'
      text: 'Keep shaking the snake!'
    ,
      title: 'Sorry Snake,'
      text: 'You\'re at the bottom of the ladder.'
  ]

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
    name = $('.username').val()
    unless name is ''
      @saveResult name, @game.score, (rating) =>
        @changeState '.thankyou', =>
          @setMessage(rating)

  setMessage: (rating) ->
    if rating is 1
      message = @messages[0]
    else if 5 >= rating >= 2
      message = @messages[1]
    else if 10 >= rating >= 6
      message = @messages[2]
    else if 30 >= rating >= 11
      message = @messages[3]
    else if 30 < rating
      message = @messages[4]
    $('#message-title').text message.title
    $('#message-text').text message.text

  calculateGameArea: ->
    gameCanvas = $('#game-canvas')
    gameCanvas.attr('height', @availableHeight())
    gameCanvas.attr('width', @availableWidth())

  availableWidth: ->
    width = Math.floor(screen.width/@gridSize) * @gridSize
    if width > 320 then 320 else width

  availableHeight: ->
    height = document.querySelector('.game').offsetHeight - @headerHeight - @controlsHeight
    height = Math.floor(height/@gridSize) * @gridSize
    if height > 320 then 320 else height

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
  new TrainSnake()
