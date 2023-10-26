-- -- -- -- -- --
-- COMMON --
-- -- -- -- -- --

-- game settings --
local gameMode
local delta

-- resolution --
local screenX, screenY
local offsetX = 0
local offsetY = 0
local areaX = 1000
local areaY = 800
local activeResolution


-- buttons --
local isEscPressed, isSpacePressed, isEnterPressed, isUpPressed, isDownPressed, isLeftPressed, isRightPressed

-- fonts --
local fontBig, fontMedium, fontSmall, fontSmallMedium, fontScore


local pacman, ghosts, tunnel
local mapSizeX, mapSizeY
local gridSize = 24
local gridX = 28
local gridY = 30
local gridOffsetX,  gridOffsetY
local dotSize = 0.14 * gridSize
local score = 0
local lives
local level = 1
local gameTimer = 0
local collectedDots

-- images --
local pacmanSprites

local menuBgR = 0
local menuBgG = 0
local menuBgB = 0

local menuMode, menuActive

local menuTimer
local menuEnabled
local menuPositions = 2

local maze = {}
local dots = {}
local corners = {}

--UPDATE FUNCTIONS

function love.update(dt)
    delta = dt
    if gameMode == "menu" then
        updateMainMenu()
    end
    if gameMode == "game" then
        updateGame()
    end
    if gameMode == "pause" then
        updatePause()
    end
    if gameMode == "getReady" then
        updateGetReady()
    end
    if gameMode == "gameOver" then
        updateGameOver()
    end
end


function updateMainMenu()
	menuTimerWait()
	if isEscPressed then
		if menuEnabled then
			love.event.push( 'quit' )
		end
	end
	if isEnterPressed and menuEnabled then
		if menuActive == 1 then
			initGame()
		end
		if menuActive == 2 then
			love.event.push( 'quit' )
		end
	end
	if isUpPressed and (menuActive > 1) then
		if menuEnabled then
			menuActive = menuActive - 1
			menuTimer = 0
		end
	end
	if isDownPressed and (menuActive < menuPositions) then
		if menuEnabled then
			menuActive = menuActive + 1
			menuTimer = 0
		end
	end
	menuTimerAdd()
end

function initGame()
	gameMode = "getReady"
	lives = 3
	score = 0
	gameOverTimer = 0
	getReadyTimer = 0
	gameTimer = 0
	collectedDots = 0
	initMap()
	initPacman()
	initGhosts()
	gridOffsetX = (areaX * 0.5) - (gridX * gridSize * 0.5) + offsetX
	gridOffsetY = (areaY * 0.5) - (gridY * gridSize * 0.5) + offsetY
	-- initPause()
end

function initMap()
	local i, j, k

    local mazeData = require("maps.maze")
    local dotsData = require("maps.dots")
    local cornersData = require("maps.corners")


    for i = 0, gridX, 1 do
        maze[i] = {}
        dots[i] = {}
        corners[i] = {}

        for j = 0, gridY, 1 do
            maze[i][j] = false
            dots[i][j] = false
            corners[i][j] = 0
        end
    end

    j = 0
    k = 0
    for i = 1, #mazeData do
		for p=1, #mazeData[i] do
			local c = mazeData[i][p]
			if c == 1 then
				maze[j][k] = true
			end
			j = j + 1
			if j == gridX then
				j = 0
				k = k + 1
			end
		end
    end

	j = 0
    k = 0
    for i = 1, #dotsData do
		for p=1, #dotsData[i] do
			local c = dotsData[i][p]
			if c == 1 then
				dots[j][k] = true
			end
			j = j + 1
			if j == gridX then
				j = 0
				k = k + 1
			end
		end
    end

	
	for i = 0, gridX, 1 do
		corners[i] = {}
		for j = 0, gridY, 1 do
			corners[i][j] = 0
		end
	end

	j = 0
	k = 0
	for i = 1, #cornersData do
		
		for p=1, #cornersData[i] do
			local c = cornersData[i][p]
			if c == 1 then
				corners[j][k] = 1
			end
			if c == 2 then
				corners[j][k] = 2
			end
			if c == 3 then
				corners[j][k] = 3
			end
			if c == 4 then
				corners[j][k] = 4
			end
			if c == 5 then
				corners[j][k] = 5
			end
			if c == 6 then
				corners[j][k] = 6
			end
			
			j = j + 1
			if j == gridX then
				j = 0
				k = k + 1
			end
		end
	end

	tunnel = {}
	tunnel[1] = {}
	tunnel[2] = {}
	tunnel[1].x = 1
	tunnel[1].y = 13
	tunnel[2].x = 26
	tunnel[2].y = 13
