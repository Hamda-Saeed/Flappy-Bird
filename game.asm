[org 0x0100]
jmp start

pillar1X: dw 0+125
pillar2X: dw 44+115
pillar3X: dw 88+115

seed: dw 0x0

pillar1Rand: dw 0x0B
pillar2Rand: dw 0x0
pillar3Rand: dw 0x0

birdY: db 14
birdOldY: db 14
birdDirection: db 'D'
wingUp: db 0
birdEye: dw 0xF020
bird_y_pos: db 0x06

oldkbisr: times 2 dw 0x0
oldtimer: times 2 dw 0x0

delayCount: db 0x0
birdDelay: db 0x0

escPressed: db 0x0
exitAnimation: db 0x0

score: dw 0x0
highest_score dw 0x0
scoreUpdated: db 0x0
isCollided: db 0x0
gameRunning: db 0x0

paused: db 'Paused'
exit: db'Are you sure you want to exit?'
yes: db 'Y'
no: db 'N'

bird: db 0x0F
instructions: db 0x01

line_1: db '  *****  *    *   ****  *****   *****   *   *     ****  *****  *****    ***    *    *   ****   $'
line_2: db '    *    **   *   *       *     *   *   *   *    *        *      *     *   *   **   *   *      $'
line_3: db '    *    * *  *    *      *     ****    *   *    *        *      *     *   *   * *  *    *     $'
line_4: db '    *    *  * *      *    *     *  *    *   *    *        *      *     *   *   *  * *      *   $'
line_5: db '  *****  *   **   ****    *     *   *    ***      ****    *    *****    ***    *   **   ****   $'

ins0: db 'Press any key to continue$'
ins1: db 'Press up arrow key to move the bird up$'
ins2: db 'Avoid collision with the pillars$'
ins3: db 'Press esc key to pause or quit$'
ins4: db 'Press esc to Quit Game$'
ins5: db 'Press R to restart the Game$'

name_prompt1: db 'Hamda Saeed$'
roll_prompt1: db '23L-3107$'

name_prompt2: db 'Abdul Moeed Maan$'
roll_prompt2: db '23L-0743$'

semester: db 'Fall 2024$'

space: db'Press spacebar to continue$'
up: db'Press up arrow key to start game$'
Score: db'Score:$'
Highest_Score: db'Highest Score:$'
Name: db 'Name:$'
name: db 'Enter your name: $'

; PCB layout:
; ax,bx,cx,dx,si,di,bp,sp,ip,cs,ds,ss,es,flags,next,dummy
; 0, 2, 4, 6, 8,10,12,14,16,18,20,22,24, 26 , 28 , 30
pcb: times 2*16 dw 0 ; space for 32 PCBs
nextpcb: dw 1 ; index of next free pcb
current: dw 0 ; index of current pcb

timer:
    push ds
    push bx
    push cs
    pop ds ; initialize ds to data segment

    cmp byte [delayCount], 0
    ja decrementDelay

    mov byte [birdDirection], 'D'
    jmp scheduler

    decrementDelay:
        dec byte [delayCount]
    jmp scheduler

    scheduler:
        mov bx, [current] ; read index of current in bx
        shl bx, 1
        shl bx, 1
        shl bx, 1
        shl bx, 1
        shl bx, 1 ; multiply by 32 for pcb start

        mov [pcb+bx+0], ax ; save ax in current pcb
        mov [pcb+bx+4], cx ; save cx in current pcb
        mov [pcb+bx+6], dx ; save dx in current pcb
        mov [pcb+bx+8], si ; save si in current pcb
        mov [pcb+bx+10], di ; save di in current pcb
        mov [pcb+bx+12], bp ; save bp in current pcb
        mov [pcb+bx+24], es ; save es in current pcb
        pop ax ; read original bx from stack
        mov [pcb+bx+2], ax ; save bx in current pcb
        pop ax ; read original ds from stack
        mov [pcb+bx+20], ax ; save ds in current pcb
        pop ax ; read original ip from stack
        mov [pcb+bx+16], ax ; save ip in current pcb
        pop ax ; read original cs from stack
        mov [pcb+bx+18], ax ; save cs in current pcb
        pop ax ; read original flags from stack
        mov [pcb+bx+26], ax ; save flags in current pcb
        mov [pcb+bx+22], ss ; save ss in current pcb
        mov [pcb+bx+14], sp ; save sp in current pcb
        
        mov bx, [pcb+bx+28] ; read next pcb of this pcb
        mov [current], bx ; update current to new pcb
        mov cl, 5
        shl bx, cl ; multiply by 32 for pcb start
        
        mov cx, [pcb+bx+4] ; read cx of new process
        mov dx, [pcb+bx+6] ; read dx of new process
        mov si, [pcb+bx+8] ; read si of new process
        mov di, [pcb+bx+10] ; read diof new process
        mov bp, [pcb+bx+12] ; read bp of new process
        mov es, [pcb+bx+24] ; read es of new process
        mov ss, [pcb+bx+22] ; read ss of new process
        mov sp, [pcb+bx+14] ; read sp of new process
        push word [pcb+bx+26] ; push flags of new process
        push word [pcb+bx+18] ; push cs of new process
        push word [pcb+bx+16] ; push ip of new process
        push word [pcb+bx+20] ; push ds of new process

        mov ax, [pcb+bx+0] ; read ax of new process
        mov bx, [pcb+bx+2] ; read bx of new process
        pop ds ; read ds of new process
jmp far [cs:oldtimer]

kbisr:
    push ax

    cmp byte [cs:isCollided], 1
    je kbisrEOI

    in al, 0x60

    firstCmp:
        cmp al, 0x01 ;check is esc key is pressed
        jne secondCmp

        mov byte [cs:escPressed], 1
        jmp kbisrEOI

    secondCmp:        
        cmp al, 0x48 ;check if up key is pressed
        jne thirdCmp

        mov byte [cs:birdDirection], 'U'
        mov byte [cs:delayCount], 3
        jmp kbisrEOI

    thirdCmp:
        cmp al, 0xC8 ;check if up key is released
        jne fourthCmp

        mov byte [cs:delayCount], 3
        jmp kbisrEOI

    fourthCmp:

    kbisrEOI:
        pop ax
jmp far [cs:oldkbisr] ;chaining oldkbisr for int 0x16

start:
    call initpcb
    
    call hookISRs

    mov ah, 0x00
    mov al, 0x54
    int 0x10 ; changing the resolution to 43*132

    call PrintIntroScreen

    call PrintInstructionScreen
    
    restartGame:
        mov byte [gameRunning], 1

        call initializeValues

        call PrintStartScreen ;printing the static start screen
        
        call PrintUpString
        
        call getStartInput
        cmp byte [exitAnimation], 1
        je outOfAnimation ;if he decides to exit before starting the game
        
        call PrintStartScreen

        call printScoreString

        animationLoop:
            cmp byte [isCollided], 1
            je hasCollided

            cmp byte [escPressed], 1
            jne continueAnimation

            call displayConfirmationScreen

            cmp byte [exitAnimation], 1
            je outOfAnimation

            continueAnimation:
                call PlayAnimation
                call UpdateScore
                call delay
        jmp animationLoop

        hasCollided:
            call CollisionHappened
            mov byte [exitAnimation], 1

        outOfAnimation:
            mov byte [gameRunning], 0
            call PrintGameOverScreen

        getEndInput:
            xor ah, ah
            int 0x16

            cmp ah, 0x01
            je terminate

    cmp ah, 0x13
    je restartGame
        jne getEndInput
    
    terminate:
        call unhookISRs

        ; Turn speaker off
        in al, 61h
        and al, 0FCh
        out 61h, al

        call clrscr
mov ax, 0x4C00
int 0x21

