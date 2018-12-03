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
	
	public function new(name: String, image: Image, px : Float, py : Float, width: Int = 0, height: Int = 0, z: Int = 1) {
		super(image, width, height, z);
		x = px;
		y = py;
		accy = 0;
		this.name = name;
	}
	
	private function get_name() : String {
		return name;
	}
	
	public var name(get, null) : String;
	
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
			var scaleX: kha.FastFloat = width/drawWidth;
			var sceleY: kha.FastFloat = height/drawHeight;
			if (scaleX < scaleY) w *= scaleX;
			else h *= scaleY;
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
