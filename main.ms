import "importUtil"
ensureImport "events"
ensureImport "listUtil"
ensureImport "stringUtil"
ensureImport "qa"

ensureImport "coreUtil"

SCREEN_SIZE = [960, 640]
TAB_SIZE = 4

flip = function(dispIndex1 = null, dispIndex2 = null)
	if dispIndex1 == null then
		dispIndex1 = 5
		dispIndex2 = 6
	end if
	if dispIndex2 == null then dispIndex2 = gfx.index
	if display(dispIndex1).mode == displayMode.off then
		// show disp1, but point gfx at (off-screen) disp2
		display(dispIndex1).mode = displayMode.tile
		display(dispIndex2).mode = displayMode.tile
		// globals.gfx = display(dispIndex2)
		display(dispIndex2).mode = displayMode.off
	else
		// show disp2, but point gfx at (off-screen) disp1
		display(dispIndex2).mode = displayMode.tile
		display(dispIndex1).mode = displayMode.tile
		// globals.gfx = display(dispIndex1)
		display(dispIndex1).mode = displayMode.off
	end if
end function

clearBackground = function
	for y in range(0, Displays.background.extent[1] - 1)
		for x in range(0, Displays.background.extent[0] - 1)
			Displays.background.setCellTint x, y, color.black
		end for
	end for
end function

renderStatusBar = function(doc)

	for x in range(0, Displays.background.extent[0] - 1)
		Displays.foreground.setCell x, 0, code(" ")
		Displays.foreground.setCellTint x, 0, color.orange
		Displays.background.setCellTint x, 0, color.blue
	end for

	text = "[{row},{column}]".fill(doc.cursor)
	x = 0
	for ch in text
		Displays.foreground.setCell x, 0, code(ch)
		Displays.foreground.setCellTint x, 0, color.orange
		x += 1
	end for


	text = doc.path
	x = Displays.foreground.extent[0] - text.len
	for ch in text
		Displays.foreground.setCell x, 0, code(ch)
		Displays.foreground.setCellTint x, 0, color.orange
		x += 1
	end for
end function

renderDocument = function(doc)
	index = 0
	row = 25
	column = 0
	for r in range(doc.cursor.row, doc.lines.len - 1)
		docLine = doc.lines[r]
		if docLine.len > 0 then
			for c in range(doc.cursor.column, docLine.len - 1)
				ch = docLine[c]
				if ch == char(9) then
					column += TAB_SIZE
				else
					Displays.foreground.setCell column, row, code(ch)
					column += 1
				end if

				index += 1
				if column >= Displays.foreground.extent[0] then break
			end for
		end if

		column = 0
		row -= 1
		if row <= 0 then break
	end for
end function

readFileContents = function(path)
	return file.readLines(path)
end function

Document = {}
Document.make = function(path)
	doc = new Document
	doc.path = path
	doc.lines = []
	doc.cursor = {
		"row": 0,
		"column": 0,
	}
	doc.isDirty = true
	return doc
end function

events.eventLoop.onKeyDown["escape"] = function; events.eventLoop.stop; end function

events.eventLoop.onUpdate = function
	horizontal = 0
	vertical = 0
	if key.available then
		ch = code(key.get)
		if ch == 19 then vertical = -1
		if ch == 20 then vertical = 1
		if ch == 17 then horizontal = -1
		if ch == 18 then horizontal = 1
	end if

	if vertical != 0 then
		doc.cursor.row += floor(vertical)
		doc.isDirty = true
	end if
	if horizontal != 0 then
		doc.cursor.column += floor(horizontal)
		doc.isDirty = true
	end if

	if doc.isDirty then
		if doc.cursor.row < 0 then doc.cursor.row = 0
		if doc.lines.len > 0 then
			if doc.cursor.row >= doc.lines.len then doc.cursor.row = doc.lines.len - 1
		else
			doc.cursor.row = 0
		end if

		if doc.cursor.column < 0 then doc.cursor.column = 0
		if doc.lines[doc.cursor.row].len > 0 then
			if doc.cursor.column >= doc.lines[doc.cursor.row].len then doc.cursor.column = doc.lines[doc.cursor.row].len - 1
		else
			doc.cursor.column = 0
		end if

		clearBackground
		Displays.foreground.clear code(" ")
		renderDocument doc
		renderStatusBar doc
		globals.doc.isDirty = false
	end if
end function

Displays = {
	"foreground": null,
	"background": null,

	"foreground0": null,
	"background0": null,
	"foreground1": null,
	"background1": null,
}

// Prepare the display.
clear

display(4).mode = displayMode.tile
Displays.foreground0 = display(4)
Displays.foreground0.mode == displayMode.off
Displays.foreground0.tileSet = file.loadImage("assets/micro-font.png")

// Size of each tile in the image.
Displays.foreground0.tileSetTileSize = [16, 24]
Displays.foreground0.cellSize = Displays.foreground0.tileSetTileSize
Displays.foreground0.scrollX = 0
Displays.foreground0.scrollY = 0

// Columns, rows on screen.
Displays.foreground0.extent = [
	floor(SCREEN_SIZE[0] / Displays.foreground0.tileSetTileSize[0]),
	floor(SCREEN_SIZE[1] / Displays.foreground0.tileSetTileSize[1]),
]

display(5).mode = displayMode.tile
Displays.foreground1 = display(5)
Displays.foreground1.mode == displayMode.off
Displays.foreground1.tileSet = file.loadImage("assets/micro-font.png")

// Size of each tile in the image.
Displays.foreground1.tileSetTileSize = [16, 24]
Displays.foreground1.cellSize = Displays.foreground1.tileSetTileSize
Displays.foreground1.scrollX = 0
Displays.foreground1.scrollY = 0

// Columns, rows on screen.
Displays.foreground1.extent = [
	floor(SCREEN_SIZE[0] / Displays.foreground1.tileSetTileSize[0]),
	floor(SCREEN_SIZE[1] / Displays.foreground1.tileSetTileSize[1]),
]

display(6).mode = displayMode.tile
Displays.background0 = display(6)
Displays.background0.mode == displayMode.off
Displays.background0.tileSet = Image.create(Displays.foreground0.cellSize[0], Displays.foreground0.cellSize[1], color.white)
Displays.background0.tileSetTileSize = Displays.foreground0.tileSetTileSize
Displays.background0.cellSize = Displays.foreground0.cellSize
Displays.background0.scrollX = Displays.foreground0.scrollX
Displays.background0.scrollY = Displays.foreground0.scrollY
Displays.background0.extent = Displays.foreground0.extent
Displays.background0.clear 0

display(7).mode = displayMode.tile
Displays.background1 = display(7)
Displays.background1.mode == displayMode.off
Displays.background1.tileSet = Image.create(Displays.foreground0.cellSize[0], Displays.foreground0.cellSize[1], color.white)
Displays.background1.tileSetTileSize = Displays.foreground0.tileSetTileSize
Displays.background1.cellSize = Displays.foreground0.cellSize
Displays.background1.scrollX = Displays.foreground0.scrollX
Displays.background1.scrollY = Displays.foreground0.scrollY
Displays.background1.extent = Displays.foreground0.extent
Displays.background1.clear 0

flip 4, 5
Displays.foreground = Displays.foreground0
flip 6, 7
Displays.background = Displays.background0

doc = Document.make("test.txt")

doc.lines = readFileContents(doc.path)
renderDocument doc
renderStatusBar doc

// Begin the main loop.
events.eventLoop.run
