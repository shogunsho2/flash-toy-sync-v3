import core.ArrayUtil;
import core.FunctionUtil;
import core.stateTypes.ArrayState;
import core.stateTypes.ArrayStateReference;
import core.stateTypes.BooleanState;
import core.stateTypes.BooleanStateReference;
import core.stateTypes.DisplayObjectState;
import core.stateTypes.DisplayObjectStateReference;
import core.stateTypes.MovieClipState;
import core.stateTypes.MovieClipStateReference;
import core.stateTypes.NumberState;
import core.stateTypes.NumberStateReference;
import core.stateTypes.PointState;
import core.stateTypes.PointStateReference;
import core.stateTypes.StringState;
import core.stateTypes.StringStateReference;
import flash.geom.Point;
/**
 * ...
 * @author notSafeForDev
 */
class core.StateManager {
	
	public var listeners : Array;
	public var states : Array;
	public var references : Array;
	public var lastNotificationStateValues : Array;
	
	public function StateManager() {
		listeners = [];
		states = [];
		references = [];
		lastNotificationStateValues = [];
		
		for (var i : Number = 0; i < states.length; i++) {
			lastNotificationStateValues.push(undefined);
		}
	}
	
	public function addNumberState(_default : Number) : Object {
		_default = _default != undefined ? _default : 0;
		var state : NumberState = new NumberState(_default);
		var reference : NumberStateReference = new NumberStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function addBooleanState(_default : Boolean) : Object {
		var state : BooleanState = new BooleanState(_default);
		var reference : BooleanStateReference = new BooleanStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function addPointState(_default : Point) : Object {
		var state : PointState = new PointState(_default);
		var reference : PointStateReference = new PointStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function addDisplayObjectState(_default : MovieClip) : Object {
		var state : DisplayObjectState = new DisplayObjectState(_default);
		var reference : DisplayObjectStateReference = new DisplayObjectStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function addMovieClipState(_default : MovieClip) : Object {
		var state : MovieClipState = new MovieClipState(_default);
		var reference : MovieClipStateReference = new MovieClipStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function addArrayState(_default : Array) : Object {
		var state : ArrayState = new ArrayState(_default);
		var reference : ArrayStateReference = new ArrayStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function addStringState(_default : String) : Object {
		var state : StringState = new StringState(_default);
		var reference : StringStateReference = new StringStateReference(state);
		states.push(state);
		references.push(reference);
		return {state: state, reference: reference};
	}
	
	public function listen(_scope, _handler : Function, _statesReferences : Array) : Object {
		var handler : Function = FunctionUtil.bind(_scope, _handler);
		var listener : Object = {handler: handler, stateReferences: _statesReferences}
		listeners.push(listener);
		return listener;
	}
	
	public function stopListening(_listener : Object) : Void {
		var index : Number = ArrayUtil.indexOf(listeners, _listener);
		if (index >= 0) {
			listeners.splice(index, 1);
		}
	}
	
	public function notifyListeners() : Void {
		var i : Number = 0;
		var newStateValues : Array = getStateValues();
		var updatedStatesReferences : Array = [];
		
		for (i = 0; i < references.length; i++) {
			if (newStateValues[i] != lastNotificationStateValues[i]) {
				updatedStatesReferences.push(references[i]);
			}
		}
		
		lastNotificationStateValues = newStateValues;
		
		if (updatedStatesReferences.length > 0) {
			for (i = 0; i < listeners.length; i++) {
				notifyListener(listeners[i], updatedStatesReferences);
			}
		}
	}
	
	private function notifyListener(_listener : Object, _updatedStatesReferences : Array) : Void {
		var shouldNotify : Boolean = _listener.stateReferences.length == 0;
		for (var i : Number = 0; i < _listener.stateReferences.length; i++) {
			if (ArrayUtil.indexOf(_updatedStatesReferences, _listener.stateReferences[i]) >= 0) {
				shouldNotify = true;
				break;
			}
		}
		
		if (shouldNotify == false) {
			return;
		}
		
		_listener.handler.apply(_listener.scope);
	}
	
	private function getStateValues() : Array {
		var values : Array = [];
		for (var i : Number = 0; i < states.length; i++) {
			values.push(states[i].getState());
		}
		return values;
	}
}