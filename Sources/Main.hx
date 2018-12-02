package;

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

typedef StringPair = { key : String, value : String }

class Main {
	public static inline var width: Int = 1024;
	public static inline var height: Int = 768;
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

	private static var mousePosX: Int = Std.int(width / 2);
	private static var mousePosY: Int = Std.int(height / 2);
	private static var money: Int = 0;
	private static var cansNormal: Int = 0;
	private static var cans10up: Int = 0;

	private static function onMouseDown(button: Int, x: Int, y: Int): Void {
		
	}

	private static function onMouseUp(button: Int, x: Int, y: Int): Void {
		var worldX = x + Scene.the.screenOffsetX;
		var worldY = y + Scene.the.screenOffsetY;
		var guysBelowPoint = Scene.the.getHeroesBelowPoint(x, y);
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
		mousePosX = x;
		mousePosY = y;
		
		var guysBelowPoint = Scene.the.getHeroesBelowPoint(x, y);
		if (guysBelowPoint.length == 1) {
			
		}
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

		if (mousePosX  < scrollArea)
			Scene.the.camx -= Std.int(scrollSpeed * ((scrollArea - mousePosX) / scrollArea));
		if (mousePosX > width - scrollArea)
			Scene.the.camx += Std.int(scrollSpeed * ((scrollArea - (width - mousePosX)) / scrollArea));
		Scene.the.camx = Std.int(Math.max(Scene.the.camx, Std.int(width / 2)));
		Scene.the.camx = Std.int(Math.min(Scene.the.camx, map.length * tileWidth - Std.int(width / 2)));

		if (mousePosY < scrollArea)
			Scene.the.camy -= Std.int(scrollSpeed * ((scrollArea - mousePosY) / scrollArea));
		if (mousePosY > height - scrollArea)
			Scene.the.camy += Std.int(scrollSpeed * ((scrollArea - (height - mousePosY)) / scrollArea));
		Scene.the.camy = Std.int(Math.max(Scene.the.camy, Std.int(height / 2)));
		Scene.the.camy = Std.int(Math.min(Scene.the.camy, map[0].length * tileHeight - Std.int(height / 2)));

		Scene.the.update();
	}

	static function render(framebuffer: Framebuffer): Void {
		var g = backbuffer.g2;
		g.begin();
		
		Scene.the.render(g);
		
		g.transformation = FastMatrix3.identity();
		
		var hudDisplays : Array<StringPair> = [
			{ key: "Money: ", value: Std.string(money) },
			{ key: "Cans: ", value: Std.string(cansNormal) },
			{ key: "10ups: ", value: Std.string(cans10up) }
		];

		g.font = font;
		g.fontSize = 24;
		var stringWidth: Float = 0;
		for (i in 0...hudDisplays.length)
			stringWidth = Math.max(g.font.width(g.fontSize, hudDisplays[i].key + hudDisplays[i].value), stringWidth);
		var stringHeight: Float = g.font.height(g.fontSize);

		var pad: Int = 5;
		var spac: Int = 5;
		g.color = Color.Black;
		g.fillRect(width - (stringWidth + 2 * pad + spac), spac, stringWidth + 2 * pad, stringHeight * 3 + pad * 4);
		g.color = Color.White;
		var yOffset: Float = pad + spac;
		for (i in 0...hudDisplays.length)
		{
			g.drawString(hudDisplays[i].key, width - (stringWidth + pad + spac), yOffset);
			g.drawString(hudDisplays[i].value, width - (g.font.width(g.fontSize, hudDisplays[i].value) + pad + spac), yOffset);
			yOffset += pad + stringHeight;
		}

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

	public static function main() {
		System.start({title: "10Up Origins", width: width, height: height}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				init();
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
			});
		});
	}
}
