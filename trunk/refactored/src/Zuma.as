package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.*;
	import flash.utils.Timer;
	import gs.easing.Linear;
	import gs.TweenLite;
	
	public class Zuma extends Sprite
	{
		private const BALLS_ON_START:int = 35;
		public var maxCombo:uint = 1;
		public var combo:uint = 0;
		private var _delay:uint;
		private var _totalNum:uint;
		private var _stepLength:uint = 2;
		private var shooterPos:Point;
		private var shooter:Frog;
		private var ballArray:Array;
		private var _timer:Timer;
		private var ballShooted:Array;
		private var ballCrushed:Array;
		private var ballAttracted:Array;
		private var canShoot:Boolean = true;
		private var lastId:uint;
		
		public function Zuma(LEVEL:Class)
		{
			_delay = LEVEL.SPEED;
			_totalNum = LEVEL.NUM;
			shooterPos = LEVEL.FrogPosition;
			initMap(LEVEL.MapArray);
			initBall();
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		private function initMap(arr:Array):void
		{
			graphics.lineStyle(2, 0xFFFFFF);
			graphics.moveTo(arr[0][0], arr[0][1]);
			for (var i:uint = 1; i < arr.length - 2; i++)
			{
				var xc:Number = (arr[i][0] + arr[i + 1][0]) / 2;
				var yc:Number = (arr[i][1] + arr[i + 1][1]) / 2;
				graphics.curveTo(arr[i][0], arr[i][1], xc, yc);
			}
			graphics.curveTo(arr[i][0], arr[i][1], arr[i + 1][0], arr[i + 1][1]);
			for (var j:uint = 0; j < arr.length - 2; j++)
			{
				var p0:Point = (j == 0)? new Point(arr[0][0], arr[0][1])
									   : new Point((arr[j][0] + arr[j + 1][0]) / 2, (arr[j][1] + arr[j + 1][1]) / 2);
				var p1:Point = new Point(arr[j + 1][0], arr[j + 1][1]);
				var p2:Point = (j <= arr.length - 4) ? new Point((arr[j + 1][0] + arr[j + 2][0]) / 2, (arr[j + 1][1] + arr[j + 2][1]) / 2)
													 : new Point(arr[j + 2][0], arr[j + 2][1]);
				var steps:uint = Bezier.init(p0, p1, p2, _stepLength);
				for (var m:uint = 1; m <= steps; m++)
				{
					var data:Array = Bezier.getAnchorPoint(m);
					StaticVars.MapData.push(data);
				}
			}
			var l:uint = StaticVars.MapData.length;
			graphics.beginFill(0xFF3300);
			graphics.drawCircle(StaticVars.MapData[l - 9][0], StaticVars.MapData[l - 9][1], 18);
			graphics.endFill();
		}
		
		private function initBall():void
		{
			ballArray = new Array();
			var _ball:Ball = getBall();
			ballArray.unshift(_ball);
			addChild(_ball);
			_ball.POS = Ball.RADIUS;
			addEventListener(Event.ENTER_FRAME, ballRollIn);
			SoundMgr.playRollingSound();
		}
		
		/// Вкатить шарики
		private function ballRollIn(e:Event):void
		{
			if(ballArray.length < BALLS_ON_START)
			{
				for (var i:uint = 0; i < ballArray.length; i++)
					ballArray[i].POS += 4;
					
				if(FirstBall.POS == Ball.DIAMETR)
				{
					var _ball:Ball = getBall();
					ballArray.unshift(_ball);
					addChild(_ball);
					_ball.POS = Ball.RADIUS;
				}
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, ballRollIn);
				ballShooted = new Array();
				ballCrushed = new Array();
				_timer = new Timer(_delay);
				_timer.addEventListener(TimerEvent.TIMER, onTimer)
				_timer.start();
				shooter.init();
				SoundMgr.stopRollingSound();
			}
		}
		
		/// Укатить шарики в последний тоннель
		private function ballRollOut(e:Event):void
		{
			for (var i:int = ballArray.length - 1; i >= 0; i--)
			{
				if(ballArray[i].POS > StaticVars.MapData.length - Ball.RADIUS + 1)
				{
					removeChild(ballArray.splice(i, 1)[0]);
					if(!ballArray.length)
					{
						removeEventListener(Event.ENTER_FRAME, ballRollOut);
						SoundMgr.stopGameOverSound();
					}
				}
				else
				{
					ballArray[i].POS += 8;
				}
			}
		}
		
		private function onTimer(e:TimerEvent):void
		{
			if(ballArray.length != 0)
			{
				//толкаем змейку
				pushBallFrom(0, 1);
				
				//добавляем шары
				if(FirstBall.POS == Ball.DIAMETR && _totalNum != 0)
				{
					var _ball:Ball = getBall();
					ballArray.unshift(_ball);
					addChild(_ball);
					_ball.POS = Ball.RADIUS;
				}
			}
		}
		
		private function onAddToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			shooter = new Frog();
			addChild(shooter);
			TweenLite.to(shooter, 1, 
			{ 
				x: shooterPos.x, 
				y: shooterPos.y, 
				ease: Linear.easeNone, 
				onComplete: moveFinished 
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
		}

		private function onMouseClicked(e:MouseEvent):void
		{
			if (canShoot && shooter.canShoot)
			{
				shoot();
				SoundMgr.ShootSound.play();
			}
		}
		
		private function onMouseMoveHandler(e:MouseEvent):void
		{
			var dx:Number = mouseX - shooter.x;
			var dy:Number = mouseY - shooter.y;
			var radians:Number = Math.atan2(dy,dx);
			shooter.rotation = radians * 180 / Math.PI - 90;
		}
		
		private function moveFinished():void 
		{
			stage.addEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		private function getBall():Ball
		{
			--_totalNum;
			var randomNum:uint = uint(Math.random() * 6);
			switch(randomNum)
			{
				case 0 :
				return new Ball(StaticVars.RedBall);
				case 1 :
				return new Ball(StaticVars.BlueBall);
				case 2 :
				return new Ball(StaticVars.GreenBall);
				case 3 :
				return new Ball(StaticVars.PurpleBall);
				case 4 :
				return new Ball(StaticVars.WhiteBall);
				case 5 :
				return new Ball(StaticVars.YellowBall);
				default : return null;
			}
		}
	
		private function shoot():void
		{
			var radian:Number = (shooter.rotation + 90) * Math.PI / 180;
			var _ball:Ball = shooter.getCurrentBall();
			_ball.x = shooter.x + 60 * Math.cos(radian);
			_ball.y = shooter.y + 60 * Math.sin(radian);
			addChild(_ball);
			ballShooted.push(new Array(_ball, radian));
			addEventListener(Event.ENTER_FRAME, shootBall);
		}
		
		private function shootBall(e:Event):void
		{
			if (!ballShooted.length)
			{
				removeEventListener(Event.ENTER_FRAME, shootBall);
				return;
			}
			
			for (var i:uint = 0; i < ballShooted.length; i++)
			{
				var shootedBall:Ball = ballShooted[i][0];
				var radians:Number = ballShooted[i][1];
				
				if (!isInScopes(shootedBall))
				{
					removeChild(shootedBall);
					ballShooted.splice(i, 1);
					continue;
				}
				
				var collisionIndex:int = cheackCollision(shootedBall);
				//пересечения нету
				if(collisionIndex == -1)
				{
					shootedBall.x += Math.cos(radians) * Ball.RADIUS;
					shootedBall.y += Math.sin(radians) * Ball.RADIUS;
					continue;
				}
				
				//если было пересечение
				SoundMgr.CollisionSound.play(100);
				var dis:Number = getDistance(ballArray[collisionIndex], shootedBall);
				shootedBall.x -= (Ball.DIAMETR - dis) * Math.cos(radians);
				shootedBall.y -= (Ball.DIAMETR - dis) * Math.sin(radians);
	
				var prevDis:Number = getDistance(shootedBall, StaticVars.getPoint(ballArray[collisionIndex].POS - Ball.RADIUS));
				var nextDis:Number =  getDistance(shootedBall, StaticVars.getPoint(ballArray[collisionIndex].POS + Ball.RADIUS));

				insertBall(shootedBall, collisionIndex, prevDis > nextDis ? "next" : "previous");
				ballShooted.splice(i, 1);
			}
		}
		
		///шар в пределах экрана?
		private function isInScopes(shootedBall:Ball):Boolean
		{
			return shootedBall.x > 0 && shootedBall.x < stage.stageWidth && shootedBall.y > 0 && shootedBall.y < stage.stageHeight;
		}
		
		private function getDistance(firstBall:Object, secondBall:Object):Number
		{
			return Math.sqrt((firstBall.x - secondBall.x) * (firstBall.x - secondBall.x) + (firstBall.y - secondBall.y) * (firstBall.y - secondBall.y));
		}
		
		private function cheackCollision(ball:Ball):int
		{
			for (var i:uint = 0; i < ballArray.length; i++)
				if(getDistance(ballArray[i], ball) <= Ball.DIAMETR)
					return i;
			return -1;
		}
		
		private function isIntersection(firstBall:Ball, secondBall:Ball):Boolean
		{
			return firstBall.POS - secondBall.POS < Ball.DIAMETR;
		}
		
		private function insertBall(ball:Ball, index:uint, position:String):void 
		{
			var insertPos:uint;
			if(position == "next")
			{
				insertPos = ballArray[index].POS +  Ball.RADIUS;
				if(ballArray[index + 1] && isIntersection(ballArray[index + 1], ballArray[index]))
				{
					ballCrushed.push([ball, ballArray[index + 1]]);
					addEventListener(Event.ENTER_FRAME, cheackPushCollision);  
				}
			}
			else
			{
				if(ballArray[index - 1] && isIntersection(ballArray[index], ballArray[index - 1]))
				{
					insertPos = ballArray[index - 1].POS + Ball.RADIUS; 
					ballCrushed.push([ball, ballArray[index]]);
					addEventListener(Event.ENTER_FRAME, cheackPushCollision);  
				}
				else
				{
					insertPos = ballArray[index].POS -  Ball.RADIUS;
				}
			}
			
			var targetPoint:Point = StaticVars.getPoint(insertPos);
			TweenLite.to(ball, .2, 
			{ 
				x: targetPoint.x, 
				y: targetPoint.y, 
				ease: Linear.easeNone, 
				onComplete: motionFinished, 
				onCompleteParams: [ball, insertPos] 
			});  
		}
		
	  	private function cheackPushCollision(e:Event):void
		{
			if (!ballCrushed.length)
			{
				removeEventListener(Event.ENTER_FRAME, cheackPushCollision);
				return;
			}
			
			for(var i:uint = 0; i < ballCrushed.length; i++)
			{
				var isCollision:Boolean = getDistance(ballCrushed[i][0], ballCrushed[i][1]) < Ball.DIAMETR;
				var moveStep:uint = 0;
				
				while(isCollision)
				{
					++moveStep;
					var nextPt:Point = StaticVars.getPoint(ballCrushed[i][1].POS + moveStep);
					isCollision = getDistance(ballCrushed[i][0], nextPt) <  Ball.DIAMETR;
				}
				
				var index:int = ballArray.indexOf(ballCrushed[i][1]);
				if(index != -1)
					pushBallFrom(index, moveStep);
			}
			
		}
		
		private function motionFinished(obj:Ball, insertPos:uint):void
		{
			var index:uint;
			for (var i:uint = 0; i < ballArray.length; i++)
			{
				if(ballArray[i].POS > insertPos)
				{
					index = i;
					break;
				}
				if(i == ballArray.length - 1)
				{
					index = i + 1;
				}
			}

			ballCrushed.splice(ballCrushed.indexOf(obj),1);

			obj.POS = insertPos
			ballArray.splice(index, 0, obj);
			
			if (ballArray[index - 1] 
				&& ballArray[index - 1].COLOR == ballArray[index].COLOR 
				&& ballArray[index].POS - ballArray[index - 1].POS > Ball.RADIUS + 1)
				addToBallAttracted(ballArray[index]);
				
			if (ballArray[index + 1] 
				&& ballArray[index + 1].COLOR == ballArray[index].COLOR 
				&& ballArray[index + 1].POS - ballArray[index].POS > Ball.RADIUS + 1)
				addToBallAttracted(ballArray[index + 1]);
			clearCheack(index, true);
		}

		private function pushBallFrom(index:uint, step:int):void
		{
			var temp:Array = new Array();
			temp.push(ballArray[index]);
			for (var i:uint = index; i < ballArray.length - 1; i++)
			{
				if (ballArray[i + 1].POS - ballArray[i].POS <= Ball.RADIUS)
				{
					if (ballArray[i + 1].POS - ballArray[i].POS < Ball.RADIUS)
						ballArray[i + 1].POS = ballArray[i].POS + Ball.RADIUS;
					temp.push(ballArray[i + 1]);
				}
				else break;
			}

			for (var j:uint = 0; j < temp.length; j++)
				temp[j].POS += step;
			//если шарик докатился до конца - геймовер, убираем шарики, проигрываем звук и тп.
			if(LastBall.POS >= StaticVars.MapData.length - Ball.RADIUS + 1 )
			{
				canShoot = false;
				SoundMgr.playGameOverSound();
				_timer.stop();
				//удаляем eventListeners
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				removeEventListener(Event.ENTER_FRAME, cheackPushCollision);
				removeEventListener(Event.ENTER_FRAME, attract);
				
				removeChild(LastBall);
				ballArray.splice(ballArray.length - 1, 1);
				addEventListener(Event.ENTER_FRAME, ballRollOut);
			}
		}
		
		private function get FirstBall():Ball
		{
			return ballArray[0];
		}
		
		private function get LastBall():Ball
		{
			return ballArray[ballArray.length - 1];
		}
		
		private function clearCheack(index:uint, clear:Boolean):uint
		{
			var temp:Array = new Array();
			temp.push(ballArray[index]);
			var color:uint = ballArray[index].COLOR;
			
			var i:uint = index + 1;
			while(ballArray[i])
			{
				if (ballArray[i].COLOR != color) break;
				if(ballArray[i].POS - ballArray[i - 1].POS <= Ball.RADIUS + 1 || !clear)
				{
					temp.push(ballArray[i]);
					++i;
				}
				else break;
			}
			
			var j:int = index - 1;
			while(ballArray[j])
			{
				if (ballArray[j].COLOR != color) break;
				if (ballArray[j + 1].POS - ballArray[j].POS <= Ball.RADIUS + 1 || !clear)
				{
					temp.push(ballArray[j]);
					--j;
				}
				else break;
			}
			++j;
			if(temp.length > 2 && clear)
				clearBall(j, temp);
			return temp.length;
		}
		
		//вот тут надо порыться
		private function clearBall(f:uint, arr:Array):void
		{
			++combo;
			var id:uint = combo > 5 ? 5 : combo;
			
			if (combo > 1)
				SoundMgr.BallExplosionSound.play();

			for (var i:uint = 0; i < arr.length; i++)
			{
				arr[i].explode();
				SoundMgr.playCollisionSound(id);
			}
			
			if(ballArray.length == arr.length)
			{
				canShoot = false;
				lastId = LastBall.POS;
				setTimeout(gamePass, 600);
			}
			ballArray.splice(f,arr.length);
			
			if(_totalNum == 0)
				cheackColor(arr[0].COLOR);
			
			
			if (ballArray[f - 1] && ballArray[f] && ballArray[f - 1].COLOR == ballArray[f].COLOR)
			{
				if (clearCheack(f, false) < 3)
				{
					if(combo > maxCombo)
						maxCombo = combo;
					combo = 0;
				}
				addToBallAttracted(ballArray[f]);
			}
			else
			{
				if(combo > maxCombo)
					maxCombo = combo;
				combo = 0;
			}
		}

		///удаляем из списка цветов пушки цвет, которого нету в ряду
		private function cheackColor(color:uint):void
		{
			for (var i:uint = 0; i < ballArray.length; i++)
				if (ballArray[i].COLOR == color) 
					return;
			for (var j:uint = 0; j < ballShooted.length; j++)
				if (ballShooted[j].COLOR == color) 
					return;
			shooter.colorCleared(color);
		}
	
		///добавляем шар в массив на схлопование (с задержкой)
		private function addToBallAttracted(_ball:Ball):void
		{
			if(!ballAttracted)
				ballAttracted = new Array();
			ballAttracted.push(_ball);
			setTimeout(
			function():void 
			{
				addEventListener(Event.ENTER_FRAME, attract);
			}
			,400);
		}

		///схлопывание шаров
		private function attract(e:Event):void
		{
			if(!ballAttracted.length)
			{
				removeEventListener(Event.ENTER_FRAME, attract);
				return;
			}
			
			for (var i:uint = 0; i < ballAttracted.length; i++)
			{
				var index:int = ballArray.indexOf(ballAttracted[i]);
				if(index != -1 && ballArray[index - 1])
				{
					if(ballAttracted[i].COLOR == ballArray[index - 1].COLOR)
					{
						var steps:uint = ballAttracted[i].POS - ballArray[index - 1].POS > 19 ? 3 
																							  : ballAttracted[i].POS - ballArray[index - 1].POS - Ball.RADIUS;
						pushBallFrom(index, -steps);
						if(ballAttracted[i].POS - ballArray[index - 1].POS <= Ball.RADIUS)
						{
							SoundMgr.CollisionSound.play();
							ballAttracted.splice(i, 1);
							if(!ballAttracted.length)
								removeEventListener(Event.ENTER_FRAME,attract);
							clearCheack(index - 1, true);
						}
					}
					else
					{
						ballAttracted.splice(i, 1);
						if(combo > maxCombo)
							maxCombo = combo;
						combo = 0;
					}
				}
			}
		}
		
		private function gamePass():void
		{
			_timer.delay = 80;
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.addEventListener(TimerEvent.TIMER, extraScore);
		}
		
		private function extraScore(e:TimerEvent):void
		{
			if (lastId + Ball.RADIUS < StaticVars.MapData.length - Ball.RADIUS + 1)
			{
				lastId += Ball.RADIUS;
				SoundMgr.EndExplosionSound.play();
				var mc:endExplosion = new endExplosion();
				mc.x = StaticVars.MapData[lastId][0];
				mc.y = StaticVars.MapData[lastId][1];
				addChild(mc);
			}
			else
			{
				_timer.removeEventListener(TimerEvent.TIMER,extraScore);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveHandler);
				stage.removeEventListener(MouseEvent.CLICK,onMouseClicked);
			}
		}
		
		
	}
}