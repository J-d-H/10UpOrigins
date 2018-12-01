package;

import kha.math.Random;
import sprites.*;
import hr.*;
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
	public static inline var width: Int = 1024;
	public static inline var height: Int = 768;
	public static inline var scaling: Int = 1;
	public static inline var tileWidth: Int = 32;
	public static inline var tileHeight: Int = 32;
	private static inline var scrollArea: Int = 32;
	private static inline var scrollSpeed: Int = 5;
	private static inline var maxEmployees: Int = 40;
	private static inline var employeeStartingAge: Float = 0;
	private static inline var employeeStartingTimeForCan: Float = 10;
	private static inline var employeeStartingProgressTo10UpPerCan: Float = 0;
	private static inline var agingSpeed: Float = 1 / 30;
	private static inline var timeToPause: Float = 20;
	private static inline var timeForPause: Float = 10;
	private static inline var healthPerFullPause: Float = 0.2;
	private static inline var healthChangeWhenWorking: Float = -(healthPerFullPause / timeToPause) * 0.5; // Lose one half Pause
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
	private static var employeeWorking: Array<Bool> = new Array<Bool>();
	private static var employeeAge: Array<Float> = new Array<Float>();
	private static var employeeTimeForCan: Array<Float> = new Array<Float>();
	private static var employeeProgressTo10UpPerCan: Array<Float> = new Array<Float>();
	private static var employeeProgressToCan: Array<Float> = new Array<Float>();
	private static var employeeProgressTo10Up: Array<Float> = new Array<Float>();
	private static var employeeTimeToNextPause: Array<Float> = new Array<Float>();
	private static var employeeTimeForCurrentPause: Array<Float> = new Array<Float>();
	private static var employeeHealth: Array<Float> = new Array<Float>();

	private static function onMouseDown(button: Int, x: Int, y: Int): Void {
		Staff.AddGuy();
	}

	private static function onMouseUp(button: Int, x: Int, y: Int): Void {
		
	}

	private static function onMouseMove(x: Int, y: Int, moveX: Int, moveY: Int): Void {
		mousePosX = x;
		mousePosY = y;
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
		
		for (i in 0...maxEmployees)
		{
			employeeWorking.push(true);
			employeeAge.push(employeeStartingAge);
			employeeTimeForCan.push(employeeStartingTimeForCan);
			employeeProgressTo10UpPerCan.push(employeeStartingProgressTo10UpPerCan);
			employeeProgressToCan.push(0);
			employeeProgressTo10Up.push(0);
			employeeTimeToNextPause.push(timeToPause);
			employeeTimeForCurrentPause.push(0);
			employeeHealth.push(1);
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
		
		for (i in 0...maxEmployees)
		{
			// Employee aging and stats up-/ downgrades
			employeeAge[i] += deltaTime * agingSpeed;
			// (0, 10), (20, 3), (40, 10)
			employeeTimeForCan[i] = 10 - 0.7 * employeeAge[i] + 0.0175 * employeeAge[i] * employeeAge[i];
			// (0, 0), (20, 0.25), (40, 0)
			employeeProgressTo10UpPerCan[i] = 0 + 0.025 * employeeAge[i] - 0.00625 * employeeAge[i] * employeeAge[i];

			// Pause progress
			if (!employeeWorking[i])
			{
				employeeHealth[i] += (healthPerFullPause / timeForPause) * deltaTime;
				// No overheal plz, we are not Wolfenstein
				if (employeeHealth[i] > 1)
					employeeHealth[i] = 1;

				employeeTimeForCurrentPause[i] += deltaTime;
				if (employeeTimeForCurrentPause[i] >= timeForPause)
				{
					employeeTimeForCurrentPause[i] -= timeForPause;
					employeeWorking[i] = true;
				}
			}
			// Employee progress
			else if (employeeWorking[i])
			{
				employeeHealth[i] += healthChangeWhenWorking * deltaTime;
				if (employeeHealth[i] <= 0)
				{
					// Hire new employe
					employeeWorking[i] = true;
					employeeAge[i] = employeeStartingAge;
					employeeTimeForCan[i] = employeeStartingTimeForCan;
					employeeProgressTo10UpPerCan[i] = employeeStartingProgressTo10UpPerCan;
					employeeProgressToCan[i] = 0;
					employeeProgressTo10Up[i] = 0;
					employeeTimeToNextPause[i] = timeToPause;
					employeeTimeForCurrentPause[i] = 0;
					employeeHealth[i] = 1;
				}
				else
				{
					employeeProgressToCan[i] += deltaTime;
					employeeTimeToNextPause[i] -= deltaTime;
					// Needs pause
					if (employeeTimeToNextPause[i] <= 0)
					{
						employeeTimeToNextPause[i] += timeToPause;
						employeeWorking[i] = false;
					}
					// Can finished
					else if (employeeProgressToCan[i] >= employeeTimeForCan[i])
					{
						if (employeeProgressTo10Up[i] >= 1)
						{
							// 10up can
							employeeProgressTo10Up[i] -= 1;
							++cans10up;
						}
						else
						{
							// Normal can
							employeeProgressTo10Up[i] += employeeProgressTo10UpPerCan[i];
							++cansNormal;
						}
						employeeProgressToCan[i] -= employeeTimeForCan[i];
					}
				}
			}
		}

		if (mousePosX < scrollArea)
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
		g.drawString(Std.string(employeeAge[0]), 10, 10);
		g.drawString(Std.string(employeeTimeForCan[0]), 10, 30);
		g.drawString(Std.string(employeeProgressTo10UpPerCan[0]), 10, 50);
		
		g.drawString(Std.string(employeeProgressToCan[0]), 10, 70);
		g.drawString(Std.string(employeeProgressTo10Up[0]), 10, 90);
		g.drawString(Std.string(employeeHealth[0]), 10, 110);

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
