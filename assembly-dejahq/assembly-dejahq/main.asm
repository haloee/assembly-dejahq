.386
.model flat, stdcall
.stack 4096

; Windows API f�ggv�nyek deklar�l�sa
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
    resultBuffer BYTE 4 DUP(0)    ; Eredm�ny ki�r�s�hoz buffer
    hConsoleOutput DWORD ?
    hConsoleInput DWORD ?
    bytesWritten DWORD ?
    bytesRead DWORD ?

.code

main PROC
    ; Konzol kimenet �s bemenet lek�r�se
    INVOKE GetStdHandle, -11     ; STD_OUTPUT_HANDLE
    mov hConsoleOutput, eax
    INVOKE GetStdHandle, -10     ; STD_INPUT_HANDLE
    mov hConsoleInput, eax

    ; Els� sz�m bek�r�se
    INVOKE WriteConsoleA, hConsoleOutput, ADDR promptMessage1, SIZEOF promptMessage1, ADDR bytesWritten, 0
    INVOKE ReadConsoleA, hConsoleInput, ADDR inputBuffer, 4, ADDR bytesRead, 0
    movzx eax, inputBuffer       ; Olvasott karakter sz�m�rt�ke
    sub eax, '0'                 ; ASCII -> int konverzi�
    mov ecx, eax                 ; Az els� sz�m t�rol�sa ECX-ben

    ; M�sodik sz�m bek�r�se
    INVOKE WriteConsoleA, hConsoleOutput, ADDR promptMessage2, SIZEOF promptMessage2, ADDR bytesWritten, 0
    INVOKE ReadConsoleA, hConsoleInput, ADDR inputBuffer, 4, ADDR bytesRead, 0
    movzx eax, inputBuffer
    sub eax, '0'
    mov edx, eax                 ; A m�sodik sz�m t�rol�sa EDX-ben

    ; �sszeg f�ggv�ny h�v�sa
    push ecx
    push edx
    CALL AddNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; �sszeg ki�r�sa
    INVOKE WriteConsoleA, hConsoleOutput, ADDR addMessage, SIZEOF addMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Szorzat f�ggv�ny h�v�sa
    push ecx
    push edx
    CALL MultiplyNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Szorzat ki�r�sa
    INVOKE WriteConsoleA, hConsoleOutput, ADDR multMessage, SIZEOF multMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; K�l�nbs�g f�ggv�ny h�v�sa
    push ecx
    push edx
    CALL SubtractNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; K�l�nbs�g ki�r�sa
    INVOKE WriteConsoleA, hConsoleOutput, ADDR diffMessage, SIZEOF diffMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Oszt�s f�ggv�ny h�v�sa
    cmp edx, 0
    je DivisionError
    push ecx
    push edx
    CALL DivideNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Oszt�s ki�r�sa
    INVOKE WriteConsoleA, hConsoleOutput, ADDR divMessage, SIZEOF divMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0
    jmp AfterDivision

DivisionError:
    INVOKE WriteConsoleA, hConsoleOutput, ADDR divErrorMessage, SIZEOF divErrorMessage, ADDR bytesWritten, 0

AfterDivision:

    ; Marad�kos oszt�s
    cmp edx, 0
    je AfterModulus
    push ecx
    push edx
    CALL ModulusNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Marad�kos oszt�s ki�r�sa
    INVOKE WriteConsoleA, hConsoleOutput, ADDR modMessage, SIZEOF modMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

AfterModulus:

    ; Hatv�nyoz�s
    push ecx
    push edx
    CALL PowerNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    ; Hatv�nyoz�s eredm�ny�nek ki�r�sa
    INVOKE WriteConsoleA, hConsoleOutput, ADDR powerMessage, SIZEOF powerMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; �sszehasonl�t�s eredm�ny�nek ki�r�sa
    push ecx
    push edx
    CALL CompareNumbers
    add esp, 8
    add eax, '0'
    mov resultBuffer, al

    INVOKE WriteConsoleA, hConsoleOutput, ADDR comparisonMessage, SIZEOF comparisonMessage, ADDR bytesWritten, 0
    INVOKE WriteConsoleA, hConsoleOutput, ADDR resultBuffer, 1, ADDR bytesWritten, 0

    ; Kil�p�s
    mov eax, 0
    INVOKE ExitProcess, eax
main ENDP

; �sszead�s f�ggv�ny
AddNumbers PROC
    mov eax, [esp+4]
    add eax, [esp+8]
    ret
AddNumbers ENDP

; Szorz�s f�ggv�ny
MultiplyNumbers PROC
    mov eax, [esp+4]
    imul eax, [esp+8]
    ret
MultiplyNumbers ENDP

; Kivon�s f�ggv�ny
SubtractNumbers PROC
    mov eax, [esp+4]
    sub eax, [esp+8]
    ret
SubtractNumbers ENDP

; Oszt�s f�ggv�ny
DivideNumbers PROC
    mov eax, [esp+4]
    cdq
    idiv dword ptr [esp+8]
    ret
DivideNumbers ENDP

; Marad�kos oszt�s f�ggv�ny
ModulusNumbers PROC
    mov eax, [esp+4]
    cdq
    idiv dword ptr [esp+8]
    mov eax, edx  ; A marad�k eredm�nye EDX-ben van, ezt adjuk vissza
    ret
ModulusNumbers ENDP

; Hatv�nyoz�s f�ggv�ny
PowerNumbers PROC
    mov eax, 1
    mov ecx, [esp+8]   ; Hatv�ny
    mov ebx, [esp+4]   ; Alap

PowerLoop:
    test ecx, ecx      ; Ellen�rz�s, hogy ecx (exponent) nulla-e
    jz PowerDone
    imul eax, ebx      ; Szorz�s az alappal
    dec ecx
    jmp PowerLoop

PowerDone:
    ret
PowerNumbers ENDP

; �sszehasonl�t�s f�ggv�ny
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
