-- Simple drift script using some of the overtake script UI.
-- The more you slide the more points you make.
-- The faster you go, faster the combo multiplier goes up.
-- Drift run ends if you stay under the required speed and are not sliding. 

-- Event configuration:
local requiredSpeed = 40

-- ScoreTrackerPlugin
local msg = ac.OnlineEvent({
    ac.StructItem.key("driftScoreEnd"),
    Score = ac.StructItem.int64(),
    Multiplier = ac.StructItem.int32(),
    Car = ac.StructItem.string(64),
})




-- Function to start the timer prepare(dt), once speed is reached.
function script.prepare(dt)
    ac.debug("speed", ac.getCarState(1).speedKmh)
    return ac.getCarState(1).speedKmh > 35
end

-- Event state:
local timePassed = 0
local driftPoints = 0
local totalScore = 0
local comboMeter = 1
local highestCombo = 1
local comboProgress = 1
local comboColor = 0
local highestScore = 0
local lastScore = 0
local dangerouslySlowTimer = 0
local carsState = {}
local wheelsWarningTimeout = 0
local topScore = 0
local topScorePlayer = ""
local sliding = 0
local slidingMult = 0

function script.update(dt)
    if timePassed == 0 then
        addMessage("Let’s go!", 0)
    end
    
    local player = ac.getCar(0)
    if not player then
        return
    end
    timePassed = timePassed + dt
-- Activate or disable combo fading
    --local comboFadingRate = 0.4 * math.lerp(1, 0.1, math.lerpInvSat(player.speedKmh, 80, 200)) + player.wheelsOutside    
    --comboProgress = math.max(1, comboProgress - dt * comboFadingRate)
    --comboMeter = math.floor(comboProgress)
