package{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class StaticVars
	{
		public static const PropLife:uint = 15000;
		public static var MapData:Array = new Array();
		public static const WhiteBall:BitmapData = new white(Ball.DIAMETR, 1600);
		public static const RedBall:BitmapData = new red(Ball.DIAMETR, 1600);
		public static const BlueBall:BitmapData = new blue(Ball.DIAMETR, 1600);
		public static const PurpleBall:BitmapData = new purple(Ball.DIAMETR, 1600);
		public static const GreenBall:BitmapData = new green(Ball.DIAMETR, 1600);
		public static const YellowBall:BitmapData = new yellow(Ball.DIAMETR, 1600);
		
		static public function getPoint(pos:Number):Point
		{
			return new Point(MapData[pos][0], StaticVars.MapData[pos][1]);
		}
	}
}