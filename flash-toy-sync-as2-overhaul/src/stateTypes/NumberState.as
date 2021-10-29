/**
 * This file have been transpiled from Actionscript 3.0 to 2.0, any changes made to this file will be overwritten once it is transpiled again
 */

import stateTypes.*
import core.JSON

/**
 * ...
 * @author notSafeForDev
 */
class stateTypes.NumberState extends State {
	
	public function NumberState(_defaultValue : Number) {
		super(_defaultValue, NumberStateReference);
	}
	
	public function getValue() : Number {
		return value;
	}
	
	public function setValue(_value : Number) : Void {
		value = _value;
	}
}