end

function initPacman()
	pacman = {}
	pacman.mapX = 13
	pacman.mapY = 16
	pacman.lastMapX = pacman.mapX
	pacman.lastMapY = pacman.mapY
	pacman.x = pacman.mapX * gridSize + gridSize * 0.5
	pacman.y = pacman.mapY * gridSize + gridSize * 0.5
	pacman.speed = 140
	pacman.size = gridSize * 0.5 - 4
	pacman.sprite = 1
	pacman.spriteInc = true
	pacman.direction = 4
	pacman.directionText = "left"
	pacman.nextDirection = 4
	pacman.nextDirectionText = "left"
	pacman.movement = 0
	pacman.distance = 0
	pacman.image = 1
	pacman.upFree = false
	pacman.downFree = false
	pacman.leftFree = false
	pacman.rightFree = false
	pacman.sameSpriteTimer = 0
	if maze[pacman.mapX][pacman.mapY-1] == false then
		pacman.upFree = true
	end
	if maze[pacman.mapX][pacman.mapY+1] == false then
		pacman.downFree = true
	end
	if maze[pacman.mapX-1][pacman.mapY] == false then
		pacman.leftFree = true
	end
	if maze[pacman.mapX+1][pacman.mapY] == false then
		pacman.rightFree = true
	end
end

function resetPacmanPosition()
	pacman.mapX = 13
	pacman.mapY = 16
	pacman.lastMapX = pacman.mapX
	pacman.lastMapY = pacman.mapY
	pacman.x = pacman.mapX * gridSize + gridSize * 0.5
	pacman.y = pacman.mapY * gridSize + gridSize * 0.5
	pacman.sprite = 1
	pacman.spriteInc = true
	pacman.direction = 4
	pacman.directionText = "left"
	pacman.nextDirection = 4
	pacman.nextDirectionText = "left"
	pacman.movement = 0
	pacman.distance = 0
	pacman.image = 1
end

function initGhosts()
	ghosts = {}
	for i = 1, 4, 1 do
		ghosts[i] = {}
		ghosts[i].mapX = 0
		ghosts[i].mapY = 0
		ghosts[i].x = 0
		ghosts[i].y = 0
		ghosts[i].out = false
		ghosts[i].upFree = false
		ghosts[i].downFree = false
		ghosts[i].leftFree = false
		ghosts[i].rightFree = false
		ghosts[i].direction = 1
		ghosts[i].nextDirection = 1
		ghosts[i].speed = 100
		ghosts[i].normSpeed = 100
	end
	resetGhostsPosition()
end

function resetGhostsPosition()
	ghosts[1].mapX = 12
	ghosts[1].mapY = 10
	ghosts[1].direction = 4
	ghosts[1].nextDirection = 4
	--
	ghosts[2].mapX = 15
	ghosts[2].mapY = 10
	ghosts[2].direction = 2
	ghosts[2].nextDirection = 2
	--
	ghosts[3].mapX = 13
	ghosts[3].mapY = 13
	ghosts[3].direction = 1
	ghosts[3].nextDirection = 1
	--
	ghosts[4].mapX = 14
	ghosts[4].mapY = 13
	ghosts[4].direction = 1
	ghosts[4].nextDirection = 1
	for i = 1, 4, 1 do
		ghosts[i].x = ghosts[i].mapX * gridSize + gridSize * 0.5
		ghosts[i].y = ghosts[i].mapY * gridSize + gridSize * 0.5
		if maze[ghosts[i].mapX][(ghosts[i].mapY)-1] == false then
			ghosts[i].upFree = true
		end
		if maze[ghosts[i].mapX][(ghosts[i].mapY)+1] == false then
			ghosts[i].downFree = true
		end
		if maze[(ghosts[i].mapX)-1][ghosts[i].mapY] == false then
			ghosts[i].leftFree = true
		end
		if maze[(ghosts[i].mapX)+1][ghosts[i].mapY] == false then
			ghosts[i].rightFree = true
		end
	end
