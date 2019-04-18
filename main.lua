-- [ Deck IDs ]
bag = nil
deck_GUID = '659e77'
stak_GUID = ''

-- [ Di IDs ]
die_GUID = '3466ba'

-- [ Play-Zone IDs ]
zone_GUID = '37e3cc'

-- [ Color Selection ]
color_cube = '634b06'

-- [ Last Played Card ]
lastPlay = ''  -- The face of the card played last
lastColors = nil -- The last card that was played
lastStack = true -- If the last card can be stacked on

-- [ Playing settings ]
playMode = 'draw' -- Ruleset for what a player can do on their turn
playColorChange = nil

-- [ Draw Settings ]
lastDraw = ''  -- Color of who drew a card last
turnDraw = 0   -- The number of cards the current turn has to draw
drawCount = 1  -- The number of cards lastDraw has drawn
drawStart = 7  -- The number of cards to start with
attacked = nil -- The player that has an attack card played on them

-- [ Deck Settings ]
deckSize = 0   -- Current size of the deck
deckLimit = 32  -- Limit of the deck size before cards are shuffled

-- [ Active Game ]
started = false      -- If game is started
dostart = false      -- If game is being started
canend = false       -- If game is able to end / somebody has 0 cards

-- [ Settings ]
doForcePerms = true    -- If player has to be admin to start/end game
doRollOnStart = true   -- If should roll for who gets to play first
doCounterFX = true     -- Counter glowing
doAutoDraw = true      -- If cards should be dealt automatically on + cards
doCardCount = true     -- Show in chat # of cards drawn
doCardAnnounce = true  -- Show in chat card played
doUseTurns = true      -- If turns should be enabled on game start
doAnnounceTurns = true -- If turns should be announced
doRuleDrawOne = false  -- Force a drawing limit of 1 card
doValidateCards = true -- If played cards should be
doCallUno = true       -- Ingame UNO button is used
doLookForGroup = false -- Is looking for new players to join

-- [ Settings: House Rules ]
house = {
    Challenge = true,  -- Allow challenging
    StackDraws = true, -- Allow +2 +3 to stack
    Rotate = false,    -- Rotate hands on 0's
    Switch = false,    -- Swap hands on 7's
    FalseUno = false,  -- Draw cards when incorrectly calling uno
    JumpIn = false    -- Players can jump in
}

-- Player colors at the table
firstPlayer = nil
playerSettings = {}
playerNick = {}
playerWins = {}
colors = {"White","Red","Orange","Yellow","Green","Blue","Purple","Pink"}
validCardColors = { "Blue", "Cyan", "Green", "Orange", "Purple", "Red" }
playingColors = {}
playingHands = {}

-- Uno
unoHolders = {}

-- Position to place cards at
topCard = {
    position={x=-0.06, y=2.00, z=0.02},
    rotation={360, 180, 360}
}

-- Triangles for each player in the middle of the table
gameIds = {
    White="e88c10",
    Red="fbb104",
    Orange="10a3e8",
    Yellow="30a12a",
    Green="52cac1",
    Blue="72f6e2",
    Purple="ba5384",
    Pink="dd4e7f"
}

-- RGB values for each Player
colorIds = {
    White={r=254,g=254,b=254},
    Pink={r=255,g=0,b=231},
    Purple={r=201,g=0,b=255},
    Blue={r=0,g=0,b=255},
    Green={r=0,g=128,b=0},
    Yellow={r=255,g=254,b=0},
    Orange={r=255,g=168,b=0},
    Red={r=255,g=0,b=0}
}

cardColorIds = {
    Blue={r=0,g=0,b=255},
    Cyan={r=64,g=208,b=224},
    Green={r=0,g=128,b=0},
    Orange={r=255,g=168,b=0},
    Purple={r=113,g=16,b=173},
    Red={r=255,g=0,b=0},
    Wild={r=0,b=0,g=0}
}

-- Hand Zones
handZones = {
    ["491a5f"] = "White",
    ["3fb946"] = "Pink",
    ["47f89c"] = "Purple",
    ["dded25"] = "Blue",
    ["3f4fc0"] = "Green",
    ["f21809"] = "Yellow",
    ["b5e206"] = "Orange",
    ["b21b08"] = "Red"
}

-- RGB values for messages
color_white = { 1, 1, 1 }
color_red = { 1, 0, 0 }
color_green = { 0, 1, 0 }
color_lime = { 0, 0.5, 0 }
color_yellow = colorIds['Yellow']

-- [ Center Buttons Parameters ]
dbParams = {}
dbParams.click_function= 'clickedButton'
dbParams.function_owner = Global
dbParams.tooltip = 'New Game'
dbParams.label = ''
dbParams.position = { 0, 0, 0 }
dbParams.width = 100
dbParams.height = 100
dbParams.font_size = 160

rotation = 180

-- [ When one of the center buttons is clicked ]
function clickedButton( button, pColor, alt )
    if alt then
        return
    end

    local player = Player[ pColor ]
    local name = Players.Name( player )

    --deck = getObjectFromGUID( deck_GUID )
    local buttonColor = button.getVar("player_color")
    local buttonOwner = Player[ buttonColor ]

    if ( buttonColor ~= pColor ) and ( ( player.team == "None" ) or ( buttonOwner.team == "None" ) and ( player.team == buttonOwner.team ) ) then
        -- Tell player to use correct button
        printToColor( "That button does not belong to you.", pColor, color_red )
    else
        -- If button color is correct ...
        if started then
            -- If game is started ...
            if canend then
                -- If the game can be ended ...
                if player.admin or not doForcePerms then
                    onUnoEnd( player )
                else
                    printToColor( "You must be promoted to end the game.", pColor, color_red )
                end
            else
                -- Return if not player turn
                if Turns.enable and pColor ~= Turns.turn_color then
                    return
                end
                -- Return if cannot draw
                if _G.playMode ~= "draw" then
                    return
                end

                -- If game cannot be ended ...
                if lastDraw ~= pColor then
                    drawCount = 1
                end
                lastDraw = pColor

                toDraw = 1
                if turnDraw > 0 then
                    toDraw = turnDraw
                    drawCount = toDraw
                end

                -- Draw card message
                if doCardCount then
                    printToAllExcept( name .. " draws " .. drawCount .. " card" .. ( drawCount ~= 1 and "s" or "" ) .. ".", player.color, color_yellow )
                end

                -- If draw counter is same as cards needed
                if Turns.enable then
                    if drawCount == turnDraw then
                        Players.ShiftTurns( true )
                        turnDraw = 0
                    end
                end

                -- Shuffle and give card
                if toDraw == 1 then
                    Players.Draw( buttonColor )
                else
                    Players.Deal( buttonColor, toDraw )
                end

                -- Increase draw counter
                drawCount=drawCount+1
            end
        else
            -- If the game is not started ...
            if player.admin or not doForcePerms then
                -- If player is promoted ...
                onUnoStart( player )
            else
                printToColor( "You must be promoted to start the game.", pColor, color_red )
            end
        end
    end
end

