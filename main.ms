import "importUtil"
ensureImport "events"
ensureImport "listUtil"
ensureImport "stringUtil"
ensureImport "qa"

ensureImport "coreUtil"

TAB_SIZE = 4

readFileContents = function(path)
	// f = file.open(path, "r")
	// text = f.read
	// f.close
	// return text
	return file.readLines(path)
end function

events.eventLoop.onUpdate = function
	// td.setCell 7, 5, cellIdx
	// globals.cellIdx = (cellIdx + 1) % 256
	// wait 0.1
end function

// Prepare the display.
clear
display(5).mode = displayMode.tile
td = display(5)
td.tileSet = file.loadImage("assets/micro-font.png")
td.tileSetTileSize = [16, 24]  // size of each tile in the image
td.cellSize = td.tileSetTileSize
td.scrollX = 0
td.scrollY = 0

SCREEN_SIZE = [960, 640]

// Columns, rows on screen.
td.extent = [floor(SCREEN_SIZE[0] / td.tileSetTileSize[0]), floor(SCREEN_SIZE[1] / td.tileSetTileSize[1])]

docLines = readFileContents("test.txt")

td.clear code(" ")
index = 0
// topRow = docLines.len
row = 25
column = 0

for r in range(0, docLines.len - 1)
	docLine = docLines[r]
	if docLine.len > 0 then
		for c in range(0, docLine.len - 1)
			ch = docLine[c]
			if ch == char(9) then
				column += TAB_SIZE
			else
				td.setCell column, row, code(ch)
				column += 1
			end if
			
			index += 1
			if column >= td.extent[0] then break
		end for
	end if

	column = 0
	row -= 1
	// if row < 0 then break
end for

// while index < text.len
// 	ch = text[index]
// 	if (ch == char(13) or ch == char(10)) then
// 		column = 0
// 		row += 1
// 	else if ch == char(9) then
// 		column += TAB_SIZE
// 	else
// 		td.setCell column, row, code(ch)
// 		column += 1
// 	end if
// 	index += 1
// end while

// Begin the main loop.
events.eventLoop.run