end
--DRAW FUNCTIONS 


function love.draw()
    if gameMode == "menu" then
        drawMenu()
    end
    if gameMode == "game" then
        drawGame()
    end
    if gameMode == "pause" then
        drawPause()
    end 
    if gameMode == "getReady" then
        drawGetReady()
    end
    if gameMode == "gameOver" then
        drawGameOver()
    end	
end


function drawMenu()
	--drawArea()
	love.graphics.setBackgroundColor(menuBgR, menuBgG, menuBgB)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(fontBig)
	love.graphics.print("PACMAN LUA - test", offsetX+160, offsetY+100)
	love.graphics.setFont(fontMedium)
	if menuActive == 1 then red() else white() end
	love.graphics.print("NEW GAME", offsetX+200, offsetY+300)
	if menuActive == 2 then red() else white() end
	love.graphics.print("QUIT", offsetX+200, offsetY+350)
    
    love.graphics.setColor(1, 0, 0, 1) -- Red color for selected item
    love.graphics.print("Nebojsa Mirkovic", offsetX+160, offsetY+500)
    love.graphics.print(">", offsetX + 160, offsetY + 300 + (menuActive - 1) * 50)
    
end

function drawCorner(x, y, cornerType)
    love.graphics.draw(cornerSprites[cornerType], x, y)
end

function drawGhosts()
	for i = 1, 4, 1 do
		white()
		love.graphics.draw(ghostsSprites[i], ghosts[i].x+gridOffsetX-22, ghosts[i].y+gridOffsetY-22)
	end
end

function drawPacman()
	white()
	love.graphics.draw(pacmanSprites[pacman.direction][pacman.sprite], pacman.x+gridOffsetX-22, pacman.y+gridOffsetY-22)
end

function drawGetReady()
	drawGame()
	white()
	love.graphics.setFont(fontBig)
	love.graphics.print("GET READY!", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2 - 450)
end

function drawGame()
	drawMaze()
	drawDots()
	drawScore()
	drawLives()
	drawGhosts()
	drawPacman()
end


function drawMaze()
    local centerX = love.graphics.getWidth() / 2 - 350
    local centerY = love.graphics.getHeight() / 2 - 375

    local gridSize = 24
    
    local corners = require("maps.corners")
    for i = 1, gridY do
        local x = centerX
        local y = centerY + (i - 1) * gridSize

        for j = 1, gridX do
            if type(corners[i][j]) == "number" then
                drawCorner(x, y, corners[i][j])
            end

            x = x + gridSize
        end
    end
end

function drawDots()
    local centerX = love.graphics.getWidth() / 2 - 340
    local centerY = love.graphics.getHeight() / 2 - 365

    local gridSize = 24
    for i = 1, gridY do
        local x = centerX
        local y = centerY + (i - 1) * gridSize

        for j = 1,gridX do
            if dots[j][i] == true then
                drawColoredCircle(x + 27, y + 27, 4)
            end

            x = x + gridSize
        end
    end
end


function drawColoredCircle(x, y, radius)
    white()
    love.graphics.circle("fill", x, y, radius)  
end

function drawScore()
	love.graphics.setFont(fontScore)
	white()
	love.graphics.print("Score ".. tostring(score), gridOffsetX + (gridX - 7) * gridSize, gridOffsetY - 60)
	love.graphics.print("Level ".. tostring(level), gridOffsetX + gridSize - 20, gridOffsetY - 60)
end

function drawLives()
	if lives > 1 then
		for i = 1, lives-1, 1 do
			white()
			love.graphics.draw(pacmanSprites[4][2], gridOffsetX + i * 20, gridOffsetY + gridY * gridSize)
		end
	end
end

function resetMenu()
	menuActive = 1
	menuTimer = 0
	menuEnabled = false
end

--color

function white()
	love.graphics.setColor(1, 1, 1, 1)
end

function red()
	love.graphics.setColor(1, 0, 0, 1)
end

function blue()
	love.graphics.setColor(0, 0, 1, 1)
end

function yellow()
	love.graphics.setColor(1, 1, 0, 1)
end

--load functions

function love.load()
    loadEverything()
    gameMode = "menu"
	menuMode = "main"
end