initpcb:
	push bp
    mov bp, sp

    push ax
    push bx
    push cx

    mov bx, [nextpcb] ; read next available pcb index
    
    mov cl, 5
    shl bx, cl ; multiply by 32 for pcb start ix2^5 

    mov [pcb+bx+18], cs ; save in pcb space for cs
    mov ax, PlayMusic
    mov [pcb+bx+16], ax ; save in pcb space for cs
    
    mov word [pcb+bx+26], 0x0200 ; initialize thread flags
    mov ax, [pcb+28] ; read next of 0th thread in ax
    mov [pcb+bx+28], ax ; set as next of new thread
    
    mov ax, [nextpcb] ; read new thread index
    mov [pcb+28], ax ; set as next of 0th thread
    
    pop cx
    pop bx
    pop ax

    pop bp
ret

hookISRs:
    push bp
    mov bp, sp

    push es
    push ax

    xor ax, ax
    mov es, ax
    
    mov ax, [es:9*4]
    mov [oldkbisr], ax ;save offset of oldkbisr
    mov ax, [es:9*4+2]
    mov [oldkbisr+2], ax ;save segment of oldkbisr

    mov ax, [es:8*4]
    mov [oldtimer], ax ;save offset of oldtimer
    mov ax, [es:8*4+2]
    mov [oldtimer+2], ax ;save segment of oldtimer

    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    mov word [es:8*4], timer
    mov [es:8*4+2], cs
    sti

    pop ax
    pop es

    pop bp
ret

initializeValues:
    mov word [pillar1X], 0+125
    mov word [pillar2X], 44+115
    mov word [pillar3X], 88+115

    mov word [seed], 0x0

    mov word [pillar1Rand], 0x0B ;initializing pillar1 random length
    push 0x0
    call getRandomNumber
    pop word [pillar2Rand] ;initializing pillar2 random length
    push 0x0
    call getRandomNumber
    pop word [pillar3Rand] ;initializing pillar3 random length

    mov byte [birdY], 14
    mov byte [birdOldY], 14
    mov byte [birdDirection], 'D' 
    mov byte [wingUp], 0   
    mov word [birdEye], 0xF020

    mov byte [delayCount], 0
    mov byte [birdDelay], 0

    mov byte [escPressed], 0
    mov byte [exitAnimation], 0

    mov word [score], 0
    mov byte [isCollided], 0
ret

getRandomNumber:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    
    mov ax, [seed]
    mov dx, 0
    mov bx, 18
    div bx
    
    mov [seed], ax
    
    add dx, 3
    mov [bp+4], dx

    cmp word [seed], 1000
    ja skipSeedUpdate

    mov ah, 0x00
    int 0x1A

    mov [seed], dx

    skipSeedUpdate:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
ret

PrintStartScreen:
    call PrintBackground ;printing the background

    call StoreBackground ;storing the complete background in a buffer

    mov word [pillar1X], 0+125
    times 10 call MoveP1 ;printing the first pillar with hard coded values
    
    call PrintBird ;printing the bird at the hardcoded initial position
ret

PrintBackground: 
    call FillColor ;filling the colours of the background
    call PrintClouds ;printing clouds in the sky region
    call PrintFlowers ;printing flowers in the ground region
ret

FillColor:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax ;video memory segment
    xor di, di ;di=0

    mov ah, 0x30 ;cyan color
    mov al, 0x20 ;space

    mov cx, 34*132 ;34 columns

    cld
    rep stosw ;filling the first 34 rows with cyan color
    
    mov ah, 0x20 ;green color
    mov al, 0x20 ;space

    mov cx, 8*132 ;8 rows

    cld
    rep stosw ;filling the next 8 rows with green color

    mov ah, 0x0A ;light green
    mov al, 0xDB ;full block

    mov cx, 1*132 ;next 1 row

    cld
    rep stosw ;filling the next 1 line with light green colour

    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

PrintClouds:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax    ; video memory segment

    ; Define a macro
    %macro draw_cloud 4
    mov di, ((%1 * 132) + %2) * 2
    mov al, 0xDB
    mov ah, %3
    mov [es:di], ax
    mov cx, %4
    rep stosw
    %endmacro

    ; First cloud-------------------------------------
    draw_cloud 4, 9, 0x0F, 5
    draw_cloud 5, 9, 0x07, 5
    draw_cloud 5, 7, 0x0F, 2
    draw_cloud 5, 14, 0x0F, 2
    draw_cloud 6, 2, 0x0F, 5
    draw_cloud 6, 7, 0x07, 9
    draw_cloud 6, 16, 0x0F, 5
    draw_cloud 7, 0, 0x0F, 5
    draw_cloud 7, 5, 0x07, 12
    draw_cloud 8, 3, 0x0F, 5
    draw_cloud 8, 8, 0x07, 7
    draw_cloud 8, 15, 0x0F, 2

    ; Additional clouds--------------------------------
    draw_cloud 10, 127, 0x0F, 5
    draw_cloud 11, 127, 0x07, 5
    draw_cloud 11, 125, 0x0F, 2
    draw_cloud 12, 120, 0x0F, 5
    draw_cloud 12, 125, 0x07, 7
    draw_cloud 13, 118, 0x0F, 5
    draw_cloud 13, 123, 0x07, 9
    draw_cloud 14, 121, 0x0F, 5
    draw_cloud 14, 126, 0x07, 6

    ; Second cloud--------------------------------------
    draw_cloud 6, 92, 0x0F, 5
    draw_cloud 7, 92, 0x07, 5
    draw_cloud 7, 90, 0x0F, 2
    draw_cloud 7, 97, 0x0F, 2
    draw_cloud 8, 85, 0x0F, 5
    draw_cloud 8, 90, 0x07, 9
    draw_cloud 8, 99, 0x0F, 5
    draw_cloud 9, 83, 0x0F, 5
    draw_cloud 9, 88, 0x07, 11
    draw_cloud 9, 97, 0x0F, 2
    draw_cloud 10, 86, 0x0F, 5
    draw_cloud 10, 91, 0x0F, 10

    ; Third cloud----------------------------------------
    draw_cloud 9, 40, 0x0F, 4
    draw_cloud 10, 40, 0x07, 4
    draw_cloud 10, 44, 0x0F, 2
    draw_cloud 10, 36, 0x0F, 4
    draw_cloud 11, 38, 0x07, 4
    draw_cloud 11, 34, 0x0F, 4

    ; Fourth cloud----------------------------------------
    draw_cloud 1, 80, 0x0F, 4
    draw_cloud 2, 80, 0x07, 4
    draw_cloud 2, 84, 0x0F, 2
    draw_cloud 2, 76, 0x0F, 4
    draw_cloud 3, 78, 0x07, 4
    draw_cloud 3, 74, 0x0F, 4

    ; Fifth cloud------------------------------------------
    draw_cloud 0, 45, 0x07, 4
    draw_cloud 0, 49, 0x0F, 2
    draw_cloud 1, 47, 0x0F, 2
    draw_cloud 1, 42, 0x07, 5
    draw_cloud 2, 40, 0x0F, 2
    draw_cloud 2, 42, 0x07, 4
    draw_cloud 2, 46, 0x0F, 1

    ; Additional details-----------------------------------
    draw_cloud 0, 118, 0x07, 4
    draw_cloud 1, 114, 0x0F, 4
    draw_cloud 12, 56, 0x07, 4
    draw_cloud 13, 52, 0x0F, 4

    ; Sixth cloud------------------------------------------
    draw_cloud 3, 128, 0x07, 4
    draw_cloud 4, 130, 0x0F, 2
    draw_cloud 4, 125, 0x07, 5
    draw_cloud 5, 123, 0x0F, 2
    draw_cloud 5, 125, 0x07, 4
    draw_cloud 5, 129, 0x0F, 1
    draw_cloud 7, 129, 0x07, 2

    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

