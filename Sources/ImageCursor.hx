package;

import kha.Image;

class ImageCursor implements Cursor 
{
	private var _image: Image;
	private var _width: Int;
	private var _height: Int;
	private var _clickX: Int;
	private var _clickY: Int;


	public function new(img: Image, clickX: Int = 0, clickY: Int = 0, width: Int = 0, height: Int = 0) {
		_image = img;
		_width = width;
		_height = height;
		_clickX = clickX;
		_clickY = clickY;
		if (_width <= 0) _width = img.width;
		if (_height <= 0) _height = img.height;
	}

	public var clickX(get, never): Int;

	function get_clickX(): Int {
		return _clickX;
	}

	public var clickY(get, never): Int;

	function get_clickY(): Int {
		return _clickY;
	}
	
	public var width(get, never): Int;

	function get_width(): Int {
		return _width;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return _height;
	}
	
	public function render(g: kha.graphics2.Graphics, x: Int, y: Int): Void {
		g.drawScaledImage(_image, x - clickX, y - clickY, width, height);
	}
	
	public function update(x: Int, y: Int): Void {

	}
}
