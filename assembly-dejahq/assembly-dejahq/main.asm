.386
.model flat, stdcall
.stack 4096

; Windows API függvények deklarálása
ExitProcess PROTO, dwExitCode:DWORD
GetStdHandle PROTO, nStdHandle:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD, lpBuffer:PTR BYTE, nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:PTR DWORD, lpReserved:DWORD
ReadConsoleA PROTO, hConsoleInput:DWORD, lpBuffer:PTR BYTE, nNumberOfCharsToRead:DWORD, lpNumberOfCharsRead:PTR DWORD, lpReserved:DWORD

.data
    promptMessage1 BYTE "Enter the first number (0-9): ", 0
    promptMessage2 BYTE "Enter the second number (0-9): ", 0
    addMessage BYTE "The sum is: ", 0
    multMessage BYTE "The product is: ", 0
    diffMessage BYTE "The difference is: ", 0
    divMessage BYTE "The division is: ", 0
    divErrorMessage BYTE "Cannot divide by zero.", 0
    modMessage BYTE "The remainder is: ", 0
    powerMessage BYTE "The power is: ", 0
    comparisonMessage BYTE "Comparison result: ", 0
    inputBuffer BYTE 4 DUP(0)     ; Bemenethez buffer
    resultBuffer BYTE 4 DUP(0)    ; Eredmény kiírásához buffer
    hConsoleOutput DWORD ?
    hConsoleInput DWORD ?
    bytesWritten DWORD ?
    bytesRead DWORD ?

.code

main PROC
    ; Konzol kimenet és bemenet lekérése
    INVOKE GetStdHandle, -11     ; STD_OUTPUT_HANDLE
    mov hConsoleOutput, eax
    INVOKE GetStdHandle, -10     ; STD_INPUT_HANDLE
    mov hConsoleInput, eax

    ; Elsõ szám bekérése
    INVOKE WriteConsoleA, hConsoleOutput, ADDR promptMessage1, SIZEOF promptMessage1, ADDR bytesWritten, 0
    INVOKE ReadConsoleA, hConsoleInput, ADDR inputBuffer, 4, ADDR bytesRead, 0
    movzx eax, inputBuffer       ; Olvasott karakter számértéke
    sub eax, '0'                 ; ASCII -> int konverzió
    mov ecx, eax                 ; Az elsõ szám tárolása ECX-ben

    ; Második szám bekérése
    INVOKE WriteConsoleA, hConsoleOutput, ADDR promptMessage2, SIZEOF promptMessage2, ADDR bytesWritten, 0
    INVOKE ReadConsoleA, hConsoleInput, ADDR inputBuffer, 4, ADDR bytesRead, 0
    movzx eax, inputBuffer
    sub eax, '0'
    mov edx, eax                 ; A második szám tárolása EDX-ben

    ; Összeg függvény hívása
    push ecx
    push edx
    CALL AddNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Összeg kiírása
    INVOKE WriteConsoleA, hConsoleOutput, ADDR addMessage, SIZEOF addMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Szorzat függvény hívása
    push ecx
    push edx
    CALL MultiplyNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Szorzat kiírása
    INVOKE WriteConsoleA, hConsoleOutput, ADDR multMessage, SIZEOF multMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Különbség függvény hívása
    push ecx
    push edx
    CALL SubtractNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Különbség kiírása
    INVOKE WriteConsoleA, hConsoleOutput, ADDR diffMessage, SIZEOF diffMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Osztás függvény hívása
    cmp edx, 0
    je DivisionError
    push ecx
    push edx
    CALL DivideNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Osztás kiírása
    INVOKE WriteConsoleA, hConsoleOutput, ADDR divMessage, SIZEOF divMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0
    jmp AfterDivision

DivisionError:
    INVOKE WriteConsoleA, hConsoleOutput, ADDR divErrorMessage, SIZEOF divErrorMessage, ADDR bytesWritten, 0

AfterDivision:

    ; Maradékos osztás
    cmp edx, 0
    je AfterModulus
    push ecx
    push edx
    CALL ModulusNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Maradékos osztás kiírása
    INVOKE WriteConsoleA, hConsoleOutput, ADDR modMessage, SIZEOF modMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

AfterModulus:

    ; Hatványozás
    push ecx
    push edx
    CALL PowerNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Hatványozás eredményének kiírása
    INVOKE WriteConsoleA, hConsoleOutput, ADDR powerMessage, SIZEOF powerMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Összehasonlítás eredményének kiírása
    push ecx
    push edx
    CALL CompareNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    INVOKE WriteConsoleA, hConsoleOutput, ADDR comparisonMessage, SIZEOF comparisonMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Kilépés
    mov eax, 0
    INVOKE ExitProcess, eax
main ENDP

; Összeadás függvény
AddNumbers PROC
    mov eax, [esp+4]
    add eax, [esp+8]
    ret
AddNumbers ENDP

; Szorzás függvény
MultiplyNumbers PROC
    mov eax, [esp+4]
    imul eax, [esp+8]
    ret
MultiplyNumbers ENDP

; Kivonás függvény
SubtractNumbers PROC
    mov eax, [esp+4]
    sub eax, [esp+8]
    ret
SubtractNumbers ENDP

; Osztás függvény
DivideNumbers PROC
    mov eax, [esp+4]
    cdq
    idiv dword ptr [esp+8]
    ret
DivideNumbers ENDP

; Maradékos osztás függvény
ModulusNumbers PROC
    mov eax, [esp+4]
    cdq
    idiv dword ptr [esp+8]
    mov eax, edx  ; A maradék eredménye EDX-ben van, ezt adjuk vissza
    ret
ModulusNumbers ENDP

; Hatványozás függvény
PowerNumbers PROC
    mov eax, 1
    mov ecx, [esp+8]   ; Hatvány
    mov ebx, [esp+4]   ; Alap

PowerLoop:
    test ecx, ecx      ; Ellenõrzés, hogy ecx (exponent) nulla-e
    jz PowerDone
    imul eax, ebx      ; Szorzás az alappal
    dec ecx
    jmp PowerLoop

PowerDone:
    ret
PowerNumbers ENDP

; Összehasonlítás függvény
CompareNumbers PROC
    mov eax, [esp+4]
    mov ebx, [esp+8]
    cmp eax, ebx
    ja FirstGreater
    jb SecondGreater
    mov eax, '='
    ret

FirstGreater:
    mov eax, '>'
    ret

SecondGreater:
    mov eax, '<'
    ret
CompareNumbers ENDP

END main