function loadEverything()
	fontBig = love.graphics.newFont(48)
	fontMedium = love.graphics.newFont(36)
	fontSmall = love.graphics.newFont(14)
	fontSmallMedium = love.graphics.newFont(28)
	fontScore = love.graphics.newFont("fonts/Pacmania.TTF", 28)
    
    pacmanSprites = {}
	pacmanSprites[1] = {}
	pacmanSprites[2] = {}
	pacmanSprites[3] = {}
	pacmanSprites[4] = {}
	pacmanSprites[1][1] = love.graphics.newImage("images/pacman/up/pacman1up.png")
	pacmanSprites[1][2] = love.graphics.newImage("images/pacman/up/pacman2up.png")
	pacmanSprites[1][3] = love.graphics.newImage("images/pacman/up/pacman3up.png")
	pacmanSprites[2][1] = love.graphics.newImage("images/pacman/right/pacman1right.png")
	pacmanSprites[2][2] = love.graphics.newImage("images/pacman/right/pacman2right.png")
	pacmanSprites[2][3] = love.graphics.newImage("images/pacman/right/pacman3right.png")
	pacmanSprites[3][1] = love.graphics.newImage("images/pacman/down/pacman1down.png")
	pacmanSprites[3][2] = love.graphics.newImage("images/pacman/down/pacman2down.png")
	pacmanSprites[3][3] = love.graphics.newImage("images/pacman/down/pacman3down.png")
	pacmanSprites[4][1] = love.graphics.newImage("images/pacman/left/pacman1left.png")
	pacmanSprites[4][2] = love.graphics.newImage("images/pacman/left/pacman2left.png")
	pacmanSprites[4][3] = love.graphics.newImage("images/pacman/left/pacman3left.png")

	ghostsSprites = {}
	ghostsSprites[1] = love.graphics.newImage("images/ghosts/1.png")
	ghostsSprites[2] = love.graphics.newImage("images/ghosts/2.png")
	ghostsSprites[3] = love.graphics.newImage("images/ghosts/3.png")
	ghostsSprites[4] = love.graphics.newImage("images/ghosts/4.png")

	cornerSprites = {}
	cornerSprites[1] = love.graphics.newImage("images/maze/1.png")
	cornerSprites[2] = love.graphics.newImage("images/maze/2.png")
	cornerSprites[3] = love.graphics.newImage("images/maze/3.png")
	cornerSprites[4] = love.graphics.newImage("images/maze/4.png")
	cornerSprites[5] = love.graphics.newImage("images/maze/5.png")
	cornerSprites[6] = love.graphics.newImage("images/maze/6.png")

	resetMenu()
	createResolutions()
	setResolution(1)

	love.keyboard.setKeyRepeat(true)
end

--resolution

function createResolutions()
	--wanted to have more resolutions, but didn't have time :)
	resolutions = {}

	resolutions[1] = {}
	resolutions[1].x = 1920
	resolutions[1].y = 1080
	resolutions[1].name = "1920x1080"

end

function setResolution(res)
	love.window.setMode(resolutions[res].x, resolutions[res].y, {fullscreen=true, fullscreentype="exclusive"})
	offsetX = (resolutions[res].x - areaX) / 2
	offsetY = (resolutions[res].y - areaY) / 2
	activeResolution = res
end


-- UPDATE FUNCTIONS --

