package at.joanneum.projekt.main
{

	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.filesystem.*;
	import at.joanneum.projekt.main.*;

	public class HighScore extends MovieClip
	{

		private var newHighScore:TextField = new TextField();
		private var goToMenu:TextField = new TextField();
		private var format:TextFormat = new TextFormat();
		private var stageRef:Stage;

		public function HighScore(stageRef:Stage)
		{
			this.stageRef = stageRef;
			initPage();
		}

		private function initPage():void
		{
			format.size = 40;
			var loopLength:Number;
			var highScore = "";
			var scores:String = getPreviousScores();
			if (scores != null)
			{
				var scoreList:Array = scores.split(";");
				var sortedScoreList = sortHighScores(scoreList);
				sortedScoreList = sortedScoreList.reverse();
				if (sortedScoreList.length > 5)
				{
					loopLength = 5;
				}
				else
				{
					loopLength = sortedScoreList.length;
				}
				for (var i:int = 0; i < loopLength; i++)
				{
					highScore = highScore + sortedScoreList[i];
				}
			}
			else
			{
				highScore = "No scores so far! Start playing!!!";
			}
			newHighScore.htmlText = highScore;
			newHighScore.x = 280;
			newHighScore.y = 150;
			newHighScore.width = 800;
			newHighScore.height = 500;
			newHighScore.textColor = 0xFF00FF;
			newHighScore.setTextFormat(format);
			goToMenu.text = "Continue";
			goToMenu.x = 320;
			goToMenu.y = 532;
			goToMenu.width = 378;
			goToMenu.textColor = 0xFF00FF;
			goToMenu.backgroundColor = 0xFFFF00;;
			goToMenu.background = true;
			goToMenu.setTextFormat(format);
			goToMenu.autoSize;
			stageRef.addChild(newHighScore);
			stageRef.addChild(goToMenu);
		}

		private function getPreviousScores():String
		{
			var scoreList:Array;
			var scores:String;
			var newFile:File = File.applicationStorageDirectory;
			try
			{
				newFile = newFile.resolvePath("HighScore/HighScore_Data.txt");
				var inStream:FileStream = new FileStream();
				inStream.open(newFile, FileMode.READ);
				scores = inStream.readUTFBytes(newFile.size);
				inStream.close();
			}
			catch (e:Error)
			{
				trace("No file found");
				inStream.close();
			}
			return scores;
		}

		private function sortHighScores(scores:Array):Array
		{
			return scores.sort(sortOnPoints);
		}

		private function sortOnPoints(scoreA:String, scoreB:String):Number
		{
			var scoreArrayA = scoreA.split(" ");
			var scoreArrayB = scoreB.split(" ");
			if (int(scoreArrayA[4]) > int(scoreArrayB[4]))
			{
				return 1;
			}
			if (int(scoreArrayA[4]) < int(scoreArrayB[4]))
			{
				return -1;
			} else {
				return 0;
			}
		}

		public function onFinish():void
		{
			stageRef.removeChild(newHighScore);
			stageRef.removeChild(goToMenu);
		}

	}

}