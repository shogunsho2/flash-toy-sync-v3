/**
 * ...
 * @author notSafeForDev
 */
class core.TranspiledGraphics{
	
	private var graphics : MovieClip;
	
	public function TranspiledGraphics(_graphics : MovieClip) {
		graphics = _graphics;
	}
	
	public function beginFill(_color : Number, _alpha : Number) : Void {
		graphics.beginFill(_color, _alpha == undefined ? 100 : _alpha * 100);
	}
	
	public function moveTo(_x : Number, _y : Number) : Void {
		graphics.moveTo(_x, _y);
	}
	
	public function lineTo(_x : Number, _y : Number) : Void {
		graphics.lineTo(_x, _y);
	}
	
	public function curveTo(_controlX : Number, _controlY : Number, _anchorX : Number, _anchorY : Number) : Void {
		graphics.curveTo(_controlX, _controlY, _anchorX, _anchorY);
	}
	
	public function drawRect(_x : Number, _y : Number, _width : Number, _height : Number) : Void {
		graphics.moveTo(_x, _y); // Top left
		graphics.lineTo(_x + _width, _y); // To top right
		graphics.lineTo(_x + _width, _y + _height); // To bottom right
		graphics.lineTo(_x, _y + _height); // To bottom left
		graphics.moveTo(_x, _y); // To top left
	}
	
	public function drawRoundedRect(_x : Number, _y : Number, _width : Number, _height : Number, _radius : Number) : Void {
		var right : Number = _x + _width;
		var bottom : Number = _y + _height;
		
		graphics.moveTo(_x + _radius, _y); // Top left
		graphics.lineTo(right - _radius, _y); // Top edge
		graphics.curveTo(right, _y, right, _y + _radius); // Top right corner 
		graphics.lineTo(right, _height - _radius); // Right edge
		graphics.curveTo(right, bottom, right - _radius, bottom); // Bottom right corner
		graphics.lineTo(_x + _radius, bottom); // Bottom edge
		graphics.curveTo(_x, bottom, _x, bottom - _radius); // Bottom left corner
		graphics.lineTo(_x, _y + _radius); // Left edge
		graphics.curveTo(_x, _y, _x + _radius, _y); // Top left corner
	}
	
	public function clear() : Void {
		graphics.clear();
	}
}