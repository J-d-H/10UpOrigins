package manipulatables;

import kha2d.Rectangle;
import kha.graphics2.Graphics;
import kha.Image;
import kha2d.Scene;
import kha2d.Sprite;
import manipulatables.ManipulatableItem.OrderType;

class UseableSprite extends Sprite implements ManipulatableItem
{
	public var isInInventory(default, null) : Bool = false;

	private var _inventoryName: String;

	public function new(name: String, image: Image, px : Float, py : Float, width: Int = 0, height: Int = 0, z: Int = 1, inventoryName: String = null) {
		super(image, width, height, z);
		x = px;
		y = py;
		accy = 0;
		this.name = name;
		_inventoryName = inventoryName;
	}

	private function get_name() : String {
		if (isInInventory && _inventoryName != null)
		{
			return _inventoryName;
		}
		return name;
	}

	private function get_nameTranslated(): String
	{
		return Localization.getText(get_name());
	}
	
	public var name(get, null) : String;
	public var nameTranslated(get, null): String;
	
	public function canBeManipulatedWith(item : ManipulatableItem) : Bool {
		throw "Not implemented.";
	}
	
	public function getOrder(selectedItem : ManipulatableItem) : OrderType {
		if (isInInventory || selectedItem != null)
			return OrderType.WontWork;
		else
			return OrderType.Take;
	}
	
	public function executeOrder(order : OrderType, item : ManipulatableItem) : Void {
		if (order == OrderType.Take) {
			take();
		} else if (order == OrderType.InventoryItem) {
			Inventory.select(this);
		}
	}
	
	public function take() {
		isInInventory = true;
		Scene.the.removeHero(this);
		Inventory.pick(this);
	}
	
	public function loose(px : Int, py : Int, destroy = false): Void
	{
		x = px;
		y = py;
		isInInventory = false;
		if (!destroy) Scene.the.addHero(this);
		Inventory.loose(this);
	}
	
	public function renderForInventory(g: Graphics, x : Int, y : Int, drawWidth : Int, drawHeight : Int) {
		if (image != null) {
			var w: kha.FastFloat = drawWidth;
			var h: kha.FastFloat = drawHeight;
			var originalAspect: kha.FastFloat = width/height;
			var scaledAspect: kha.FastFloat = drawWidth/drawHeight;
			if (originalAspect < scaledAspect) w *= originalAspect/scaledAspect;
			else h *= scaledAspect/originalAspect;
			g.drawScaledSubImage(image, Std.int(animation.get() * width) % image.width, Math.floor(animation.get() * width / image.width) * height, width, height, x + 0.5 * (drawWidth-w), y + 0.5 * (drawHeight-h), w, h);
		}
	}

	public override function collisionRect(): Rectangle
	{
		tempcollider.x = x - collider.width * scaleX + width;
		tempcollider.y = y - collider.height * scaleY + height;
		tempcollider.width  = collider.width * scaleX;
		tempcollider.height = collider.height * scaleY;
		return tempcollider;
	}

	override function update() {
		if (isInInventory) return;
		super.update();
	}
}
