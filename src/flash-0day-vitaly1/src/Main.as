package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author dsa
	 */
	public class Main extends Sprite 
	{
		public function Main():void 
		{
			//trace("Got to checkpoint 0");
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//trace("Got to checkpoint 1.");
			//var bu = new MyClass();
			//bu.TryExpl();
			MyClass.TryExpl();
			// entry point
		}
	}
	
}