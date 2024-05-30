-- show_logo.lua
-- Script per mostrare un logo in alto a sinistra su un server di Assetto Corsa

-- Percorso del file immagine del logo
local logo_path = "path/to/your/logo.png"  -- Assicurati di sostituire con il percorso corretto del logo

-- Variabile per memorizzare l'immagine del logo
local logo_image

-- Funzione chiamata quando il server si avvia
function onServerStart()
    -- Carica l'immagine del logo
    logo_image = ac.loadImage(logo_path)
    if logo_image then
        ac.log("Logo caricato correttamente.")
    else
        ac.log("Errore nel caricamento del logo.")
    end
end

-- Funzione chiamata ad ogni aggiornamento del rendering
function onRender(dt)
    if logo_image then
        -- Dimensioni e posizione del logo
        local x = 10
        local y = 10
        local width = 100  -- Larghezza desiderata del logo
        local height = 100  -- Altezza desiderata del logo
        
        -- Disegna l'immagine del logo in alto a sinistra
        ac.drawImage(logo_image, x, y, width, height)
    end
end

-- Funzione chiamata quando il server si ferma
function onServerStop()
    ac.log("Il server si sta fermando.")
end
