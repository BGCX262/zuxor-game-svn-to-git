package cheackPoints
{
	import flash.geom.Point;
	public class level_1
	{
		//驱动小球滚动的timer的延迟
		public static const SPEED:uint = 50;
		//总球数
		public static const NUM:uint = 100;
		//青蛙的位置
		public static const FrogPosition:Point = new Point(452,353);
		//曲线路径信息
		public static var MapArray:Array =  [[879,57],[832,55],[648,48],[418,49],[142,68],[66,134],
											[50,225],[53,335],[76,458],[135,542],[300,559],
											[546,558],[677,542],[741,491],[746,378],[734,259],
											[679,155],[564,150],[336,159],[180,193],[158,262],
											[154,351],[207,434],[312,484],[482,474],[591,456],
											[635,384],[613,277],[473,234],[309,251],[289,356],];
	}
}