PrintFlowers:
    push bp
    mov bp, sp

    push es       ; Save ES
    push di       ; Save DI
    push ax       ; Save AX
    push cx       ; Save CX

    mov ax, 0B800h
    mov es, ax

    ; Define macros to reduce redundancy
    %macro draw_row 3
    mov di, (%1 * 132 + %2) * 2
    mov al, 219
    mov ah, %3
    mov cx, 132
    rep stosw
    %endmacro

    %macro draw_detail 4
    mov di, (%1 * 132 + %2) * 2
    mov al, 219
    mov ah, %3
    mov cx, %4
    rep stosw
    %endmacro

    ; Drawing the flower rows
    draw_row 42, 0, 0Ah
    draw_row 41, 0, 02h
    draw_row 40, 0, 02h
    draw_row 39, 0, 02h
    draw_row 38, 0, 02h
    draw_row 37, 0, 02h
    draw_row 36, 0, 02h
    draw_row 35, 0, 02h
    draw_row 34, 0, 02h

    ; Additional flower details
    draw_detail 41, 5, 0Ah, 2
    draw_detail 40, 5, 0Ah, 2
    draw_detail 39, 5, 0Ah, 2
    draw_detail 38, 3, 04h, 4
    draw_detail 37, 3, 04h, 4
    draw_detail 41, 9, 0Ah, 2
    draw_detail 40, 9, 0Ah, 2
    draw_detail 39, 9, 0Ah, 2
    draw_detail 38, 9, 0Ah, 2
    draw_detail 37, 9, 0Ah, 2
    draw_detail 36, 7, 04h, 6
    draw_detail 35, 7, 04h, 2
    draw_detail 35, 9, 0Eh, 2
    draw_detail 35, 11, 04h, 2
    draw_detail 34, 7, 04h, 6
    draw_detail 41, 13, 0Ah, 2
    draw_detail 40, 11, 04h, 6
    draw_detail 39, 11, 04h, 2
    draw_detail 39, 13, 0Eh, 2
    draw_detail 39, 15, 04h, 2
    draw_detail 38, 11, 04h, 6
    draw_detail 35, 15, 04h, 6
    draw_detail 36, 15, 04h, 2
    draw_detail 36, 17, 0Eh, 2
    draw_detail 36, 19, 04h, 2
    draw_detail 37, 15, 04h, 6
    draw_detail 38, 17, 0Ah, 2
    draw_detail 39, 17, 0Ah, 2
    draw_detail 40, 17, 0Ah, 2
    draw_detail 41, 17, 0Ah, 2
    draw_detail 41, 22, 0Ah, 2
    draw_detail 40, 22, 0Ah, 2
    draw_detail 39, 22, 0Ah, 2
    draw_detail 38, 22, 04h, 4
    draw_detail 37, 22, 04h, 4

    ;white flower-------------------------------------------
    draw_detail 41, 39, 0Ah, 2
    draw_detail 40, 39, 0Ah, 2
    draw_detail 39, 39, 0Ah, 2
    draw_detail 38, 39, 0Ah, 2
    draw_detail 37, 39, 0Ah, 2
    draw_detail 36, 37, 0Fh, 6
    draw_detail 35, 37, 0Fh, 2
    draw_detail 35, 39, 04h, 2
    draw_detail 35, 41, 0Fh, 2
    draw_detail 34, 37, 0Fh, 6
    draw_detail 41, 43, 0Ah, 2
    draw_detail 40, 41, 0Fh, 6
    draw_detail 39, 41, 0Fh, 2
    draw_detail 39, 43, 04h, 2
    draw_detail 39, 45, 0Fh, 2
    draw_detail 38, 41, 0Fh, 6
    draw_detail 35, 45, 0Fh, 6
    draw_detail 36, 45, 0Fh, 2
    draw_detail 36, 47, 04h, 2
    draw_detail 36, 49, 0Fh, 2
    draw_detail 37, 45, 0Fh, 6
    draw_detail 38, 47, 0Ah, 2
    draw_detail 39, 47, 0Ah, 2
    draw_detail 40, 47, 0Ah, 2
    draw_detail 41, 47, 0Ah, 2

    ;Red flower-------------------------------------------
    draw_detail 41, 65, 0Ah, 2
    draw_detail 40, 65, 0Ah, 2
    draw_detail 39, 65, 0Ah, 2
    draw_detail 38, 63, 04h, 4
    draw_detail 37, 63, 04h, 4
    draw_detail 41, 69, 0Ah, 2
    draw_detail 40, 69, 0Ah, 2
    draw_detail 39, 69, 0Ah, 2
    draw_detail 38, 69, 0Ah, 2
    draw_detail 37, 69, 0Ah, 2
    draw_detail 36, 67, 04h, 6
    draw_detail 35, 67, 04h, 2
    draw_detail 35, 69, 0Eh, 2
    draw_detail 35, 71, 04h, 2
    draw_detail 34, 67, 04h, 6
    draw_detail 41, 73, 0Ah, 2
    draw_detail 40, 71, 04h, 6
    draw_detail 39, 71, 04h, 2
    draw_detail 39, 73, 0Eh, 2
    draw_detail 39, 75, 04h, 2
    draw_detail 38, 71, 04h, 6
    draw_detail 35, 75, 04h, 6
    draw_detail 36, 75, 04h, 2
    draw_detail 36, 77, 0Eh, 2
    draw_detail 36, 79, 04h, 2
    draw_detail 37, 75, 04h, 6
    draw_detail 38, 77, 0Ah, 2
    draw_detail 39, 77, 0Ah, 2
    draw_detail 40, 77, 0Ah, 2
    draw_detail 41, 77, 0Ah, 2
    draw_detail 41, 82, 0Ah, 2
    draw_detail 40, 82, 0Ah, 2
    draw_detail 39, 82, 0Ah, 2
    draw_detail 38, 82, 04h, 4
    draw_detail 37, 82, 04h, 4


    ;white flower-------------------------------------------
    draw_detail 41, 109, 0Ah, 2
    draw_detail 40, 109, 0Ah, 2
    draw_detail 39, 109, 0Ah, 2
    draw_detail 38, 109, 0Ah, 2
    draw_detail 37, 109, 0Ah, 2
    draw_detail 36, 107, 0Fh, 6
    draw_detail 35, 107, 0Fh, 2
    draw_detail 35, 109, 04h, 2
    draw_detail 35, 111, 0Fh, 2
    draw_detail 34, 107, 0Fh, 6
    draw_detail 41, 113, 0Ah, 2
    draw_detail 40, 111, 0Fh, 6
    draw_detail 39, 111, 0Fh, 2
    draw_detail 39, 113, 04h, 2
    draw_detail 39, 115, 0Fh, 2
    draw_detail 38, 111, 0Fh, 6
    draw_detail 35, 115, 0Fh, 6
    draw_detail 36, 115, 0Fh, 2
    draw_detail 36, 117, 04h, 2
    draw_detail 36, 119, 0Fh, 2
    draw_detail 37, 115, 0Fh, 6
    draw_detail 38, 117, 0Ah, 2
    draw_detail 39, 117, 0Ah, 2
    draw_detail 40, 117, 0Ah, 2
    draw_detail 41, 117, 0Ah, 2


    pop cx       ; Restore CX
    pop ax       ; Restore AX
    pop di       ; Restore DI
    pop es       ; Restore ES
    
    pop bp
ret

StoreBackground:
    push bp
    mov bp, sp
    
    push es
    push di
    push ds
    push si
    push ax
    push cx
    
    mov ax, 0xB800
    mov ds, ax
    xor si, si
    
    push cs
    pop es
    mov di, screenBuffer
    
    mov cx, 43*132
    
    cld
    rep movsw
    
    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es
    
    pop bp
