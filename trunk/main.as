package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import cheackPoints.*;
	public class main extends Sprite
	{
		public function main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			initGame();
		}
		//------------------Initialize the main game class----------------------------
		private function initGame():void
		{
			var game:zuma = new zuma(level_1);
			addChild(game);
		}
	}
}