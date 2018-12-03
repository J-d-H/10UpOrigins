package;

import kha.math.Vector2i;
import manipulatables.Injection;
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

enum HAnchor
{
	Left;
	Center;
	Right;
}

enum VAnchor
{
	Top;
	Center;
	Down;
}

typedef StringPair = { key : String, value : String }

class Main {
	
	private static inline var minWidth: Int = 600;
	private static inline var minHeight: Int = 200;
	public static var width(default, null): Int = 1024;
	public static var height(default, null): Int = 768;
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
    private static var gamePaused: Bool = false;
	
	public static var Player(default, null) = "Boss";
	public static var npcSpawns : Array<Vector2> = new Array<Vector2>();
	public static var interactiveSprites: Array<InteractiveSprite>;
	private static var guyBelowMouse: RandomGuy = null;

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

	private static var adventureCursor: AdventureCursor;

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
			width = Std.int(Math.max(minWidth, width));
			height = Std.int(Math.max(minHeight, height));

			backbuffer = Image.createRenderTarget(width, height + Inventory.height);
			Scene.the.setSize(width, height);
			
			Inventory.y = height;

			var scaleX = backbuffer.width/window.width;
			var scaleY = backbuffer.height/window.height;
			if (scaleX < 1)
			{
				windowScale = Math.min(scaleX, scaleY);
			}
			else
			{
				windowScale = Math.max(scaleX, scaleY);
			}
			windowOffsetX = Std.int((window.width - backbuffer.width/windowScale) / 2);
			windowOffsetY = Std.int((window.height - backbuffer.height/windowScale) / 2);

