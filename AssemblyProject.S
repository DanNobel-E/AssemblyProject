.define initAddress $8000

;screen references
.define screenCols $10;
.define screenRows $10;
.define clearColor $00


;player init parameters
.define playerColor $01
.define paintColor $06
.define playerInitRow $07
.define playerInitCol $07

;player parameters addresses
.define currentRowAddress $00
.define currentColAddress $01
.define currentPlayerPosAddress $02
.define oldPlayerPosAddress $03
.define currentPaintAddress $04




; input keys
.define upKey $01
.define downKey $02
.define leftKey $04
.define rightKey $08
.define paintKey $20


.org initAddress

;reset stack
PLA
PLA

;main
JSR init
JSR gameLoop


init:  ;game initialization
    LDA #playerInitRow
    STA currentRowAddress
    LDA #playerInitCol
    STA currentColAddress
    JSR calculatePlayerPosition
    LDA currentPlayerPosAddress
    STA currentPaintAddress
    JSR drawPlayer
    RTS



gameLoop:           ;looping instructions
    clear:                          ;clears the screen
        JSR clearPlayerPosition
    input:                          ;reads inputs from input keys
        JSR playerInput
    update:                         ;checks paint position
        JSR paintCheck
    draw:                           ;draws player
        JSR drawPlayer
    delay:                          ;slows the simulation to optimize speed
        JSR spinWheels
    JMP gameLoop


playerInput:                ;manages player key inputs
    JSR up
    JSR down
    JSR left
    JSR right
    JSR readPaint
    inputEnd:
    RTS

;
;input controls management
;reads input keys
up:
    LDA $4000
    AND #upKey
    BNE moveUp
    RTS

down:
    LDA $4000
    AND #downKey
    BNE moveDown
    RTS

left:
    LDA $4000
    AND #leftKey
    BNE moveLeft
    RTS

right:
    LDA $4000
    AND #rightKey
    BNE moveRight
    RTS 

;sets directions
moveUp: 
    LDX currentRowAddress
    JSR downEdgeComparison
    JSR updateOldPos
    DEC currentRowAddress
    JSR calculatePlayerPosition
    JSR moveEnd

moveDown: 
    LDX currentRowAddress
    JSR upEdgeComparison
    JSR updateOldPos
    INC currentRowAddress
    JSR calculatePlayerPosition
    JSR moveEnd



moveLeft: 
    LDX currentColAddress
    JSR downEdgeComparison
    JSR updateOldPos
    DEC currentColAddress
    JSR calculatePlayerPosition
    JSR moveEnd
    


moveRight: 
    LDX currentColAddress
    JSR upEdgeComparison
    JSR updateOldPos
    INC currentColAddress
    JSR calculatePlayerPosition
    JMP moveEnd

;checks edges crossing
downEdgeComparison:
    CPX #$00
    BEQ clean
    RTS

upEdgeComparison:
    CPX #$0f
    BEQ clean
    RTS

clean:  ;cleans the stack
    PLA
    PLA
    JMP moveEnd

moveEnd:    ;cleans the stack when reading keys
    PLA
    PLA
    JMP inputEnd


readPaint:          ;reads painting key
    LDA $4000
    AND #paintKey
    BNE savePaintAddress
    RTS

savePaintAddress:       ;saves the position of the last painted pixel
    LDA currentPlayerPosAddress
    STA currentPaintAddress
    JMP moveEnd

paintCheck:             ;checks the postion of the current painted pixel
    LDX currentPaintAddress
    CPX currentPlayerPosAddress
    BNE paint
    RTS

paint:                  ;paints the current selected pixel
    LDA #paintColor
    LDY currentPaintAddress
    STA $0200,Y
    PLA
    PLA
    JMP draw
;
;

calculatePlayerPosition:     ;sets current player position
    LDA #$00
    LDX currentRowAddress
    BNE posLoop
        endPosLoop:
            ADC currentColAddress
            STA currentPlayerPosAddress
        RTS

posLoop:                    ;loops pixel array to find the correct row
    ADC #screenCols
    DEX
    BNE posLoop
    JMP endPosLoop


clearPlayerPosition:        ;clears old player position
    LDA #clearColor
    LDY oldPlayerPosAddress
    STA $0200,Y
    RTS

drawPlayer:                 ;draws player at his current position
    LDA #playerColor
    LDY currentPlayerPosAddress
    STA $0200,Y 
    RTS 

updateOldPos:               ;stores in memory old player position 
    LDX currentPlayerPosAddress
    STX oldPlayerPosAddress
    RTS

spinWheels:                 ;delays the simulation
  LDX #0
spinloop:
  NOP
  NOP
  DEX
  BNE spinloop
  RTS


.goto $FFFC
.dw initAddress
.dw $0000