ret

PrintColumn:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax ;video memory segment

    mov di, [bp+8] ;column offset

    mov ah, [bp+4] ;reading attribute parameter
    mov al, '^'

    mov cx, [bp+6] ;random length of the upperPillar
    dec cx
    cld
    upperPillarLoop:
        stosw ;printing upper pillar column
        add di, 262
    loop upperPillarLoop

    mov ah, 0x00
    stosw ;printing the border
    add di, 262

    add di, (12*132)*2

    stosw ;printing the border
    add di, 262

    mov ah, [bp+4] ;reading attribute byte
    mov cx, 34-12
    sub cx, [bp+6] ;random length of upper column
    dec cx
    lowerPillarLoop:
        stosw ;printing lower pillar column
        add di, 262
    loop lowerPillarLoop

    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret 6

RestoreBirdBackground:
    push bp
    mov bp, sp
    
    push es
    push di
    push ds
    push si
    push ax
    push cx
    
    mov ax, 0xB800
    mov es, ax
    
    push cs
    pop ds
    
    mov ax, 132
    mul byte [birdOldY]
    add ax, 20
    shl ax, 1
    mov di, ax
    mov si, screenBuffer
    add si, ax
    
    mov cx, 8
    
    cld 
    rep movsw
    
    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es
    
    pop bp
ret

PrintBird:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push bx
    push cx

    call RestoreBirdBackground
    
    mov ax, 0xB800
    mov es, ax ;video memory segment

    mov ax, 132
    mul byte [birdY] ;starting row(y) of bird
    add ax, 20 ;constant distance from left border
    shl ax, 1
    mov di, ax ;assign bird's starting index to di

    mov ah, 0x40 ;red color
    mov al, 0x20 ;space

    mov cx, 5 ;five rows
    birdBase:
        push cx

        mov cx, 8 ;eight columns
        cld
        rep stosw ;printing the bird's base
        add di, 248

        pop cx
    loop birdBase

    sub di, ((4 * 132) - 5) * 2 ;bird's eye
    mov ax, [birdEye] ;change the attribute and character after collision
    stosw
    mov ah, 0x00
    mov al, 0x20
    stosw
    add di, 260
    stosw
    stosw

    add di, ((2 * 132) - 1) * 2 ;bird's beak
    mov ah, 0x60
    stosw
    stosw

    sub di, ((2 * 132) + 5) * 2 ;bird's wing
    mov cx, 3

    cmp byte [wingUp], 1
    je movUp

    movDown:
    mov bx, 264
    inc byte[wingUp]
    jmp birdWing

    movUp:
    mov bx, -264
    dec byte [wingUp]
    jmp birdWing

    birdWing:
        push cx

        sub di, cx
        sub di, cx ;going no. of cx words space back to print cx blocks of wing level
        rep stosw ;printing the wing
        add di, bx ;printing the wing up or down

        pop cx
    loop birdWing

    pop cx
    pop bx
    pop ax
    pop di
    pop es

    pop bp
ret

PrintUpString:
    push bp
    mov bp, sp

    push dx

    mov dh, 16
    mov dl, 40
    call set_cursor_position

    mov dx, up
    call print_string

    pop dx

    pop bp
ret

printScoreString:
    push bp
    mov bp, sp

    push dx

    mov dh, 42
    mov dl, 57
    call set_cursor_position

    mov dx, Score
    call print_string


    mov dh, 0
    mov dl, 0
    call set_cursor_position

    pop dx

    pop bp
ret

getStartInput:
    push bp
    mov bp, sp

    push ax

    getStartInputAgain:
    xor ah, ah
    int 0x16 ;BIOS interrupt to get input

    cmp byte [escPressed], 1 ;checking if the user enters esc key
    jne continueCheckingInput

    call displayConfirmationScreen

    cmp byte [exitAnimation], 1
    je outOfGetStartInput

    continueCheckingInput:
    cmp ah, 0x48 ;check is the up key is pressed
    jne getStartInputAgain

    outOfGetStartInput:
    pop ax

    pop bp
ret

PlayAnimation:
    call MoveGround
    call MovePillars

    call CheckCollision

    cmp byte [birdDelay], 0
    jg skipMoveBird

    mov byte [birdDelay], 3
    call MoveBird

    call CheckCollision

    skipMoveBird:
        dec byte [birdDelay]
ret

MoveGround:
    push bp
    mov bp, sp

    push 0x0

    push es
    push di
    push ds
    push si
    push ax
    push cx

    mov di, (34*132)*2
    mov cx, 8
    MoveGroundLoop:
        push cx

        mov ax, 0xB800
        mov ds, ax
        mov si, di

        push ss
        pop es
        mov di, bp
        sub di, 2

        cld
        movsw

        push ds
        pop es
        mov di, si
        sub di, 2

        mov cx, 131
        cld
        rep movsw

        push ss
        pop ds
        mov si, bp
        sub si, 2

        cld
        movsw

        pop cx
    loop MoveGroundLoop

    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es

    pop bp
    pop bp
ret

MoveBird:
    push bp
    mov bp, sp
    
    push ax
    
    cmp byte [birdDirection], 'D'
    je moveDown
    cmp byte [birdDirection], 'U'
    je moveUp

    moveDown:
        cmp byte [birdY], 29
        je PB

        mov al, [birdY]
        mov [birdOldY], al
        inc byte [birdY]
        jmp PB

    moveUp:
        cmp byte [birdY], 0
        je PB

        mov al, [birdY]
        add al, 4
        mov [birdOldY], al
        dec byte [birdY]
        jmp PB

    PB:
        call PrintBird
    
    pop ax
    
    pop bp
ret

MovePillars:
    call MoveP1
    call MoveP2
    call MoveP3
ret

MoveP1:
    push word [pillar1Rand]
    push word [pillar1X]
    call MoveP
    pop word [pillar1X]
    pop word [pillar1Rand]
ret

MoveP2:
    push word [pillar2Rand]
    push word [pillar2X]
    call MoveP
    pop word [pillar2X]
    pop word [pillar2Rand]
ret

MoveP3:
    push word [pillar3Rand]
    push word [pillar3X]
    call MoveP	
    pop word [pillar3X]
    pop word [pillar3Rand]
ret
    
MoveP:
    push bp
    mov bp, sp
    
    push cx
    
    mov cx, [bp+4]
        
    cmp cx, 1
    jl rightEdge
    cmp cx, 131
    jg endMoveP
    
    jmp callMovePillar	
    
    rightEdge:
        cmp cx, -10
        je ResetPillar
        
    callMovePillar:
        push word [bp+6] ;pillar lengths
        push cx ;starting index
        call MovePillar
        jmp endMoveP
        
    ResetPillar:	
        mov word [bp+4], 131
        push 0x0
        call getRandomNumber
        pop word [bp+6]

    endMoveP:
        dec word [bp+4]
    pop cx
    
    pop bp
ret 

RestorePillarBuffer:
    push bp
    mov bp, sp

    push es
    push di
    push ds
    push si
    push ax
    push cx

    push cs
    pop ds
    
    mov ax, 0xB800
    mov es, ax
    
    mov ax, [bp+4] ;pillar no. x
    add ax, 9
    shl ax, 1
    mov di, ax	
    mov si, screenBuffer
    add si, ax

    mov cx, [bp+6]
    cld
    RestoreUpperPillarLoop:
        movsw
        add di, 262
        add si, 262
    loop RestoreUpperPillarLoop
    
    add di, (12*132)*2
    add si, (12*132)*2
    
    mov cx, 34-12
    sub cx, [bp+6]
    RestoreLowerPillarLoop:
        movsw
        add di, 262
        add si, 262
    loop RestoreLowerPillarLoop

    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es

    pop bp
ret 4

