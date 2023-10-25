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


function updateGame()
	
end

function updateMainMenu()
	if isEnterPressed and menuEnabled then
		if menuActive == 1 then
			initGame()
		end
		if menuActive == 2 then
			love.event.push( 'quit' )
		end
	end
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

    local dots = {}
    local corners = {}

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
		for p=1, #mazeData[i] do
			local c = dotsData[i][p]
			if c == "1" then
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
		
		for p=1, #mazeData[i] do
			local c = cornersData[i][p]
			if c == "1" then
				corners[j][k] = 1
			end
			if c == "2" then
				corners[j][k] = 2
			end
			if c == "3" then
				corners[j][k] = 3
			end
			if c == "4" then
				corners[j][k] = 4
			end
			if c == "5" then
				corners[j][k] = 5
			end
			if c == "6" then
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
	pacman.specialDotActive = false
	pacman.specialDotTimer = 0
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

function initGhosts()
	ghosts = {}
	for i = 1, 4, 1 do
		ghosts[i] = {}
		ghosts[i].mapX = 0
		ghosts[i].mapY = 0
		ghosts[i].x = 0
		ghosts[i].y = 0
		ghosts[i].eaten = false
		ghosts[i].out = false
		ghosts[i].upFree = false
		ghosts[i].downFree = false
		ghosts[i].leftFree = false
		ghosts[i].rightFree = false
		ghosts[i].direction = 1
		ghosts[i].nextDirection = 1
		ghosts[i].speed = 100
		ghosts[i].normSpeed = 100
		ghosts[i].slowSpeed = 70
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

function drawGhost(x, y, ghostType)
    love.graphics.draw(ghostsSprites[ghostType], x, y)
end

function drawPacman(x, y, i, j)
    love.graphics.draw(pacmanSprites[i][j], x, y)
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
	drawGhost(love.graphics.getWidth() / 2 + 2, love.graphics.getHeight() / 2 - 33, 1)
	drawGhost(love.graphics.getWidth() / 2 - 18, love.graphics.getHeight() / 2 - 33, 2)
	drawGhost(love.graphics.getWidth() / 2 - 38, love.graphics.getHeight() / 2 - 33, 3)
	drawGhost(love.graphics.getWidth() / 2 - 58, love.graphics.getHeight() / 2 - 33, 4)
	drawPacman(love.graphics.getWidth() / 2 - 18, love.graphics.getHeight() / 2 + 13, 2, 3)
end


function drawMaze()
    local centerX = love.graphics.getWidth() / 2 - 350
    local centerY = love.graphics.getHeight() / 2 - 375

    local gridSize = 24
    
    local corners = require("maps.corners")
    for i = 1, 30 do
        local x = centerX
        local y = centerY + (i - 1) * gridSize

        for j = 1, 28 do
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
    local dots = require("maps.dots")
    for i = 1, 30 do
        local x = centerX
        local y = centerY + (i - 1) * gridSize

        for j = 1, 28 do
            if dots[i][j] == 1 then
                drawColoredCircle(x + 2, y + 2, 4)
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
	ghostsSprites[5] = love.graphics.newImage("images/ghosts/safe.png")
	ghostsSprites[6] = love.graphics.newImage("images/ghosts/eaten.png")

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
    elseif key == "return" or key == "space" then
        
        if menuActive == 1 then
            initGame()
        elseif menuActive == 2 then
            love.event.quit() 
        end
    end
end

