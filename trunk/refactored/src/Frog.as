package
{
	import flash.display.MovieClip;
	import gs.easing.Linear;
	import gs.TweenLite;
	
	public class Frog extends Frogy
	{
		public var currentBall:Ball;
		public var nextBall:Ball;
		private var current_mask:MovieClip;
		private var next_mask:MovieClip;
		public var canShoot:Boolean = false;
		private var redExist:Boolean = true;
		private var blueExist:Boolean = true;
		private var greenExist:Boolean = true;
		private var purpleExist:Boolean = true;
		private var whiteExist:Boolean = true;
		private var yellowExist:Boolean = true;
		
		public function Frog()
		{
			current_mask = getChildByName("currentmask") as MovieClip;
			next_mask = getChildByName("nextmask") as MovieClip;
			current_mask.alpha = 0;
			next_mask.alpha = 0;
		}

		public function init():void
		{
			currentBall = getBall();
			currentBall.x = 0;
			currentBall.y = 0;
			nextBall = getBall();
			nextBall.x = 0;
			nextBall.y =  -42;
			addChild(currentBall);
			addChild(nextBall);
			currentBall.mask = current_mask;
			nextBall.mask = next_mask;
			TweenLite.to(currentBall, 0.3,
			{
				y: "+25",
				ease: Linear.easeNone,
				onComplete: onMoveFinished
			});
			TweenLite.to(nextBall, 0.3,
			{
				y: "+16",
				ease: Linear.easeNone
			});
		}

		public function getCurrentBall():Ball
		{
			canShoot = false;
			play();
			var _ball:Ball = currentBall;
			nextShoot();
			return _ball;
		}

		private function nextShoot():void
		{
			removeChild(currentBall);
			currentBall = nextBall;
			currentBall.x = 0;
			currentBall.y = 0;
			currentBall.mask = current_mask;
			nextBall = getBall();
			nextBall.x = 0;
			nextBall.y = -42;
			addChild(nextBall);
			nextBall.mask = next_mask;
			TweenLite.to(currentBall, 0.3,
			{
				y:"+25",
				ease: Linear.easeNone,
				onComplete: onMoveFinished
			});
			TweenLite.to(nextBall, 0.3,
			{
				y:"+16",
				ease:Linear.easeNone
			});
		}

		private function getBall():Ball 
		{
			var _ball:Ball;
			end:while(true)
			{
				var randomNum:uint = uint(Math.random() * 6);
				switch(randomNum)
				{
					case 0 :
					if(blueExist) {_ball = new Ball(StaticVars.BlueBall);break end;}
					break;
					case 1 :
					if(redExist) {_ball = new Ball(StaticVars.RedBall);break end;}
					break;
					case 2 :
					if(greenExist){ _ball = new Ball(StaticVars.GreenBall);break end;}
					break;
					case 3 :
					if(purpleExist){ _ball = new Ball(StaticVars.PurpleBall);break end;}
					break;
					case 4 :
					if(whiteExist){ _ball = new Ball(StaticVars.WhiteBall);break end;}
					break;
					case 5 :
					if(yellowExist) {_ball = new Ball(StaticVars.YellowBall);break end;}
					break;
					default :;
				}
			}
			return _ball;
		}

		public function colorCleared(color:uint):void
		{
			switch(color)
			{
				case 0xCC0000 : redExist = false;break;
				case 0x0066FF : blueExist = false;break;
				case 0x9900CC : purpleExist = false;break;
				case 0x00CC00 : greenExist = false;break;
				case 0xCCCCCC : whiteExist = false;break;
				case 0xFFFF00 : yellowExist = false;break;
			}

			if(!(redExist || blueExist || greenExist || purpleExist || whiteExist || yellowExist))
			{
				TweenLite.to(currentBall,0.3,{y:"-25",ease:Linear.easeNone,onComplete:onMoveFinished});
				TweenLite.to(nextBall,0.3,{y:"-26",ease:Linear.easeNone});
			}
			else
			{
				if(currentBall.COLOR == color)
				{
					removeChild(currentBall);
					currentBall = getBall();
					currentBall.x = 0;
					currentBall.y = 25;
					addChild(currentBall);
					currentBall.mask = current_mask;
				}
				if(nextBall.COLOR == color)
				{
					removeChild(nextBall);
					nextBall = getBall();
					nextBall.x = 0;
					nextBall.y = -26;
					addChild(nextBall);
					nextBall.mask = next_mask;
				}
			}
		}
		
		private function onMoveFinished():void
		{
			canShoot = true;
		}
	}
}