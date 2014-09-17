package at.joanneum.projekt.engine  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class Star extends MovieClip {
		
		var stageRef:Stage;
		var speed:Number;

		public function Star(stageRef:Stage) {
			this.stageRef = stageRef
			createStar(true);
			addEventListener(Event.ENTER_FRAME, animation);
		}

		private function createStar(randomY:Boolean = false):void {
			y =  randomY ? Math.random()*stageRef.stageHeight:0;
			x = Math.random()*stageRef.stageWidth;
			alpha = Math.random();
			rotation = Math.random()*360;
			scaleX = 0.5;
			scaleY = 0.5;
			speed = 2 + Math.random()*2;
		}

		public function animation(e:Event):void {
			y += speed;
			if (y > stageRef.stageHeight){
				createStar();
			}
		}





	}
	
}