MovePillar:
    push bp
    mov bp, sp
        
    push es
    push di
    push ds
    push si
    push ax
    push cx
    
    push word [bp+6]
    push word [bp+4]
    call RestorePillarBuffer

    mov ax, 0xB800
    mov es, ax

    mov ax, [bp+4] ;pillar(i)x
    shl ax, 1
    mov di, ax
    sub di, 2

    cmp di, 0
    jl nextCol1
    cmp di, 262
    ja noMovement

    push di
    push word [bp+6]
    push 0x00
    call PrintColumn

    nextCol1:
        add di, 2

        cmp di, 0
        jl nextCol2
        cmp di, 262
        ja noMovement

        push di
        push word [bp+6]
        push 0x1F
        call PrintColumn    

    nextCol2:
        add di, 16

        cmp di, 0
        jl noMovement
        cmp di, 262
        ja noMovement

        push di
        push word [bp+6]
        push 0x00
        call PrintColumn
    
    noMovement:
    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es
    
    pop bp
ret 4

StoreCollisionBackground:
    push bp
    mov bp, sp
    
    push es
    push di
    push ds
    push si
    push ax
    push bx
    push cx

    mov ax, 132
    mov bl, [birdY] ;starting row(y) of bird
    add bl, 5
    mul bl
    add ax, 20 ;constant distance from left border
    shl ax, 1
    mov bx, ax
    
    mov ax, 0xB800
    mov ds, ax
    mov si, bx
    
    push cs
    pop es
    mov di, screenBuffer
    add di, bx

    cld
    storeCollisionBackgroundLoop:
        
        mov cx, 8
        rep movsw

        add si, 264-16
        add di, 264-16

    cmp si, 8976
    jb storeCollisionBackgroundLoop
    
    pop cx
    pop bx
    pop ax
    pop si
    pop ds
    pop di
    pop es
    
    pop bp
ret

CheckCollision:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax

    cmp byte [birdY], 29
    je collisionDetected

    mov ax, 132
    mul byte [birdY] ;starting row(y) of bird
    add ax, 20 ;constant distance from left border
    shl ax, 1
    mov di, ax ;assign bird's starting index to di

    mov ax, 0x005E ;cmp with the black border

    sub di, 264 ;get to the row above the bird

    mov cx, 8
    cld
    repne scasw
    jz collisionDetected

    add di, 264 ;get to the next column on the bird's first row

    mov cx, 5
    CheckCollisionLoop:
        scasw
        jz collisionDetected
        
        add di, 264-2
    loop CheckCollisionLoop

    sub di, 16 ;get to the first column below the bird

    mov cx, 8
    cld
    repne scasw
    jz collisionDetected

    jmp noCollisionDetected

    collisionDetected:
        mov byte [isCollided], 1

    noCollisionDetected:
        pop cx
        pop ax
        pop di
        pop es

    pop bp
ret

CollisionHappened:
    mov byte [birdDirection], 'D'
    mov word [birdEye], 0x7058
    call StoreCollisionBackground
    call MoveBirdDown
ret

MoveBirdDown:
    mov byte [wingUp], 0
    call MoveBird
    times 2 call delay

    cmp byte [birdY], 29
    je outOfMoveBirdDown

    jmp MoveBirdDown

    outOfMoveBirdDown:
ret

displayConfirmationScreen:
    call StoreConfirmationScreenBuffer
    call PrintConfirmationScreen ;print "Do you want to exit."
    
    getInputAgain:
        xor ah, ah
        int 0x16

        cmp ah, 0x31 ;check if n key is pressed
        je NPressed
        cmp ah, 0x15 ;check if y key is pressed
        jne getInputAgain

        mov byte [exitAnimation], 1
        jmp outOfDisplayConfirmationScreen

    NPressed:
        call RestoreConfirmationScreenBuffer
        mov byte [escPressed], 0

    outOfDisplayConfirmationScreen:
ret

StoreConfirmationScreenBuffer:
    push bp
    mov bp, sp

    push es
    push di
    push ds
    push si
    push ax
    push cx

    mov ax, 0xB800
    mov ds, ax
    mov si, ((14*132)+45)*2
    push cs
    pop es
    mov di, confirmationScreenBuffer

    mov cx, 5
    cld
    StoreConfirmationScreenBufferLoop:
        push cx

        mov cx, 42
        rep movsw

        add si, 264-(42*2)

        pop cx
    loop StoreConfirmationScreenBufferLoop

    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es

    pop bp
ret

PrintConfirmationScreen:
    push bp
    mov bp, sp

    push es       ; Save ES
    push di       ; Save DI
    push ax       ; Save AX
    push bx       ; Save BX
    push cx       ; Save CX
    push dx       ; Save DX
        
    mov ax, 0xB800
    mov es, ax
    mov di, (14* 132+ 45) * 2  
    mov al, 219
    mov ah, 0x0

    mov cx, 5
    PrintConfirmationScreenLoop1:
        push cx

        mov cx, 42
        rep stosw

        add di, 264-(42*2)
        pop cx
    loop PrintConfirmationScreenLoop1

    mov ah,0x13
    mov al,1
    mov bh,0
    mov bl,7
    mov dx,0x1033
    mov cx,30
    push cs
    pop es
    mov bp,exit
    int 0x10

    mov ah,0x13
    mov al,1
    mov bh,0
    mov bl,7
    mov dx,0x0E40
    mov cx,6
    push cs
    pop es
    mov bp,paused
    int 0x10

    mov ah,0x13
    mov al,1
    mov bh,0
    mov bl,7
    mov dx,0x1235
    mov cx,1
    push cs
    pop es
    mov bp,yes
    int 0x10

    mov ah,0x13
    mov al,1
    mov bh,0
    mov bl,7
    mov dx,0x1249
    mov cx,1
    push cs
    pop es
    mov bp,no
    int 0x10
    
    mov ah, 0x02          ; BIOS function to set cursor position
    mov bh, 0x00          ; Display page number (usually 0)
    mov dh, 0             ; Row number (starting from 0)
    mov dl, 0            ; Column number (starting from 0)
    int 0x10              ; Call BIOS interrupt

    pop dx       ; Restore DX
    pop cx       ; Restore CX
    pop bx       ; Restore BX
    pop ax       ; Restore AX
    pop di       ; Restore DI
    pop es       ; Restore ES

    pop bp
ret

RestoreConfirmationScreenBuffer:
    push bp
    mov bp, sp

    push es
    push di
    push ds
    push si
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax
    mov di, ((14*132)+45)*2
    push cs
    pop ds
    mov si, confirmationScreenBuffer

    mov cx, 5
    cld
    RestoreConfirmationScreenBufferLoop:
        push cx

        mov cx, 42
        rep movsw

        add di, 264-(42*2)

        pop cx
    loop RestoreConfirmationScreenBufferLoop

    pop cx
    pop ax
    pop si
    pop ds
    pop di
    pop es

    pop bp
ret

UpdateScore:
    call CalculateScore
    call PrintScore
ret

CalculateScore:
    cmpP1:
        cmp word [pillar1X], 10
        jne cmpP2
        je incScore

    cmpP2:
        cmp word [pillar2X], 10
        jne cmpP3
        je incScore

    cmpP3:
        cmp word [pillar3X], 10
        jne outOfCalculateScore
        je incScore
        
    incScore:
        inc word [score]
        mov byte [scoreUpdated], 1

    outOfCalculateScore:
ret

PrintScore:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push bx
    push cx
    push dx

    mov ax, 0xB800
    mov es, ax
    
    mov bx, 42        ; Row
    mov cx, 65        ; Column
    imul ax, bx, 132
    add ax, cx
    shl ax, 1
    mov di, ax

    ; Convert score to ASCII and print it
    mov ax, [score]
    mov bx, 10
    xor cx, cx

    print_digit:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        cmp ax, 0
    jne print_digit

    print_digits:
        pop dx
        mov al, dl
        mov ah, 0x0F
        stosw
    loop print_digits

    pop dx
    pop cx
    pop bx
    pop ax
    pop di
    pop es

    pop bp
