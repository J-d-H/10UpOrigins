package;

import kha.Canvas;
import kha.Window;
import kha.math.Random;
import sprites.*;
import hr.Staff;
import kha.math.Vector2;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import kha.Color;
import kha.Image;
import kha.Font;
import kha.Scaler;
import kha.math.FastMatrix3;
import kha.input.Mouse;
import kha2d.Scene;
import kha2d.Tilemap;
import kha2d.Tile;

class Main {
	public static var width(default, null): Int = 1024;
	public static var height(default, null): Int = 768;
	public static inline var scaling: Int = 1;
	public static inline var tileWidth: Int = 32;
	public static inline var tileHeight: Int = 32;
	private static inline var scrollArea: Int = 32;
	private static inline var scrollSpeed: Int = 5;
	private static var tilemap: Tilemap;
	private static var tileColissions: Array<Tile>;
	private static var map: Array<Array<Int>>;
	private static var backbuffer: Image;
	private static var font: Font;
    private static var lastTime = 0.0;
	
	public static var Player(default, null) = "Boss";
	public static var npcSpawns : Array<Vector2> = new Array<Vector2>();
	public static var interactiveSprites: Array<InteractiveSprite>;

	private static var money: Int = 0;
	private static var cansNormal: Int = 0;
	private static var cans10up: Int = 0;

	public static var lastWindowWidth: Int;
	public static var lastWindowHeigth: Int;
	public static var mouseWindowPosX(default, null): Int;
	public static var mouseWindowPosY(default, null): Int;
	public static var mouseScenePosX(default, null): Int;
	public static var mouseScenePosY(default, null): Int;
	private static var window: Window;
	private static var windowScale: Float;
	private static var windowOffsetX: Int;
	private static var windowOffsetY: Int;
	private static var scene: Scene;

	private static function updateMouse(x: Int, y: Int): Void
	{
		var updatedWindow = false;
		if (lastWindowWidth != window.width || lastWindowHeigth != window.height)
		{
			updatedWindow = true;
			lastWindowWidth = window.width;
			lastWindowHeigth = window.height;
			width = Std.int(Math.min(Scene.the.getWidth(), window.width));
			height = Std.int(Math.min(Scene.the.getHeight(), window.height));
			// TODO: fix backbuffer
			var scaleX = width/window.width;
			var scaleY = height/window.height;
			if (scaleX < 1)
			{
				windowScale = Math.max(scaleX, scaleY);
			}
			else
			{
				windowScale = Math.min(scaleX, scaleY);
			}
			windowOffsetX = Std.int((window.width - width/windowScale) / 2);
			windowOffsetY = Std.int((window.height - height/windowScale) / 2);

			trace("  Gamescreen: " + width + "/" + height);
			trace("       Scene: " + Scene.the.getWidth() + "/" + Scene.the.getHeight());
			trace("      Window: " + window.width + "/" + window.height);
			trace("  backbuffer: " + backbuffer.width + "/" + backbuffer.height);
			trace(" windowScale: " + windowScale);
			trace("windowOffset: " + windowOffsetX + "/" + windowOffsetY);
		}
		
		mouseWindowPosX = x;
		mouseWindowPosY = y;

		mouseScenePosX = Std.int((x - windowOffsetX) * windowScale) + Scene.the.screenOffsetX;
		mouseScenePosY = Std.int((y - windowOffsetY) * windowScale) + Scene.the.screenOffsetY;
	}

	private static function onMouseDown(button: Int, x: Int, y: Int): Void {
		
	}

	private static function onMouseUp(button: Int, x: Int, y: Int): Void {
		updateMouse(x, y);
		
		trace("window: " + x + "/" + y);
		trace("scene: " + mouseScenePosX + "/" + mouseScenePosY);

		var guysBelowPoint = Scene.the.getHeroesBelowPoint(mouseScenePosX, mouseScenePosY);
		for (guy in guysBelowPoint)
		{
			if (Std.is(guy, RandomGuy))
			{
				var randomGuy : RandomGuy = cast guy;
				randomGuy.executeOrder(WorkHarder);
			}
		}
	}

	private static function onMouseMove(x: Int, y: Int, moveX: Int, moveY: Int): Void {
		updateMouse(x, y);
	}

	private static function onMouseWheel(delta: Int): Void {
		
	}

