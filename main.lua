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
			-- initGame()
		end
		if menuActive == 2 then
			love.event.push( 'quit' )
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

function drawGetReady()
	drawGame()
	white()
	love.graphics.setFont(fontScore)
	love.graphics.print("GET READY!", gridOffsetX + 270, gridOffsetY + 420)
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