function updatePacman()
	-- update input --
	if isUpPressed then
		pacman.nextDirection = 1
		pacman.nextDirectionText = "up"		
	end
	if isDownPressed then
		pacman.nextDirection = 3
		pacman.nextDirectionText = "down"
	end
	if isLeftPressed then
		pacman.nextDirection = 4
		pacman.nextDirectionText = "left"
	end
	if isRightPressed then
		pacman.nextDirection = 2
		pacman.nextDirectionText = "right"
	end

	-- check if pacman reaches a tunnel --

	if (pacman.mapX == tunnel[1].x) and (pacman.mapY == tunnel[1].y) then
		pacman.mapX = tunnel[2].x - 1
		pacman.mapY = tunnel[2].y
		pacman.x = pacman.mapX * gridSize + gridSize * 0.5
		pacman.y = pacman.mapY * gridSize + gridSize * 0.5
	end

	if (pacman.mapX == tunnel[2].x) and (pacman.mapY == tunnel[2].y) then
		pacman.mapX = tunnel[1].x + 1
		pacman.mapY = tunnel[1].y
		pacman.x = pacman.mapX * gridSize + gridSize * 0.5
		pacman.y = pacman.mapY * gridSize + gridSize * 0.5
	end


	-- chceck if left/right/up/down free --
	pacman.upFree = false
	pacman.downFree = false
	pacman.leftFree = false
	pacman.rightFree = false
	if maze[pacman.mapX][pacman.mapY-1] == false then
		pacman.upFree = true
	end
	if maze[pacman.mapX][pacman.mapY+1] == false then
		pacman.downFree = true
	end
	if maze[pacman.mapX-1][pacman.mapY] == false then
		pacman.leftFree = true
	end
	if maze[pacman.mapX+1][pacman.mapY] == false then
		pacman.rightFree = true
	end

	if pacman.mapY == 10 then
		if (pacman.mapX == 13) or (pacman.mapX == 14) then
			pacman.downFree = false
		end
	end

	-- check if pacman out of his box --
	if pacman.x < (pacman.mapX * gridSize + gridSize) then
		pacman.mapX = pacman.mapX - 1
	end
	if pacman.x > (pacman.mapX * gridSize + gridSize) then
		pacman.mapX = pacman.mapX + 1
	end
	if pacman.y < (pacman.mapY * gridSize + gridSize) then
		pacman.mapY = pacman.mapY - 1
	end
	if pacman.y > (pacman.mapY * gridSize + gridSize) then
		pacman.mapY = pacman.mapY + 1
	end

	-- calculate pacman movement --

	pacman.movement = delta * pacman.speed

	-- check if pacman can move --

	if pacman.direction == 1 then
		if pacman.upFree then
			pacman.y = pacman.y - pacman.movement
		end
		if pacman.y > (pacman.mapY * gridSize + 0.5 * gridSize) then
			pacman.y = pacman.y - pacman.movement
		end
	end

	if pacman.direction == 3 then
		if pacman.downFree then
			pacman.y = pacman.y + pacman.movement
		end
		if pacman.y < (pacman.mapY * gridSize + 0.5 * gridSize) then
			pacman.y = pacman.y + pacman.movement
		end
	end

	if pacman.direction == 2 then
		if pacman.rightFree then
			pacman.x = pacman.x + pacman.movement
		end
		if pacman.x < (pacman.mapX * gridSize + 0.5 * gridSize) then
			pacman.x = pacman.x + pacman.movement
		end
	end

	if pacman.direction == 4 then
		if pacman.leftFree then
			pacman.x = pacman.x - pacman.movement
		end
		if pacman.x > (pacman.mapX * gridSize + 0.5 * gridSize) then
			pacman.x = pacman.x - pacman.movement
		end
	end

	-- check if pacman can change direction and if he can, do so --

	if pacman.direction ~= pacman.nextDirection then
		if (math.abs(pacman.x - (pacman.mapX * gridSize + 0.5 * gridSize)) < 2.5) and (math.abs(pacman.y - (pacman.mapY * gridSize + 0.5 * gridSize)) < 2.5) then
			if (pacman.nextDirection == 1) and pacman.upFree then
				pacmanChangeDirection()
			end
			if (pacman.nextDirection == 3) and pacman.downFree then
				pacmanChangeDirection()
			end
			if (pacman.nextDirection == 2) and pacman.rightFree then
				pacmanChangeDirection()
			end
			if (pacman.nextDirection == 4) and pacman.leftFree then
				pacmanChangeDirection()
			end
		end
	end

	-- check if pacman is on a dot --
	

	if (dots[pacman.mapX][pacman.mapY] == true) then
		dots[pacman.mapX][pacman.mapY] = false
		score = score + 1
		collectedDots = collectedDots + 1
	end


	-- calculate pacman distance and update sprite --
	if (pacman.lastMapX > pacman.mapX) or (pacman.lastMapX < pacman.mapX) then
		pacman.lastMapX = pacman.mapX
		increasePacmanDistance()
		increasePacmanSprite()
		pacman.sameSpriteTimer = 0
	end
	if (pacman.lastMapY > pacman.mapY) or (pacman.lastMapY < pacman.mapY) then
		pacman.lastMapY = pacman.mapY
		increasePacmanDistance()
		increasePacmanSprite()
		pacman.sameSpriteTimer = 0
	end
	if (pacman.lastMapX == pacman.mapX) and (pacman.lastMapY == pacman.mapY) then
		pacman.sameSpriteTimer = pacman.sameSpriteTimer + delta
	end
	if pacman.sameSpriteTimer > 0.2 then
		pacman.sprite = 1
		pacman.spriteInc = true
	end