	private static function init(): Void {
		if (Mouse.get() != null) Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);

		Random.init(Std.int(System.time * 100));
		lastTime = Scheduler.time();
		font = Assets.fonts.LiberationSans_Regular;
		backbuffer = Image.createRenderTarget(width * scaling, height * scaling);
		initLevel();
		scene = Scene.the;
		Scene.the.camx = Std.int(width / 2);
		
		for (i in 0...npcSpawns.length)
		{
			Staff.addGuy();
		}
	}
	
	public static function initLevel(): Void {
		tileColissions = new Array<Tile>();
		for (i in 0...1024) {
			tileColissions.push(new Tile(i, isCollidable(i)));
		}
		var blob = Assets.blobs.factory_map;
		var fileIndex = 0;
		var levelWidth: Int = blob.readS32BE(fileIndex); fileIndex += 4;
		var levelHeight: Int = blob.readS32BE(fileIndex); fileIndex += 4;
		map = new Array<Array<Int>>();
		for (x in 0...levelWidth) {
			map.push(new Array<Int>());
			for (y in 0...levelHeight) {
				map[x].push(blob.readS32BE(fileIndex)); fileIndex += 4;
			}
		}
		var spriteCount = blob.readS32BE(fileIndex); fileIndex += 4;
		var sprites = new Array<Int>();
		for (i in 0...spriteCount) {
			sprites.push(blob.readS32BE(fileIndex)); fileIndex += 4;
			sprites.push(blob.readS32BE(fileIndex)); fileIndex += 4;
			sprites.push(blob.readS32BE(fileIndex)); fileIndex += 4;
		}
		
		Scene.the.setSize(width * scaling, height * scaling);
		Scene.the.clear();
		Scene.the.setBackgroundColor(Color.fromBytes(255, 255, 255));
		var tilemap = new Tilemap(Assets.images.tileset, tileWidth, tileHeight, map, tileColissions);
		Scene.the.setColissionMap(tilemap);
		Scene.the.addBackgroundTilemap(tilemap, 1);
		
		var computers : Array<Vector2> = new Array<Vector2>();
		var bookshelves : Array<Vector2> = new Array<Vector2>();
		var elevatorPositions : Array<Vector2> = new Array<Vector2>();
		npcSpawns = new Array<Vector2>();
		interactiveSprites = new Array();
		for (i in 0...spriteCount) {
			var sprite : kha2d.Sprite = null;
			switch (sprites[i * 3]) {
			case 0:
				//agentSpawn = new Vector2(sprites[i * 3 + 1], sprites[i * 3 + 2]);
			case 1:
				//computers.push(new Vector2(sprites[i * 3 + 1], sprites[i * 3 + 2]));
			case 2:
				elevatorPositions.push(new Vector2(sprites[i * 3 + 1], sprites[i * 3 + 2]));
			case 3:
				var door : Door = new Door(sprites[i * 3 + 1], sprites[i * 3 + 2]);
				Scene.the.addOther(door);
				interactiveSprites.push(door);
			case 4:
				bookshelves.push(new Vector2(sprites[i * 3 + 1], sprites[i * 3 + 2]));
			case 5:
				npcSpawns.push(new Vector2(sprites[i * 3 + 1], sprites[i * 3 + 2]));
			case 6:
				//npcSpawns.push(new Vector2(sprites[i * 3 + 1], sprites[i * 3 + 2]));
				var coffee : Coffee = new Coffee(sprites[i * 3 + 1], sprites[i * 3 + 2]);
				Scene.the.addOther(coffee);
				interactiveSprites.push(coffee);
			case 7:
				var wooddoor : Wooddoor = new Wooddoor(sprites[i * 3 + 1], sprites[i * 3 + 2]);
				Scene.the.addOther(wooddoor);
			}
		}
	}
	
	private static function isCollidable(tilenumber: Int): Bool {
		switch (tilenumber) {
		case 464: return true;
		case 465: return true;
		case 466: return true;
		case 467: return true;
		case 468: return true;
		case 469: return true;
		case 480: return true;
		case 481: return true;
		case 482: return true;
		case 483: return true;
		case 484: return true;
		case 485: return true;
		case 496: return true;
		case 501: return true;
		case 512: return true;
		default:
			return false;
		}
	}

	static function update(): Void {
		var deltaTime = Scheduler.time() - lastTime;
		lastTime = Scheduler.time();
		
		Staff.update(deltaTime);


		if (mouseWindowPosX  < scrollArea)
			Scene.the.camx -= Std.int(scrollSpeed * ((scrollArea - mouseWindowPosX) / scrollArea));
		if (mouseWindowPosY > window.width - scrollArea)
			Scene.the.camx += Std.int(scrollSpeed * ((scrollArea - (window.width - mouseWindowPosX)) / scrollArea));
		Scene.the.camx = Std.int(Math.max(Scene.the.camx, Std.int(width / 2)));
		Scene.the.camx = Std.int(Math.min(Scene.the.camx, map.length * tileWidth - Std.int(width / 2)));

		if (mouseWindowPosY < scrollArea)
			Scene.the.camy -= Std.int(scrollSpeed * ((scrollArea - mouseWindowPosY) / scrollArea));
		if (mouseWindowPosY > window.height - scrollArea)
			Scene.the.camy += Std.int(scrollSpeed * ((scrollArea - (height - mouseWindowPosY)) / scrollArea));
		Scene.the.camy = Std.int(Math.max(Scene.the.camy, Std.int(height / 2)));
		Scene.the.camy = Std.int(Math.min(Scene.the.camy, map[0].length * tileHeight - Std.int(height / 2)));

		Scene.the.update();
	}

	static function render(framebuffer: Framebuffer): Void {
		var g = backbuffer.g2;
		g.begin();
		
		Scene.the.render(g);
		
		g.transformation = FastMatrix3.identity();

		g.color = Color.White;
		g.font = font;
		g.fontSize = 24;
		var k0: String = "Money: ";
		var k1: String = "Cans: ";
		var k2: String = "10ups: ";
		var v0: String = Std.string(money);
		var v1: String = Std.string(cansNormal);
		var v2: String = Std.string(cans10up);
		var s0: String = k0 + v0;
		var s1: String = k1 + v1;
		var s2: String = k2 + v2;
		var stringWidth: Float = Math.max(Math.max(font.width(g.fontSize, s0), font.width(g.fontSize, s1)), font.width(g.fontSize, s2));
		var stringHeight: Float = font.height(g.fontSize);

		var pad: Int = 5;
		var spac: Int = 5;
		g.color = Color.Black;
		g.fillRect(width - (stringWidth + 2 * pad + spac), spac, stringWidth + 2 * pad, stringHeight * 3 + pad * 4);
		g.color = Color.White;
		var yOffset: Float = pad + spac;
		g.drawString(k0, width - (stringWidth + pad + spac), yOffset);
		g.drawString(v0, width - (font.width(g.fontSize, v0) + pad + spac), yOffset);
		yOffset += pad + stringHeight;
		g.drawString(k1, width - (stringWidth + pad + spac), yOffset);
		g.drawString(v1, width - (font.width(g.fontSize, v1) + pad + spac), yOffset);
		yOffset += pad + stringHeight;
		g.drawString(k2, width - (stringWidth + pad + spac), yOffset);
		g.drawString(v2, width - (font.width(g.fontSize, v2) + pad + spac), yOffset);

		// Debug only
		#if debug
		g.drawString("Age: " + Std.string(Staff.employeeAge[0]), 10, 10);
		g.drawString("TfC: " + Std.string(Staff.employeeTimeForCan[0]), 10, 30);
		g.drawString("PpC: " + Std.string(Staff.employeeProgressTo10UpPerCan[0]), 10, 50);
		
		g.drawString("PtC: " + Std.string(Staff.employeeProgressToCan[0]), 10, 70);
		g.drawString("P10: " + Std.string(Staff.employeeProgressTo10Up[0]), 10, 90);
		g.drawString("Hth: " + Std.string(Staff.employeeHealth[0]), 10, 110);
		#end

		g.end();
		
		framebuffer.g2.begin();
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	public static function onResize(width: Int, height: Int): Void
	{
		trace("RESIZE: " + width + "/" + height);
	}

	public static function main() {
		System.start({title: "10Up Origins", width: width, height: height}, function (window) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				init();
				Main.window = window;
				window.notifyOnResize(function (width, height) { onResize(width, height); });
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
			});
		});
	}
}
