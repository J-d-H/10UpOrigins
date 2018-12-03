package;

import kha2d.Animation;
import kha.Color;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import manipulatables.UseableSprite;

class Inventory {
	public static var y : Int;
	public static var itemWidth = 32 * 2;
	public static var spacing = 5;
	public static var itemHeight = 32 * 2;
	static var items : Array<UseableSprite> = new Array();
	static var selected : Int = -1;
	static var offset : Int = 0;
	
	public static var height(get, never): Int;
	@:noCompletion
	private static function get_height(): Int
	{
		return itemHeight + 2 * spacing;
	}

	public static function init() {
		items = new Array();
		selected = -1;
		y = Main.height - height;
	}
	
	public static function isEmpty() : Bool {
		return items.length == 0;
	}
	
	@:access(manipulatables.UseableSprite.isInInventory)
	public static function pick(item : UseableSprite) {
		items.push(item);
		item.isInInventory = true;
	}
	
	@:access(manipulatables.UseableSprite.isInInventory)
	public static function loose(item : UseableSprite) {
		items.remove(item);
		item.isInInventory = false;
	}
	
	public static function select(item : UseableSprite) {
		var s = items.indexOf(item);
		if (s == selected) {
			selected = -1;
		} else {
			selected = s;
		}
	}
	
	public static function getSelectedItem() : UseableSprite {
		return (selected >= 0 && selected < items.length) ? items[selected] : null;
	}
	
	public static function getItemBelowPoint(px : Int, py : Int) : UseableSprite {
		var pos : Int = -1;
		if ( y <= py && py <= y + spacing + itemHeight ) {
			px -= spacing;
			while (px >= 0) {
				pos += 1;
				px -= itemWidth;
				if (px < 0) {
					if (pos >= 0 && pos < items.length) {
						return items[pos];
					} else {
						return null;
					}
				}
				px -= 2 * spacing;
			}
			pos = -1;
		}
		return null;
	}
	
	public static function paint(g: Graphics) {
		var itemX = spacing;
		var itemY = y + spacing;
		g.color = Color.Black;
		g.fillRect(0, y, Main.width, height);
		g.color = Color.White;
		for (i in offset...items.length) {
			g.color = Color.White;
			items[i].renderForInventory(g, itemX, itemY, itemWidth, itemHeight);
			if (i == selected) {
				g.color = Color.fromBytes(255, 0, 255);
				var top = itemY - 1;
				var bottom = itemY + itemHeight + 1;
				var left = itemX;
				var right = itemX + itemWidth + 1;
				g.drawLine( left, top, right, top, 3);
				g.drawLine( left, top, left, bottom, 3);
				g.drawLine( left, bottom, right, bottom, 3);
				g.drawLine( right, top, right, bottom, 3);
			}
			itemX += itemWidth + 2 * spacing;
		}
	}
}
