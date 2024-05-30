-- Variabile per tenere traccia dei chilometri percorsi
local kmPercorsi = 0

-- Funzione per aggiornare i chilometri percorsi
local function aggiornaChilometri(deltaKm)
    kmPercorsi = kmPercorsi + deltaKm
end

-- Modifica della funzione script.update per aggiornare i chilometri percorsi
function script.update(dt)
    -- Esempio: aggiornamento dei chilometri ogni secondo
    aggiornaChilometri(0.1) -- Aggiungi 0.1 km per ogni secondo
end

function script.drawUI()
    -- Disegna il logo
    positionImage(image_0, 'top_left', debugImage)

    -- Disegna i chilometri percorsi sotto il logo
    display.text({
        text = "Km percorsi: " .. kmPercorsi,
        pos = vec2(image_0.paddingX, image_0.paddingY + image_0.sizeY * image_0.scale + 10), -- Sposta il testo sotto il logo
        letter = vec2(8, 16),
        font = 'aria',
        color = rgbm.colors.white
    })

    -- Debug: Disegna le linee di debug
    if debugLines then
        drawdebugLines()
    end
end
