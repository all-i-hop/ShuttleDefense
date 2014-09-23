package  at.joanneum.projekt.main {
	
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.display.Stage;
	import flash.text.TextField;
	import at.joanneum.projekt.main.*;
	
	public class NewHighscore extends MovieClip {
		
		private var newHighScore:TextField 		= new TextField();
		private var goToMenu:TextField 			= new TextField();
		private var format:TextFormat 			= new TextFormat();
		private var stageRef:Stage;
		

		public function NewHighscore(stageRef:Stage) {
			this.stageRef = stageRef;
			initPage();
		}
		
		private function initPage():void {
			format.size = 60
			newHighScore.text = "Score: " + Main.highScoreValue.toString();
			newHighScore.x = 320;
			newHighScore.y = 282;
			newHighScore.width = 800;
			newHighScore.textColor = 0xFF00FF;
			newHighScore.setTextFormat(format);
			goToMenu.text = "Continue"
			goToMenu.x = 320;
			goToMenu.y = 432;
			goToMenu.width = 378;
			goToMenu.textColor = 0xFF00FF;
			goToMenu.backgroundColor = 0xFFFF00;
			goToMenu.background = true;
			goToMenu.setTextFormat(format);
			stageRef.addChild(newHighScore);
			stageRef.addChild(goToMenu);
			
			
		}
		
		public function onFinish():void {
			stageRef.removeChild(newHighScore);
			stageRef.removeChild(goToMenu);
		}
		
	}
	
}
