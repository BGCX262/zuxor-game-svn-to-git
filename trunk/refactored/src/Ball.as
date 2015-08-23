package{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.*;

	public class Ball extends Sprite
	{
		static public const DIAMETR:Number = 32;
		private var color:uint;
		private var propType:Class;
		private var propMC:MovieClip;
		private var pos:uint;
		private var _mask:Shape;
		private var bitmap:Bitmap;
		private var bmd:BitmapData;
		private var srcData:BitmapData;
		private var pt:Point;
		private var rect:Rectangle;
		private var frame:uint;
		
		public static function get RADIUS():Number
		{
			return DIAMETR / 2;
		}
		
		public function Ball(src:BitmapData){
			srcData = src;
			frame = 0;
			initBitmap();
			color = defineColor();
		}
		
		private function initBitmap():void
		{
			_mask = new Shape();
			_mask.graphics.beginFill(0x000000);
			_mask.graphics.drawCircle(0, 0, RADIUS);
			_mask.graphics.endFill();
			addChild(_mask);
			pt = new Point(0,0);
			rect = new Rectangle(0, 0, DIAMETR, DIAMETR);
			bitmap = new Bitmap();
			bitmap.x = -RADIUS;
			bitmap.y = -RADIUS;
			addChild(bitmap);
			bitmap.mask = _mask;
			bmd = new BitmapData(DIAMETR, DIAMETR);
			
			bmd.copyPixels(srcData, rect, pt);
			bitmap.bitmapData = bmd;
			bitmap.smoothing = true;
		}
		
		public function get COLOR():uint
		{
			return color;
		}
		
		public function set PROP(type:Class):void
		{
			propType = type;
			propMC = new propType();
			addChild(propMC);
			setTimeout(clearProp,StaticVars.PropLife);
		}
		
		public function get PROP():*
		{
			return propType;
		}
		
		private function clearProp():void
		{
			propType = null;
			removeChild(propMC);
			propMC = null;
		}
		
		public function set POS(_pos:uint):void
		{
			if(_pos > pos)
				nextFrame();
			else if (_pos < pos)
				prevFrame();
				
			pos = _pos;
			this.x = StaticVars.MapData[pos][0];
			this.y = StaticVars.MapData[pos][1];
			this.rotation = StaticVars.MapData[pos][2] - 90;
		}
		
		public function explode():void
		{
			bitmap.visible = false;
			var myColor:ColorTransform = new ColorTransform();
			myColor.color = color;
			var explosion_mc:MovieClip = new explosion();
			explosion_mc.transform.colorTransform = myColor;
			addChild(explosion_mc);
			explosion_mc.addEventListener(Event.REMOVED, explodeComplete);
		}
		
		private function explodeComplete(e:Event):void
		{
			e.target.removeEventListener(Event.REMOVED_FROM_STAGE, explodeComplete);
			this.stage && this.parent.removeChild(this);
		}
		
		public function get POS():uint
		{
			return pos;
		}
		
		private function nextFrame():void
		{
			if(frame + 1 == 50)
				frame = 0;
			else
				++frame;
			rect.y = frame * DIAMETR;
			bmd.copyPixels(srcData,rect,pt);
			bitmap.smoothing = true;
		}
		
		private function prevFrame():void
		{
			if(frame-1 < 0)
				frame = 49;
			else
				--frame;
			rect.y = frame * DIAMETR;
			bmd.copyPixels(srcData,rect,pt);
			bitmap.smoothing = true;
		}
		
		public function clone():Ball
		{
			return new Ball(srcData);
		}
		
		private function defineColor():uint
		{
			switch(getQualifiedClassName(srcData))
			{
				case "red": return 0xCC0000;
				case "blue": return 0x0066FF;
				case "purple": return 0x9900CC;
				case "green": return 0x00CC00;
				case "white": return 0xCCCCCC;
				case "yellow": return 0xFFFF00;
				default :return 0;
			}
		}
	}
}