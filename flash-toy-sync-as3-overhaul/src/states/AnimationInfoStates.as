package states {
	
	import components.StateManager;
	import stateTypes.BooleanState;
	import stateTypes.BooleanStateReference;
	import stateTypes.MovieClipTranspilerState;
	import stateTypes.MovieClipTranspilerStateReference;
	import stateTypes.StringState;
	import stateTypes.StringStateReference;
	
	/**
	 * ...
	 * @author notSafeForDev
	 */
	public class AnimationInfoStates {
		
		private static var stateManager : StateManager;
		
		public var _movieClip : MovieClipTranspilerState;
		public static var movieClip : MovieClipTranspilerStateReference;
		
		public var _name : StringState;
		public static var name : StringStateReference;
		
		public var _isLoaded : BooleanState;
		public static var isLoaded : BooleanStateReference;
		
		public function AnimationInfoStates(_stateManager : StateManager) {
			if (stateManager != null) {
				throw new Error("Unable to create new instance, there can only be one instance");
			}
			
			_movieClip = _stateManager.addState(MovieClipTranspilerState, null);
			movieClip = _movieClip.reference;
			
			_name = _stateManager.addState(StringState, "");
			name = _name.reference;
			
			_isLoaded = _stateManager.addState(BooleanState, false);
			isLoaded = _isLoaded.reference;
			
			stateManager = _stateManager;
		}
		
		public static function listen(_scope : * , _handler : Function, _stateReferences : Array) : void {
			stateManager.listen(_scope, _handler, _stateReferences);
		}
	}
}