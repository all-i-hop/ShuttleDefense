package at.joanneum.projekt.engine
{
	import flash.display.Stage;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import fl.transitions.TweenEvent;
	import fl.motion.MotionEvent;
	import at.joanneum.projekt.main.Main;
	import com.kasperkamperman.monitor.ArduinoMonitor;
	import com.kasperkamperman.monitor.WavePlot;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	import net.eriksjodin.arduino.events.ArduinoSysExEvent;
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.ArduinoWithServo;

	import flash.display.MovieClip;
	import flash.events.Event;



	public class Ship extends MovieClip
	{

		private const SPEED:Number = 2;
		private const VSPEED:Number = 0.8;
		private const MAX_SPEED:Number = 20;
		private var friction:Number = 0.96;
		private var vx:Number = 0;
		private var vy:Number = 0;
		private var leftDown:Boolean = false;
		private var rightDown:Boolean = false;
		private var upDown:Boolean = false;
		private var down:Boolean = false;
		private var stageRef:Stage;
		public var initComplete:Boolean;
		public var linearMonitorA0:MovieClip;
		public var linearMonitorA0ScaleFactor:Number;

		public function Ship(stageRef:Stage)
		{
			this.stageRef = stageRef;
			addEventListener(Event.ENTER_FRAME,onFrame);
			stageRef.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			stageRef.addEventListener(KeyboardEvent.KEY_UP, onKeyRemove);
		}

		private function onKeyPress(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case 37 :
					leftDown = true;
					break;
				case 39 :
					rightDown = true;
					break;
				case 38 :
					upDown = true;
					break;
				case 40 :
					down = true;
					break;
			}
		}
		
		private function onKeyRemove(e:KeyboardEvent):void 
		{
			switch (e.keyCode)
			{
				case 37 :
					leftDown = false;;
					break;
				case 39 :
					rightDown = false;
					break;
				case 38 :
					upDown = false;
					break;
				case 40 :
					down = false;
					break;
			}
		}

		private function onFrame(e:Event):void
		{
			if (leftDown)
			{
				vx -=  SPEED;
			}

			if (rightDown)
			{
				vx +=  SPEED;
			}

			if (upDown)
			{
				vy -=  VSPEED;
			}

			if (down)
			{
				vy +=  VSPEED;
			}

			vy *=  friction;
			vx *=  friction;

			//Check for max speed
			if ((vx > MAX_SPEED))
			{
				vx = MAX_SPEED;
			}
			if ((vx <  -  MAX_SPEED))
			{
				vx =  -  MAX_SPEED;
			}
			if ((vy > MAX_SPEED))
			{
				vy = MAX_SPEED;
			}
			if ((vy <  -  MAX_SPEED))
			{
				vy =  -  MAX_SPEED;
			}

			x +=  vx;
			y +=  vy;

			// rotation
			rotation = vx;
			scaleX = (MAX_SPEED - Math.abs(vx)) / (MAX_SPEED * 5) + 0.5;

			//Stay in screen
			if ((x < 0))
			{
				x = 0;
				vx -=  vx * 1.5;
			}
			else if ((y < 0))
			{
				y = 0;
				vy -=  vy * 1.5;
			}
			else if (((x + 30) > stageRef.stageWidth))
			{
				x = stageRef.stageWidth - 52.3;
				vx -=  vx * 1.5;
			}
			else if (((y + 45) > stageRef.stageHeight))
			{
				y = stageRef.stageHeight - 45;
				vy -=  vy * 1.5;
			}
		}
	}
}