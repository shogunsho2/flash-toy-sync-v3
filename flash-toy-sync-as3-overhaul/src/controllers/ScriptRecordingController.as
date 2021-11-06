package controllers {
	
	import components.KeyboardInput;
	import core.TPMovieClip;
	import flash.geom.Point;
	import models.SceneModel;
	import models.SceneScriptModel;
	import states.AnimationPlaybackStates;
	import states.ScriptRecordingStates;
	import states.ScriptTrackerStates;
	import ui.Colors;
	import ui.Shortcuts;
	import utils.ArrayUtil;
	
	/**
	 * ...
	 * @author notSafeForDev
	 */
	public class ScriptRecordingController {
		
		private var scriptRecordingStates : ScriptRecordingStates;
		
		private var baseMarkerSubController : ScriptSampleMarkerSubController;
		private var stimMarkerSubController : ScriptSampleMarkerSubController;
		private var tipMarkerSubController : ScriptSampleMarkerSubController;
		
		private var lastRecordedFrame : Number = -1;
		
		public function ScriptRecordingController(_scriptRecordingStates : ScriptRecordingStates, _container : TPMovieClip) {
			scriptRecordingStates = _scriptRecordingStates;
			
			var markerContainer : TPMovieClip = TPMovieClip.create(_container, "scriptSampleMarkersContainer");
			
			baseMarkerSubController = new ScriptSampleMarkerSubController(ScriptSampleMarkerSubController.MARKER_TYPE_BASE, markerContainer);
			stimMarkerSubController = new ScriptSampleMarkerSubController(ScriptSampleMarkerSubController.MARKER_TYPE_STIM, markerContainer);
			tipMarkerSubController = new ScriptSampleMarkerSubController(ScriptSampleMarkerSubController.MARKER_TYPE_TIP, markerContainer);
			
			KeyboardInput.addShortcut(Shortcuts.recordFrame, this, onRecordFrameShortcut, []);
			KeyboardInput.addShortcut(Shortcuts.recordScene, this, onRecordSceneShortcut, []);
			
			ScriptTrackerStates.listen(this, onTrackerAttachedToStatesChange, [ScriptTrackerStates.baseTrackerAttachedTo, ScriptTrackerStates.stimTrackerAttachedTo, ScriptTrackerStates.tipTrackerAttachedTo]);
			AnimationPlaybackStates.currentScene.listen(this, onCurrentSceneStateChange);
		}
		
		public function update() : void {
			var activeChild : TPMovieClip = AnimationPlaybackStates.activeChild.value;
			var currentScene : SceneModel = AnimationPlaybackStates.currentScene.value;
			var currentFrame : Number = activeChild != null ? activeChild.currentFrame : -1;
			var script : SceneScriptModel = currentScene != null ? currentScene.getPlugins().getScript() : null;
			
			var isRecording : Boolean = ScriptRecordingStates.isRecording.value;
			
			if (isRecording == true && (currentScene.isForceStopped() == true || currentFrame < lastRecordedFrame)) {
				scriptRecordingStates._isRecording.setValue(false);
				isRecording = false;
			}
			
			if (isRecording == true) {
				recordCurrentFrame();
			}
			
			var basePoint : Point = null;
			var stimPoint : Point = null;
			var tipPoint : Point = null;
			
			if (script != null && script.isFrameWithinRecordedFrames(currentFrame) == true) {
				basePoint = script.getInterpolatedPosition(script.getBasePositions(), currentFrame);
				stimPoint = script.getInterpolatedPosition(script.getStimPositions(), currentFrame);
				tipPoint = script.getInterpolatedPosition(script.getTipPositions(), currentFrame);
			}
			
			scriptRecordingStates._interpolatedBasePoint.setValue(basePoint);
			scriptRecordingStates._interpolatedStimPoint.setValue(stimPoint);
			scriptRecordingStates._interpolatedTipPoint.setValue(tipPoint);
			
			baseMarkerSubController.update(script, currentFrame);
			stimMarkerSubController.update(script, currentFrame);
			tipMarkerSubController.update(script, currentFrame);
		}
		
		private function onTrackerAttachedToStatesChange() : void {
			var canRecordDependencies : Array = [ScriptTrackerStates.baseGlobalTrackerPoint.value, ScriptTrackerStates.stimGlobalTrackerPoint.value, ScriptTrackerStates.tipGlobalTrackerPoint.value];
			
			scriptRecordingStates._canRecord.setValue(ArrayUtil.includes(canRecordDependencies, null) == false);
		}
		
		private function onCurrentSceneStateChange() : void {
			scriptRecordingStates._isRecording.setValue(false);
		}
		
		private function onRecordFrameShortcut() : void {
			if (ScriptRecordingStates.canRecord.value == true) {
				recordCurrentFrame();
			}
		}
		
		private function onRecordSceneShortcut() : void {
			if (ScriptRecordingStates.canRecord.value == false) {
				return;
			}
			
			var currentScene : SceneModel = AnimationPlaybackStates.currentScene.value;
			
			var currentFrames : Vector.<Number> = currentScene.getCurrentFrames();
			var currentFramesArray : Array = [];
			for (var i : Number = 0; i < currentFrames.length; i++) {
				currentFramesArray.push(currentFrames[i]);
			}
			
			scriptRecordingStates._isRecording.setValue(true);
			scriptRecordingStates._recordingScene.setValue(currentScene);
			scriptRecordingStates._recordingStartFrames.setValue(currentFramesArray);
			
			recordCurrentFrame();
			
			currentScene.play();
		}
		
		private function recordCurrentFrame() : void {
			var currentScene : SceneModel = AnimationPlaybackStates.currentScene.value;
			var activeChild : TPMovieClip = AnimationPlaybackStates.activeChild.value;
			
			var base : Point = ScriptTrackerStates.baseGlobalTrackerPoint.value;
			var stim : Point = ScriptTrackerStates.stimGlobalTrackerPoint.value;
			var tip : Point = ScriptTrackerStates.tipGlobalTrackerPoint.value;
			
			var script : SceneScriptModel = currentScene.getPlugins().getScript();
			script.addPositions(activeChild.currentFrame, base, stim, tip);
			
			lastRecordedFrame = activeChild.currentFrame;
		}
	}
}