end

function increasePacmanDistance()
	pacman.distance = pacman.distance + 1
end

function increasePacmanSprite()
	if pacman.sprite == 3 then
		pacman.spriteInc = false
	end
	if pacman.sprite == 1 then
		pacman.spriteInc = true
	end
	if pacman.spriteInc then
		pacman.sprite = pacman.sprite + 1
	end
	if pacman.spriteInc == false then
		pacman.sprite = pacman.sprite - 1
	end
end


function pacmanChangeDirection()
	pacman.direction = pacman.nextDirection
	pacman.directionText = pacman.nextDirectionText
	pacman.x = pacman.mapX * gridSize + gridSize * 0.5
	pacman.y = pacman.mapY * gridSize + gridSize * 0.5
end

function updateGhosts()
	for i = 1, 4, 1 do
		ghosts[i].speed = ghosts[i].normSpeed
		if (ghosts[i].mapX == pacman.mapX) and (ghosts[i].mapY == pacman.mapY) then
			lives = lives - 1
			gameMode = "getReady"
			getReadyTimer = 0
			resetPacmanPosition()
			resetGhostsPosition()
		end

		-- check if up/down/left/right free --
		ghosts[i].upFree = false
		ghosts[i].downFree = false
		ghosts[i].leftFree = false
		ghosts[i].rightFree = false
		if maze[ghosts[i].mapX][ghosts[i].mapY-1] == false then
			ghosts[i].upFree = true
		end
		if maze[ghosts[i].mapX][ghosts[i].mapY+1] == false then
			ghosts[i].downFree = true
		end
		if maze[ghosts[i].mapX-1][ghosts[i].mapY] == false then
			ghosts[i].leftFree = true
		end
		if maze[ghosts[i].mapX+1][ghosts[i].mapY] == false then
			ghosts[i].rightFree = true
		end

		if (ghosts[i].mapX == 21) and (ghosts[i].mapY == 13) then
			ghosts[i].rightFree = false
		end

		if (ghosts[i].mapX == 6) and (ghosts[i].mapY == 13) then
			ghosts[i].leftFree = false
		end

		if ghosts[i].mapY == 10 then
			if (ghosts[i].mapX == 13) or (ghosts[i].mapX == 14) then
				ghosts[i].downFree = false
			end
		end

		-- check if ghost out of his box --
		if ghosts[i].x < (ghosts[i].mapX * gridSize + gridSize) then
			ghosts[i].mapX = ghosts[i].mapX - 1
		end
		if ghosts[i].x > (ghosts[i].mapX * gridSize + gridSize) then
			ghosts[i].mapX = ghosts[i].mapX + 1
		end
		if ghosts[i].y < (ghosts[i].mapY * gridSize + gridSize) then
			ghosts[i].mapY = ghosts[i].mapY - 1
		end
		if ghosts[i].y > (ghosts[i].mapY * gridSize + gridSize) then
			ghosts[i].mapY = ghosts[i].mapY + 1
		end

		-- make ghosts move --
		if gameTimer > 4 then
			moveGhosts(i)
		else
			if i < 3 then
				moveGhosts(i)
			end
		end

		local ghostXdistance = math.abs(ghosts[i].x - (ghosts[i].mapX * gridSize + 0.5 * gridSize))
		local ghostYdistance = math.abs(ghosts[i].y - (ghosts[i].mapY * gridSize + 0.5 * gridSize))
		if (ghostXdistance < 2.5) and (ghostYdistance < 2.5) then
			if (ghosts[i].direction == 1) and (ghosts[i].upFree == false) then
				randomGhostNexDirection(i)
				ghostsChangeDirection(i)
			end
			if (ghosts[i].direction == 3) and (ghosts[i].downFree == false) then
				randomGhostNexDirection(i)
				ghostsChangeDirection(i)
			end
			if (ghosts[i].direction == 4) and (ghosts[i].leftFree == false) then
				randomGhostNexDirection(i)
				ghostsChangeDirection(i)
			end
			if (ghosts[i].direction == 2) and (ghosts[i].rightFree == false) then
				randomGhostNexDirection(i)
				ghostsChangeDirection(i)
			end
		end
		
	end
