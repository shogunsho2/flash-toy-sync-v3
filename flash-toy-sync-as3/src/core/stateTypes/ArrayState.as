package core.stateTypes {
	
	/**
	 * ...
	 * @author notSafeForDev
	 */
	public class ArrayState {
		
		private var value : Array;
		private var previousValue : Array;
		private var listeners : Array = [];
		
		public function ArrayState(_default : Array = null) {
			previousValue = _default;
			value = _default;
		}
		
		public function listen(_scope : *, _handler : Function) : Object {
			var listener : Object = {handler: _handler, scope : _scope}
			listeners.push(listener);
			return listener;
		}
		
		public function setState(_value : Array) : void {
			if (_value == value) {
				return;
			}
			
			for (var i : Number = 0; i < listeners.length; i++) {
				this.listeners[i].handler(_value);
				if (this.listeners[i].once == true) {
					this.listeners.splice(i, 1);
					i--;
				}
			}
			previousValue = value;
			value = _value;
		}
		
		public function getState() : Array {
			return value != null ? value.slice() : null;
		}
		
		public function getPreviousState() : Array {
			return previousValue.slice();
		}
	}
}