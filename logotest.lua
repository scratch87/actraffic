-- show_logo_link.lua
-- Script per mostrare un logo in alto a sinistra su un server di Assetto Corsa e gestire un "clic" tramite un tasto

local http = require("socket.http")
local ltn12 = require("ltn12")

-- URL del file immagine del logo
local logo_url = "https://i.imgur.com/WRsO6Yi.png"  -- Sostituisci con l'URL corretto del logo

-- Percorso del file immagine del logo sul disco
local logo_path = "logo.png"  -- Il nome del file immagine locale

-- Variabile per memorizzare l'immagine del logo
local logo_image

-- Dimensioni e posizione del logo
local x = 10
local y = 10
local width = 100  -- Larghezza desiderata del logo
local height = 100  -- Altezza desiderata del logo

-- URL del link
local link_url = "http://example.com"  -- Sostituisci con l'URL del tuo link

-- Funzione per scaricare l'immagine
local function downloadImage(url, path)
    local response = {}
    local _, code = http.request{
        url = url,
        sink = ltn12.sink.file(io.open(path, "wb"))
    }
    return code == 200
end

-- Funzione per aprire il link (simulata, non possibile direttamente in Lua per Assetto Corsa)
local function openLink(url)
    ac.log("Apertura del link: " .. url)
    -- Qui potresti inserire il codice per aprire il link utilizzando un metodo esterno, se disponibile
end

-- Funzione chiamata quando il server si avvia
function onServerStart()
    -- Scarica l'immagine del logo
    if downloadImage(logo_url, logo_path) then
        ac.log("Logo scaricato correttamente.")
    else
        ac.log("Errore nel download del logo.")
        return
    end

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
        -- Disegna l'immagine del logo in alto a sinistra
        ac.drawImage(logo_image, x, y, width, height)
    end
end

-- Funzione chiamata ad ogni aggiornamento del server
function onTick()
    -- Verifica se il tasto "L" è premuto
    if ac.isKeyPressed(ac.KEY_L) then
        openLink(link_url)
    end
end

-- Funzione chiamata quando il server si ferma
function onServerStop()
    ac.log("Il server si sta fermando.")
end