end

function randomGhostNexDirection(ghost)
	local nextDirection
	local forbiddenDirection
	if ghosts[ghost].direction == 1 then
		forbiddenDirection = 3
	end
	if ghosts[ghost].direction == 2 then
		forbiddenDirection = 4
	end
	if ghosts[ghost].direction == 3 then
		forbiddenDirection = 1
	end
	if ghosts[ghost].direction == 4 then
		forbiddenDirection = 2
	end
	repeat
		nextDirection = math.random(1, 4)
	until (nextDirection ~= ghosts[ghost].nextDirection) and (nextDirection ~= forbiddenDirection)
	ghosts[ghost].nextDirection = nextDirection
end

function moveGhosts(ghost)
	local movement = ghosts[ghost].speed * delta
	if ghosts[ghost].direction == 1 then
		if ghosts[ghost].upFree then
			ghosts[ghost].y = ghosts[ghost].y - movement
		end
		if ghosts[ghost].y > (ghosts[ghost].mapY * gridSize + 0.5 * gridSize) then
			ghosts[ghost].y = ghosts[ghost].y - movement
		end
	end
	if ghosts[ghost].direction == 3 then
			if ghosts[ghost].downFree then
			ghosts[ghost].y = ghosts[ghost].y + movement
		end
		if ghosts[ghost].y < (ghosts[ghost].mapY * gridSize + 0.5 * gridSize) then
			ghosts[ghost].y = ghosts[ghost].y + movement
		end
	end
	if ghosts[ghost].direction == 2 then
		if ghosts[ghost].rightFree then
			ghosts[ghost].x = ghosts[ghost].x + movement
		end
		if ghosts[ghost].x < (ghosts[ghost].mapX * gridSize + 0.5 * gridSize) then
			ghosts[ghost].x = ghosts[ghost].x + movement
		end
	end
	if ghosts[ghost].direction == 4 then
		if ghosts[ghost].leftFree then
			ghosts[ghost].x = ghosts[ghost].x - movement
		end
		if ghosts[ghost].x > (ghosts[ghost].mapX * gridSize + 0.5 * gridSize) then
			ghosts[ghost].x = ghosts[ghost].x - movement
		end
	end
end

function ghostsChangeDirection(ghost)
	ghosts[ghost].direction = ghosts[ghost].nextDirection
	ghosts[ghost].x = ghosts[ghost].mapX * gridSize + gridSize * 0.5
	ghosts[ghost].y = ghosts[ghost].mapY * gridSize + gridSize * 0.5
end

function nextLevel()
	collectedDots = 0
	level = level + 1
	resetPacmanPosition()
	resetGhostsPosition()
	initMap()
	gameMode = "getReady"
	for i = 1, 4, 1 do
		ghosts[i].normSpeed = ghosts[i].normSpeed + 10
	end
	pacman.speed = pacman.speed + 2
end

function menuTimerWait()
	if menuTimer > 0.2 then
		menuEnabled = true
	else
		menuEnabled = false
	end
end

function menuTimerAdd()
	menuTimer = menuTimer + delta
end

function updateGame()
	menuTimerWait()
	if isEscPressed and menuEnabled then
		gameMode = "pause"
		menuTimer = 0
	end
	updatePacman()
	updateGhosts()
	menuTimerAdd()
	gameTimer = gameTimer + delta
	if lives == 0 then
		gameMode = "gameOver"
	end
	if collectedDots == 240 then
		nextLevel()
	end
end

-- -- -- -- -- --
-- PAUSE --
-- -- -- -- -- --

local pauseOffsetX
local pauseOffsetY
local pauseSizeX
local pauseSizeY
local gameOverTimer = 0
local getReadyTimer = 0

function initPause()
	pauseOffsetX = gridOffsetX + 6 * gridSize
	pauseOffsetY = gridOffsetY + 10 * gridSize
	pauseSizeX = gridX * gridSize - 2 * 6 * gridSize
	pauseSizeY = gridY * gridSize - 2 * 10 * gridSize
