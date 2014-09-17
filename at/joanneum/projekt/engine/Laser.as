package at.joanneum.projekt.engine
{

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import at.joanneum.projekt.main.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import fl.motion.MotionEvent;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.kasperkamperman.monitor.ArduinoMonitor;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	import net.eriksjodin.arduino.events.ArduinoSysExEvent;
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.ArduinoWithServo;



	public class Laser extends MovieClip
	{
		
		private var bulletSpeed:Number = 16;
		private var delayTime:Timer 		= new Timer(200,1);
		private var explosionSound:Sound 	= new Sound();
		private var channel:SoundChannel 	= new SoundChannel();
		private var stageRef:Stage;
		private var laserTween:Tween;
		private var a:Arduino;
		
		public function Laser(stageRef:Stage, x:Number, y:Number, a:Arduino):void
		{
			this.stageRef = stageRef;
			this.x = x;
			this.y = y;
			this.a = a;
			laserTween = new Tween(this,"y",None.easeIn,y,0,0.5,true);
			laserTween.addEventListener(TweenEvent.MOTION_CHANGE, onChange);
			laserTween.addEventListener(TweenEvent.MOTION_FINISH, onFinish);
			delayTime.addEventListener(TimerEvent.TIMER_COMPLETE, ondelayTimeComplete);
			loadSound();

		}
		
		private function loadSound():void{
			explosionSound.load(new URLRequest("/Sounds/explosion.MP3"));
		}
		
		private function ondelayTimeComplete(e:TimerEvent):void {
			a.writeDigitalPin(7,0);
		}

		public function onChange(e:TweenEvent):void
		{
			for (var i:int = 0; i < Main.enemies.length; i++)
			{
				if (hitTestObject(Main.enemies[i]))
				{
					a.writeDigitalPin(7,1);
					delayTime.start();
					channel = explosionSound.play();
					Main.enemies[i].removeSelf();
					Main.enemies.splice(i,1);
					Main.highScoreValue += 10;
					removeSelf();
				}
			}


		}
		
		public function onFinish(e:TweenEvent):void {
			
			if (stageRef.contains(this))
				stageRef.removeChild(this);
				Main.lasers.reverse().pop();
				Main.lasers.reverse();
		}

		private function removeSelf():void
		{

			if (stageRef.contains(this))
			{
				stageRef.removeChild(this);
			}

		}

	}
}