			trace("   Gamescreen: " + width + "/" + height);
			trace("        Scene: " + Scene.the.getWidth() + "/" + Scene.the.getHeight());
			trace("       Window: " + window.width + "/" + window.height);
			trace("   backbuffer: " + backbuffer.width + "/" + backbuffer.height);
			trace(" windowScale: " + windowScale);
			trace("windowOffset: " + windowOffsetX + "/" + windowOffsetY);
		}
		
		mouseWindowPosX = x;
		mouseWindowPosY = y;

		if (mouseWindowPosY < width)
		{
			var sceneXY = getSceneXY(x, y);
			mouseScenePosX = sceneXY.x;
			mouseScenePosY = sceneXY.y;
		}
		else
		{
			mouseScenePosX = -1000;
			mouseScenePosY = -1000;
		}
	}

	public static function getSceneXY(x: Int, y: Int): Vector2i
	{
		return new Vector2i(Std.int((x - windowOffsetX) * windowScale) + Scene.the.screenOffsetX,
		                    Std.int((y - windowOffsetY) * windowScale) + Scene.the.screenOffsetY);
	}

	private static function getGuyBelowCoords(sceneX: Int, sceneY: Int): RandomGuy
	{
		var guysBelowPoint = Scene.the.getSpritesBelowPoint(sceneX, sceneY);
		for (guy in guysBelowPoint)
		{
			if (Std.is(guy, RandomGuy))
			{
				var randomGuy : RandomGuy = cast guy;
				if (randomGuy.status != WorkerDead)
					return randomGuy;
			}
		}
		return null;
	}

	private static function onMouseDown(button: Int, x: Int, y: Int): Void {
		if (gamePaused)
		{
			gamePaused = false;
			FactoryState.the.showYearlyStatsFlag = false;
		}

		updateMouse(x,y);

		adventureCursor.onMouseDown(button, x, y);
	}

	private static function onMouseUp(button: Int, x: Int, y: Int): Void
	{
		updateMouse(x, y);

		adventureCursor.onMouseUp(button,x,y);
	}

	private static function onMouseMove(x: Int, y: Int, moveX: Int, moveY: Int): Void {
		updateMouse(x, y);
		guyBelowMouse = getGuyBelowCoords(mouseScenePosX, mouseScenePosY);
	}

	private static function onMouseWheel(delta: Int): Void {

	}

	private static function init(): Void {
		if (Mouse.get() != null) Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);

		Random.init(Std.int(System.time * 100));
		lastTime = Scheduler.time();
		font = Assets.fonts.LiberationSans_Regular;

		Inventory.init();
		Inventory.pick(new RandomGuy());
		Inventory.pick(new Injection(0,0));

		initLevel();
		scene = Scene.the;
		updateMouse(Std.int(window.width/2), Std.int(window.height/2));
		Scene.the.camx = Std.int(width / 2);
		
		adventureCursor = new AdventureCursor();
		
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
		
		Scene.the.setSize(width, height);
		Scene.the.clear();
		Scene.the.setBackgroundColor(Color.fromBytes(255, 255, 255));
		var tilemap = new Tilemap(Assets.images.tileset, tileWidth, tileHeight, map, tileColissions);
		Scene.the.setColissionMap(tilemap);
		Scene.the.addBackgroundTilemap(tilemap, 1);
		
		var computers : Array<Vector2> = new Array<Vector2>();
		var bookshelves : Array<Vector2> = new Array<Vector2>();
		npcSpawns = new Array<Vector2>();
		interactiveSprites = new Array();
		for (i in 0...spriteCount) {
			var sprite : kha2d.Sprite = null;
			switch (sprites[i * 3]) {
			case 0:
				sprite = new kha2d.Sprite(Assets.images._0);
				sprite.x = sprites[i * 3 + 1];
				sprite.y = sprites[i * 3 + 2];
				sprite.maxspeedy = 0;
				Scene.the.addOther(sprite);
			case 1:
				sprite = new kha2d.Sprite(Assets.images._1);
				sprite.x = sprites[i * 3 + 1];
				sprite.y = sprites[i * 3 + 2];
				sprite.maxspeedy = 0;
				Scene.the.addOther(sprite);
			case 2:
				sprite = new kha2d.Sprite(Assets.images._2);
				sprite.x = sprites[i * 3 + 1];
				sprite.y = sprites[i * 3 + 2];
				sprite.maxspeedy = 0;
				Scene.the.addOther(sprite);
			case 3:
				sprite = new kha2d.Sprite(Assets.images._3);
				sprite.x = sprites[i * 3 + 1];
				sprite.y = sprites[i * 3 + 2];
				sprite.maxspeedy = 0;
				Scene.the.addOther(sprite);
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
		
		var sceneXY = getSceneXY(mouseWindowPosX, mouseWindowPosY);
		mouseScenePosX = sceneXY.x;
		mouseScenePosY = sceneXY.y;

		adventureCursor.update(mouseWindowPosX, mouseWindowPosY);
		
		if (!gamePaused)
		{
			Staff.update(deltaTime);
			FactoryState.the.update(deltaTime);

			if (mouseWindowPosX  < scrollArea)
				Scene.the.camx -= Std.int(scrollSpeed * ((scrollArea - mouseWindowPosX) / scrollArea));
			if (mouseWindowPosX > window.width - scrollArea)
				Scene.the.camx += Std.int(scrollSpeed * ((scrollArea - (window.width - mouseWindowPosX)) / scrollArea));
			Scene.the.camx = Std.int(Math.max(Scene.the.camx, Std.int(width / 2)));
			Scene.the.camx = Std.int(Math.min(Scene.the.camx, Scene.the.getWidth() - Std.int(width / 2)));

			if (mouseWindowPosY < scrollArea)
				Scene.the.camy -= Std.int(scrollSpeed * ((scrollArea - mouseWindowPosY) / scrollArea));
			if (mouseWindowPosY > window.height - scrollArea)
				Scene.the.camy += Std.int(scrollSpeed * ((scrollArea - (window.height - mouseWindowPosY)) / scrollArea));
			Scene.the.camy = Std.int(Math.max(Scene.the.camy, Std.int(height / 2)));
			Scene.the.camy = Std.int(Math.min(Scene.the.camy, Scene.the.getHeight() - Std.int(height / 2)));

			Scene.the.update();
		}
	}

	static function render(framebuffer: Framebuffer): Void {
		var g = backbuffer.g2;
		g.begin();
		
		Scene.the.render(g);
		
		g.transformation = FastMatrix3.identity();

		//BlaBox.render(g);
		Inventory.paint(g);

		g.font = font;
		g.fontSize = 24;
		
		var spac: Int = 5;
		var hudDisplays : Array<StringPair> = [
			{ key: "Time: ", value: Std.string(1 + FactoryState.the.months) + "/" + Std.string(1 + FactoryState.the.years) },
			{ key: "Money: ", value: Std.string(FactoryState.the.money) },
			{ key: "Cans: ", value: Std.string(FactoryState.the.cansNormal) },
			{ key: "10ups: ", value: Std.string(FactoryState.the.cans10up) },
			{ key: "Deaths: ", value: Std.string(FactoryState.the.casualties) }
		];
		renderStatsBox(width - spac, spac, 5, hudDisplays, g, Right, Top);

		// Debug only
		#if debug
		g.drawString("Age: " + Std.string(Staff.allguys[0].employeeAge), 10, 10);
		g.drawString("TfC: " + Std.string(Staff.allguys[0].employeeTimeForCan), 10, 30);
		g.drawString("PpC: " + Std.string(Staff.allguys[0].employeeProgressTo10UpPerCan), 10, 50);
		
		g.drawString("PtC: " + Std.string(Staff.allguys[0].employeeProgressToCan), 10, 70);
		g.drawString("P10: " + Std.string(Staff.allguys[0].employeeProgressTo10Up), 10, 90);
		g.drawString("Hth: " + Std.string(Staff.allguys[0].employeeHealth), 10, 110);
		#end
		
		if (guyBelowMouse != null)
		{
			var guyDisplays : Array<StringPair> = [
				{ key: guyBelowMouse.name, value: "" },
				{ key: "Age: ", value: Std.string(Math.floor(guyBelowMouse.employeeAge + 18)) },
				{ key: "Health: ", value: Std.string(Math.round(guyBelowMouse.employeeHealth * 100)) + "%" },
				{ key: "Speed: ", value: Std.string(Math.round((1 / guyBelowMouse.employeeTimeForCan) * 100) / 100) },
				{ key: "Quality: ", value: Std.string(Math.round(guyBelowMouse.employeeProgressTo10UpPerCan * 100) / 100) },
				{ key: "Cans: ", value: Std.string(Math.floor(guyBelowMouse.employeeCansNot)) },
				{ key: "10ups: ", value: Std.string(Math.floor(guyBelowMouse.employeeCans10up)) }
			];
			renderStatsBox(mouseWindowPosX, mouseWindowPosY, 5, guyDisplays, g, Left, Top);
		}

		if (FactoryState.the.showYearlyStatsFlag)
		{
			gamePaused = true;
			g.fontSize = 36;

			var yearDisplays : Array<StringPair> = [
				{ key: "Summary of year " + Std.string(1 + FactoryState.the.years - 1), value: "" },
				{ key: "", value: "" },
				{ key: "Income:    ", value: Std.string(
					FactoryState.the.yearlyIncome[FactoryState.the.yearlyIncome.length - 1]) +
				 		(FactoryState.the.yearlyIncome.length > 1 ? 
				 			formatChange
							 	(FactoryState.the.yearlyIncome[FactoryState.the.yearlyIncome.length - 1] -
								 FactoryState.the.yearlyIncome[FactoryState.the.yearlyIncome.length - 2])
							: "") },
				{ key: "Wages:    ", value: Std.string(FactoryState.the.yearlyWages[FactoryState.the.yearlyWages.length - 1]) +
				 		(FactoryState.the.yearlyWages.length > 1 ? 
				 			formatChange
							 	(FactoryState.the.yearlyWages[FactoryState.the.yearlyWages.length - 1] -
								 FactoryState.the.yearlyWages[FactoryState.the.yearlyWages.length - 2])
							: "") },
				{ key: "Cans:    ", value: Std.string(FactoryState.the.yearlyCansNormal[FactoryState.the.yearlyCansNormal.length - 1]) +
				 		(FactoryState.the.yearlyCansNormal.length > 1 ? 
				 			formatChange
							 	(FactoryState.the.yearlyCansNormal[FactoryState.the.yearlyCansNormal.length - 1] -
								 FactoryState.the.yearlyCansNormal[FactoryState.the.yearlyCansNormal.length - 2])
							: "") },
				{ key: "10ups:    ", value: Std.string(FactoryState.the.yearlyCans10up[FactoryState.the.yearlyCans10up.length - 1]) +
				 		(FactoryState.the.yearlyCans10up.length > 1 ? 
				 			formatChange
							 	(FactoryState.the.yearlyCans10up[FactoryState.the.yearlyCans10up.length - 1] -
								 FactoryState.the.yearlyCans10up[FactoryState.the.yearlyCans10up.length - 2])
							: "") },
				{ key: "Deaths:    ", value: Std.string(FactoryState.the.yearlyCasualties[FactoryState.the.yearlyCasualties.length - 1]) +
				 		(FactoryState.the.yearlyCasualties.length > 1 ? 
				 			formatChange
							 	(FactoryState.the.yearlyCasualties[FactoryState.the.yearlyCasualties.length - 1] -
								 FactoryState.the.yearlyCasualties[FactoryState.the.yearlyCasualties.length - 2])
							: "") }
			];
			renderStatsBox(width / 2, height / 2, 15, yearDisplays, g, Center, Center);
		}

		adventureCursor.render(g, mouseWindowPosX, mouseWindowPosY);

		g.end();
		
		framebuffer.g2.begin();
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	private static function formatChange(change: Int): String
	{
		if (change > 0)
		{
			return " (+" + Std.string(change) + ")";
		}
		else if (change < 0)
		{
			return " (" + Std.string(change) + ")";
		}
		else
		{
			return " (+/-" + Std.string(change) + ")";
		}
	}

	private static function renderStatsBox(x: Float, y: Float, pad: Float, stats: Array<StringPair>, g: kha.graphics2.Graphics, hAnchor: HAnchor, vAnchor: VAnchor)
	{
		var stringWidth: Float = 0;
		for (i in 0...stats.length)
			stringWidth = Math.max(g.font.width(g.fontSize, stats[i].key + stats[i].value), stringWidth);
		var stringHeight: Float = g.font.height(g.fontSize);

		var boxWidth: Float = stringWidth + 2 * pad;
		var boxHeight: Float = stringHeight * stats.length + pad * (stats.length + 1);
		var xOffset: Float = hAnchor == Left ? x : (hAnchor == Right ? x - boxWidth : x - boxWidth / 2);
		var yOffset: Float = vAnchor == Top ? y : (vAnchor == Down ? y - boxHeight : y - boxHeight / 2);

		g.color = Color.Black;
		g.fillRect(xOffset, yOffset, boxWidth, boxHeight);
		
		g.color = Color.White;
		xOffset += pad;
		yOffset += pad;
		for (i in 0...stats.length)
		{
			g.drawString(stats[i].key, xOffset, yOffset);
			g.drawString(stats[i].value, xOffset + stringWidth - g.font.width(g.fontSize, stats[i].value), yOffset);
			yOffset += pad + stringHeight;
		}
	}

	public static function onResize(width: Int, height: Int): Void
	{
		trace("RESIZE: " + width + "/" + height);
	}

	public static function main() {
		System.start({title: "10Up Origins", width: width, height: height + Inventory.height}, function (window) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				Main.window = window;
				init();
				window.notifyOnResize(function (width, height) { onResize(width, height); });
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
			});
		});
	}
}
