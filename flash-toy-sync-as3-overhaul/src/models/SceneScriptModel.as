package models {
	
	import flash.geom.Point;
	import utils.SceneScriptUtil;
	
	/**
	 * ...
	 * @author notSafeForDev
	 */
	public class SceneScriptModel {
		
		/** The scene this script is used for */
		protected var scene : SceneModel;
		
		/** The first recorded frame of the scene, which won't necessariliy be the same as the first inner frame of the scene */
		protected var firstRecordedInnerFrame : Number = -1;
		
		/** The screen position of the base of the "penis", on each frame in the scene */
		protected var basePositions : Vector.<Point>;
		/** The screen position where the stimulation takes place on the "penis", on each frame in the scene */
		protected var stimPositions : Vector.<Point>;
		/** The screen position of the tip of the "penis", on each frame in the scene */
		protected var tipPositions : Vector.<Point>;
		
		private var splitEventListener : Object;
		private var mergeEventListener : Object;
		
		public function SceneScriptModel(_scene : SceneModel) {
			scene = _scene;
			
			splitEventListener = scene.splitEvent.listen(this, onSceneSplit);
			mergeEventListener = scene.mergeEvent.listen(this, onSceneMerged);
			
			basePositions = new Vector.<Point>();
			tipPositions = new Vector.<Point>();
			stimPositions = new Vector.<Point>();
		}
		
		public function clone(_clonedScene : SceneModel) : SceneScriptModel {
			var clonedScript : SceneScriptModel = new SceneScriptModel(_clonedScene);
			
			clonedScript.firstRecordedInnerFrame = firstRecordedInnerFrame;
			clonedScript.basePositions = basePositions.slice();
			clonedScript.tipPositions = tipPositions.slice();
			clonedScript.stimPositions = stimPositions.slice();
			
			return clonedScript;
		}
		
		public function addPositions(_frame : Number, _base : Point, _stim : Point, _tip : Point) : void {
			if (basePositions.length == 0) {
				firstRecordedInnerFrame = _frame;
				basePositions.push(_base);
				stimPositions.push(_stim);
				tipPositions.push(_tip);
				return;
			}
			
			var lastFrameForPositions : Number = firstRecordedInnerFrame + (basePositions.length - 1);
			
			var totalFillBeginning : Number = Math.max(0, firstRecordedInnerFrame - _frame);
			var totalFillEnd : Number = Math.max(0, _frame - lastFrameForPositions);
			
			fillInBlankPositionsAtBeginning(totalFillBeginning);
			fillInBlankPositionsAtEnd(totalFillEnd);
			
			firstRecordedInnerFrame = Math.min(firstRecordedInnerFrame, _frame);
			
			var frameIndex : Number = _frame - firstRecordedInnerFrame;
			
			basePositions[frameIndex] = _base;
			stimPositions[frameIndex] = _stim;
			tipPositions[frameIndex] = _tip;
		}
		
		public function isComplete() : Boolean {
			return firstRecordedInnerFrame == scene.getInnerStartFrame() && basePositions.length == scene.getTotalInnerFrames();
		}
		
		public function getBasePositions() : Vector.<Point> {
			return basePositions.slice();
		}
		
		public function getStimPositions() : Vector.<Point> {
			return stimPositions.slice();
		}
		
		public function getTipPositions() : Vector.<Point> {
			return tipPositions.slice();
		}
		
		public function isFrameWithinRecordedFrames(_frame : Number) : Boolean {
			var lastRecordedFrame : Number = firstRecordedInnerFrame + basePositions.length - 1;
			return basePositions.length > 0 && _frame >= firstRecordedInnerFrame && _frame <= lastRecordedFrame;
		}
		
		public function hasRecordedPositionOnFrame(_positions : Vector.<Point>, _frame : Number) : Boolean {
			var frameIndex : Number = _frame - firstRecordedInnerFrame;
			return _positions[frameIndex] != null;
		}
		
		public function getInterpolatedPosition(_positions : Vector.<Point>, _frame : Number) : Point {
			var frameIndex : Number = _frame - firstRecordedInnerFrame;
			return SceneScriptUtil.getInterpolatedPosition(_positions, frameIndex);
		}
		
		protected function destroy() : void {
			scene.mergeEvent.stopListening(mergeEventListener);
			scene.splitEvent.stopListening(splitEventListener);
		}
		
		private function onSceneSplit(_firstHalf : SceneModel) : void {
			if (basePositions.length == 0) {
				return;
			}
			
			var totalRemovedFromBeginning : Number = Math.max(0, scene.getInnerStartFrame() - firstRecordedInnerFrame);
			
			basePositions.splice(0, totalRemovedFromBeginning);
			stimPositions.splice(0, totalRemovedFromBeginning);
			tipPositions.splice(0, totalRemovedFromBeginning);
			
			if (basePositions.length > 0) {
				firstRecordedInnerFrame = Math.max(firstRecordedInnerFrame, scene.getInnerStartFrame());
			} else {
				firstRecordedInnerFrame = -1;
			}
			
			var firstHalfScript : SceneScriptModel = _firstHalf.getPlugins().getScript();
			
			var firstHalfTotalRecoredFrames : Number = Math.max(0, _firstHalf.getInnerEndFrame() - firstHalfScript.firstRecordedInnerFrame + 1);
			
			firstHalfScript.basePositions = firstHalfScript.basePositions.slice(0, firstHalfTotalRecoredFrames);
			firstHalfScript.stimPositions = firstHalfScript.stimPositions.slice(0, firstHalfTotalRecoredFrames);
			firstHalfScript.tipPositions = firstHalfScript.tipPositions.slice(0, firstHalfTotalRecoredFrames);
			
			if (firstHalfScript.basePositions.length == 0) {
				firstHalfScript.firstRecordedInnerFrame = -1;
			}
		}
		
		private function onSceneMerged(_otherScene : SceneModel) : void {
			var otherScript : SceneScriptModel = _otherScene.getPlugins().getScript();
			if (otherScript.basePositions.length == 0) {
				return;
			}
			
			var totalFillBeginning : Number = Math.max(0, firstRecordedInnerFrame - _otherScene.getInnerStartFrame());
			
			fillInBlankPositionsAtBeginning(totalFillBeginning);
			
			firstRecordedInnerFrame = Math.min(firstRecordedInnerFrame, _otherScene.getInnerStartFrame());
			
			var i : Number;
			for (i = 0; i < totalFillBeginning; i++) {
				basePositions[i] = otherScript.basePositions[i];
				stimPositions[i] = otherScript.stimPositions[i];
				tipPositions[i] = otherScript.tipPositions[i];
			}
			
			var endFrame : Number = firstRecordedInnerFrame + basePositions.length - 1;
			var otherEndFrame : Number = otherScript.firstRecordedInnerFrame + otherScript.basePositions.length - 1;
			var totalFillEnd : Number = Math.max(0, otherEndFrame - endFrame);
			
			fillInBlankPositionsAtEnd(totalFillEnd);
			
			var startCopyFromFrame : Number = Math.max(endFrame + 1, otherScript.firstRecordedInnerFrame);
			var totalFramesToCopy : Number = (otherEndFrame - startCopyFromFrame) + 1;
			
			for (i = 0; i < totalFramesToCopy; i++) {
				var otherFrameIndex : Number = (startCopyFromFrame - otherScript.firstRecordedInnerFrame) + i;
				var frameIndex : Number = (startCopyFromFrame - firstRecordedInnerFrame) + i;
				
				basePositions[frameIndex] = otherScript.basePositions[otherFrameIndex];
				stimPositions[frameIndex] = otherScript.stimPositions[otherFrameIndex];
				tipPositions[frameIndex] = otherScript.tipPositions[otherFrameIndex];
			}
			
			otherScript.destroy();
		}
		
		private function fillInBlankPositionsAtBeginning(_totalBlankPositions : Number) : void {
			for (var i : Number = 0; i < _totalBlankPositions; i++) {
				basePositions.unshift(null);
				stimPositions.unshift(null);
				tipPositions.unshift(null);
			}
		}
		
		private function fillInBlankPositionsAtEnd(_totalBlankPositions : Number) : void {
			for (var i : Number = 0; i < _totalBlankPositions; i++) {
				basePositions.push(null);
				stimPositions.push(null);
				tipPositions.push(null);
			}
		}
	}
}