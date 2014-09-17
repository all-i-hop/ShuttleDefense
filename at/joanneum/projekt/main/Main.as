package at.joanneum.projekt.main
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.globalization.Collator;
	import flash.display.Stage;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.desktop.*;
	import flash.filesystem.*;
	import flash.media.*;
	import flash.net.*;
	import flashx.textLayout.events.ModelChange;
	import at.joanneum.projekt.engine.*;
	import flash.ui.Mouse; 
	import flash.ui.MouseCursor; 
	import flash.display.StageDisplayState; 
	import flash.display.StageScaleMode; 
	import flash.display.StageAlign; 
	import net.eriksjodin.arduino.events.ArduinoEvent;
	import net.eriksjodin.arduino.events.ArduinoSysExEvent;
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.ArduinoWithServo;



	public class Main extends MovieClip
	{

		private var newGame:TextField 			= new TextField();
		private var quit:TextField				= new TextField();
		private var format:TextFormat 			= new TextFormat();
		private var highscoreFormat:TextFormat 	= new TextFormat();
		private var highscoreLable:TextField	= new TextField();
		private var highScore:TextField			= new TextField();
		private var highScoreText:TextField 	= new TextField();
		private var pushButton:Boolean 			= true;
		private var protectedHit:Boolean 		= false;
		private var isProtected:Boolean			= false;
		private var highScorePageOn:Boolean 	= false;
		private var startGameLEDOver:Boolean 	= false;
		private var menuPageOn:Boolean 			= false;
		private var gamePageOn:Boolean 			= false;
		private var gameOverPageOn:Boolean 		= false;
		private var shipHit:Boolean 			= false;
		private var newEnemy:Boolean 			= false;
		private var gameMode:Boolean 			= false;
		private var rotationPoss:Boolean 		= true;
		private var firstRot:Number				= 0;
		private var maxStars:Number 			= 80;
		private var rot_counter:int 			= 0;
		private var shootSound:Sound			= new Sound();
		private var channel:SoundChannel		= new SoundChannel();
		private var enemyTimer:Timer 			= new Timer(800,1);// creating new enemy
		private var gamePlayTimer:Timer 		= new Timer(15000,1);//advancing game mode
		private var delayTime:Timer				= new Timer(100,1);  // to prevent multiple signals after push button
		private var vibrationDelayTime:Timer	= new Timer(800,1); // when shiphit -> vibration timer and red LED
		private var ledTimer:Timer				= new Timer(2000,1);  //LEDs go out on game initialization
		private var armorTimer:Timer 			= new Timer(15000,1); // creating new armor
		private var protectionTime:Timer 		= new Timer (500,1); //time ship is protected after shiphit with protection
		private var armor:Armor;
		private var gameOverPage:NewHighscore;
		private var highScorePage:HighScore;
		private var numEvents:int;
		private var initComplete:Boolean;
		private var ship:Ship;
		private var a;		//Arduino
		private const FILE_NAME 				= "HighScore_Data.txt";
		public static var highScoreValue:int 	= 0;
		public static var enemies:Array			= new Array();
		public static var lasers:Array			= new Array();

		public function Main()
		{
			stage.displayState=StageDisplayState.FULL_SCREEN;
			Mouse.cursor=MouseCursor.AUTO; 
			Mouse.hide();
			stage.color = 000033;
			backgroundStars();
			a = new Arduino("127.0.0.1",5331);
			a.addEventListener(Event.CONNECT, onSocketConnect);
			a.addEventListener(ArduinoEvent.FIRMWARE_VERSION, onReceiveFirmwareVersion);
			a.addEventListener(Event.CLOSE, onSocketClose);
		}
		
		private function initGameData() {
			delayTime.addEventListener(TimerEvent.TIMER_COMPLETE, delayTimeComplete);
			vibrationDelayTime.addEventListener(TimerEvent.TIMER_COMPLETE, vibrationDelayTimeComplete);
			ledTimer.addEventListener(TimerEvent.TIMER_COMPLETE, ledTimeComplete);
			gamePlayTimer.addEventListener(TimerEvent.TIMER, advanceGame);
			enemyTimer.addEventListener(TimerEvent.TIMER, createNewEnemy);
			armorTimer.addEventListener(TimerEvent.TIMER_COMPLETE, armorTimerComplete);
			protectionTime.addEventListener(TimerEvent.TIMER_COMPLETE, protectionTimeComplete);
			loadSound("./Sounds/ufo_highpitch.wav");
			startGameLed();
		}

		// triggered when a serial socket connection has been established
		public function onSocketConnect(e:Object):void
		{
			trace("Socket connected!");
			// request the firmware version
			a.requestFirmwareVersion();
		}
		

		//Event Listener für Firmware Version
		// the firmware version is requested when the Arduino class has made a socket connection.
		// when we receive this event we know that the Arduino has been successfully connected.
		public function onReceiveFirmwareVersion(e:ArduinoEvent):void
		{
			trace("Firmware version: " + e.value);
			if (int(e.value) != 2)
			{
				trace("Unexpected Firmware version encountered! This Version of as3glue was written for Firmata2.");
			}
			// the port value of an event can be used to determine which board the event was dispatched from
			// this is one way of dealing with multiple boards, another is to add different listener methods
			trace("Port: " + e.port);

			// do some stuff on the Arduino...
			initArduino();
		}
		

		// FUNCTIONS
		// triggered when a serial socket connection has been closed
		public function onSocketClose(e:Object):void
		{
			trace("Socket closed!");
		}

		public function initArduino():void
		{
			trace("Initializing Arduino");
			//Digitales Pin Reporting aktivieren
			a.enableDigitalPinReporting();
			a.setPinMode(2, Arduino.INPUT);
			a.setPinMode(4, Arduino.INPUT);
			a.setPinMode(5, Arduino.INPUT);
			a.setPinMode(7, Arduino.OUTPUT);
			a.setPinMode(12, Arduino.OUTPUT);
			a.writeDigitalPin(5,0);
			a.writeDigitalPin(4,0);
			initComplete = true;
			initGameData();
		}
	
		//Green lights go out;
		private function delayTimeComplete(e:TimerEvent):void {
			pushButton = true;	
		}
		
		private function vibrationDelayTimeComplete(e:TimerEvent):void {
			a.writeDigitalPin(12,0);
			a.writeDigitalPin(8,0);
			a.writeDigitalPin(7,0);
			pushButton = true;
			
		}
		//stop flashing lights
		private function ledTimeComplete(e:TimerEvent):void {
				a.writeDigitalPin(8,0);
				a.writeDigitalPin(7,0);
				initGame();
		}
		// decrease the time for creating enemies -> increases difficulty
		private function advanceGame(e:TimerEvent):void
		{
			if (enemyTimer.delay > 100)
			{
				enemyTimer.delay -=  100;
				gamePlayTimer.start();

			}

		}

		// if time passes new enemy can be created
		private function createNewEnemy(e:TimerEvent):void
		{
			if (enemies.length < 120)
			{
				newEnemy = true;
			}
		}
		
		//time to get an Armor
		private function armorTimerComplete(e:TimerEvent):void {
			if (gamePageOn && !isProtected) {
				armor = new Armor(stage);
				stage.addChild(armor);
				armorTimer.start();
			}
		}
		
		private function protectionTimeComplete (e:TimerEvent):void  {
			protectedHit = false;
		}

		//creates background
		private function backgroundStars():void
		{
			for (var i:int = 0; i < maxStars; i++)
			{
				var newStar:Star = new Star(stage);
				stage.addChild(newStar);
			}
		}

		private function startGameLed():void {
			var ledDelay: Timer = new Timer(800,1); // delay for second pair of LEDS to go on
			a.writeDigitalPin(8,1);
			ledDelay.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event){
									  a.writeDigitalPin(7,1);
									  ledTimer.start();
									  });
			ledDelay.start();
		}

		function loadSound(mySound:String):void {
			 shootSound.load(new URLRequest("Sounds/shoot.MP3")); 
	}


		//Main menu layout
		private function initGame():void
		{
			menuPageOn = true;
			format.size = 60;
			highscoreFormat.size = 30;
			// New Game
			newGame.text = "New Game";
			newGame.x = 380;
			newGame.y = 132;
			newGame.width = 378;
			newGame.background = true;
			newGame.backgroundColor = 0xFFFF00;
			newGame.textColor = 0xFF00FF;
			newGame.setTextFormat(format);
			//  Highscore;
			highScore.text = "High Score";
			highScore.x = 380;
			highScore.y = 282;
			highScore.width = 378;
			highScore.textColor = 0xFF00FF;
			highScore.backgroundColor = 0xFFFF00;
			highScore.background = false;
			highScore.setTextFormat(format);
			// Quit;
			quit.text = "Quit";
			quit.x = 380;
			quit.y = 432;
			quit.width = 378;
			quit.textColor = 0xFF00FF;
			quit.backgroundColor = 0xFFFF00;
			quit.background = false;
			quit.setTextFormat(format);
			// HighScorebox and lable
			highscoreLable.text = "Score:";
			highscoreLable.x = 28;
			highscoreLable.y = 706.95;
			highscoreLable.width = 120;
			highscoreLable.textColor = 0xFFFFFF;
			highscoreLable.setTextFormat(highscoreFormat);
			// Score;
			highScoreText.text = "0";
			highScoreText.x = 160;
			highScoreText.y = 706.95;
			highScoreText.width = 60;
			highScoreText.textColor = 0xFFFFFF;
			highScoreText.setTextFormat(highscoreFormat);
			//Add to Stage;
			stage.addChild(highScore);
			stage.addChild(newGame);
			stage.addChild(quit);
			//Activate EventListeners for game  initialisation
			//Game navigation
			a.addEventListener(ArduinoEvent.DIGITAL_DATA, menuButtonPress); 
			
		}

		private function menuButtonPress(e:ArduinoEvent):void
		{
			if (e.pin == 2){
				if (pushButton) {
					if (menuPageOn)
				{
					if (newGame.background == true)
					{
						startGame();
					}if (highScore.background == true) {
						stage.removeChild(newGame);
						stage.removeChild(quit);
						stage.removeChild(highScore);
						highScorePage = new HighScore(stage);
						stage.addChild(highScorePage);
						highScorePageOn = true;
						menuPageOn = false;
					}
					if (quit.background == true)
					{
						quitGame();
					}
				}
				else if (gameOverPageOn)
				{
					gameOverPageOn = false;
					gameOverPage.onFinish();
					stage.removeChild(gameOverPage);
					saveHighScore(highScoreValue);
					highScoreValue = 0;
					initGame();
				}
				else if (highScorePageOn) {
					highScorePage.onFinish();
					stage.removeChild(highScorePage);
					highScorePageOn = false;
					menuPageOn = true;
					initGame();
				}
				else if (gamePageOn) {
					stage.addChild(new Laser(stage,ship.x + 10,ship.y - 15, a));
					channel = shootSound.play();
				}
			}
			pushButton = false;
			delayTime.start();
		}
			if (e.pin == 4 ) {
				if (firstRot == 0){
					firstRot = 4
				}
				checkRotation(0);
			}	
			if (e.pin == 5) {
				if (firstRot == 0) {
					firstRot = 5
				}
				checkRotation(1);
			}
		}

		private function checkRotation(rotDirection:Number) { // rotDirection 1 = clockwise | 0 = opposite
			if (rot_counter < 3) {
				rot_counter++;
			}
			else {
				rot_counter = 0;
				if (rotDirection == 1 && firstRot == 4){
					menuDown();
				}
				else if (rotDirection == 0 && firstRot == 5) {
					menuUp();
				}
				firstRot = 0;
			}
			a.writeDigitalPin(5,0);
			a.writeDigitalPin(4,0);
		}
		
		private function menuUp():void  {
			if (newGame.background == true)
				{
					newGame.background = false;
					highScore.background = true;
				}
				else if (highScore.background == true)
				{
					highScore.background = false;
					quit.background = true;
				}
				else if (quit.background == true)
				{
					quit.background = false;
					newGame.background = true;
				}
				rotationPoss = true
		}
		
		private function menuDown():void {
			if (newGame.background == true)
				{
					newGame.background = false;
					quit.background = true;
				}
				else if (highScore.background == true)
				{
					highScore.background = false;
					newGame.background = true;
				}
				else if (quit.background == true)
				{
					quit.background = false;
					highScore.background = true;
				}
				rotationPoss = true
		}
			
		
		private function saveHighScore(score:int):void {
			var scores:String = "";
			var newFile:File = File.applicationStorageDirectory;
			try {
				newFile = newFile.resolvePath("HighScore/HighScore_Data.txt");
				var inStream:FileStream = new FileStream();
				inStream.open(newFile, FileMode.READ);
				scores = inStream.readUTFBytes(newFile.size)
				inStream.close();
			} catch (e:Error) {
				trace("No file found");
				inStream.close();
			}			
			var outStream:FileStream = new FileStream();
			outStream.open(newFile, FileMode.WRITE);
			var date:Date = new Date();
			scores = scores + ("On " + date.date + "."  + (date.month + 1) + "." + date.fullYear +
							  " at " + date.hours + ":" + date.minutes + ":" + date.seconds + " " +
							  highScoreValue.toString()+ " Points \n;")
			outStream.writeUTFBytes(scores);
			outStream.close();
		}

		//Creating Gamemode
		private function startGame()
		{
			delayTime.start() // prevent shooting several times at once
			armorTimer.start();
			menuPageOn = false;
			gamePageOn = true;
			enemies = new Array();
			lasers = new Array();
			ship = new Ship(stage,a);
			ship.x = 300;
			ship.y = 400;
			gamePlayTimer.start();
			enemyTimer.start();
			stage.addEventListener(Event.ENTER_FRAME, createGameMap);
			stage.removeChild(newGame);
			stage.removeChild(highScore);
			stage.removeChild(quit);
			stage.addChild(highscoreLable);
			stage.addChild(highScoreText);
			stage.addChild(ship);
		}


		//Creating enemies for gameplay
		private function createGameMap(e:Event):void
		{
			highScoreText.text = highScoreValue.toString();
			highScoreText.setTextFormat(highscoreFormat);
			// ship collects armer
			if (armor != null && armor.hitTestObject(ship)) {
				isProtected = true;
				armor.stopTween();
				}
			if (newEnemy) //time to create a new enemy 
			{
				var comet = new Comet(stage);
				stage.addChild(comet);
				enemies.push(comet);
				newEnemy = false;
				enemyTimer.start();
			}

			for (var i:int; i < enemies.length; i++)
			{
				if (enemies[i].hitTestObject(ship) && !isProtected)
				{
					if(!protectedHit) {
						pushButton = false;
						shipHit = true;
					}
				}
				else if (enemies[i].hitTestObject(ship) && isProtected) {
					shipHit = false;
					isProtected = false;
					protectedHit = true;
					protectionTime.start();
					stage.removeChild(armor);
					}
			}
			if ((shipHit == true) && !isProtected)
			{
				a.writeDigitalPin(12,1);
				a.writeDigitalPin(8,1);
				vibrationDelayTime.start();
				gameOver();
				shipHit = false;
			}
			
			if (isProtected) {
				armor.x = ship.x - 85;
				armor.y = ship.y - 85;
			}
		}

		//Ship was hit bei comet
		public function gameOver():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, createGameMap);
			stage.removeChild(ship);
			ship = null;
			enemyTimer.delay = 800;
			gameOverPage = new NewHighscore(stage);// Add the gameOverPage to stage
			stage.addChild(gameOverPage);
			armorTimer.reset();
			enemyTimer.reset();
			gameOverPageOn = true;
			gamePageOn = false;
		}

		private function quitGame():void
		{
			NativeApplication.nativeApplication.exit();
		}

	}
}		