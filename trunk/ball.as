package{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.display.Graphics;
	import flash.utils.*;
/*  
    小球类型，包含属性color颜色，在地图曲线中的位置pos，道具类型
	包含公共方法设置位置，小球爆炸，clone函数
*/
	public class ball extends Sprite{
		//小球的颜色
		private var color:uint;
		//道具的类型
		private var propType:Class;
		//道具MC
		private var propMC:MovieClip;
		//在地图曲线中的位置
		private var pos:uint;
		//遮罩
		private var _mask:Shape;
		//位图
		private var bitmap:Bitmap;
		//显示该位图的BitmapData
		private var bmd:BitmapData;
		//位图元数据
		private var srcData:BitmapData;
		//copyPixels方法中的参数
		private var pt:Point;
		private var rect:Rectangle;
		//模拟帧数
		private var frame:uint;
		
		public function ball(src:BitmapData){
			srcData = src;
			frame = 0;
			initBitmap();
			color = defineColor();
		}
	//------------初始化位图的显示------------
		private function initBitmap(){
			_mask = new Shape();
			_mask.graphics.beginFill(0x000000);
			_mask.graphics.drawCircle(0,0,16);
			_mask.graphics.endFill();
			addChild(_mask);
			pt = new Point(0,0);
			rect = new Rectangle(0,0,32,32);
			bitmap = new Bitmap();
			bitmap.x = -16;
			bitmap.y = -16;
			addChild(bitmap);
			bitmap.mask = _mask;
			bmd = new BitmapData(32,32);
			bmd.copyPixels(srcData,rect,pt);
			bitmap.bitmapData = bmd;
			bitmap.smoothing = true;
		}
	//------------获取颜色--------------------
		public function get COLOR():uint{
			return color;
		}
	//------------设置道具--------------------
		public function set PROP(type:Class){
			propType = type;
			propMC = new propType();
			addChild(propMC);
			setTimeout(clearProp,staticVars.PropLife);
		}
	//------------访问道具--------------------
		public function get PROP():*{
			return propType;
		}
	//------------清除道具--------------------
		private function clearProp(){
			propType = null;
			removeChild(propMC);
			propMC = null;
		}
	//------------设置小球的位置--------------
		public function set POS(_pos:uint){
			if(_pos > pos){
				nextFrame();
			}
			else if(_pos < pos){
				prevFrame();
			}
			pos = _pos;
			this.x = staticVars.MapData[pos][0];
			this.y = staticVars.MapData[pos][1];
			this.rotation = staticVars.MapData[pos][2] - 90;
		}
	//------------小球爆炸-------------------
		public function explode():void
		{
			bitmap.visible = false;
			var myColor:ColorTransform = new ColorTransform();
			myColor.color = color;
			var explosion_mc:MovieClip = new explosion();
			explosion_mc.transform.colorTransform = myColor;
			addChild(explosion_mc);
			explosion_mc.addEventListener(Event.REMOVED,explodeComplete);
			
		}
	//------------爆炸结束--------------------
		private function explodeComplete(e:Event):void
		{
			e.target.removeEventListener(Event.REMOVED_FROM_STAGE,explodeComplete);
			this.stage&&this.parent.removeChild(this);
		}
	//------------访问小球的位置--------------
		public function get POS():uint{
			return pos;
		}
	//------------显示下一帧------------------
		private function nextFrame(){
			if(frame + 1 == 50){
				frame = 0;
			}else{
				++frame;
			}
			rect.y = frame * 32;
			bmd.copyPixels(srcData,rect,pt);
			bitmap.smoothing = true;
		}
	//------------显示上一帧------------------
		private function prevFrame(){
			if(frame-1 < 0){
				frame = 49;
			}else{
				--frame;
			}
			rect.y = frame * 32;
			bmd.copyPixels(srcData,rect,pt);
			bitmap.smoothing = true;
		}
	//-----------克隆小球-----------------------
		public function clone():ball
		{
			return new ball(srcData);
		}
	//---------确定颜色，爆炸时需要用到16进制的颜色值来转换颜色
		private function defineColor():uint
		{
			switch(getQualifiedClassName(srcData))
			{
				case "red" : return 0xCC0000;
				case "blue" :return 0x0066FF;
				case "purple" : return 0x9900CC;
				case "green" : return 0x00CC00;
				case "white" : return 0xCCCCCC;
				case "yellow" : return 0xFFFF00;
				default :return 0;
			}
		}
	}
}