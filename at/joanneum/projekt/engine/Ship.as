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

		private const SPEED:Number= 2;
		private const VSPEED:Number = 1;
		private const MAX_SPEED:Number= 20;
		private var friction:Number= 0.96;
		private var vx:Number = 0;
		private var vy:Number = 0;
		private var leftDown:Boolean = false;
		private var rightDown:Boolean = false;
		private var upDown:Boolean = false;
		private var down:Boolean = false;
		private var stageRef:Stage;
		public var a:Arduino;
		public var initComplete:Boolean;
		public var linearMonitorA0:MovieClip;
		public var linearMonitorA0ScaleFactor:Number;

		public function Ship(stageRef:Stage, a:Arduino)
		{
			this.stageRef = stageRef;
			addEventListener(Event.ENTER_FRAME, onFrame);
			this.a = a;
			a.addEventListener(ArduinoEvent.ANALOG_DATA, onReceiveAnalogData);
			initArduino();
		}



		// INIT ARDUINO
		// set input and output pins
		public function initArduino():void
		{
			trace("Initializing Arduino");

			//Analoge und digitale Eingänge konfigurieren
			a.setAnalogPinReporting(5, Arduino.ON);
			a.setAnalogPinReporting(5, Arduino.ON);
			a.setAnalogPinReporting(4,Arduino.ON);

			// Jetzt ist die Initialisierung fertig!
			initComplete = true;

		}

		public function onReceiveAnalogData(e:ArduinoEvent):void
		{
			//trace((numEvents++) +" Analog pin " + e.pin + " on port: " + e.port +" = " + e.value);

			//Nur wenn Initialisierung komplett abgeschlossen ist, sind die Werte brauchbar!
			if (initComplete)
			{

				switch (e.pin)
				{
					case 5 :
						if (e.value < 280)
						{
							leftDown = true;
							rightDown = false;
						}
						if (e.value > 330)
						{
							rightDown = true;
							leftDown = false;
						}
						if (e.value > 280 && e.value < 330)
						{
							rightDown = false;
							leftDown = false;
						}
						break;
					case 4 :
						if (e.value < 290)
						{
							upDown = true;
							down = false;
						}
						else if (e.value > 340)
						{
							down = true;
							upDown = false;
						}
						else if (e.value > 290 && e.value < 340)
						{
							upDown = false;
							down = false;
						}
						if (e.value > 400)
						{
							vy =  -  MAX_SPEED;
						}
						break;
				}

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
			if (vx > MAX_SPEED)
			{
				vx = MAX_SPEED;
			}
			if (vx < -MAX_SPEED)
			{
				vx =  -  MAX_SPEED;
			}
			if (vy > MAX_SPEED)
			{
				vy = MAX_SPEED;
			}
			if (vy < -MAX_SPEED)
			{
				vy =  -  MAX_SPEED;
			}

			x +=  vx;
			y +=  vy;

			// rotation
			rotation = vx;
			scaleX = (MAX_SPEED - Math.abs(vx)) / (MAX_SPEED * 5) + 0.5;

			//Stay in screen
			if (x < 0 )
			{
				x = 0;
				vx -=  vx * 1.5;
			}
			else if (y < 0)
			{
				y = 0;
				vy -=  vy * 1.5;
			}
			else if ((x + 30)> stageRef.stageWidth)
			{
				x = (stageRef.stageWidth - 52.3);
				vx -=  vx * 1.5;
			}
			else if ((y + 45) > stageRef.stageHeight)
			{
				y = (stageRef.stageHeight - 45);
				vy -=  vy * 1.5;
			}
		}
	}
}