end

-- DRAW FUNCTIONS --

function drawPause()
	drawGame()
	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.rectangle("fill", 0, 0, resolutions[activeResolution].x, resolutions[activeResolution].y)
	red()
	love.graphics.rectangle("fill", pauseOffsetX-1, pauseOffsetY-1, pauseSizeX+2, pauseSizeY+2)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", pauseOffsetX, pauseOffsetY, pauseSizeX, pauseSizeY)

	white()
	love.graphics.setFont(fontMedium)
	love.graphics.print("PAUSE", pauseOffsetX+30, pauseOffsetY+20)
	love.graphics.setFont(fontSmallMedium)
	if menuActive == 1 then red() else white() end
	love.graphics.print("RETURN TO GAME", pauseOffsetX+30, pauseOffsetY+80)
	if menuActive == 2 then red() else white() end
	love.graphics.print("RETURN TO MENU", pauseOffsetX+30, pauseOffsetY+120)
	if menuActive == 3 then red() else white() end
	love.graphics.print("QUIT GAME", pauseOffsetX+30, pauseOffsetY+160)
end

function drawGameOver()
	drawGame()
	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.rectangle("fill", 0, 0, resolutions[activeResolution].x, resolutions[activeResolution].y)

	white()
	love.graphics.setFont(fontMedium)
	love.graphics.print("GAME OVER", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2)
	love.graphics.setFont(fontSmall)
	love.graphics.print("Press space to return to menu", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2 + 50)
end

-- UPDATE FUNCTIONS --

function updatePause()
	menuTimerWait()
	if isSpacePressed and menuEnabled then
		menuTimer = 0
	end
	if isEscPressed and menuEnabled then
		gameMode = "game"
		menuTimer = 0
		resetMenu()
	end
	if isUpPressed and (menuActive > 1) then
		if menuEnabled then
			menuActive = menuActive - 1
			menuTimer = 0
		end
	end
	if isDownPressed and (menuActive < menuPositions) then
		if menuEnabled then
			menuActive = menuActive + 1
			menuTimer = 0
		end
	end
	if isEnterPressed and menuEnabled then
		if menuActive == 1 then
			gameMode = "game"
			menuTimer = 0
			resetMenu()
		end
		if menuActive == 2 then
			gameMode = "menu"
			menuMode = "main"
			menuPositions = 4
			resetMenu()
		end
		if menuActive == 3 then
			love.event.push( 'quit' )
		end
	end
	menuTimerAdd()
end

function updateGameOver()
	if isSpacePressed then
		gameMode = "menu"
		menuMode = "main"
		menuPositions = 2
		resetMenu()
	end
end

function updateGetReady()
	getReadyTimer = getReadyTimer + delta
	if getReadyTimer > 2.5 then
		gameMode = "game"
		getReadyTimer = 0
	end
end


function love.keypressed(key)
    if key == "up" then
        menuActive = menuActive - 1
        if menuActive < 1 then
            menuActive = 2 
        end
    elseif key == "down" then
        menuActive = menuActive + 1
        if menuActive > 2 then
            menuActive = 1
        end
		if key == " " then
			isSpacePressed = true
		end
    elseif key == "return" or key == "space" then
        
        if menuActive == 1 then
            initGame()
        elseif menuActive == 2 then
            love.event.quit() 
        end
    end
end

function love.keypressed( key, unicode )
	if key == "escape" then
		isEscPressed = true
	end
	if key == " " then
		isSpacePressed = true
	end
	if key == "return" then
		isEnterPressed = true
	end
	if key == "up" then
		isUpPressed = true
	end
	if key == "down" then
		isDownPressed = true
	end
	if key == "left" then
		isLeftPressed = true
	end
	if key == "right" then
		isRightPressed = true
	end
end


function love.keyreleased( key, unicode )
	if key == "escape" then
		isEscPressed = false
	end
	if key == " " then
		isSpacePressed = false
	end
	if key == "return" then
		isEnterPressed = false
	end
	if key == "up" then
		isUpPressed = false
	end
	if key == "down" then
		isDownPressed = false
	end
	if key == "left" then
		isLeftPressed = false
	end
	if key == "right" then
		isRightPressed = false
	end
end

