package
{
	import flash.display.MovieClip;
	import fl.transitions.easing.None;
	import gs.TweenLite;
	public class frog extends MovieClip
	{
		//当前的球
		public var currentBall:ball;
		//下一个球
		public var nextBall:ball;
		//当前球的遮罩
		private var current_mask:MovieClip;
		//下一个球的遮罩
		private var next_mask:MovieClip;
		//是否能发射了
		public var canShoot:Boolean = false;
		//各个颜色的小球是否存在
		private var redExist:Boolean = true;
		private var blueExist:Boolean = true;
		private var greenExist:Boolean = true;
		private var purpleExist:Boolean = true;
		private var whiteExist:Boolean = true;
		private var yellowExist:Boolean = true;
		public function frog()
		{
			current_mask = getChildByName("currentmask") as MovieClip;
			next_mask = getChildByName("nextmask") as MovieClip;
			current_mask.alpha = 0;
			next_mask.alpha = 0;
		}
	//------------------------游戏开始初始化小球-----------------------
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
			TweenLite.to(currentBall,0.3,{y:"+25",ease:None.easeNone,onComplete:onMoveFinished});
			TweenLite.to(nextBall,0.3,{y:"+16",ease:None.easeNone});
		}
	//-----------------------发射的时候，从此发射器中获当前取小球--------
		public function getCurrentBall():ball
		{
			canShoot = false;
			play();
			var _ball = currentBall;
			nextShoot();
			return _ball;
		}
	//-----------------------准备下一发--------------------------------
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
			TweenLite.to(currentBall,0.3,{y:"+25",ease:None.easeNone,onComplete:onMoveFinished});
			TweenLite.to(nextBall,0.3,{y:"+16",ease:None.easeNone});
		}
	//-----------------------随机获取小球------------------------------
		private function getBall():ball 
		{
			var _ball:ball;
			end:while(true)
			{
				var randomNum:uint = uint(Math.random() * 6);
				switch(randomNum)
				{
					case 0 :
					if(blueExist) {_ball = new ball(staticVars.BlueBall);break end;}
					break;
					case 1 :
					if(redExist) {_ball = new ball(staticVars.RedBall);break end;}
					break;
					case 2 :
					if(greenExist){ _ball = new ball(staticVars.GreenBall);break end;}
					break;
					case 3 :
					if(purpleExist){ _ball = new ball(staticVars.PurpleBall);break end;}
					break;
					case 4 :
					if(whiteExist){ _ball = new ball(staticVars.WhiteBall);break end;}
					break;
					case 5 :
					if(yellowExist) {_ball = new ball(staticVars.YellowBall);break end;}
					break;
					default :;
				}
			}
			return _ball;
		}
	//-----------------------检查颜色，防止发射器中出现球链中没有的颜色---------------
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
			//全部颜色的球清除完毕说明游戏已结束，将发射器中的球缩回
			if(!(redExist || blueExist || greenExist || purpleExist || whiteExist || yellowExist))
			{
				TweenLite.to(currentBall,0.3,{y:"-25",ease:None.easeNone,onComplete:onMoveFinished});
				TweenLite.to(nextBall,0.3,{y:"-26",ease:None.easeNone});
			}
			else
			{
				//被清除的颜色与当前球，下一个球相同则更换
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
	//-----------------------移动效果结束------------------------------
		private function onMoveFinished():void
		{
			canShoot = true;
		}
	}
}