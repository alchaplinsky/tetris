function SnakeGame() {
  var canvas = document.getElementById("game-canvas");
  var context = canvas.getContext("2d");

  game = {

    score: 0,
    fps: 8,
    over: false,
    message: null,

    start: function() {
      game.over = false;
      game.message = null;
      game.score = 0;
      game.fps = 8;
      snake.init();
      food.set();
    },

    stop: function() {
      game.over = true;
    },

    drawBox: function(options) {
      if(options.color) {
        context.fillStyle = options.color;
      }else {
        context.fillStyle = options.image;
      }
      context.beginPath();
      context.moveTo(options.x - (options.size / 2), options.y - (options.size / 2));
      context.lineTo(options.x + (options.size / 2), options.y - (options.size / 2));
      context.lineTo(options.x + (options.size / 2), options.y + (options.size / 2));
      context.lineTo(options.x - (options.size / 2), options.y + (options.size / 2));
      context.closePath();
      context.fill();
    },

    resetCanvas: function() {
      context.clearRect(0, 0, canvas.width, canvas.height);
    }

  };

  snake = {

    size: 16,
    x: null,
    y: null,
    color: '#0F0',
    direction: 'left',
    sections: [],

    init: function() {
      snake.sections = [];
      snake.direction = 'left';
      snake.x = canvas.width / 2 + snake.size / 2;
      snake.y = canvas.height /2 + snake.size / 2;
      for (i = snake.x + (5 * snake.size); i >= snake.x; i-=snake.size) {
        snake.sections.push(i + ',' + snake.y);
      }
    },

    move: function() {
      switch(snake.direction) {
        case 'up':
          snake.y-=snake.size;
          break;
        case 'down':
          snake.y+=snake.size;
          break;
        case 'left':
          snake.x-=snake.size;
          break;
        case 'right':
          snake.x+=snake.size;
          break;
      }
      snake.checkCollision();
      snake.checkGrowth();
      snake.sections.push(snake.x + ',' + snake.y);
    },

    draw: function() {
      for (i = 0; i < snake.sections.length; i++) {
        snake.drawSection(snake.sections[i].split(','));
      }
    },

    drawSection: function(section) {
      image = new Image();
      image.src = '../images/snake_chunk.png';
      image.onload = function() {
        var pattern = context.createPattern(this, "repeat")
        game.drawBox({ x: parseInt(section[0]), y: parseInt(section[1]), size: snake.size, image: pattern });
      }
    },

    checkCollision: function() {
      if (snake.isCollision(snake.x, snake.y) === true) {
        game.stop();
      }
    },

    isCollision: function(x, y) {
      if (x < snake.size/2 ||
          x > canvas.width ||
          y < snake.size/2 ||
          y > canvas.height ||
          snake.sections.indexOf(x+','+y) >= 0) {
        return true;
      }
    },

    checkGrowth: function() {
      if (snake.x == food.x && snake.y == food.y) {
        game.score++;
        if (game.score % 5 == 0 && game.fps < 60) {
          game.fps++;
        }
        food.set();
      } else {
        snake.sections.shift();
      }
    }

  };

  food = {

    size: null,
    x: null,
    y: null,
    color: '#0FF',

    set: function() {
      food.size = snake.size;
      food.x = (Math.ceil(Math.random() * 10) * snake.size * 2) - snake.size / 2;
      food.y = (Math.ceil(Math.random() * 10) * snake.size * 2) - snake.size / 2;
    },

    draw: function() {
      game.drawBox({x: food.x, y: food.y, size: food.size, color: food.color});
    }

  };

  inverseDirection = {
    'up':'down',
    'left':'right',
    'right':'left',
    'down':'up'
  };

  keys = {
    up: [38, 75, 87],
    down: [40, 74, 83],
    left: [37, 65, 72],
    right: [39, 68, 76]
  };

  Object.prototype.getKey = function(value){
    for(var key in this){
      if(this[key] instanceof Array && this[key].indexOf(value) >= 0){
        return key;
      }
    }
    return null;
  };

  addEventListener("keydown", function (e) {
      lastKey = keys.getKey(e.keyCode);
      if (['up', 'down', 'left', 'right'].indexOf(lastKey) >= 0
          && lastKey != inverseDirection[snake.direction]) {
        snake.direction = lastKey;
      }
  }, false);

  var requestAnimationFrame =  requestAnimationFrame ||
        webkitRequestAnimationFrame ||
        mozRequestAnimationFrame ||
        msRequestAnimationFrame ||
        oRequestAnimationFrame;

  function loop() {
    if (game.over == false) {
      game.resetCanvas();
      snake.move();
      food.draw();
      snake.draw();
    }
    setTimeout(function() {
      requestAnimationFrame(loop);
    }, 1000 / game.fps);
  };

  requestAnimationFrame(loop);
  game.start();
}