ret

clrscr:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax
    xor di, di

    mov ax, 0x0720

    mov cx, 43
    clrscrLoop:
        push cx

        mov cx, 132
        rep stosw

        call delay
    
        pop cx
    loop clrscrLoop

    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

unhookISRs:
    push bp
    mov bp, sp

    push es
    push ax

    xor ax, ax
    mov es, ax
    
    cli
    mov ax, [oldkbisr]
    mov word [es:9*4], ax ;restore offset of oldkbisr
    mov ax, [oldkbisr+2]
    mov [es:9*4+2], ax ;restore segment of oldkbisr

    mov ax, [oldtimer]
    mov [es:8*4], ax ;restore offset of oldtimer
    mov ax, [oldtimer+2]
    mov [es:8*4+2], ax ;restore segment of oldtimer
    sti

    pop ax
    pop es

    pop bp
ret

delay:
    push cx

    mov cx, 2
    delayL1:
        push cx
        mov cx, 0xFFFF
        delayL2:
            loop delayL2
        pop cx
    loop delayL1

    pop cx
ret

PrintIntroScreen:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax
    xor di, di

    ;background
    mov ah, 0x30
    mov al, 0x20
    mov cx, 35*132
    cld
    rep stosw

    call PrintClouds
    call PrintFlowers
    call draw_bird
    call Flappy_Bird

    mov dh, 16
    mov dl, 50 
    call set_cursor_position 
    mov dx, space
    call print_string

    call waitLoop

    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

PrintInstructionScreen:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax
    xor di, di

    ; Background
    mov ah, 0x30
    mov al, 0x20
    mov cx, 35*132

    cld
    rep stosw

    call PrintClouds
    call PrintFlowers
    call GetPlayerName
    call Instruction

    ; Define a macro to handle repetitive tasks
    %macro print_instruction 2
    mov dh, %1
    mov dl, 50
    call set_cursor_position
    mov dx, %2
    call print_string
    call wait_next
    %endmacro

    ; Using the macro for each instruction
    print_instruction 15, ins0
    print_instruction 18, ins1
    print_instruction 20, ins2
    print_instruction 22, ins3

    mov dh, 0
    mov dl, 0
    call set_cursor_position


    pop cx
    pop ax
    pop di
    pop es
    pop bp
ret

PrintGameOverScreen:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx
    push dx

    mov ax, 0xB800
    mov es, ax
    xor di, di      ; Start at the beginning of video memory

    ;background
    mov ah, 0x30
    mov al, 0x20
    mov cx, 35*132
    cld
    rep stosw

    call PrintClouds
    call PrintFlowers
    call draw_bird
    call game_over
    call PrintFinalScore
    call UpdateAndPrintHighestScore
    call PrintPlayerName

    mov dh, 30
    mov dl, 55
    call set_cursor_position

    mov dx, ins4
    call print_string

    mov dh, 32
    mov dl, 55
    call set_cursor_position

    mov dx, ins5
    call print_string

    mov dh, 0
    mov dl, 0
    call set_cursor_position

    pop dx
    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

draw_bird:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx

    mov ax, 0xb800   
    mov es, ax

    movzx di, byte [bird_y_pos]     ; Load bird_y_pos
    imul di, 132                    ; Multiply by 132 to get row offset
    add di, 65                      ; Add horizontal offset (column 65)
    shl di, 1                       ; Multiply by 2 (character + attribute)

    ; 1st row of the bird
    mov ah, 0x04                    ; Attribute for bird color
    mov al, 0xDB                    ; Character for bird
    mov cx, 9                       ; Width of the bird row
    rep stosw

    ; 2nd row of the bird
    movzx di, byte [bird_y_pos]     
    add di, 1                       ; Move to next row
    imul di, 132                    
    add di, 66                      ; Offset for second row
    shl di, 1                       
    mov ah, 0x04                    
    mov al, 0xDB                    
    mov cx, 10                      
    rep stosw

    ; 3rd row of the bird
    movzx di, byte [bird_y_pos]     
    add di, 2                       
    imul di, 132                    
    add di, 67                      
    shl di, 1                       
    mov ah, 0x04                    
    mov al, 0xDB                    
    mov cx, 8                       
    rep stosw
    
    ; Eye of the bird
    movzx di, byte [bird_y_pos]     
    add di, 2                       
    imul di, 132                    
    add di, 69                      
    shl di, 1                       
    mov ah, 0x0F                    
    mov al, 0xDB                    
    mov cx, 1                       
    rep stosw

    movzx di, byte [bird_y_pos]     
    add di, 2                       
    imul di, 132                    
    add di, 70                      
    shl di, 1  
    mov ah, 0x00                    
    mov al, 0xDB                    
    mov cx, 1                       
    rep stosw
    
    ; Beak of the bird
    movzx di, byte [bird_y_pos]     
    add di, 2                       
    imul di, 132                    
    add di, 75                      
    shl di, 1                       
    mov ah, 0x06                    
    mov al, 0xDB                    
    mov cx, 2                       
    rep stosw
    
    ; 4th row of the bird
    movzx di, byte [bird_y_pos]     
    add di, 3                       
    imul di, 132                    
    add di, 67                      
    shl di, 1                       
    mov ah, 0x04                    
    mov al, 0xDB                    
    mov cx, 8                       
    rep stosw

    ; Beak continuation
    movzx di, byte [bird_y_pos]     
    add di, 3                       
    imul di, 132                    
    add di, 75                      
    shl di, 1                       
    mov ah, 0x06                    
    mov al, 0xDB                    
    mov cx, 3                       
    rep stosw

    ; 5th row of the bird
    movzx di, byte [bird_y_pos]     
    add di, 4                       
    imul di, 132                    
    add di, 65                      
    shl di, 1                       
    mov ah, 0x04                    
    mov al, 0xDB                    
    mov cx, 11                      
    rep stosw

    ; 6th row of the bird
    movzx di, byte [bird_y_pos]     
    add di, 5                       
    imul di, 132                    
    add di, 62                      
    shl di, 1                       
    mov ah, 0x04                    
    mov al, 0xDB                    
    mov cx, 13                      
    rep stosw
    
    ; 7th row of the bird
    movzx di, byte [bird_y_pos]     
    add di, 6                       
    imul di, 132                    
    add di, 67                      
    shl di, 1                       
    mov ah, 0x04                    
    mov al, 0xDB                    
    mov cx, 6                       
    rep stosw

    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

