package
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.utils.*;
	public class SoundMgr
	{
		public static var CollisionSound:Sound = new collisionSound();
		public static var ShootSound:Sound = new shootSound();
		public static var EndExplosionSound:Sound = new endExplosionSound();
		public static var BallExplosionSound:Sound = new ballExplosionSound();
		private static var C1:Sound = new c1();
		private static var C2:Sound = new c2();
		private static var C3:Sound = new c3();
		private static var C4:Sound = new c4();
		private static var C5:Sound = new c5();
		private static var PopSound:Sound = new popSound();
		private static var RollingSound:Sound = new rollingSound();
		private static var soundChannel:SoundChannel = new SoundChannel();
		private static var id:uint;

		public function SoundMgr():void
		{
			
		}
		public static function playRollingSound():void
		{
			soundChannel = RollingSound.play();
			id = setTimeout(repeat,1000);
		}
		public static function stopRollingSound():void
		{
			clearTimeout(id);
			soundChannel.stop();
			trace("stop");
		}
		private static function repeat():void
		{
			playRollingSound();
			trace("repeat");
		}
		public static function playCollisionSound(id:uint):void
		{
			switch(id)
			{
				case 1 : C1.play(100);break;
				case 2 : C2.play(100);break;
				case 3 : C3.play(100);break;
				case 4 : C4.play(100);break;
				case 5 : C5.play(100);break;
				default :;
			}
		}
		public static function playGameOverSound():void
		{
			playRollingSound();
		}
		public static function stopGameOverSound():void
		{
			stopRollingSound();
			PopSound.play();
		}
	}
}