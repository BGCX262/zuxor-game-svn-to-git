package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import levels.Level2;
	public class Main extends Sprite
	{
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			initGame();
		}
		//------------------Initialize the main game class----------------------------
		private function initGame():void
		{
			var game:Zuma = new Zuma(Level2);
			addChild(game);
		}
	}
}