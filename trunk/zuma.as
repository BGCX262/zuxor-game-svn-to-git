package
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import fl.transitions.easing.None;
	import flash.utils.*;
	import gs.TweenLite;
	public class zuma extends Sprite
	{
		//timer的延迟
		private var _delay:uint;
		//游戏中球的总数
		private var _totalNum:uint;
		//每一步的长度
		private var _stepLength:uint = 2;
		//发射器的位置
		private var shooterPos:Point;
		//发射器
		private var shooter:frog;
		//开始滚入的小球的个数
		private const rollInNum:int = 35;
		//存储球链中所有的小球
		private var ballArray:Array;
		//驱动小球向前滚动的timer
		private var _timer:Timer;
		//发射出来的小球
		private var ballShooted:Array;
		//做小球的挤入效果时存储需要被检测碰撞的小球
		private var ballCrushed:Array;
		//被吸引回退的第一个球的数组
		private var ballAttracted:Array;
		//最大连击数
		public var maxCobom:uint = 1;
		//当前连击数
		public var cobom:uint = 0;
		//游戏是否结束
		private var canShoot:Boolean = true;
		//计算额外加分的时候要用到
		private var lastId:uint;
		
		public function zuma(LEVEL:Class)
		{
			_delay = LEVEL.SPEED;
			_totalNum = LEVEL.NUM;
			shooterPos = LEVEL.FrogPosition;
			initMap(LEVEL.MapArray);
			initBall();
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
	//----------------------------初始化地图信息---------------------------
		private function initMap(arr:Array)
		{
			graphics.lineStyle(2,0xFFFFFF);
			graphics.moveTo(arr[0][0],arr[0][1]);
			for(var i:uint = 1;i<arr.length - 2;++i)
			{
				var xc:Number = (arr[i][0] + arr[i+1][0])/2;
				var yc:Number = (arr[i][1] + arr[i+1][1])/2;
				graphics.curveTo(arr[i][0],arr[i][1],xc,yc);
			}
			graphics.curveTo(arr[i][0],arr[i][1],arr[i+1][0],arr[i+1][1]);
			for(var j:uint = 0;j<arr.length - 2;++j)
			{
				var p0:Point = (j == 0)?new Point(arr[0][0],arr[0][1]):new Point((arr[j][0]+arr[j+1][0])/2,(arr[j][1]+arr[j+1][1])/2);
				var p1:Point = new Point(arr[j+1][0],arr[j+1][1]);
				var p2:Point = (j <= arr.length - 4)?new Point((arr[j+1][0] + arr[j+2][0])/2,(arr[j+1][1] + arr[j+2][1])/2):new Point(arr[j+2][0],arr[j+2][1]);
				var steps:uint = Bezier.init(p0, p1, p2, _stepLength);
				for(var m:uint = 1;m<=steps;++m)
				{
					var data:Array = Bezier.getAnchorPoint(m);
					staticVars.MapData.push(data);
				}
			}
			var l:uint = staticVars.MapData.length;
			graphics.beginFill(0xFF3300);
			graphics.drawCircle(staticVars.MapData[l - 9][0],staticVars.MapData[l - 9][1],18);
			graphics.endFill();
		}
	//--------------------------初始化第一个小球，并开始滚入小球-------------------------
		private function initBall()
		{
			ballArray = new Array( );
			var _ball:ball = getBall();
			ballArray.unshift(_ball);
			addChild(_ball);
			//将数组的第16个位置设为起点
			_ball.POS = 16;
			addEventListener(Event.ENTER_FRAME,ballRollIn);
			soundMgr.playRollingSound();
		}
	//--------------------------开始滚入小球--------------------------------------------
		private function ballRollIn(e:Event)
		{
			if(ballArray.length < rollInNum)
			{
				for(var i:uint = 0;i < ballArray.length;++i)
					{
						//所有小球移动4个位置
						ballArray[i].POS += 4;
					}
				//第一个球距起点16个位置则补充小球进去
				if(ballArray[0].POS == 32)
				{
					var _ball:ball = getBall();
					ballArray.unshift(_ball);
					addChild(_ball);
					_ball.POS = 16;
				}
			}
			else
			//滚入小球完毕
			{
				//停止滚入小球
				removeEventListener(Event.ENTER_FRAME,ballRollIn);
				//初始化ballShooted数组，用来存储发射出来的小球
				ballShooted = new Array();
				ballCrushed = new Array();
				//初始化Timer，开始驱动小球向前滚动
				_timer = new Timer(_delay);
				_timer.addEventListener(TimerEvent.TIMER,onTimer)
				_timer.start();
				//发射器初始化
				shooter.init();
				//停止滚动声音
				soundMgr.stopRollingSound();
			}
		}
	//--------------------------滚入小球结束后，由该函数驱动小球向前滚动------------------
		private function onTimer(e:TimerEvent)
		{
			//与第一个小球相连的小球都向前滚动一步
			if(ballArray.length != 0)
			{
				pushBallFrom(0,1);
				//如果总球数不为0并且第一个球距第一个点位置相差16则补充小球
				if(ballArray[0].POS == 32 && _totalNum != 0)
				{
					var _ball:ball = getBall();
					ballArray.unshift(_ball);
					addChild(_ball);
					_ball.POS = 16;
				}
			}
		}
	//--------------------------onAddToStage,初始化发射器并为之添加侦听器----------------
		private function onAddToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			shooter = new frog();
			addChild(shooter);
			TweenLite.to(shooter,1,{x:shooterPos.x,y:shooterPos.y,ease:None.easeNone,onComplete:moveFinished});
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveHandler);
		}
	//--------------------------单击鼠标------------------------------------------------
		private function onMouseClicked(e:MouseEvent):void
		{
			if(canShoot&&shooter.canShoot)
			{
				shoot();
				soundMgr.ShootSound.play();
			}
		}
	//--------------------------鼠标移动，旋转发射器-----------------------------------
		private function onMouseMoveHandler(e:MouseEvent):void
		{
			var dx:Number = mouseX - shooter.x;
			var dy:Number = mouseY - shooter.y;
			var radians:Number = Math.atan2(dy,dx);
			shooter.rotation = radians * 180 / Math.PI - 90;
		}
	//--------------------------发射器的移动效果完成------------------------------------
		private function moveFinished():void 
		{
			this.stage.addEventListener(MouseEvent.CLICK,onMouseClicked);
		}
	//--------------------------获取一个小球--------------------------------------------
		private function getBall():ball
		{
			--_totalNum;
			var randomNum:uint = uint(Math.random() * 6);
			switch(randomNum)
			{
				case 0 :
				return new ball(staticVars.RedBall);
				case 1 :
				return new ball(staticVars.BlueBall);
				case 2 :
				return new ball(staticVars.GreenBall);
				case 3 :
				return new ball(staticVars.PurpleBall);
				case 4 :
				return new ball(staticVars.WhiteBall);
				case 5 :
				return new ball(staticVars.YellowBall);
				default : return null;
			}
		}
	//----------------------发射小球--------------------------------------------------
		private function shoot()
		{
			//发射球时的弧度
			var radian:Number = (shooter.rotation + 90) * Math.PI/180;
			var _ball:ball = shooter.getCurrentBall();
			_ball.x = shooter.x + 60 * Math.cos(radian);
			_ball.y = shooter.y + 60 * Math.sin(radian);
			addChild(_ball);
			/*因发射出来的小球可能不只一个球同时存在，所以建立数组来保存
			小球以及相应发射该小球时的角度(经测试最多同时存在3个)*/
			ballShooted.push(new Array(_ball,radian));
			//侦听ENTER_FRAME事件，控制小球的运动
			addEventListener(Event.ENTER_FRAME,shootBall);
		}
	//----------------------控制小球的运动，并做是否碰撞是否越界的检测,确定小球插入的位置-------------------
		private function shootBall(e:Event)
		{
			if(ballShooted.length != 0)
			{
				//这个循环对发射出来的每个球都进行检测
				for(var i:uint = 0;i<ballShooted.length;++i)
				{
					//这里检测是否越界
					if(ballShooted[i][0].x > 0 && ballShooted[i][0].x < stage.stageWidth && ballShooted[i][0].y > 0 && ballShooted[i][0].y < stage.stageHeight)
					{
						//检测碰撞
							var flag:int = cheackCollision(ballShooted[i]);
							if(flag == -1)
							{
								ballShooted[i][0].x += Math.cos(ballShooted[i][1]) * 16;
								ballShooted[i][0].y += Math.sin(ballShooted[i][1]) * 16;
							}
							else
							{
								soundMgr.CollisionSound.play(100);
								var _ball:ball = ballShooted[i][0];
								var radians:Number = ballShooted[i][1];
								var dis:Number = Math.sqrt((ballArray[flag].x - _ball.x)*(ballArray[flag].x - _ball.x) + (ballArray[flag].y - _ball.y)*(ballArray[flag].y - _ball.y));
								//调整下小球的位置使之与碰撞的小球刚好接触
								ballShooted[i][0].x -= (32 - dis) * Math.cos(radians);
								ballShooted[i][0].y -= (32 - dis) * Math.sin(radians);
					
								/*碰到了则算出球应该在哪两个小球中挤入进去,采用检测相邻两个放球的位置与要
								插入的球的距离的方法，哪个距离近则向哪边插入小球，这也是为什么要将起点跟终
								点设为与实际路径的起点终点相差16个位置的原因，防止+16或者-16之后造成数组的越界
								*/
								//算出距前一个小球的位置的距离
								var PrevX:Number = staticVars.MapData[ballArray[flag].POS - 16][0];
								var PrevY:Number = staticVars.MapData[ballArray[flag].POS - 16][1];
								var prevDis:Number = Math.sqrt((_ball.x - PrevX)*(_ball.x - PrevX) + (_ball.y - PrevY)*(_ball.y - PrevY));
								//算出距下一个小球的位置的距离
								var NextX:Number = staticVars.MapData[ballArray[flag].POS + 16][0];
								var NextY:Number = staticVars.MapData[ballArray[flag].POS + 16][1];
								var nextDis:Number = Math.sqrt((_ball.x - NextX)*(_ball.x - NextX) + (_ball.y - NextY)*(_ball.y - NextY));
		
								
								//比较距离远近，从而得出应在被碰撞的球的前一个位置插入还是后一个位置插入
								var p:String = prevDis > nextDis ? "next" : "previous";
								insertBall(ballShooted[i][0],flag,p);
								ballShooted.splice(i,1);
							}
					}
					else
					{
						//越界则从显示列表中remove掉,并从ballShooted中移除该小球
						removeChild(ballShooted[i][0]);
						ballShooted.splice(i,1);
					}
				}
			}
			else
			{
				//ballShooted中没有小球的话就移除侦听器
				removeEventListener(Event.ENTER_FRAME,shootBall);
			}
		}
	//-----------检测发射出来的小球与球链中球的碰撞，碰撞了返回被碰撞球的索引，否则返回-1
		private function cheackCollision(arr:Array):int
		{
			var _ball:ball = arr[0];
			//这里检测是否与球链ballArray中的球碰撞,碰撞采用距离计算
			for(var j:uint = 0;j<ballArray.length;++j)
			{
				var dis:Number = Math.sqrt((ballArray[j].x - _ball.x)*(ballArray[j].x - _ball.x) + (ballArray[j].y - _ball.y)*(ballArray[j].y - _ball.y));
				if(dis <= 32)
				{
					return j;
				}
			}
			return -1;
		}
	//--------插入小球，第一个参数是要插入的小球，第二个是被碰撞的小球的索引，第三个是标志向前插入还是向后插入
		private function insertBall(obj:ball,index:uint,p:String):void 
		{
			var posX:Number;
			var posY:Number;
			var insertPos:uint;
			//确定obj要运动到的位置
			if(p == "next")
			{
				insertPos = ballArray[index].POS + 16;
				//插入的位置后面还有小球并且在挤入的时候会发生碰撞就需要检查与这个小球的碰撞情况
				if(ballArray[index + 1] && (ballArray[index + 1].POS - ballArray[index].POS) < 32 )
				{
					ballCrushed.push(new Array(obj,ballArray[index + 1]));
					addEventListener(Event.ENTER_FRAME,cheackPushCollision);  
				}
			}
			else
			{
				//向前插入分两种情况，第一种就是向前插入会挤到前面的球，此时插入的球的位置应是被碰小球的
				//前一个球的POS+16位置，并推动后面的球空出位置出来
				if(ballArray[index - 1] && (ballArray[index].POS - ballArray[index - 1].POS) < 32)
				{
					insertPos = ballArray[index - 1].POS + 16; 
					ballCrushed.push(new Array(obj,ballArray[index]));
					addEventListener(Event.ENTER_FRAME,cheackPushCollision);  
				}
				//第二种情况就是向前插入不会挤到前面的球，此时插入的球的位置应是被碰小球的POS-16个位置
				else
				{
					insertPos = ballArray[index].POS - 16;
				}
			}
			posX = staticVars.MapData[insertPos][0];
			posY = staticVars.MapData[insertPos][1];
			//做一个简单的动画效果
			TweenLite.to(obj,0.2,{x:posX,y:posY,ease:None.easeNone,onComplete:motionFinished,onCompleteParams:[obj,insertPos]});  
		}
	//------逐帧检测挤入的小球与后一个小球的碰撞情况，如果距离小于32即为碰撞，
	//------此时要将球后移，直到没碰撞，形成一个挤入的效果-------------------------
	  	private function cheackPushCollision(e:Event):void
		{
			if(ballCrushed.length != 0)
			{
				for(var i:uint = 0; i < ballCrushed.length; ++i)
				{
					var dis:Number = Math.sqrt((ballCrushed[i][0].x - ballCrushed[i][1].x)*(ballCrushed[i][0].x - ballCrushed[i][1].x) + (ballCrushed[i][0].y - ballCrushed[i][1].y)*(ballCrushed[i][0].y - ballCrushed[i][1].y));
					var isCollision:Boolean = dis < 32?true:false;
					var moveStep:uint = 0;
					while(isCollision)
					{
						//如果是碰撞的则假设小球向前移动一步在检测是否碰撞，如此下去直到不碰撞了
						++moveStep;
						dis = Math.sqrt((ballCrushed[i][0].x - staticVars.MapData[ballCrushed[i][1].POS + moveStep][0])*(ballCrushed[i][0].x - staticVars.MapData[ballCrushed[i][1].POS + moveStep][0])+(ballCrushed[i][0].y - staticVars.MapData[ballCrushed[i][1].POS + moveStep][1])*(ballCrushed[i][0].y - staticVars.MapData[ballCrushed[i][1].POS + moveStep][1]));
						isCollision = dis < 32?true:false;
					}
					//执行推进小球的操作,指定moveStep为应推进的步数,执行前需检查被检测碰撞的球
					//是否由于执行消除操作删除了，没有被删除才能执行推动小球,否则将引起数组操作越界
					var index:int;
					index = ballArray.indexOf(ballCrushed[i][1]);
					if(index != -1)
					{
						pushBallFrom(index,moveStep);
					}
				}
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME,cheackPushCollision);
			}
		}
	//-------动画效果完成后要将小球插入到数组中，并调整好位置,第一个参数是要插入的小球，
	//-------第二个是球插入到地图数组中的位置，第三个是标志向前插入还是向后插入----------------------------
		private function motionFinished(obj:ball,insertPos:uint):void
		{
			var index:uint;
			//算出应插入到ballArray中位置的索引,这里采用传入insertPos参数的方式
			//而不是传入被碰撞小球的引用的原因是为了防止消除操作删除掉了小球而算不出
			//数组的插入位置
			for(var i:uint = 0;i < ballArray.length;++i)
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

			//删除对应ballCrushed中的元素
			ballCrushed.splice(ballCrushed.indexOf(obj),1);

			//根据插入的位置在ballArray中插入该小球
			obj.POS = insertPos
			ballArray.splice(index,0,obj);

			//检查插入后是否有被吸引的小球
			if(ballArray[index - 1] && ballArray[index - 1].COLOR == ballArray[index].COLOR && ballArray[index].POS - ballArray[index - 1].POS > 17)
			{
				addToBallAttracted(ballArray[index]);
				trace(ballArray[index] == obj);
			}
			if(ballArray[index + 1] && ballArray[index + 1].COLOR == ballArray[index].COLOR && ballArray[index + 1].POS - ballArray[index].POS > 17)
			{
				addToBallAttracted(ballArray[index + 1]);
			}
			
			//检查是有要清除的小球
			clearCheack(index,true);
		}
	//-----推进小球的函数，传入参数推进的起始位置，推进的步数(为正即为向前推进，为负即为向后回退)
	//-----在使用回退道具时要传入负参数----------------------------------------------------
		private function pushBallFrom(index:uint,step:int):void
		{
			var temp:Array = new Array();
			temp.push(ballArray[index]);
			//算出所有与ballArray中索引为index的小球"相连"的小球
			for(var i:uint = index;i < ballArray.length - 1;++i)
			{
				if(ballArray[i + 1].POS - ballArray[i].POS <= 16)
				{
					//如小球位置有误差则纠正
					if(ballArray[i + 1].POS - ballArray[i].POS < 16)
					{
						ballArray[i + 1].POS = ballArray[i].POS + 16;
					}
					temp.push(ballArray[i + 1])
				}
				else
				{
					break;
				}
			}
			//然后将其移动指定的步数
			for(var j:uint = 0;j < temp.length;++j)
			{
				temp[j].POS += step;
			}
			//每次推动小球都需要判断是否结束游戏
			if(ballArray[ballArray.length - 1].POS >= staticVars.MapData.length - 17 )
			{
				canShoot = false;
				
				soundMgr.playGameOverSound();
				
				_timer.stop();
				
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveHandler);
				
				removeEventListener(Event.ENTER_FRAME,cheackPushCollision);
				
				removeEventListener(Event.ENTER_FRAME,attract);
				
				removeChild(ballArray[ballArray.length - 1]);
				ballArray.splice(ballArray.length-1,1);
				
				addEventListener(Event.ENTER_FRAME,ballRollOut);
			}
		}
	//-------------传入检查的起点向两端开始搜索，检查是否应消除小球传入一个参数clear
	//-------------表示是否执行消去，若为false则只返回搜索到颜色相同的球有几个
		private function clearCheack(index:uint,clear:Boolean):uint
		{
			var temp:Array = new Array();
			temp.push(ballArray[index]);
			var color:uint = ballArray[index].COLOR;
			//此循环向下搜索
			var i:uint = index + 1;
			while(ballArray[i])
			{
				//有一定的间隙也算作是连接,由于挤入的操作会使球插入后不一定绝对
				//只相差16个位置，所以这里判断是否连接的条件应当放宽一点，17而不是16
				if(ballArray[i].COLOR == color)
				{
					//是否要清除的参数为false则将不相连的也算起(为判断是否应取消连击计数提供依据)，否则不算，下同
					if(ballArray[i].POS - ballArray[i - 1].POS <= 17)
					{
						temp.push(ballArray[i]);
						++i;
					}
					else if(!clear)
					{
						temp.push(ballArray[i]);
						++i;
					}
					else break;
				}
				else
				{
					break;
				}
			}
			//此循环向上搜索
			var j:int = index - 1;
			while(ballArray[j])
			{
				if(ballArray[j].COLOR == color)
				{
					if(ballArray[j + 1].POS - ballArray[j].POS <=17)
					{
						
						temp.push(ballArray[j]);
						--j;
					}
					else if(!clear)
					{
						temp.push(ballArray[j]);
						--j;
					}
					else break;
				}
				else
				{
					break;
				}
			}
			//将j加1后传给清除小球函数，作为删除小球的起点
			++j;
			//temp长度大于三则执行消除小球，传入该消除的小球数组以及起始球索引
			if(temp.length > 2 && clear)
			{
				clearBall(j,temp);
			}
			return temp.length;
		}
	//------------------消除小球，并在消除后检测是否两端小球颜色相同，相同则应该吸引过去-----------
		private function clearBall(f:uint,arr:Array):void
		{
			//当前连击数加1
			++cobom;
			//播放的音调
			var id:uint = cobom>5?5:cobom;
			
			if(cobom>1)
			{
				soundMgr.BallExplosionSound.play();
			}
			for(var i:uint = 0; i < arr.length; ++i)
			{
				//小球爆炸
				arr[i].explode();
				soundMgr.playCollisionSound(id);
			}
			
			//从球链数组中删除这些小球前先判断删除后是否游戏过关，如删除后游戏过关就得先获取ballArray中
			//最后一个球的POS位置传给extraScore()函数，计算出额外的加分
			if(ballArray.length == arr.length)
			{
				canShoot = false;
				lastId = ballArray[ballArray.length - 1].POS;
				setTimeout(gamePass,600);
			}
			ballArray.splice(f,arr.length);
			
			//若全部球滚出来了,就需要检查发射器中球的颜色了
			if(_totalNum == 0)
			{
				cheackColor(arr[0].COLOR);
			}
			
			
			//检测断开的球链两端颜色是否相同应该吸引过去,注意此处删除了小球，应对比颜色的小球索引有变化
			if(ballArray[f-1]&&ballArray[f]&&(ballArray[f - 1].COLOR == ballArray[f].COLOR))
			{
				//利用clearCheack的返回值来确定是否为连击,吸引结束不会引发消除则更新最大连击数
				//并将当前连击数置为0
				
				if(clearCheack(f,false) < 3)
				{
					if(cobom > maxCobom)
					{
						maxCobom = cobom;
					}
					cobom = 0;
				}
				
				//因在吸引过程中球链可能会有变动，比如爆炸、插入后，导致不能吸引，所以逐帧执行检测是否要吸引,延迟400毫秒执行
				//将被吸引的小球加入检测数组
				addToBallAttracted(ballArray[f]);
			}
			else
			//这里需要更新连击数
			{
				if(cobom > maxCobom)
				{
					maxCobom = cobom;
				}
				cobom = 0;
			}
		}
	//------------------------------检查发射器的颜色，使发射器中球不会出现球链中没有的颜色---------
		private function cheackColor(color:uint):void
		{
			//检查球链中的球
			for(var i:uint = 0;i<ballArray.length;++i)
			{
				if(ballArray[i].COLOR == color) return;
			}
			//检查发射出来的球但还未插入的
			for(var j:uint = 0;j < ballShooted.length;++j)
			{
				if(ballShooted[j].COLOR == color) return;
			}
			shooter.colorCleared(color);
		}
	//----------------将需要被检测吸引的小球加入ballAttracted数组----------------------
		private function addToBallAttracted(_ball:ball):void
		{
			if(ballAttracted == null)
				{
					ballAttracted = [];
					ballAttracted.push(_ball);
				}
				else
				{
					ballAttracted.push(_ball);
				}
				setTimeout(function(){addEventListener(Event.ENTER_FRAME,attract);},400);
		}
	//----------------传入球断开的球的两端的球的索引点，将球吸引闭合起来-----------------
		private function attract(e:Event):void
		{
			if(ballAttracted.length != 0)
			{
				for(var i:uint = 0;i<ballAttracted.length;++i)
				{
					var index:int = ballArray.indexOf(ballAttracted[i]);
					if(index != -1 && ballArray[index - 1])
					{
						if(ballAttracted[i].COLOR == ballArray[index - 1].COLOR)
						{
							//算出应移动多少步
							var steps:uint = ballAttracted[i].POS - ballArray[index - 1].POS > 19?3:ballAttracted[i].POS - ballArray[index - 1].POS - 16;
							pushBallFrom(index,-steps);
							//判断吸引是否结束了
							if(ballAttracted[i].POS - ballArray[index - 1].POS <= 16)
							{
								soundMgr.CollisionSound.play();
								//吸引结束从数组中删除
								ballAttracted.splice(i,1);
								
								if(ballAttracted.length == 0)
								{
									removeEventListener(Event.ENTER_FRAME,attract);
									//trace("移除了侦听器");
								}
								clearCheack(index-1,true);
							}
						}
						else
						{
							//此种情况针对由于消除、插入操作造成的不能继续吸引，并且连击条件被破坏
							ballAttracted.splice(i,1);
							if(cobom > maxCobom)
							{
								maxCobom = cobom;
							}
							cobom = 0;
						}
					}
				}
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME,attract);
				//trace("移除了吸引侦听器");
			}
		}
	//---------------游戏过关-----------------------------------------------------------
		private function gamePass():void
		{
			_timer.delay = 80;
			_timer.removeEventListener(TimerEvent.TIMER,onTimer);
			_timer.addEventListener(TimerEvent.TIMER,extraScore);
		}
	//---------------计算加分-----------------------------------------------------------
		private function extraScore(e:TimerEvent):void
		{
			if(lastId + 16 < staticVars.MapData.length - 17)
			{
				lastId += 16;
				soundMgr.EndExplosionSound.play();
				var mc:endExplosion = new endExplosion();
				mc.x = staticVars.MapData[lastId][0];
				mc.y = staticVars.MapData[lastId][1];
				addChild(mc);
			}
			else
			{
				_timer.removeEventListener(TimerEvent.TIMER,extraScore);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveHandler);
				stage.removeEventListener(MouseEvent.CLICK,onMouseClicked);
			}
		}
	//---------------游戏结束，小球进终点后消除------------------------------------------
		private function ballRollOut(e:Event):void
		{
			for(var i:int = ballArray.length-1;i>=0;--i)
			{
				if(ballArray[i].POS > staticVars.MapData.length - 17)
				{
					removeChild(ballArray[i]);
					ballArray.splice(i,1);
					if(ballArray.length == 0)
					{
						removeEventListener(Event.ENTER_FRAME,ballRollOut);
						soundMgr.stopGameOverSound();
					}
				}
				else
				{
					ballArray[i].POS += 8;
				}
			}
		}
	}
}