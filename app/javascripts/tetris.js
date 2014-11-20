Tetris = (function(){
	function Maps(){
		this.y = this.Y0 = 0;
		this.x = this.X0 = 4;
		this.queue = function(){
			var f = [];
			for(var i = 0; i ++ < 2;){
				f.push(randomFigure());
			}
			return f;
		}()
		this.map = function(){
			var W = 9, H = 20;
			var m = [];
			for(var y = 0; y < H; y ++){
				m.push([]);
				for(var x = 0; x < W; x ++){
					m[y].push(false);
				}
			}
			return m;
		}()
	}
	Maps.prototype.isFree4 = function(f, y1, x1){
		var newy, newx;
		for(var y = 0; y < f.length; y ++){
			for(var x = 0; x < f[y].length; x ++){
				if(f[y][x]){
					newy = y + y1;
					newx = x + x1;
					if(!this.map.exist(newy, newx) || this.map[newy][newx]){
						return false;
					}
				}
			}
		}
		return true;
	}

	function PlayGround(){
		this.N = this.constructor.prototype.N ++;
		this.maps = new Maps();
		this.timeouts = {};
		this.auto = [];
		this.gameover = false;
		Tetris.score = this.score = 0;
		this.dom = (function(){
			var wrapper, div, table, tr, td, label;

			wrapper = document.createElement("DIV");
			wrapper.className = "pg_keeper";
			wrapper.appendChild(
				(function(){
					div = document.createElement("DIV");
					div.className = "score";
					div.appendChild(
						(function(){
							label = document.createElement("div");
							label.innerHTML = "Your score";
							return label;
						}).call(this)
					)
					div.appendChild(document.createElement("div"));
					return div;
				}).call(this)
			)
			wrapper.appendChild(
				(function(){
					table = document.createElement("TABLE");
					map = this.maps.map;
					for(var y = 0; y < map.length; y ++){
						table.appendChild(
							function(){
								tr = document.createElement("TR");
								for(var x = 0; x < map[y].length; x ++){
									tr.appendChild(document.createElement("TD"))
								}
								return tr;
							}()
						)
					}
					return table;
				}).call(this)
			)
			wrapper.appendChild(
				(function(){
					div = document.createElement("DIV");
					div.className = "next-figure";
					for(var i = 1, to = this.maps.queue.length; i < to ; i ++){
						div.appendChild(
							function(){
								table = document.createElement("TABLE");
								table.style.opacity = (to - i + 1) / to;
								for(var y = 0; y < 4; y ++){
									table.appendChild(
										function(){
											tr = document.createElement("TR");
											for(var x = 0; x < 4; x ++){
												tr.appendChild(document.createElement("TD"));
											}
											return tr;
										}()
									)
								}
								return table;
							}()
						)
					}
					return div;
				}).call(this)
			)
			return wrapper;
		}).call(this)
		this.draw();
		this.refreshScore();
	}

	PlayGround.prototype.translate = function(yo, xo){
		var maps = this.maps;
		if(yo == 0 && xo == 0){
			var test = maps.queue[0].cw();
			for(var i = 0; i < test[0].length; i ++){
				if(maps.isFree4(test, maps.y, maps.x - i)){
					maps.queue[0] = maps.queue[0].cw();
					maps.x -= i;
					break;
				}
			}
		}
		if(maps.isFree4(maps.queue[0], maps.y + yo, maps.x + xo)){
			maps.y += yo;
			maps.x += xo;
		}else if(yo > 0){
			for(var i = yo; i >= 0; i --){
				if(maps.isFree4(maps.queue[0], maps.y + i, maps.x + xo)){
					for(var y = 0; y < maps.queue[0].length; y ++){
						for(var x = 0; x < maps.queue[0][y].length; x ++){
							if(maps.queue[0][y][x]){
								maps.map[maps.y + i + y][x + maps.x] = maps.queue[0][y][x];
							}
						}
					}
					for(var y = 0; y < maps.map.length; y ++){
						var matches = 0;
						for(var x = 0; x < maps.map[y].length; x ++){
							if(maps.map[y][x]){
								matches ++;
							}
						}
						if(matches == maps.map[y].length){
							var l = maps.map.splice(y, 1)[0].length;
							maps.map.unshift(
								function(){
									var newLine = [];
									for(var N = 0; N++ < l;){
										newLine.push(false);
									}
									return newLine;
								}()
							)
							this.score ++;
							Tetris.score = this.score;
							this.refreshScore();
						}
					}
					maps.y = maps.Y0; maps.x = maps.X0;
					if(maps.isFree4(maps.queue[1], maps.y, maps.x)){
						maps.queue.shift();
						maps.queue.push(randomFigure());
						if(this.N == 0){
							this.drawQueue();
						}
					}else{
						window.clearTimeout(timer);
						this.gameover = true;
						this.dom.childNodes[1].style.backgroundColor = "#a9a9a9";
						event = new Event('gameOver')
    				document.dispatchEvent(event)
						/* Game Over */
					}
					break;
				}
			}
		}
		this.draw();
	}

	PlayGround.prototype.ai = function(mode){
		if(!mode){
			for(var i = 0; i < this.auto.length; i ++){
				window.clearTimeout(this.auto[i]);
			}
			return false;
		}
		var pg = this;
		(function(){
			var autoMove = arguments.callee,  contact;
			if(pg.gameover){
				return false;
			}
			for(var y = pg.maps.map.length - 1; y >= 0; y --){
				contact = new Contactor();
				for(var x = 0; x < pg.maps.map[y].length; x ++){
					contact.calc(pg.maps, y, x);
				}
				if(contact.contacts > 0){
					break;
				}
			}
			var rots = 0;
			(function(){
				if(pg.gameover){
					return false;
				}
				if(rots ++ < contact.rots){
					pg.translate(0, 0);
					pg.auto[0] = window.setTimeout(arguments.callee, 150);
				}else{
					var xo;
					(function(){
						if(pg.gameover){
							return false;
						}

						xo = contact.x - pg.maps.x;

						if(Math.abs(xo)){
							pg.translate(0, xo > 0 ? 1 : - 1);
							pg.auto[1] = window.setTimeout(arguments.callee, 100);
						}else{
							var yo = contact.y - pg.maps.y;
							(function(){
								if(pg.gameover){
									return false;
								}
								if(yo --){
									pg.translate(1, 0);
									pg.auto[2] = window.setTimeout(arguments.callee, 45);
								}else{
									pg.auto[3] = window.setTimeout(autoMove, step);
								}
							}())
						}
					}())
				}
			}())
		}())
	}

	PlayGround.prototype.animation = function(options){
		var pg = this;
		(function(){
			if(pg.gameover){
				return false;
			}
			for(prop in options) if(options.hasOwnProperty(prop)){
				if(options[prop] === null){
					window.clearTimeout(pg.timeouts[prop]);
					continue;
				}
				switch(prop){
					case "left":
						pg.translate(0, -1);
					break;

					case "rcw":
						pg.translate(0, 0);
					break;

					case "right":
						pg.translate(0, 1);
					break;

					case "down": case "fall":
						pg.translate(1, 0);
					break;
				}
				pg.timeouts[prop] = window.setTimeout(arguments.callee, prop == "down" ? step : options[prop]);
			}
		})()
	}

	PlayGround.prototype.draw = function(){
		var map, table;

		map = this.maps.map;
		table = this.dom.childNodes[1];

		for(var y = 0; y < map.length; y ++){
			for(var x = 0; x < map[y].length; x ++){
				table.rows[y].cells[x].className = map[y][x] || "";
			}
		}

		if(this.gameover){
			return false;
		}

		map = this.maps.queue[0];
		table = this.dom.childNodes[1];
		for(var y = 0; y < map.length; y ++){
			for(var x = 0; x < map[y].length; x ++){
				if(map[y][x]){
					table.rows[this.maps.y + y].cells[this.maps.x + x].className =  map[y][x];
				}
			}
		}
	}

	PlayGround.prototype.drawQueue = function(){
		var map, table;
		for(var i = 1; i < this.maps.queue.length; i ++){
			map = this.maps.queue[i];
			table = this.dom.childNodes[2].childNodes[i - 1];
			for(var y = 0; y < table.rows.length; y ++){
				for(var x = 0; x < table.rows[y].cells.length; x ++){
					table.rows[y].cells[x].className = "";
					if(map.exist(y, x) && map[y][x]){
						table.rows[y].cells[x].className =  map[y][x];
					}
				}
			}
		}
	}

	PlayGround.prototype.refreshScore = function(){
		this.dom.firstChild.lastChild.innerHTML = this.score;
	}

	function Contactor(){
		this.y = 0;
		this.x = 0;
		this.rots = 0;
		this.contacts = 0;
	}

	Contactor.prototype.calc = function(maps, y, x){
		var f = maps.queue[0].copy(), tc, len;
		for(var i = 0; i < 4; i ++){
			if(i != 0){
				f = f.cw();
			}
			len = f.length - 1;
			if(maps.isFree4(f, y - len, x) &&
				(function(){
					for(var h = 0; h < y - len; h ++){
						if(!maps.isFree4(f, h, x)){
							return false;
						}
					}
					return true;
				}())
			){
				tc = 0;
				for(var r = 0; r < f.length; r ++){
					for(var c = 0; c < f[r].length; c ++){
						if(f[r][c]){
							for(var yo = -1; yo <= 1; yo ++){
								for(var xo = -1; xo <= 1; xo ++){
									if(Math.abs(yo) != Math.abs(xo)){
										var ym = y + r + yo - len;
										var xm = x + c + xo;
										if(!maps.map.exist(ym, xm)){
											if(yo == 1){
												tc ++;
											}
										}else{
											if(maps.map[ym][xm]){
												tc ++;
											}
										}
									}
								}
							}
						}
					}
				}
				if(tc > this.contacts){
					this.y = y - len;
					this.x = x;
					this.rots = i;
					this.contacts = tc;
				}
			}
		}
	}

	function randomFigure(){
		return function(type){
			(function(feature){
				for(var y = 0; y < type.length; y ++){
					for(var x = 0; x < type[y].length; x ++){
						if(type[y][x]) type[y][x] = feature;
					}
				}
			}(["red", "orange", "yellow", "green", "lightblue", "blue", "violet"].rand()))
			for(var i = 0; i ++ < Math.random()*10;){
				if(Math.random() > Math.random()){
					type = type.cw();
				}
			}
			return type;
		}(	[
				[	[0, 1, 1],
					[1, 1, 0]
								],

				[
					[1, 1, 0],
					[0, 1, 1]
								],
				[
					[1, 1],
					[1, 1]
							],
				[
					[1 ,1, 1, 1]
									],
				[
					[1, 0],
					[1, 0],
					[1, 1]
							],
				[
					[0, 1],
					[0, 1],
					[1, 1]
							],
				[
					[1, 1, 1],
					[0, 1, 0]
								]
			].rand()
		)
	}

	function key(e){
		if(!e) e = window.event;
		return e.which || e.keyCode;
	}

	function On(){
		on = true;

		if(!p[0].gameover){
			keh.onkeyup = function(e){
				switch(key(e)){
					case keys[0].val:
						p[0].animation({left: null});
						keys[0].pushed = false;
					break;
					case keys[1].val:
						p[0].animation({rcw: null});
						keys[1].pushed = false;
					break;
					case keys[2].val:
						p[0].animation({right: null});
						keys[2].pushed = false;
					break;
					case keys[3].val:
						p[0].animation({fall: null});
						keys[3].pushed = false;
					break;
				}
			}
			keh.onkeydown = function(e){
				switch(key(e)){
					case keys[0].val:
						if(!keys[0].pushed){
							p[0].animation({left: 100});
							keys[0].pushed = true;
						}
					break;
					case keys[1].val:
						if(!keys[1].pushed){
							p[0].animation({rcw: 250});
							keys[1].pushed = true;
						}
					break;
					case keys[2].val:
						if(!keys[2].pushed){
							p[0].animation({right: 100});
							keys[2].pushed = true;
						}
					break;
					case keys[3].val:
						if(!keys[3].pushed){
							p[0].animation({fall: 45});
							keys[3].pushed = true;
						}
					break;
				}
			}
		}

		(function(){
			sec ++;
			if(sec % 30 == 0){
				step *= 0.9;
			}
			timer = window.setTimeout(arguments.callee, 1000);
		}())
		for(var counter = 0; counter < p.length; counter ++){
			if(p[counter].gameover){
				continue;
			}
			p[counter].animation({down: step});
			if(counter == 0){
				continue;
			}
			p[counter].ai(true);
		}
	}

	function Off(){
		on = false;

		keh.onkeyup = null;
		keh.onkeydown = null;

		window.clearTimeout(timer);
		for(var counter = 0; counter < p.length; counter ++){
			p[counter].animation({left: null, right: null, down: null, rcw: null, fall: null});
			if(counter == 0){
				continue;
			}
			p[counter].ai(false);
		}
	}

	function OnOff(){
		on ? Off() : On();
	}

	var	PLAYERS = 2, STEP0 = 1000, B = 20;
	var ie = false;
	//@cc_on ie = true;
	var	context, p, on, step, timer, sec, keys =	[
														{val: 37, pushed: false},
														{val: 38, pushed: false},
														{val: 39, pushed: false},
														{val: 40, pushed: false}
													], keh = ie ? document : window;

	keh.onkeypress = function(e){
		if(key(e) == 32){
			OnOff();
		}
	}

	return {
		install: function(element, players){
			if(!element){
				return false;
			}

			if(players){
				PLAYERS = players;
			}

			step = STEP0; sec = 0; p = []; on = false;

			PlayGround.prototype.N = 0;

			while(element.childNodes[0]){
				element.removeChild(element.childNodes[0]);
			}


			for(var counter = 0; counter < PLAYERS; counter ++){
				p.push(new PlayGround());

				if(p[counter].N == 0){
					p[counter].drawQueue();
				}

				element.appendChild(p[counter].dom);
			}

			Off();
		},
		onoff: OnOff
	}
}())