Flappy_Bird:
    push bp
    mov bp, sp
    
    push es
    push di
    push ax
    push cx

    mov ax, 0xb800
    mov es, ax

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 30
    shl di, 1
    mov ah, 0x00
    mov al, 0xDB
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 41
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 41
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 5
    imul di, 132
    add di, 41
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 41
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 30
    shl di, 1
    mov cx, 2
    rep stosw
    
    call delay

    movzx di, byte [bird]
    add di, 5
    imul di, 132
    add di, 30
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 30
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 30
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 41
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 53
    shl di, 1
    mov cx, 5
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 52
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 57
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 5
    imul di, 132
    add di, 51
    shl di, 1
    mov cx, 9
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 57
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 57
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 52
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 52
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 68
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 5
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 78
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 5
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 82
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 3
    imul di, 132
    add di, 89
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 83
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 4
    imul di, 132
    add di, 88
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 5
    imul di, 132
    add di, 84
    shl di, 1
    mov cx, 5
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 6
    imul di, 132
    add di, 85
    shl di, 1
    mov cx, 3
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 7
    imul di, 132
    add di, 85
    shl di, 1
    mov cx, 3
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 9
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 7
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 68
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 11
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 7
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 68
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 13
    imul di, 132
    add di, 62
    shl di, 1
    mov cx, 7
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 9
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 75
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 11
    imul di, 132
    add di, 75
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 75
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 13
    imul di, 132
    add di, 72
    shl di, 1
    mov cx, 8
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 9
    imul di, 132
    add di, 82
    shl di, 1
    mov cx, 7
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 82
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 88
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 11
    imul di, 132
    add di, 82
    shl di, 1
    mov cx, 7
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 82
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 86
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 13
    imul di, 132
    add di, 82
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 13
    imul di, 132
    add di, 87
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 9
    imul di, 132
    add di, 92
    shl di, 1
    mov cx, 7
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 92
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 10
    imul di, 132
    add di, 98
    shl di, 1
    mov cx, 2
    rep stosw
    
    call delay

    movzx di, byte [bird]
    add di, 11
    imul di, 132
    add di, 92
    shl di, 1
    mov cx, 2
    rep stosw
    
    call delay

    movzx di, byte [bird]
    add di, 11
    imul di, 132
    add di, 98
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 92
    shl di, 1
    mov cx, 2
    rep stosw

    call delay

    movzx di, byte [bird]
    add di, 12
    imul di, 132
    add di, 98
    shl di, 1
    mov cx, 2
    rep stosw

    call delay
    
    movzx di, byte [bird]
    add di, 13
    imul di, 132
    add di, 92
    shl di, 1
    mov cx, 7
    rep stosw


    ; Define a macro 
    %macro print_prompt 2
        mov dh, %1
        mov dl, 80
        call set_cursor_position
        mov dx, %2
        call delay
        call print_string
    %endmacro

    ; Using the macro for each prompt
    print_prompt 29, name_prompt2
    print_prompt 30, roll_prompt2
    print_prompt 31, name_prompt1
    print_prompt 32, roll_prompt1
    print_prompt 33, semester


    pop cx
    pop ax
    pop di
    pop es

    pop bp
ret

Instruction:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push cx
    push dx

    mov ax, 0xb800
    mov es, ax

    mov ah,0x0F

    ;line1---------------------------------------------------------
    call delay

    movzx di, byte [instructions]
    add di, 0
    imul di, 132
    add di, 17
    shl di, 1
    mov cx, 95
    rep stosw

    mov dh, 1
    mov dl, 17
    call set_cursor_position

    ;line2---------------------------------------------------------
    call delay

    movzx di, byte [instructions]
    add di, 1
    imul di, 132
    add di, 17
    shl di, 1
    mov cx, 95
    rep stosw

    mov dx, line_1
    call print_string

    mov dh, 2
    mov dl, 17
    call set_cursor_position

    ;line3---------------------------------------------------------
    call delay

    movzx di, byte [instructions]
    add di, 2
    imul di, 132
    add di, 17
    shl di, 1
    mov ah,0x0F
    mov cx, 95
    rep stosw

    mov dx, line_2
    call print_string

    mov dh, 3
    mov dl, 17
    call set_cursor_position

    ;line4---------------------------------------------------------
    call delay

    movzx di, byte [instructions]
    add di, 3
    imul di, 132
    add di, 17
    shl di, 1
    mov ah,0x0F
    mov cx, 95
    rep stosw

    mov dx, line_3
    call print_string

    mov dh,   4
    mov dl, 17
    call set_cursor_position

    ;line5---------------------------------------------------------
    call delay

    movzx di, byte [instructions]
    add di, 4
    imul di, 132
    add di, 17
    shl di, 1
    mov ah,0x0F
    mov cx, 95
    rep stosw

    mov dx, line_4
    call print_string

    mov dh, 5
    mov dl, 17
    call set_cursor_position

    call delay

    mov dx, line_5
    call print_string

    pop dx
    pop cx
    pop ax
    pop di
    pop es
    
    pop bp
ret

game_over:
    push bp
    mov bp, sp

    push es        ; Save ES
    push di        ; Save DI
    push ax        ; Save AX
    push cx        ; Save CX

    mov ax, 0xB800
    mov es, ax

    ; Define a macro to draw a character multiple times
    %macro draw_char 3
    mov di, (%1 * 132 + %2) * 2
    mov al, 219
    mov ah, 0F4h
    mov cx, %3
    rep stosw
    %endmacro

    ;G
    draw_char 14, 25, 8
    draw_char 15, 25, 2
    draw_char 16, 25, 2
    draw_char 17, 25, 2
    draw_char 17, 30, 3
    draw_char 18, 25, 2
    draw_char 18, 30, 3
    draw_char 19, 25, 8

    ;A
    draw_char 15, 36, 7
    draw_char 16, 41, 2
    draw_char 17, 35, 8
    draw_char 18, 35, 3
    draw_char 18, 40, 3
    draw_char 19, 35, 8

    ;M
    draw_char 15, 45, 10
    draw_char 16, 45, 10
    draw_char 17, 45, 2
    draw_char 17, 49, 2
    draw_char 17, 53, 2
    draw_char 18, 45, 2
    draw_char 18, 49, 2
    draw_char 18, 53, 2
    draw_char 19, 45, 2
    draw_char 19, 49, 2
    draw_char 19, 53, 2

    ;e
    draw_char 15, 57, 8
    draw_char 16, 57, 3
    draw_char 16, 62, 3
    draw_char 17, 57, 8
    draw_char 18, 57, 3
    draw_char 19, 57, 8

    ;o
    draw_char 14, 70, 8
    draw_char 15, 70, 8
    draw_char 16, 70, 3
    draw_char 16, 75, 3
    draw_char 17, 70, 3
    draw_char 17, 75, 3
    draw_char 18, 70, 8
    draw_char 19, 70, 8

    ;v
    draw_char 15, 80, 2
    draw_char 15, 86, 2
    draw_char 16, 80, 2
    draw_char 16, 86, 2
    draw_char 17, 81, 2
    draw_char 17, 85, 2
    draw_char 18, 81, 2
    draw_char 18, 85, 2
    draw_char 19, 82, 4

    ;e
    draw_char 15, 90, 8
    draw_char 16, 90, 3
    draw_char 16, 95, 3
    draw_char 17, 90, 8
    draw_char 18, 90, 3
    draw_char 19, 90, 8

    ;r
    draw_char 15, 100, 8
    draw_char 16, 100, 3
    draw_char 16, 105, 3
    draw_char 17, 100, 3
    draw_char 17, 105, 3
    draw_char 18, 100, 3
    draw_char 19, 100, 3

    pop cx      
    pop ax 
    pop di      
    pop es      

    pop bp
ret

set_cursor_position:
    push bp
    mov bp, sp
    
    push ax
    push bx

    mov ah, 0x02                      ; BIOS function to set cursor position
    mov bh, 0x00                      ; Page number (0 for most systems)
    int 0x10                          ; Call BIOS interrupt

    pop bx
    pop ax

    pop bp
ret

print_string:
    push bp
    mov bp, sp

    push ax

    mov ah, 0x09
    int 0x21

    pop ax
    
    pop bp
ret

waitLoop:
    push bp
    mov bp, sp

    push ax

    getSpace:
        xor ah, ah          ; BIOS keyboard interrupt function
        int 0x16              ; Wait for a key press
        
        cmp al, 0x20          ; Check if the key pressed is spacebar (ASCII 0x20)
        je spacebarPressed    ; If spacebar, jump to spacebarPressed

        ; Beep sound for invalid key press
        mov ah, 0x0E
        mov al, 0x07          ; ASCII code for bell (beep)
        int 0x10              ; BIOS video interrupt
    jmp getSpace          ; Wait for the next key press

    spacebarPressed:
        pop ax
        
        pop bp
ret

