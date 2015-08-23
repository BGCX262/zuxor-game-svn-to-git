package{
	import flash.display.BitmapData;
	/*
	集中管理一些静态数据，存储公共数据
	*/
	public class staticVars{
		//道具的生命时间(/ms)
		public static const PropLife:uint = 15000;
		//存储曲线地图的数据
		public static var MapData:Array = new Array();
		//白色小球的位图数据源
		public static const WhiteBall:BitmapData = new white(32,1600);
		//红色...
		public static const RedBall:BitmapData = new red(32,1600);
		//蓝色...
		public static const BlueBall:BitmapData = new blue(32,1600);
		//紫色...
		public static const PurpleBall:BitmapData = new purple(32,1600);
		//绿色...
		public static const GreenBall:BitmapData = new green(32,1600);
		//黄色...
		public static const YellowBall:BitmapData = new yellow(32,1600);
	}
}