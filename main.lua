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
	-- initMap()
	-- initPacman()
	-- initGhosts()
	gridOffsetX = (areaX * 0.5) - (gridX * gridSize * 0.5) + offsetX
	gridOffsetY = (areaY * 0.5) - (gridY * gridSize * 0.5) + offsetY
	-- initPause()
end

function initMap()
	
    
	tunnel = {}
	tunnel[1] = {}
	tunnel[2] = {}
	tunnel[1].x = 1
	tunnel[1].y = 13
	tunnel[2].x = 26
	tunnel[2].y = 13

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
	-- drawPacman()
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
	love.graphics.print("Score ".. tostring(score), gridOffsetX + (gridX - 4) * gridSize, gridOffsetY - 60)
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

function drawGhosts()
	
end

function drawPacman()
	
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

