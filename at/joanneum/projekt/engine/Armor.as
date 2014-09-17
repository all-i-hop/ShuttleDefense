package at.joanneum.projekt.engine
{

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import at.joanneum.projekt.main.*;
	import fl.motion.MotionEvent;
	import flash.display.*;
	import flash.geom.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import fl.motion.MotionEvent;

	public class Armor extends MovieClip
	{

		private var stageRef:Stage;
		private var speed:Number = 16;
		public var tween:Tween;

		public function Armor(stageRef:Stage)
		{
			this.stageRef = stageRef;
			drawArmor();
			y = 0;
			this.x = Math.random() * stageRef.stageWidth;
			tween = new Tween(this,"y",None.easeIn, 0, 700 ,5, true);
			tween.addEventListener(TweenEvent.MOTION_FINISH, onFinish);
			tween.addEventListener(TweenEvent.MOTION_CHANGE, onChange);
			//addEventListener(Event.ENTER_FRAME, moveArmor);

		}
		
		public function stopTween():void {
			tween.stop();
		}
		
		private function drawArmor() {
			var p:Point = new Point(100, 100);
			this.graphics.beginFill(0xFFFF00);
			this.graphics.drawCircle(p.x, p.y, 50);
			this.graphics.drawCircle(p.x, p.y, 40);
			this.graphics.endFill();
		}

		private function onChange(e:TweenEvent):void  {
			if (this.y > stageRef.stageHeight) {
				onFinish(e);
			}
		}
		
		public function onFinish(e:TweenEvent):void {
			
			if (stageRef.contains(this))
				stageRef.removeChild(this);
		}


		public function removeSelf():void
		{

			if (stageRef.contains(this))
			{
				stageRef.removeChild(this);
			}

		}


	}

}