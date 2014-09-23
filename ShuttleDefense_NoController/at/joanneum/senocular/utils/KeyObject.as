package at.joanneum.senocular.utils {
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	/**
	 * The KeyObject class recreates functionality of
	 * Key.isDown of ActionScript 1 and 2
	 *
	 * Usage:
	 * var key:KeyObject = new KeyObject(stage);
	 * if (key.isDown(key.LEFT)) { ... }
	 */
	dynamic public class KeyObject extends Proxy {
		
		private static var myStage:Stage;
		private static var keysDown:Object;
		
		public function KeyObject(myStage:Stage) {
			this.myStage = myStage;
			construct(myStage);
		}
		
		public function construct(myStage:Stage):void {
			KeyObject.myStage = myStage;
			keysDown = new Object();
			myStage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			myStage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
		}
		
		flash_proxy override function getProperty(name:*):* {
			return (name in Keyboard) ? Keyboard[name] : -1;
		}
		
		public function isDown(keyCode:uint):Boolean {
			return Boolean(keyCode in keysDown);
		}
		
		public function deconstruct():void {
			myStage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			myStage.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			keysDown = new Object();
			KeyObject.myStage = null;
		}
		
		private function keyPressed(evt:KeyboardEvent):void {
			keysDown[evt.keyCode] = true;
		}
		
		private function keyReleased(evt:KeyboardEvent):void {
			delete keysDown[evt.keyCode];
		}
	}
}