-- count_km.lua
-- Script per conteggiare i chilometri percorsi da ogni pilota su un server di Assetto Corsa

-- Tabella per memorizzare i chilometri percorsi dai piloti
local driver_km = {}

-- Funzione per calcolare la distanza tra due punti (coordinate x, y, z)
local function calculate_distance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

-- Funzione chiamata ad ogni aggiornamento del server
function onTick()
    -- Itera attraverso tutti i piloti
    for _, driver in ipairs(ac.getDrivers()) do
        -- Ottieni l'ID del pilota
        local driver_id = driver.carId

        -- Ottieni la posizione attuale del pilota
        local pos = ac.getCarPosition(driver_id)

        -- Se è la prima volta che vediamo questo pilota, inizializziamo i dati
        if not driver_km[driver_id] then
            driver_km[driver_id] = {
                last_pos = pos,
                total_km = 0
            }
        else
            -- Calcola la distanza percorsa dall'ultima posizione
            local last_pos = driver_km[driver_id].last_pos
            local distance = calculate_distance(last_pos.x, last_pos.y, last_pos.z, pos.x, pos.y, pos.z)

            -- Aggiungi la distanza percorsa al totale
            driver_km[driver_id].total_km = driver_km[driver_id].total_km + (distance / 1000) -- Converti da metri a chilometri

            -- Aggiorna l'ultima posizione
            driver_km[driver_id].last_pos = pos
        end
    end
end

-- Funzione per ottenere i chilometri percorsi da un pilota
function getKilometers(driver_id)
    if driver_km[driver_id] then
        return driver_km[driver_id].total_km
    else
        return 0
    end
end

-- Funzione chiamata quando il server si avvia
function onServerStart()
    ac.log("Il conteggio dei chilometri percorsi è attivo.")
end

-- Funzione chiamata quando il server si ferma
function onServerStop()
    ac.log("Il server si sta fermando. Chilometri percorsi dai piloti:")
    for driver_id, data in pairs(driver_km) do
        ac.log(string.format("Pilota %d: %.2f km", driver_id, data.total_km))
    end
end

-- Funzione per disegnare il testo a schermo
function onRender(dt)
    for _, driver in ipairs(ac.getDrivers()) do
        local driver_id = driver.carId
        local km = getKilometers(driver_id)
        local display_text = string.format("Km percorsi: %.2f", km)
        
        -- Ottieni la posizione dello schermo per il pilota
        local x = 10
        local y = 10 + driver_id * 20 -- Offset per evitare sovrapposizioni

        -- Disegna il testo in alto a sinistra
        ac.setText(x, y, display_text, 20, ac.Color(1, 1, 1, 1), 0, 1)
    end
end
