package at.joanneum.projekt.engine
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.display.MovieClip;
	import at.joanneum.projekt.main.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import fl.motion.MotionEvent;
	
	public class Comet extends MovieClip
	{

		var stageRef:Stage;
		var vy:Number = 10;
		var spread:Number = 0.2;
		private var cometTween:Tween;

		public function Comet(stageRef:Stage)
		{
			this.stageRef = stageRef;
			x = Math.random() * stageRef.width;
			y = 0;
			cometTween = new Tween(this,"y",None.easeIn,0,stageRef.stageHeight,3,true);
			addEventListener(Event.ENTER_FRAME, moveComet);

		}
		

		function moveComet(e:Event):void
		{
			//rotation +=  45;
			y +=  vy;

			if ( y > stageRef.stageHeight)
			{
				removeSelf();
			}
		}

	  public function removeSelf():void
	  {
		  removeEventListener(Event.ENTER_FRAME, moveComet);
			
			if (stageRef.contains(this))
				stageRef.removeChild(this);
	  }



	}
}