wait_next:
    push ax              ; Save AX register
    
    mov ah, 0x00         ; BIOS keyboard interrupt function to wait for a key press
    int 0x16             ; Call interrupt
    
    pop ax               ; Restore AX register
ret

GetPlayerName:
    push bp
    mov bp, sp

    push dx

    mov dh, 4
    mov dl, 50
    call set_cursor_position

    mov dx, name
    call print_string

    mov dx, name_buffer
    call get_input

    pop dx

    pop bp
ret

get_input:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov ah, 0x0A                      ; DOS buffered input function
    int 0x21                          ; DOS interrupt
    
    ; Append $ to the end of the entered data
    mov bx, dx                    
    add bx, 2                        
    mov cl, [bx-1]                    
    add bx, cx                        ; Move to end of the entered characters
    mov byte [bx], '$' 

    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
ret
        
PrintFinalScore:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push bx
    push cx
    push dx

    mov ax, 0xB800
    mov es, ax
    
    mov dh, 25
    mov dl, 55
    call set_cursor_position
    mov dx, Score
    call print_string
    
    mov bx, 25        ; Row
    mov cx, 63       ; Column
    imul ax, bx, 132
    add ax, cx
    shl ax, 1
    mov di, ax

    ; Convert score to ASCII and print it
    mov ax, [score]
    mov bx, 10
    xor cx, cx

    print_digitF:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        cmp ax, 0
    jne print_digitF

    print_digitsF:
        pop dx
        mov al, dl
        mov ah, 0x0F
        stosw
    loop print_digitsF

    pop dx
    pop cx
    pop bx
    pop ax
    pop di
    pop es

    pop bp
ret

UpdateAndPrintHighestScore:
    push bp
    mov bp, sp

    push es
    push di
    push ax
    push bx
    push cx
    push dx

    ; Update highest score if current score is greater
    mov ax, [score]
    cmp ax, [highest_score]
    jle skip_update
    mov [highest_score], ax

    skip_update:
        mov ax, 0xB800
        mov es, ax

        mov dh, 27
        mov dl, 55
        call set_cursor_position

        mov dx, Highest_Score
        call print_string
        
        mov bx, 27       ; Row
        mov cx, 71       ; Column
        imul ax, bx, 132
        add ax, cx
        shl ax, 1
        mov di, ax

        ; Convert highest score to dec and print it
        mov ax, [highest_score]
        mov bx, 10
        xor cx, cx

    print_digitU:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        cmp ax, 0
    jne print_digitU

    print_digitsU:
        pop dx
        mov al, dl
        mov ah, 0x0F
        stosw
    loop print_digitsU

    pop dx
    pop cx
    pop bx
    pop ax
    pop di
    pop es
    
    pop bp
ret

PrintPlayerName:
    push bp
    mov bp, sp

    push dx

    mov dh, 23
    mov dl, 55
    call set_cursor_position
    mov dx, Name
    call print_string

    mov dh, 23                       ; Set row for Name
    mov dl, 63                       ; Column 30
    call set_cursor_position
    mov dx, name_buffer+2             ; Start from the user-entered data
    call print_string

    pop dx

    pop bp
ret

; PlayMusic:
;     cmp byte [cs:exitAnimation], 1
;     je dontPlayMusic

;     ; Prepare timer 2 for sound generation
;     mov al, 0b6h
;     out 43h, al
;     ; Softer, gentler celebratory tones
;     mov cx, 3              ; 3 ascending notes
;     celebration_loop:
;         ; Lower frequency, more melodic
;         mov bx, cs:musicind
;         mov ax, [cs:music+bx];0x2800         ; Even lower base frequency
;         shr ax, cl             ; Gentle ascending progression
;         out 42h, al
;         mov al, ah
;         out 42h, al
    
;         ; Turn speaker on
;         in al, 61h
;         or al, 3h
;         out 61h, al
    
;         ; Slightly longer soundelay for softer sound
;         push cx

;         mov cx, 5
;         tone_delay:
;             push cx

;             mov cx, 0xFFFF
;             delay_loop:
;                 loop delay_loop
                
;             pop cx
;         loop tone_delay

;         pop cx    
;     loop celebration_loop
    
;     add word [cs:musicind], 2

;     cmp word [cs:musicind], 60
;     jne dontReset

;     mov word [cs:musicind], 0
    
;     dontReset:
;     dontPlayMusic:
;     ; Turn speaker off
;     in al, 61h
;     and al, 0FCh
;     out 61h, al
; jmp PlayMusic

PlayMusic:
    cmp byte [cs:exitAnimation], 1
    je stopPlayMusic

    ; Prepare timer 2 for sound generation
    mov al, 0b6h
    out 43h, al

    cmp byte [cs:gameRunning], 0
    je musicProd

    cmp byte [cs:birdDirection], 'U'
    je flapSound

    cmp byte [cs:scoreUpdated], 1
    je scoreSound

    cmp byte [cs:isCollided], 1
    je collisionSound

    jmp stopPlayMusic

    flapSound:
        mov bx, 2
        jmp soundProd

    scoreSound:
        mov bx, 0
        mov byte [cs:scoreUpdated], 0
        jmp soundProd

    collisionSound:
        mov bx, 4
        jmp soundProd


    soundProd:
        ; Lower frequency, more melodic
        mov ax, [cs:soundMusic+bx]         ; Even lower base frequency
        shr ax, 3             ; Gentle ascending progression
        out 42h, al
        mov al, ah
        out 42h, al
    
        ; Turn speaker on
        in al, 61h
        or al, 3h
        out 61h, al

        mov cx, 0x1000
        soundsDelayloop:
                loop soundsDelayloop

    jmp stopPlayMusic

    musicProd:
    mov cx, 3              ; 3 ascending notes
    celebration_loop:
        mov bx, [cs:musicind]
        mov ax, [cs:music+bx];0x2800         ; Even lower base frequency
        shr ax, cl             ; Gentle ascending progression
        out 42h, al
        mov al, ah
        out 42h, al
    
        ; Turn speaker on
        in al, 61h
        or al, 3h
        out 61h, al
    
        ; Slightly longer soundelay for softer sound
        push cx

        mov cx, 5
        tone_delay:
            push cx

            mov cx, 0xFFFF
            delay_loop:
                loop delay_loop
                
            pop cx
        loop tone_delay

        pop cx    
    loop celebration_loop
    
    add word [cs:musicind], 2

    cmp word [cs:musicind], 60
    jne dontReset

    mov word [cs:musicind], 0
    
    dontReset:
    stopPlayMusic:
    ; Turn speaker off
    in al, 61h
    and al, 0FCh
    out 61h, al
jmp PlayMusic

screenBuffer: 	times 34 * 132 dw 0x0
                times 8 * 132 dw 0x0
                times 1 * 132 dw 0x0
        
confirmationScreenBuffer: times 5*42 dw 0x0

name_buffer:    db 20, 0                 ; Max 19 chars + terminating null ($)
                times 20 db 0

soundMusic: 
    dw 0x0679   ; Flap Sound (A5, 880 Hz)
    dw 0x0618   ; Score Sound (B5, 988 Hz)
    dw 0x0F9F   ; Collision Sound (A4, 440 Hz)

music: 
    dw 0x1D16, 0x1742, 0x12E0, 0x157D, 0x1A9E, 0x1D16
    dw 0x12E0, 0x0F9F, 0x157D, 0x1742, 0x1A9E, 0x1D16
    dw 0x1E04, 0x12E0, 0x157D, 0x1742, 0x1D16, 0x1A9E
    dw 0x157D, 0x12E0, 0x1742, 0x1A9E, 0x1D16, 0x0F9F
    dw 0x1E04, 0x12E0, 0x157D, 0x1A9E, 0x1D16, 0x1742
musicind: dw 0