-- Get all other cars (Will be used for Tandem drifting bonus)
    local sim = ac.getSimState()
    while sim.carsCount > #carsState do
        carsState[#carsState + 1] = {}
    end
-- Needed for combo fading or if you wanted to cancel the run while wheels are out
    if wheelsWarningTimeout > 0 then
        wheelsWarningTimeout = wheelsWarningTimeout - dt
    elseif player.wheelsOutside > 0 then
        if wheelsWarningTimeout == 0 then
        end
        addMessage("Car is outside", -1)
        wheelsWarningTimeout = 60
    end
    
-- Is car Drifting/Sliding?
    sliding = player.localVelocity.x / math.max(3, player.speedMs)
    slidingMult = math.abs(sliding) * 10
    
    if player.speedKmh > requiredSpeed and slidingMult > 1 then
        driftPoints = slidingMult * 0.05
        totalScore = totalScore + (driftPoints * comboMeter)        
        comboProgress = comboProgress + (player.speedKmh * 0.00005)
        comboMeter = math.floor(comboProgress)
        if comboMeter > highestCombo then
            highestCombo = comboMeter
        end
    end
    
    if player.speedKmh < requiredSpeed and slidingMult < 1 then
        if dangerouslySlowTimer > 3 then
            if totalScore > highestScore then
                highestScore = math.floor(totalScore)                
                ac.sendChatMessage("scored a new personal best: " .. math.floor(totalScore) .. " points.")
                msg{ Score = totalScore, Multiplier = highestCombo, Car = ac.getCarName(0) }
            end
            if totalScore > 0 then
                lastScore = math.floor(totalScore)
            end

            totalScore = 0
            comboMeter = 1
            comboProgress = 1
        else
            if dangerouslySlowTimer == 0 then
                addMessage("Get Going!", -1)
            end
        end
        dangerouslySlowTimer = dangerouslySlowTimer + dt
        --comboMeter = 1
        return
    else
        dangerouslySlowTimer = 0
    end

end

--Using a modified Overtake UI for now
local messages = {}
local glitter = {}
local glitterCount = 0

function addMessage(text, mood)
    for i = math.min(#messages + 1, 4), 2, -1 do
        messages[i] = messages[i - 1]
        messages[i].targetPos = i
    end
    messages[1] = {text = text, age = 0, targetPos = 1, currentPos = 1, mood = mood}
    if mood == 1 then
        for i = 1, 60 do
            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
            glitterCount = glitterCount + 1
            glitter[glitterCount] = {
                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
                pos = vec2(80, 140) + dir * vec2(40, 20),
                velocity = dir:normalize():scale(0.2 + math.random()),
                life = 0.5 + 0.5 * math.random()
            }
        end
    end
end

local function updateMessages(dt)
    comboColor = comboColor + dt * 10 * comboMeter
    if comboColor > 360 then
        comboColor = comboColor - 360
    end
    for i = 1, #messages do
        local m = messages[i]
        m.age = m.age + dt
        m.currentPos = math.applyLag(m.currentPos, m.targetPos, 0.8, dt)
    end
    for i = glitterCount, 1, -1 do
        local g = glitter[i]
        g.pos:add(g.velocity)
        g.velocity.y = g.velocity.y + 0.02
        g.life = g.life - dt
        g.color.mult = math.saturate(g.life * 4)
        if g.life < 0 then
            if i < glitterCount then
                glitter[i] = glitter[glitterCount]
            end
            glitterCount = glitterCount - 1
        end
    end
    if comboMeter > 10 and math.random() > 0.98 then
        for i = 1, math.floor(comboMeter) do
            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
            glitterCount = glitterCount + 1
            glitter[glitterCount] = {
                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
                pos = vec2(195, 75) + dir * vec2(40, 20),
                velocity = dir:normalize():scale(0.2 + math.random()),
                life = 0.5 + 0.5 * math.random()
            }
        end
    end
end

local speedWarning = 0
    function script.drawUI()
        local uiState = ac.getUiState()
        updateMessages(uiState.dt)

        local speedRelative = math.saturate(math.floor(ac.getCarState(1).speedKmh) / requiredSpeed)
        speedWarning = math.applyLag(speedWarning, speedRelative < 1 and 1 or 0, 0.5, uiState.dt)

        local colorDark = rgbm(0.4, 0.4, 0.4, 1)
        local colorGrey = rgbm(0.7, 0.7, 0.7, 1)
        local colorAccent = rgbm.new(hsv(speedRelative * 120, 1, 1):rgb(), 1)
        local colorCombo =
            rgbm.new(hsv(comboColor, math.saturate(comboMeter / 10), 1):rgb(), math.saturate(comboMeter / 4))

        local function speedMeter(ref)
            ui.drawRectFilled(ref + vec2(0, -4), ref + vec2(180, 5), colorDark, 1)
            ui.drawLine(ref + vec2(0, -4), ref + vec2(0, 4), colorGrey, 1)
            ui.drawLine(ref + vec2(requiredSpeed, -4), ref + vec2(requiredSpeed, 4), colorGrey, 1)

            local speed = math.min(ac.getCarState(1).speedKmh, 180)
            if speed > 1 then
                ui.drawLine(ref + vec2(0, 0), ref + vec2(speed, 0), colorAccent, 4)
            end
        end
-- Changed Window position so that it is closer to the middle when using Triple screens. Need to figure a way to grab current resolution for better universal placement
        ui.beginTransparentWindow("driftScore", vec2(1700, 100), vec2(1900, 400))
        ui.beginOutline()

        ui.pushStyleVar(ui.StyleVar.Alpha, 1 - speedWarning)
        ui.popFont()
        ui.popStyleVar()
        ui.pushFont(ui.Font.Title)
        ui.offsetCursorY(20)
        ui.text(math.floor(totalScore) .. " pts")
        ui.sameLine(0, 20)
        ui.beginRotation()
        ui.textColored(math.floor(comboMeter) .. "x", colorCombo)
        if comboMeter > 20 then
            ui.endRotation(math.sin(comboMeter / 180 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90)
        end
        ui.pushFont(ui.Font.Main)
        ui.text("HighScore: " .. highestScore .. " pts")
        ui.text("Last Run: " .. lastScore .. " pts")
        ui.popFont()
        ui.endOutline(rgbm(0, 0, 0, 0.3))
        
        ui.pushFont(ui.Font.Main)
        local startPos = ui.getCursor()
        for i = 1, #messages do
            local m = messages[i]
            local f = math.saturate(4 - m.currentPos) * math.saturate(8 - m.age)
            ui.setCursor(startPos + vec2(20 * 0.5 + math.saturate(1 - m.age * 10) ^ 2 * 50, (m.currentPos - 1) * 15))
            ui.textColored(
                m.text,
                m.mood == 1 and rgbm(0, 1, 0, f) or m.mood == -1 and rgbm(1, 0, 0, f) or rgbm(1, 1, 1, f)
            )
        end
        for i = 1, glitterCount do
            local g = glitter[i]
            if g ~= nil then
                ui.drawLine(g.pos, g.pos + g.velocity * 4, g.color, 2)
            end
        end
        ui.popFont()
        ui.setCursor(startPos + vec2(0, 4 * 30))
        ui.pushStyleVar(ui.StyleVar.Alpha, speedWarning)
        ui.setCursorY(0)
        ui.pushFont(ui.Font.Main)
        ui.textColored("Keep speed above " .. requiredSpeed .. " km/h:", colorAccent)
        speedMeter(ui.getCursor() + vec2(-9 * 0.5, 4 * 0.2))
        ui.popFont()
        ui.popStyleVar()

        ui.endTransparentWindow()
    end
