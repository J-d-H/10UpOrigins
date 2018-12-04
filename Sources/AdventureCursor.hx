package;

import hr.RandomGuy;
import hr.Workplace;
import kha.input.Mouse;
import manipulatables.ManipulatableItem;
//import kha.AnimatedImageCursor;
import kha2d.Animation;
import kha.Assets;
import kha.Color;
import kha.Font;
import kha.FontStyle;
import kha.graphics2.Graphics;
//import kha.ImageCursor;
import kha2d.Scene;
import kha2d.Sprite;

class AdventureCursor implements Cursor {
	private var font: Font;
	private var fontSize: Int;
	private var toolTip : String;
	private var toolTipY : Int;
	
	public var width(get,never): Int;
	public var height(get, never): Int;
	public var clickX(get,never): Int;
	public var clickY(get, never): Int;
	
	private function get_clickX() : Int {
		if (currentCursor != null)
			return currentCursor.clickX;
		else
			return 3;
	}
	private function get_clickY() : Int {
		if (currentCursor != null)
			return currentCursor.clickY;
		else
			return 3;
	}
	private function get_width() : Int {
		if (currentCursor != null)
			return currentCursor.width;
		else
			return 16;
	}
	private function get_height() : Int {
		if (currentCursor != null)
			return currentCursor.height;
		else
			return 16;
	}
	
	var currentCursor : Cursor;
	var cursors : Map<OrderType, Cursor> = new Map();
	
	public var hoveredType : OrderType = Nothing;
	public var hoveredObject : ManipulatableItem = null;
	
	public var forcedTooltip : String = null;
	
	public function new() {
		cursors[OrderType.Take] = new ImageCursor(Assets.images.handcursor, 6, 9);
		cursors[OrderType.InventoryItem] = new ImageCursor(Assets.images.handcursor, 6, 9);
		cursors[OrderType.WontWork] = new ImageCursor(Assets.images.wontwork, -2, -2); // TODO: cursor
		currentCursor = null;
		Mouse.get().showSystemCursor();
		font = Assets.fonts.LiberationSans_Regular;
		fontSize = 18;
	}
	
	public function render(g: Graphics, x: Int, y: Int): Void {
		var inventoryItem = Inventory.getSelectedItem();
		if (inventoryItem != null && y < Main.height) {
			g.color = Color.White;
			g.pushOpacity(0.7);
			inventoryItem.renderForInventory(g, x - 32, y - 32, 64, 64);
			g.popOpacity();
		}

		if (currentCursor != null) {
			g.color = Color.White;
			currentCursor.render(g, x, y);
		}
		
		if (forcedTooltip != null) {
			drawTooltip(g, forcedTooltip, x, toolTipY);
		} else if (toolTip != null) {
			drawTooltip(g, toolTip, x, toolTipY);
		}
	}
	
	private function drawTooltip(g: Graphics, tip: String, x: Int, y: Int): Void {
		g.font = font;
		g.fontSize = fontSize;
		g.color = Color.Black;
		g.fillRect(x - 2, y - 2, font.width(fontSize, tip) + 4, font.height(fontSize) + 4);
		g.color = Color.White;
		g.drawString(tip, x, y);
	}

	public function onMouseDown(button: Int, x : Int, y : Int): Void
	{
	}

	public function onMouseUp(button: Int, x : Int, y : Int): Void
	{
		if (button > 0)
		{
			// deselect
			Inventory.select(Inventory.getSelectedItem());
			update(x, y);
		}
		else
		{
			if (hoveredObject != null)
			{
				hoveredObject.executeOrder(hoveredType, Inventory.getSelectedItem());
			}
		}
	}
	
	public function update(x : Int, y : Int): Void
	{
		var toolTipTop : Bool = false;
		var inventoryItem = Inventory.getSelectedItem();
		hoveredType = OrderType.Nothing;
		hoveredObject = Inventory.getItemBelowPoint(x, y);
		if (hoveredObject != null) {
			toolTipTop = true;
			toolTip = hoveredObject.nameTranslated;
			hoveredType = OrderType.InventoryItem;
		} else if (y >= Inventory.y) {
			toolTipTop = true;
			toolTip = null;
		} else {
			for (obj in Scene.the.getSpritesBelowPoint(x + Scene.the.screenOffsetX, y + Scene.the.screenOffsetY)) {
				if (Std.is(obj, ManipulatableItem)) {
					hoveredObject = cast obj;
					hoveredType = hoveredObject.getOrder(inventoryItem);
					if (hoveredType == OrderType.Nothing) {
						hoveredObject = null;
						toolTip = null;
					} else {
						if (hoveredType == OrderType.ToolTip) {
							toolTip = Localization.getText(hoveredObject.name);
						} else if (inventoryItem != null) {
							toolTip = Localization.getText(inventoryItem.name + "_" + hoveredType);
						} else {
							if (Std.is(hoveredObject, RandomGuy) && hoveredType == Take)
							{
								toolTip = Localization.getText(hoveredType + "_Worker", [hoveredObject.name]);
							}
							else 
							{
								toolTip = Localization.getText(hoveredType + "_" + hoveredObject.name);
							}
						}
					}
					break;
				}
			}
			if (hoveredObject == null && inventoryItem != null)
			{
				hoveredType = inventoryItem.getOrder(null);
				toolTip = Localization.getText(inventoryItem.name + "_" + hoveredType);
			}
		}
		
		if (cursors.exists(hoveredType)) {
			currentCursor = cursors[hoveredType];
			Mouse.get().hideSystemCursor();
			currentCursor.update(x, y);
		} else if (inventoryItem != null) {
			currentCursor = null;
			Mouse.get().hideSystemCursor();
		} else {
			currentCursor = null;
			Mouse.get().showSystemCursor();
		}

		if (toolTipTop) {
			toolTipY = y - clickY - 16;
		} else {
			toolTipY = y - clickY + height;
		}
	}
}