-- [[ Start a new game ]]
function onUnoStart( player )
    -- Check if starting count is low enough
    local players = Player.getPlayers()
    local cards = bag.getObjects()
    if #cards / #players < _G.drawStart then
        broadcastToColor( "Can't start game. Not enough cards for " .. #players .. " players. (" .. #cards .. " / " .. ( _G.drawStart * #players ) .. ")", player.color, color_red )
        return false
    end

    -- Shuffle cards
    bag.shuffle()
    bag.shuffle()
    bag.shuffle()

    dostart=true

    -- Reset mode
    _G.playMode = 'draw'

    -- Playing Order around the table
    playingColors = {}

    -- Update the UI
    UI.setAttributes( "drawButton", {
        text = "Draw Card",
        color = "Yellow",
        textColor = "Black",
        tooltip = "Draw a card from the deck (NUMPAD5)"
    })

    -- Update values for colors
    for c = 1, #colors do
        color = colors[c]

        -- Update button names
        local tGame = getObjectFromGUID( gameIds[ color ] )
        tGame.editButton( { tooltip = 'Draw Card' } )

        -- Assign seated players
        local tPlayer = Player[ color ]
        if tPlayer.seated then
            Players.Deal( color, drawStart )
            table.insert( playingColors, color )
        end
    end

    -- Clear chat log
    for p = 1, 20 do
        printToAll( "" )
    end

    log( Players.Name( player ) .. " has started a new game" )
    printToAll( Players.Name( player ) .. " started a new game, with "..#playingColors.." players. Each player starts with "..drawStart.." cards", color_green )

    -- Enable Hands
    Turns.turn_color = "Nobody"
    Turns.order = playingColors
    Turns.reverse_order = false
    Turns.pass_turns = false
    Turns.type = 2
    Turns.skip_empty_hands = false
    Turns.disable_interactations = false
    Turns.enable = doUseTurns

    if doRollOnStart then
        -- Roll for who to play first
        local highestP = nil
        local highestR = 0
        printToAll( "Rolling "..#playingColors.." di" .. ( #playingColors == 1 and "" or "ce" ), color_white )
        for c = 1, #colors do
            local color = colors[c]
            local tPlayer = Player[ color ]

            if tPlayer.seated then

                local slice = getObjectFromGUID( gameIds[ color ] )
                local position = slice.getPosition()
                position.y = position.y + 2

                local di = getObjectFromGUID( die_GUID )

                di.takeObject({
                    position = position,
                    callback_function = (function( obj )
                        obj.setColorTint( color )

                        Wait.condition((function()

                            obj.setLock( false )

                            local rolls = math.random( 6, 24 )
                            for r = 1, rolls do
                                obj.randomize()
                            end
                            obj.setVar( "player", color )

                            Wait.condition((function()

                                obj.setLock( true )
                                local roll = obj.getRotationValue()
                                printToAll( Players.Name( tPlayer ) .. " rolls a d20, and gets " .. roll, color )

                                onEndDiRoll()

                            end), (function()
                                return obj.resting
                            end))

                        end), (function()
                            return ( not obj.spawning )
                        end))
                    end)
                })
            end
        end
    else
        firstPlayer = "White"
    end

    Wait.frames((function()
        dostart=false
        started=true
    end), (15 * drawStart)+ 20)

    Wait.condition((function()
        Wait.frames((function()

            -- Place top card
            local firstPlay = shallowcopy( topCard )
            firstPlay.rotation = {360, 180, 180}
            firstPlay.callback_owner = Global
            firstPlay.callback = "onFirstPlay"
            bag.takeObject( firstPlay )

        end), 100)

        -- Put di away
        local allObjects = getAllObjects()
        local diBag = getObjectFromGUID( die_GUID )
        for o = 1, #allObjects do
            local object = allObjects[o]
            if( object.tag == "Dice" ) then
                diBag.putObject( object )
            end
        end

        -- Set starting color
        if Turns.enable then
            Turns.turn_color = firstPlayer
            Players.AnnounceTurn( Player[firstPlayer] )
        end

        firstPlayer = nil
    end), (function()
        return (firstPlayer ~= nil)
    end))
end

-- [[ Clear out the existing game ]]
function onUnoEnd( player )
    log( Players.Name( player ) .. " ended the game." )
    printToAll( Players.Name( player ) .. " has ended the game.", color_green )

    UI.setAttributes( "turnIndicator", { visibility = "Nobody" })

    dostart=false
    started=false
    canend=false

    Turns.enable = false

    -- Reset values
    lastDraw = ''
    turnDraw = 0
    drawCount = 1
    attacked = nil

    -- Take all cards from the deck
    if stak_GUID ~= nil then
        deck = getObjectFromGUID( stak_GUID )
        if deck.tag == "Card" then
            bag.putObject( deck )
        elseif deck.tag == "Deck" then
            local deckObjects = deck.getObjects()
            for d = 1, #deckObjects do
                deck.takeObject({
                    index = 1,
                    position = {
                        x = 0,
                        y = 2 + ( d * 0.2 ),
                        z = 0
                    },
                    rotation = {
                        0,
                        90 * d,
                        0
                    },
                    callback_function = (function(obj)
                        obj.use_gravity = false
                        bag.putObject( obj )
                    end)
                })
            end
        end
    end

    -- Take all remaining cards from the table
    local allCards = getAllObjects()
    for l = 1, #allCards do
        card = allCards[l]
        if card.tag == "Card" then
            bag.putObject( card )
        end
    end

    for c = 1, #colors do
        local color = colors[c]

        -- Get player RBG
        local objColor = colorIds[color]
        local rgb = {
            r = objColor.r / 255,
            g = objColor.g / 255,
            b = objColor.b / 255
        }

        Wait.frames((function()
            -- Modify Center Objects
            local gameObj = getObjectFromGUID( gameIds[ color ] )
            gameObj.setColorTint( rgb )
        end), c * 5)

        local cPlayer = Player[ color ]

        -- Update button name
        local tGame = getObjectFromGUID( gameIds[ color ] )
        tGame.editButton( { tooltip = 'New Game' } )
        tGame.interactable = false

        UI.setAttributes( "drawButton", {
            text = "New Game",
            color = "Green",
            textColor = "White",
            tooltip = "Start a new game (NUMPAD5)"
        })
    end
end

-- [[ When the top card is spawned in ]]
function onFirstPlay( cardObj, attributes )
    lastPlay = cardObj.getVar( "face_value" )

    --cardObj.interactable = false
    Wait.frames((function()
        cardObj.interactable = true
        cardObj.flip()

        printToAll( "Starting card is \""..Card.ColorString( cardObj ).." "..lastPlay.."\"", color_yellow )

        setPlayingColor( cardObj.getTable( "face_color" ) )

        Wait.frames((function()
            stak_GUID = cardObj.guid
            cardObj.interactable = false
        end), 30)

    end), 15 * drawStart)
end

-- [[ When all di have finished automatically rolling ( for roll-to-start ) ]]
function onEndDiRoll()
    local highestP = nil
    local highestR = 0

    local allObjects = getAllObjects()
    for o = 1, #allObjects do
        local object = allObjects[o]
        if object.tag == "Dice" then
            local player = object.getVar( "player" )
            local face = object.getRotationValue()

            if ( not object.resting ) or player == nil then
                return
            end

            if face > highestR then
                highestR = face
                highestP = player
            end
        end
    end

    if highestP ~= nil and highestR ~= nil then
        firstPlayer = highestP
        local player = Player[firstPlayer]
        printToAll( Players.Name( player ) .. " rolled the highest ("..highestR..") and gets to go first.", color_white )
    end
end

-- [[ When a card enters into an object ]]
function onObjectEnterContainer( container, object )
    if object.tag ~= "Card" then
        return
    end
    if object.getVar( "player" ) ~= nil and started then
        local pColor = object.getVar( "player" )
        local player = Player[ pColor ]
        if container.guid == stak_GUID or Container.Has( container, object ) then
            onPlayedCard( player, object )
        end
    end
end

Card = {
    -- Assign a card as owned by a player
    Assign = (function( card, player, highlight )
        local pColor = player.color
        if card.tag ~= "Card" then
            return false
        end
        if ( highlight == nil ) then
            highlight = true
        end
        if playingHands[ pColor ] == nil then
            playingHands[ pColor ] = {}
        end

        card.setVar( "player", pColor )

        if ( highlight == true ) then
            card.highlightOn( pColor )
        end

        table.insert( playingHands[ pColor ], card.guid )
    end),
    -- Check if two cards match by at least one color
    ColorMatch = (function( cardA, cardB )
        if cardA.tag ~= "Card" or cardB.tag ~= "Card" then
            return false
        end
        cardAColors = cardA.getTable("face_color")
        cardBColors = cardB.getTable("face_color")
        for x = 1, #cardAColors do
            cardAColor = cardAColors[x]
            for y = 1, #cardBColors do
                cardBColor = cardBColors[y]
                if cardAColor == cardBColor then
                    return true
                end
            end
        end
        return false
    end),
    ColorString = (function( card )
        if card.tag ~= "Card" then
            return ""
        end

        local faceColor = ''
        local cardColors = card.getTable( "face_color" )
        if cardColors == nil then
            return ""
        end

        for i = 1, #cardColors do
            c=cardColors[i]
            faceColor=faceColor..( faceColor == "" and "" or "/" )..c
        end

        return faceColor
    end),
    -- [[ Move the card into the bag ]]
    Discard = (function( card, seconds )
        Wait.frames((function()
            bag.putObject( card )
        end), seconds * 2 )
    end),
    -- [[ Move the card into the deck ]]
    moveToDeck = (function ( card )

        card.use_gravity = true

        local rotation = shallowcopy( topCard.rotation )
        local position = shallowcopy( topCard.position )

        if stak_GUID ~= "" then
            local stack = getObjectFromGUID( stak_GUID )
            if stack ~= nil then
                rotation = stack.getRotation()
                position = stack.getPosition()
            end
        end

        position.y = position.y + 0.20

        card.setRotation( rotation )
        card.setPosition( position )
        card.setVelocity({ 0, 0, 0 })
    end),
    -- When a card is played
    Play = (function()
    end),
    -- If a card can be played down
    Playable = (function( player, cardObj, jumpin )
        -- If "jumpin" not set in parameter
        if ( jumpin == nil ) or ( not _G.house.JumpIn ) then
            jumpin = false
        end
        if not player.seated then
            return false
        end

        -- Check who's turn it is
        if Turns.enable then
            if ( Turns.turn_color ~= player.color ) and ( not jumpin ) then
                return false
            end
        end

        playFace = cardObj.getVar( "face_value" )
        playColors = cardObj.getTable( "face_color" )

        -- If player has to draw, only accept stacked cards or NO!
        if ( turnDraw > 0 or #playColors == 0 ) and not ( playFace == "No!" or ( lastPlay == playFace and lastStack ) ) then
            return false
        elseif _G.playMode == "no!" and playFace ~= "No!" then
            return false
        end

        -- Match the card colors
        for c1 = 1, #playColors do
            playColor = playColors[c1]
            if playColor == "Wild" and ( not jumpin ) then
                -- If player plays a wild
                if playFace == "No!" then
                    -- If wild is a No, and an attack has not been played, or attacker is not the player
                    if attacked ~= player.color or not ( lastPlay == "+2" or lastPlay == "+3" or lastPlay == "+4" or lastPlay == "+8" or lastPlay == "Skip" ) then
                        return false
                    end
                end
                return true
            else
                if lastColors == nil then
                    return false
                end
                for c2 = 1, #lastColors do
                    lastColor = lastColors[ c2 ]
                    if ( ( jumpin and _G.house.JumpIn ) and ( playFace == lastPlay ) and ( lastColor == playColor ) ) then
                        return true
                    end
                    if ( ( lastColor == "Wild" ) or ( lastColor == playColor ) ) and ( not jumpin ) then
                        return true
                    end
                end
            end
        end

        -- Match the color faces
        if playFace == lastPlay and lastStack and ( not jumpin ) then
            -- If can't stack draws
            if not _G.house.StackDraws and ( (playFace == "+2") or (playFace == "+3") or (playFace == "+4") or (playFace == "+8") ) then
                return false
            end
            return true
        end
        return false
    end)
}

Container = {
    Has = (function( container, object )
        if container ~= nil and object ~= nil then
            local cards = container.getObjects()
            if #cards > 2 then
                return false
            end
            for c = 1, #cards do
                local card = cards[c]
                if card.guid == object.guid then
                    return true
                end
            end
        end
        return false
    end)
}

Players = {
    -- Announce the new turn
    AnnounceTurn = (function( player )
        if player.seated then
            UI.setAttributes( "turnIndicator", { visibility = player.color })
            if doAnnounceTurns then
                printToAll( "", color_white )
                broadcastToAll( "It's " .. Players.Name( player ) .. "'s turn!"..( turnDraw > 0 and " Draw "..turnDraw.." cards" or "" ), color_white )
                return true
            end
        end
        return false
    end),
    -- Deal cards to a player
    Deal = (function( pColor, nCards )
        for d = 0, nCards - 1 do
            Wait.frames((function()
                -- Shuffle the bag
                bag.shuffle()
                -- Deal 1 card to the player
                bag.deal( 1, pColor )
            end), 15 * d)
        end
    end),
    -- Draw cards for a player
    Draw = (function( pColor )
        local player = Player[ pColor ]

        -- Position to spawn card at
        local position = bag.getPosition()
        position["y"] = position.y - 1

        -- Count down draw requirement
        if _G.attacked == pColor and _G.turnDraw > 0 then
            _G.turnDraw = _G.turnDraw - 1
        end

        local count = _G.drawCount

        -- Check bag count
        local bagRemaining = bag.getObjects()
        log( Players.Name( player ) .. " card from bag, " .. #bagRemaining .. " cards remaining." )

        if #bagRemaining <= 0 then
            broadcastToColor( "Can't draw card. Deck is empty.", pColor, color_red )
            return false
        end

        -- Shuffle the bag
        _G.bag.shuffle()
        -- Deal object from the bag
        _G.bag.takeObject({
            -- When the card is done spawning
            callback_function = (function( obj )
                local player = Player[ pColor ]
                local playable = nil

                Wait.condition((function()
                    local faceVal = obj.getVar( "face_value" )

                    if faceVal ~= nil then
                        printToColor( count .. ". You drew \"" .. Card.ColorString( obj ) .. " " .. obj.getVar( "face_value" ) .. "\".", pColor, color_green )
                    end

                    local pCount = tonumber( playingHands[ pColor ] )
                    if ( ( pCount ~= nil ) and ( pCount < 10 ) and ( faceVal == "Discard" ) ) then
                        Players.Draw( pColor )
                        return
                    end

                    Card.Assign( obj, player )

                    if ( playerSettings[ pColor ].doDrawPlay == true ) then
                        if playable == nil then
                            playable = Card.Playable( player, obj )
                        end
                        if playable then
                            Card.moveToDeck( obj )
                            return
                        end
                    end

                    if doRuleDrawOne then
                        if playable == nil then
                            playable = Card.Playable( player, obj )
                        end
                        if not playable then
                            Players.ShiftTurns( true )
                        end
                    end

                    obj.deal( 1, pColor )
                end), (function()
                    return not obj.loading_custom
                end))
            end),
            -- Card should start flipped over
            rotation = { 360, 180, 180 },
            position = position,
            top = false,
            smooth = false
        })
        return true
    end),
    GetHandZone = (function( pColor )
        for id, color in pairs( _G.handZones ) do
            if ( pColor == color ) then
                return getObjectFromGUID( id )
            end
        end
        return nil
    end),
    -- Return the players owned cards
    Hand = (function( player )
        local pColor = player.color
        if playingHands[ pColor ] == nil then
            return {}
        end
        local guids = shallowcopy( playingHands[ pColor ] )
        local hand = {}
        for g = 1, #guids do
            local guid = guids[g]
            local card = getObjectFromGUID( guid )
            if card ~= nil then
                if card.tag == "Card" and card.getVar( "player" ) == pColor then
                    table.insert( hand, card )
                end
            end
        end
        return hand
    end),
    -- Return the players name
    Name = (function( player )
        local steam_id = string.lower( player.steam_id )
        if ( playerNick[ steam_id ] ~= nil ) then
            return playerNick[ steam_id ]
        end
        return player.steam_name
    end),
    -- rotate player hands
    RotateHands = (function( startingColor, rotateColors )
        if not Turns.enable then
            return
        end

        local first = nil
        local swapCards = {}

        -- Stop if last card
        local hand = Player[ startingColor ].getHandObjects()
        if #hand <= 0 then
            return
        end

        if not Turns.reverse_order then
            rotateColors = ReverseTable( rotateColors )
        end

        local hands = {}
        for r = 1, #rotateColors do
            local color = rotateColors[r]
            local player = Player[ color ]
            hands[ color ] = Players.Hand( player )
        end
        _G.playingHands = {}

        -- Iterate each player
        for r = 1, #rotateColors do
            local color = rotateColors[r]
            local hand = hands[ color ]

            -- Get player info
            local player = Player[ color ]

            if player.seated then
                if first == nil then
                    first = color
                end

                local nextColor = nil
                if rotateColors[ r + 1 ] == nil then
                    nextColor = first
                else
                    for rx = r + 1, #rotateColors do
                        local nextPlayer = Player[ rotateColors[ rx ] ]
                        if nextPlayer.seated and nextColor == nil then
                            nextColor = nextPlayer.color
                        end
                    end
                    if nextColor == nil then
                        nextColor = first
                    end
                end

                local nextPlayer = Player[ nextColor ]

                -- Add hand to collection
                for count, card in pairs( hand ) do
                    Card.Assign( card, nextPlayer, false )
                    table.insert( swapCards, card )
                end

                -- Player call UNO automatically
                local newHand = _G.playingHands[ nextColor ]
                if #newHand == 1 then
                    broadcastToAll( Players.Name( nextPlayer ) .. ": Uno!", color_green )
                    _G.unoHolders[ nextColor ] = true
                end
            end
        end

        log( "Rotating player hands" )

        -- Rotate hands around
        for c = 1, #swapCards do

            Wait.frames((function()

                local swapCard = swapCards[c]

                if ( swapCard ~= nil ) then
                    pColor = swapCard.getVar( "player" )

                    local pHand = Player[pColor].getHandTransform()
                    pHand.rotation.y = pHand.rotation.y - rotation

                    swapCard.setPosition( pHand.position )
                    swapCard.setRotation( pHand.rotation )
                end

            end), ( c * 2 ) + 20 )
        end
    end),
    -- Shift to next turn
    ShiftTurns = (function( announce )
        -- Return if turns are disabled
        if not Turns.enable then
            return
        end

        -- Get existing players turn
        local turnPlayer = Player[ Turns.turn_color ]
        log( "-- " .. Players.Name( turnPlayer ) .. " has ended their turn." )

        Turns.turn_color = Turns.getNextTurnColor()

        -- Get new players turn
        turnPlayer = Player[ Turns.turn_color ]
        log( "-- It is now " .. Players.Name( turnPlayer ) .. "'s turn" )

        if announce then
            Players.AnnounceTurn( turnPlayer )
        end
    end),
    -- swap player hands
    SwapHands = (function( colorA, colorB )
        if colorA == colorB then
            return
        end
        Players.RotateHands( colorA, {
            colorA,
            colorB
        })
    end),
}

-- [[ Called when a card is played ]]
function onPlayedCard( player, cardObj )
    if not player.seated then
        return
    end

    local cardColors = cardObj.getTable( "face_color" )
    local faceColor = Card.ColorString( cardObj )
    local face = cardObj.getVar( "face_value" )

    if faceColor == "Wild" then
        if face == "No!" or face == "Discard" then
            cardColors = cardObj.getTable( "wild_colors" )
        else
            showColorSelect( player.color, cardObj.getTable( "wild_colors" ) )
            cardColors = {}
        end
    end

    local hand = player.getHandObjects()

    -- Reverse for last card
    if Turns.enable then
        if _G.lastPlay == "Delayed Reverse" then
            Turns.reverse_order = not Turns.reverse_order
        end

        -- Reverse again for reverse card
        if face == "Reverse" then
            Turns.reverse_order = not Turns.reverse_order
        end

        -- If player is jumping in
        if ( Turns.turn_color ~= player.color ) then
            broadcastToAll( Players.Name( player ) .. " jumped in!", color_red )
            Turns.turn_color = player.color
            Players.ShiftTurns( true )
            return
        end

        -- If not No, and not Discard, end turn.
        if ( face ~= "No!" and face ~= "Discard" ) or ( face == "Discard" and #hand <= 1 ) then
            if player.color == Turns.turn_color then
                Players.ShiftTurns( false )
            end
        end
    end

    local discardSize = 0
    if _G.lastPlay == "Discard" then
        local hand = player.getHandObjects()
        local handCount = #hand
        if handCount <= 1 then
            Players.ShiftTurns( false )
        else
            for i = 1, #hand do
                local handCard = hand[i]
                if Card.ColorMatch( cardObj, handCard ) then
                    handCount=handCount-1
                    if handCount > 0 then
                        discardSize=discardSize+1
                        log( Players.Name( player ) .. " disposes of a \"" .. Card.ColorString( handCard ) .. " " .. handCard.getVar( "face_value" ) .. "\" card" )
                        Card.Discard( handCard, i - 1 )
                    end
                end
            end
        end
    end

    -- Print the played card
    log( Players.Name( player ) .. " plays a card" )
    if _G.doCardAnnounce then
        printToAll( Players.Name( player ) .. " plays card \"" .. faceColor .. ( face == "" and "" or " " ) .. face .. "\".", color_lime )

        if discardSize > 0 then
            printToAll( Players.Name( player ) .. " discards " .. discardSize .. " cards.", color_yellow )
        end
    end

    -- Increase the amount of cards the next player needs to draw
    if face == "+8" then
        _G.turnDraw = 8
        _G.attacked = Turns.turn_color
    elseif face == "+4" then
        _G.turnDraw = 4
        _G.attacked = Turns.turn_color
    elseif face == "+3" then
        if _G.house.StackDraws then
            _G.turnDraw = turnDraw + 3
        else
            _G.turnDraw = 3
        end
        _G.attacked = Turns.turn_color
    elseif face == "+2" then
        if _G.house.StackDraws then
            _G.turnDraw = turnDraw + 2
        else
            _G.turnDraw = 2
        end
        _G.attacked = Turns.turn_color
    else -- Attack cards [ Not draws ]
        _G.turnDraw = 0
        if face == "Skip" then
            _G.attacked = Turns.turn_color
        else -- Non-attack cards
            _G.attacked = nil
        end
    end

    -- Set the last played card by PLAYER
    _G.lastPlay = face
    setPlayingColor( cardColors )
    _G.lastStack = cardObj.getVar( "is_stackable" )
    _G.playMode = 'draw'

    local wasAnnounced = false

    -- Check hand for No! or stacking cards
    if Turns.enable then
        local deck = getObjectFromGUID( deck_GUID )

        local pHasNope=false
        local pHasPlusTwo=false
        local pHasPlusThr=false

        local nextPlayer = Player[ Turns.turn_color ]
        local nextHand = nextPlayer.getHandObjects()
        for h = 1, #nextHand do
            nextFace = nextHand[ h ].getVar( "face_value" )
            if type( nextFace ) ~= "nil" then
                if nextFace == "No!" then
                    pHasNope=true
                elseif nextFace == "+2" and _G.house.StackDraws then
                    pHasPlusTwo=true
                elseif nextFace == "+3" and _G.house.StackDraws then
                    pHasPlusThr=true
                end
            end
        end

        local pSettings = playerSettings[ nextPlayer.color ]

        -- Automatically do an action
        if lastPlay == "Skip" then
            -- Player gets skipped
            if not pHasNope or pSettings.noSkipPass then
                broadcastToColor( "You've been skipped!", nextPlayer.color, color_red)
                Players.ShiftTurns( false )
            else
                wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                broadcastToColor( "You've been skipped! Play your \"No!\" card, or type \"endturn\" to end your turn.", nextPlayer.color, color_yellow )
                _G.playMode = 'no!'
            end
        elseif lastPlay == "+8" then
            -- Player draws 8 cards
            if ( not pHasNope ) or pSettings.noDrawPassWild then
                if doAutoDraw then
                    if doCardCount then
                        printToAll( Players.Name( nextPlayer ) .. " draws 8 cards.", color_green )
                    end
                    lastDraw=Turns.turn_color
                    Players.Deal( Turns.turn_color, 8 )
                    turnDraw=0
                    drawCount=9
                    Players.ShiftTurns( false )
                else
                    wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                    broadcastToColor( "You have to draw 8 cards!", nextPlayer.color, color_red )
                end
            else
                wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                broadcastToColor( "You have to draw 8 cards! Play your \"No!\" card, or click the draw button!", nextPlayer.color, color_yellow )
            end
        elseif lastPlay == "+4" then
            -- Player draws 4 cards
            if ( not pHasNope ) or pSettings.noDrawPassWild then
                if doAutoDraw then
                    if doCardCount then
                        printToAll( Players.Name( nextPlayer ) .. " draws 4 cards.", color_green )
                    end
                    lastDraw=Turns.turn_color
                    Players.Deal( Turns.turn_color, 4 )
                    turnDraw=0
                    drawCount=5
                    Players.ShiftTurns( false )
                else
                    wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                    broadcastToColor( "You have to draw 4 cards!", nextPlayer.color, color_red )
                end
            else
                wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                broadcastToColor( "You have to draw 4 cards! Play your \"No!\" card, or click the draw button!", nextPlayer.color, color_yellow )
            end
        elseif lastPlay == "+3" then
            -- Player draws 3 cards
            if not ( pHasNope or pHasPlusThr ) or pSettings.noDrawPass then
                if doAutoDraw then
                    if doCardCount then
                        printToAll( Players.Name( nextPlayer ) .. " draws " .. turnDraw .. " card" .. ( turnDraw ~= 1 and "s" or "" ) .. ".", color_green )
                    end
                    lastDraw=Turns.turn_color
                    Players.Deal( Turns.turn_color, turnDraw )
                    turnDraw=0
                    drawCount=turnDraw+1
                    Players.ShiftTurns( false )
                else
                    wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                    broadcastToColor( "You have to draw "..turnDraw.." cards!", nextPlayer.color, color_red )
                end
            else
                wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                broadcastToColor( "You have to draw "..turnDraw.." cards! Play a \"No!\" card, a \""..lastPlay.."\" card, or click the draw button!", nextPlayer.color, color_yellow )
            end
        elseif lastPlay == "+2" then
            -- Player draws 2 cards
            if not ( pHasNope or pHasPlusTwo ) or pSettings.noDrawPass then
                if doAutoDraw then
                    if doCardCount then
                        printToAll( Players.Name( nextPlayer ) .. " draws " .. turnDraw .. " card" .. ( turnDraw ~= 1 and "s" or "" ) .. ".", color_green )
                    end
                    lastDraw=Turns.turn_color
                    Players.Deal( Turns.turn_color, turnDraw )
                    turnDraw=0
                    drawCount=turnDraw+1
                    Players.ShiftTurns( false )
                else
                    wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                    broadcastToColor( "You have to draw "..turnDraw.." cards!", nextPlayer.color, color_red )
                end
            else
                wasAnnounced = Players.AnnounceTurn( Player[ Turns.turn_color ] )
                broadcastToColor( "You have to draw " .. turnDraw .. " cards! Play a \"No!\" card, a \""..lastPlay.."\" card, or click the draw button!", nextPlayer.color, color_yellow )
            end
        end
    end

    -- Reset the draw counter
    _G.drawCount = 1
    _G.lastDraw = ''

    -- Announce who gets to go next
    if Turns.enable and not wasAnnounced then
        Players.AnnounceTurn( Player[ Turns.turn_color ] )
    end

    -- Swap hands
    if face == "0" and _G.house.Rotate then
        Wait.frames((function()
            broadcastToAll( Players.Name( player ) .. " is rotating hands!", color_yellow )
            Players.RotateHands( player.color, colors )
        end), 60)
    elseif face == "7" and _G.house.Switch then
        updateTradeableColors( player.color )
        UI.setAttributes( "tradePlayersBox", {
            visibility = player.color
        })
        UI.show( "tradePlayersBox" )
    end
end

-- [[ When game is saved ]]
function onSave()

    local save = JSON.encode({
        nicknames = _G.playerNick,
        rules = _G.house
    })

    return save
end

--[[ The OnLoad function. This is called after everything in the game save finishes loading.
Most of your script code goes here. --]]
function onLoad( saveData )

    local validSettings = {
        doCardThrows = true,
        noSkipPass = false,
        noDrawPass = false,
        noDrawPassWild = false,
        doDrawPlay = false
    }

    for c = 1, #colors do

        local color = colors[c]

        -- Get player RBG
        local objColor = colorIds[color]
        local rgb = {
            r = objColor.r / 255,
            g = objColor.g / 255,
            b = objColor.b / 255
        }

        -- Modify Buttons
        local gameId = gameIds[ color ]

        gameObj = getObjectFromGUID( gameId )
        gameObj.setColorTint( rgb )
        gameObj.interactable = false
        gameObj.setVar( "playing", false )
        gameObj.setVar( "player_color", color )

        dbParams.rotation = { 90, rotation, 0 }

        rotation=rotation-45

        -- Create button
        gameObj.createButton( dbParams )

        -- Create default player settings
        playerSettings[ color ] = shallowcopy( validSettings )
    end

    -- Lock color-UI cube
    local cube = getObjectFromGUID( _G.color_cube )
    cube.interactable = false
    cube.setLock( true )

    -- Lock di bag
    local di = getObjectFromGUID( _G.die_GUID )
    di.interactable = false
    di.setLock( true )
    di.setPosition({
        x = 0,
        y = -1,
        z = 0
    })

    -- Lock bag in place
    bag = getObjectFromGUID( _G.deck_GUID )
    bag.interactable = false
    bag.setLock( true )
    bag.setPosition({
        x = 0,
        y = -3,
        z = 0
    })
    local cards = bag.getObjects()

    -- Lock card zone in place
    local zone = getObjectFromGUID( _G.zone_GUID )
    zone.interactable = false
    zone.setLock( true )

    -- Update UI
    updateTradeableColors( "" )
    houseRulesToNotes()

    -- Update UI values
    UI.setAttributes( "deckLimit", {
        maxValue = #cards,
        value = _G.deckLimit
    })

    -- Load values from save


    -- Clear chat log
    for p = 1, 20 do
        printToAll( "" )
    end

    if ( saveData ~= "" ) then
        local loadData = JSON.decode( saveData )
        -- Get saved nicknames
        if ( loadData.nicknames ~= nil ) then
            _G.playerNick = loadData.nicknames
        end
        -- Load Rule values
        if ( loadData.rules ~= nil ) then
            local rules = loadData.rules
            for rule, val in pairs( rules ) do
                uiUpdateBool( nil, ( val and "True" or "False" ), rule )
            end
        end
        --print( saveData )
    end
    print('Finished loading Uno.')
end

function updateTradeableColors( visibleColor )
    local count = 0
    for p = 1, #colors do
        local pColor = colors[p]
        local player = Player[pColor]
        local pHand = player.getHandObjects()
        local pName = ""
        local show = ""

        if player.seated and visibleColor ~= pColor then
            pName = Players.Name( player )
            show = visibleColor
            count = count + 1
        else
            pName = ""
            show = "Nobody"
        end
        UI.setAttributes( "seatIdentity"..pColor, {
            text = pName.." ("..#pHand.." Cards)",
            visibility = show
        })
    end
    UI.setAttributes( "tradePlayersBox", {
        height = ( count * 60 ) + 36
    })
end

-- [[ When player changes color ]]
function onPlayerChangeColor( pColor )
    if _G.gameIds[pColor] ~= nil then
        player = Player[pColor]
        UI.setAttributes("seatIdentity"..pColor, {
            text = Players.Name( player ),
            visibility = ""
        })
        printToAll( "> " .. Players.Name( player ) .. " takes a seat at the table.", player.color )
    else
        updateTradeableColors( "" )
    end
end

--[[ The Object Pickup Function, called when an object is picked up --]]
function onObjectPickedUp( pColor, dObject )
    if dObject.guid == stak_GUID then
        dObject.setRotation( topCard.rotation )
        dObject.setPosition( topCard.position )
        dObject.setVelocity( { 0, 0, 0 } )
    elseif dObject.tag == "Card" then
        -- On card pickup
        cardOwner = dObject.getVar( "player" )
        if cardOwner == nil then
            return
        elseif cardOwner ~= pColor then
            broadcastToColor( "That is not your card!", pColor, color_red )
            dObject.deal( 1, cardOwner )
        end
    end
end

--[[ The Object Drop Function, called when an object is dropped --]]
function onObjectDropped( pColor, dObject )
    local player = Player[ pColor ]
    local now = os.time(os.date("!*t"))

    deck = dObject.getVar( "deck" )
    disc = dObject.getVar( "discard" )
    time = dObject.getVar( "time" )

    if dObject.guid == stak_GUID then

        dObject.setRotation( topCard.rotation )
        dObject.setPosition( topCard.position )
        dObject.setVelocity( { 0, 0, 0 } )

    elseif dObject.tag == "Card" then
        -- If object being dropped is a card
        if time ~= nil and playerSettings[ pColor ].doCardThrows == true then
            -- If time is set
            diff = now - time
            if diff < 2 then
                if _G.doValidateCards and not Card.Playable( player, dObject, Turns.enable and ( Turns.turn_color ~= pColor ) ) then
                    broadcastToColor( "You cannot play that card!" .. ( _G.turnDraw > 0 and " You need to draw "..turnDraw.." cards." or "" ) .. ( _G.playMode == "no!" and " You need to play your \"No!\" card, or end your turn." or "" ), pColor, color_red )
                    dObject.deal( 1, pColor )
                    return
                end
                Card.moveToDeck( dObject )
                return
            end
        end
        -- If object is in deck zone
        if deck then

            -- Check if player is saved to the card
            savePlayer = dObject.getVar( "player" )
            if savePlayer ~= nil then
                pColor = savePlayer
                player = Player[ pColor ]
            end

            -- Check if card can be played
            if doValidateCards and not Card.Playable( player, dObject, Turns.enable and ( Turns.turn_color ~= pColor ) ) then
                broadcastToColor( "You cannot play that card!" .. ( turnDraw > 0 and " You need to draw " .. turnDraw .. " cards." or "" ) .. ( _G.playMode == "no!" and " You need to play your \"No!\" card, or end your turn." or "" ), pColor, color_red )
                dObject.deal( 1, pColor )
                return
            end

            -- Play the card
            Card.moveToDeck( dObject )
        end
    end
end

--[[ The Zone Enter Function, called when an object enters a zone --]]
function onObjectEnterScriptingZone( zone, dObject )
    -- If zone or object missing
    if zone == nil or dObject == nil then
        return
    end

    if dObject.tag ~= "Card" then
        return
    end

    local guid = zone.guid

    dObject.setVar( "time", nil )

    if guid == _G.zone_GUID then
        -- Place object in deck
        dObject.setVar( "deck", true )

    elseif _G.handZones[ guid ] ~= nil then
        local pColor = _G.handZones[ guid ]
        local player = Player[ pColor ]
        if dObject.getVar( "player" ) == nil then

            dObject.use_hands = true
            Card.Assign( dObject, player )

        else
            if dObject.held_by_color == _G.handZones[ guid ] then
                dObject.use_hands = true
            end
        end
    end
end

--[[ The Zone Leave Function, called when an object leaves a zone --]]
function onObjectLeaveScriptingZone( zone, dObject )
    -- If zone or object missing
    if zone == nil or dObject == nil then
        return
    end
    if dObject.tag ~= "Card" then
        return
    end

    local guid = zone.guid

    if guid == _G.zone_GUID then
        -- Don't place in deck
        dObject.setVar( "deck", nil )

    elseif _G.handZones[ guid ] ~= nil then

        -- If nobody is holding the object
        if dObject.held_by_color == nil then
            return
        end

        -- When leaving hand, assign player name to card
        pColor = _G.handZones[ guid ]
        hColor = dObject.held_by_color
        player = Player[ pColor ]
        -- Ignore if not seated
        if not player.seated or ( ( not started ) or canend ) then
            return
        end
        -- Check if card can be played
        face = dObject.getVar( "face_value" )
        if face ~= nil then
            cardOwner = dObject.getVar( "player" )
            if ( pColor == cardOwner and doValidateCards ) and not Card.Playable( player, dObject, Turns.enable and ( Turns.turn_color ~= pColor ) ) then
                broadcastToColor( "You cannot play that card!" .. ( turnDraw > 0 and " You need to draw "..turnDraw.." cards." or "" ) .. ( _G.playMode == "no!" and " You need to play your \"No!\" card, or end your turn." or "" ), pColor, color_red )
                dObject.deal( 1, cardOwner )
                return
            elseif ( pColor == cardOwner ) then
                dObject.use_hands = false
            end
        end
        -- Assign time span to "quickplay"
        if hColor ~= nil then
            if pColor == hColor then
                time = os.time(os.date("!*t"))
                dObject.setVar( "time", time )
            end
        end
    end
end

-- [[ Custom chat commands ]]
function onChat( message, player )
    -- Lowercased name
    local name = string.lower( player.steam_name )
    local id = player.steam_id
    -- Split message
    local split = {}
    message:gsub( "([^ ]*)", function( i )
        table.insert( split, i )
    end)
    if ( startsWith( ".", message ) ) then
        printToColor( ( playerNick[ id ] ~= null and playerNick[ id ] or player.steam_name ) .. ": " .. message, player.color, player.color )
        -- Check message
        if ( message == ".help" ) then
            local helpData = {
                "==== BEGIN HELP ====",
                " .help - Display this information",
                " .endturn - End your turn if you become stuck",
                " .endgame - Prematurely end the game",
                " .nick - Set your nickname for chat",
                "==== END OF HELP ===="
            }
            printToColor( table.concat( helpData, "\n" ), player.color, color_yellow )

        elseif ( message == ".endturn" or message == ".end turn" ) then
            if not Turns.enable then
                -- Turns disabled
                printToColor( "Turns are not enabled!", player.color, color_red )
            elseif Turns.turn_color ~= player.color then
                -- Not players turn
                printToColor( "You cannot end your turn, it isn't your turn!", player.color, color_red )
            elseif turnDraw > 0 then
                -- Player must draw cards
                printToColor( "You cannot end your turn, you've got "..turnDraw.." cards to draw!", player.color, color_red )
            else
                -- End players turn
                _G.playMode = 'draw'
                attacked = nil
                Players.ShiftTurns( true )
            end

        elseif ( message == ".endgame" or message == ".end game" ) and ( player.admin or player.promoted ) then
            if ( not started ) then
                printToColor( "> Game has not yet started", player.color, color_red )
                return false
            end

            onUnoEnd( player )

        elseif ( message == ".test rotate" ) and ( player.admin or player.promoted ) then
            Players.RotateHands( player.color, colors )

        elseif ( message == ".test color" ) and ( player.admin or player.promoted ) then
            showColorSelect( player.color, validCardColors )

        elseif ( ( #split > 0 ) and ( split[1] == ".nick" ) ) then
            nick = string.sub( message, string.len( split[1] ) + ( ( #split > 1 ) and 2 or 1 ) ):gsub( "%s+$", " " ):gsub( "^%s+", "" )
            if ( nick == "" ) then
                printToColor( "No nickname was specified. Please type the command as such \".nick " .. player.steam_name ..  "\" or \".nick YourNameHere\".", player.color, color_red )
                return false
            end
            if ( string.len( nick ) >= 32 ) then
                printToColor( "That nickname is too long", player.color, color_red )
                return false
            end

            printToAllExcept( player.steam_name .. " is now known as \"" .. nick .. "\"", player.color, color_green )
            printToColor( "Nickname updated to \"" .. nick .. "\"", player.color, color_green )

            playerNick[ id ] = nick
        else
            printToColor( "Unknown command \"" .. message .. "\", Try \".help\"", player.color, color_red )

        end
        return false
    else
        printToAll( ( playerNick[ id ] ~= null and playerNick[ id ] or player.steam_name ) .. ": " .. message, player.color )
        return false

    end
    return true
end

--[[ The Update function. This is called once per frame. --]]
function update()
    local zone = getObjectFromGUID( zone_GUID )
    bag = getObjectFromGUID( deck_GUID )

    if zone == nil then
        return
    end

    if stak_GUID ~= "" then

        local deck = getObjectFromGUID( stak_GUID )

        if deck ~= nil then

            deck.use_gravity = false
            deck.setPosition( topCard.position )

            local rotateAmount = -45

            if Turns.enable then
                rotateAmount = ( Turns.reverse_order and rotateAmount or 0 - rotateAmount )
            end

            local rotation = deck.getRotation()
            deck.setRotation({ x = 0, y = rotation.y, z = 0 })
            deck.rotate({ x = 0, y = rotateAmount, z = 0 })

        end
    end

    local objects = zone.getObjects()

    for i = 1, #objects do
        local object = objects[ i ]
        local tag = object.tag
        if tag == "Deck" then
            object.interactable = false
            stak_GUID = object.guid
            local deck = object.getObjects()
            if deckSize ~= #deck then
                object.highlightOff()
            end
            deckSize = #deck
            if #deck > _G.deckLimit then
                local cardId = deck[1].guid
                local card = object.takeObject({
                    guid = cardId
                })
                bag.putObject( card )
                lastDraw = ''
            end
        end
    end

    -- Add players to empty array
    local colorCards = {}

    -- Count cards on the table
    local allFieldObjects = getAllObjects()
    for ob = 1, #allFieldObjects do
        local object = allFieldObjects[ob]
        if object.tag == "Card" then
            local card_owner = object.getVar("player")
            if card_owner ~= nil then
                colorCards[ card_owner ] = ( colorCards[ card_owner ] == nil and 0 or colorCards[ card_owner ] ) + 1
            end
        end
    end

    -- Update players counters
    for c = 1, #colors do
        local color = colors[c]
        -- If player has counter
        if gameIds[ color ] ~= nil then
            local player = Player[ color ]
            local steam_id = player.steam_id

            local count = ( colorCards[ color ] == nil and 0 or colorCards[ color ] )
            local counter = getObjectFromGUID( gameIds[ color ] )
            local oldCount = tonumber( counter.UI.getValue( "counter" ) )

            -- Update card change
            if count ~= oldCount then
                onCardCountChange( player, count )
            end

            if started then
                if ( count == 1 or count == 0 ) and ( player.seated and InArray( color, playingColors ) ) then
                    -- For empty hand
                    if count == 0 and not canend then
                        -- Enable game-ending button
                        canend=true

                        Turns.enable = false

                        -- Announce winner
                        broadcastToAll( Players.Name( player ) .. " wins the game!", color_green )
                        playerWins[ steam_id ] = ( playerWins[ steam_id ] ~= nil and playerWins[ steam_id ] or 0 ) + 1

                        -- Change button tooltip
                        for c = 1, #colors do
                            subColor = colors[c]

                            tGame = getObjectFromGUID( gameIds[ subColor ] )
                            tGame.editButton( { tooltip = 'End Game' } )
                            UI.setAttributes( "drawButton", {
                                text = "End Game",
                                color = "Red",
                                textColor = "White",
                                tooltip = "End the current game (NUMPAD5)"
                            })
                        end
                    end

                    -- Turn on highlight
                    if doCounterFX then
                        counter.highlightOn( player.color )
                    else
                        counter.highlightOff()
                    end
                else
                    -- Turn off highlight
                    if not ( canend and doCounterFX ) then
                        counter.highlightOff()
                    end
                end
            else
                -- If game is not started, set count to number of wins
                count = ( playerWins[ steam_id ] ~= nil and playerWins[ steam_id ] or 0 )
            end

            local counterVal = ( player.seated and count or "" )
            if counter.UI.getValue( "counter" ) ~= counterVal then
                counter.UI.setValue( "counter", counterVal )
            end
        end
    end
end

-- Color selector
function showColorSelect( pColor, colors )
    -- Update who can change the color
    _G.playColorChange = pColor

    -- Update cube
    local cube = getObjectFromGUID( _G.color_cube )

    -- Rotate to player
    if _G.gameIds[ pColor ] ~= nil then
        local triangle = getObjectFromGUID(_G.gameIds[ pColor ]).getRotation()
        local rotation = cube.getRotation()
        rotation.z = 45
        rotation.y = triangle.y - 90
        cube.setRotation( rotation )

        rotation.z = 15
        cube.setRotationSmooth( rotation, false, false )
    end

    -- Hide all valid colors from the selector
    for c = 1, #validCardColors do
        local color = validCardColors[c]
        cube.UI.setAttributes( color, {
            visibility = "Nobody"
        })
    end
    -- Show all colors from the list
    for c = 1, #colors do
        local color = colors[c]
        cube.UI.setAttributes( color, {
            visibility = ""
        })
    end
    cube.UI.setAttributes( "container", {
        width = #colors * 450
    })
    cube.UI.show( "container" )
end

-- [[ When a player selects the new playable color ]]
function onColorSelect( player, value, id )
    -- Check if player is allowed
    if ( _G.playColorChange ~= player.color ) then
        return
    end

    -- Update cube
    local cube = getObjectFromGUID( _G.color_cube )

    log("The color is now "..value)

    broadcastToAll( Players.Name( player ) .. " changed the color to "..value, color_yellow )

    cube.UI.hide( "container" )

    setPlayingColor({ value })
end

-- [[ Update the playable color ]]
function setPlayingColor( newColors )
    lastColors = newColors
    local div = #colors / #newColors
    if ( ( #newColors == 0 ) or ( #newColors > 2 ) ) then
        return
    end
    -- Update middle tiles to card colors
    for c = 1, #colors do
        Wait.frames((function()
            local color = colors[c]
            local counter = getObjectFromGUID( gameIds[ color ] )
            local objectColor = cardColorIds[( div >= c and newColors[1] or newColors[2] )]
            local rgb = {
                r = objectColor.r / 255,
                g = objectColor.g / 255,
                b = objectColor.b / 255
            }
            counter.setColorTint( rgb )
        end), c * 2)
    end
end

-- [[ When a player selected another player to trade cards with ]]
function onPlayerSelect( player, value, selectId )
    local color = UI.getAttribute( selectId, "color" )
    local oPlayer = Player[ color ]
    broadcastToAll( Players.Name( player ) .. " is trading cards with " .. Players.Name( oPlayer ), color_yellow )
    UI.hide( "tradePlayersBox" )
    Players.SwapHands( player.color, color )
end

-- [[ When the number of cards a player is holding changes ]]
function onCardCountChange( player, count )
    if ( count > 1 ) and ( unoHolders[ player.color ] == true ) then
        log( Players.Name( player ) .. " no longer has uno (has "..count.." cards)" )
        unoHolders[ player.color ] = nil
    end
end

-- Player-Specific Bools
function buttonUpdatePlayerBool( player, value, id )
    local bool = ( value == "True" )
    if ( player.color == "Grey" ) then
        return
    end
    playerSettings[ player.color ][ id ] = bool
end

-- Global Bools
function uiUpdateBool( player, value, id )
    local val = _G[ id ]
    if player == nil or player.admin then
        val = ( value == "True" )

        local houseRules = {
            StackDraws = "Stackable Draws",
            Challenge = "Challenging",
            Rotate = "Rotate on 0's",
            Switch = "Switch on 7's",
            JumpIn = "Card Jumping"
        }

        local houseRule = houseRules[ id ]
        if houseRule ~= nil then

            -- Update rule
            _G.house[ id ] = val

            -- Announce change
            if player ~= nil then
                broadcastToAll( Players.Name( player ) .. " " .. ( val and "enabled" or "disabled" ) .. " house rule \"" .. houseRule .. "\"", ( val and color_green or color_red ) )
            end

            -- Update notes accordingly
            houseRulesToNotes()

        else
            -- Update rule
            _G[ id ] = val
        end

        -- Show or hide the UNO button
        if id == "doCallUno" then
            UI.setAttributes( "callUno", { visibility = ( val and "" or "Nobody" ) })
        -- Show up in the servers list
        elseif id == "doLookForGroup" then
            setLookingForPlayers( val )
        end
    end

    UI.setAttributes( id, { isOn = val })
end

-- Print the enabled house rules to the notes section
function houseRulesToNotes()
    local output = ""

    if _G.house.Challenge then
        output = output .. "\nChallenging"
    end
    if _G.house.StackDraws then
        output = output .. "\nStackable draw"
    end
    if _G.house.JumpIn then
        output = output .. "\nJumping In"
    end
    if _G.house.Rotate then
        output = output .. "\nRotate on 0's"
    end
    if _G.house.Switch then
        output = output .. "\nSwitch on 7's"
    end

    setNotes( ( output == "" and "" or "=== Enabled House Rules ===" ) .. output )
end

-- Global Ints
function uiUpdateInt( player, value, id )
    local val = _G[ id ]
    if player.admin then
        local val = tonumber( value )
        value = tostring( val )
        _G[ id ] = val
    end
    UI.setAttributes( id, { text = value })
end

-- [[ Button to draw cards from the UI ]]
function onUIDrawEvent( player, value, id )
    local pColor = player.color
    clickedButton( getObjectFromGUID( gameIds[ pColor ] ), pColor, false )
end

-- [[ When a NUMPAD key is pressed ]]
function onScriptingButtonDown( index, pColor )
    -- 1,
    -- 2,
    -- 3,
    -- 4,
    -- 5, Draw Card
    -- 6, UNO
    -- 7,
    -- 8,
    -- 9,
    if index == 5 then
        clickedButton( getObjectFromGUID( gameIds[ pColor ] ), pColor, false )
    elseif index == 6 then
        callUno( Player[ pColor ], nil, nil )
    end
end

-- [[ Button to call Uno ]]
function callUno( player, value, id )
    if not doCallUno then
        return
    end

    local gotPlayer = false
    if _G.started then

        for c = 1, #colors do
            local color = colors[c]
            local hand = Players.Hand(Player[ color ])
            local count = #hand
            if ( count == 1 ) and ( _G.unoHolders[ color ] ~= true ) and ( color ~= player.color ) then
                local dPlayer = Player[color]
                broadcastToAll( Players.Name( dPlayer ) .. " didn't call Uno! They must draw 2 cards.", color_red )
                Players.Deal( color, 2 )
                gotPlayer = true
            end
        end

        if ( _G.unoHolders[ player.color ] ~= true ) and not gotPlayer then
            broadcastToAll( Players.Name( player ) .. ": Uno!", color_green )
            _G.unoHolders[ player.color ] = true
        end

    end
end

function startsWith( needle, haystack )
    local ndlLen = string.len( needle )
    local hayLen = string.len( haystack )
    if ( hayLen < ndlLen ) then
        return false
    end
    return string.sub( haystack, 1, ndlLen ) == needle
end

function printToAllExcept( message, player_color, text_color )
    local players = Player.getPlayers()
    for _, player in ipairs( players ) do
        if player.seated and player.color ~= player_color then
            printToColor( message, player.color, text_color )
        end
    end
end

function getHost()
    local list = Player.getPlayers()
    for _, player in ipairs( list ) do
        if player.host then
            return player
        end
    end
    return nil
end

function InArray( needle, haystack )
    for _, v in pairs( haystack ) do
        if needle == v then
            return true
        end
    end
    return false
end

function ReverseTable( t )
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function shallowcopy( orig )
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
