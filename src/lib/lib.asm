global string_length
global print_char
global print_newline
global print_string
global print_error
global print_uint
global print_int
global string_equals
global parse_uint
global parse_int
global read_word
global read_char
global string_copy
global exit

section .text

exit:
    mov rax, 60
    mov rdi, 0
    syscall

; Принимает код возврата и завершает текущий процесс


; указатель на строку хранится в rdi
; rsi - для вывода, принимает указатель на начало строки
; rdx - для вывода, принимает кол-во символов на вывод


; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
	xor rax, rax
	.loop_start:
		cmp byte [rdi + rax], 0				; sets ZF=1 if symbol on [rdi + current length] == 0 (end of string)
		je .loop_end					    ; if ZF==1, jmp .loop_end
		inc rax						        ; rax++ <--> string length will be saved on rax
		jmp .loop_start                     ; start loop again
	.loop_end:
		ret

;Принимает указатель на нуль-терминированную строку (rdi), выводит её в stdout
;Первый символ строки находится по rdi
print_string:
    push rdi
    push rsi
    push rdx

    call string_length                      ;get string length to rax
    mov rsi, rdi                            ;syscall 1(print) reads first symbol from [rsi], mov rdi (first symbol) to rsi
    mov rdx, rax                            ;syscall 1(print) reads length from rdx, mov rax (string length) on rdx

    mov rax, 1                              ;syscall reads call number from rax, we set rax==1 -> std_out call
    mov rdi, 1                              ;first argument of syscall takes from rdi, we set rdi==1 -> std_out
    syscall                                 ;print
	
    pop rdx
    pop rsi
    pop rdi

    ret



;Функции принимают аргументы в rdi, rsi, rdx, rcx, r8 и r9
;Принимает код символа и выводит его в stdout
print_char:
	push rdi                                ;push symbol to stack, pointer(rsp) now set to symbol to print
	mov rsi, rsp                            ;set pointer to symbol for print to rsi

	mov rax, 1                              ;set syscall 1(std_out)
	mov rdi, 1                              ;print to std_out

	mov rdx, 1                              ;length==1, 1 symbol

	syscall

	pop rdi                                 ;set rdi and rsp back - rsp is a called saved register
	ret


; Переводит строку (выводит символ с кодом 0xA)
print_newline:
        push rax
        push rdi
        push rsi
        push rcx
        
        mov rdi, 0xA                            ;push to rdi \n symbol
        call print_char
        
        pop rcx
        pop rsi
        pop rdi
        pop rax
        ret

;Функции принимают аргументы в rdi, rsi, rdx, rcx, r8 и r9
; Выводит беззнаковое 8-байтовое число в десятичном формате
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    push r13                                ;save r13 to stack (called-saved register)
	push r12                                ;save r12 to stack (called-saved register)
	mov r12, rsp                            ;save stack pointer to r12

	mov rax, rdi                            ;mov to rax 8-byte number from arg(rdi)

  	dec rsp                                 ;stack grows down so there we just moving to the next cell
	mov byte[rsp], 0                        ;set this cell 0

	.div_loop:
		xor rdx, rdx                        ;clear rdx

		mov r13, 10                         ;set r13 to 10
		div r13                             ;rax/r13 -> quotient(rax) and remainder(rdx)

		add rdx, 0x30                       ;translation to ASCII code of remainder(rdx)
		dec rsp                             ;next stack cell
		mov byte[rsp], dl                   ;save 8-bit char of rdx register <--> save our char

		test rax, rax                       ;set flags for rax content
		jz .print                           ;if ZF==1 (if rax == 0) jump to print
		jmp .div_loop                       ;else start loop again

	.print:
		mov rdi, rsp                        ;set pointer to last char to rdi(first arg of print_string)
		call print_string                   ;print number

		mov rsp, r12                        ;set stack pointer back to r12
		pop r12                             ;return value back to r12
		pop r13                             ;return value back to r13
		ret



;Функции принимают аргументы в rdi, rsi, rdx, rcx, r8 и r9
;Выводит знаковое 8-байтовое число в десятичном формате
print_int:
    mov rax, rdi                            ;put into rax our 8-bit number

	mov r9,0x8000000000000000               ;set mask to r9 (in binary 1000...000) - we save only sign of number
    and r9, rax                             ;after AND, we have only sign of our number
    test r9, r9                             ;test number
    jz .not_neg                             ;if ZF==1(if r9 != 0  <--> it's not negative) we just jump to print uint

    push rax                                ;save rax (still contains number)
    mov  rdi, '-'                           ;set rdi '-' sign
    call print_char                         ;print '-'
    pop rax                                 ;get rax back

    neg rax                                 ;neg number to positive, just like it was uint
    mov rdi, rax                            ;set first arg(rdi) of print_uint to our number
    jmp .not_neg

    .not_neg:
        call print_uint
        ret

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
;Функции принимают аргументы в rdi, rsi, rdx, rcx, r8 и r9
string_equals:
	xor rax, rax                            ;clear rax

	.length_check:                          ;firstly we want to know if strings are length-equals
		call string_length                  ;get length of first string to rax
		mov r9, rax                         ;save first string length to r9

		xchg rdi, rsi                       ;swap pointers of first symbols of str1 and str2
		call string_length                  ;get length of second string to rax
		cmp r9, rax                         ;compare length of str1 and str2

		jne .not_equals                     ;if not equal (ZF == 0 <--> after subtraction number not zero)
		xor rax, rax
             jmp .equals_loop                    ;else start .equals loop

	.equals_loop:
		mov r9b, byte[rdi + rax]            ;set r9 to char of first string
		cmp r9b, byte[rsi + rax]            ;compare
		jne .not_equals                     ;if not equals

		cmp byte[rsi+rax], 0                ;if this is end of string (since all previous chars was compared) - strings equals
		je .equals

		inc rax                             ;move to the next chars of strings
		jmp .equals_loop

	.equals:
		mov rax, 1                        ;true
		jmp .end
	.not_equals:
		mov rax, 0                        ;false
		jmp .end
       .end:
            xchg rdi, rsi
            ret


; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
	mov rax, 0                              ;set syscall 0 (std_in)
	mov rdi, 0                              ;set input to std_in
	mov rdx, 1                              ;length of string, in out case 0

	push 0                                  ;if we won't got anything, we'll pop 0
	mov rsi, rsp                            ;we will read to stack
	syscall                                 ;read 1 char, if we can of course

	pop rax                                 ;if we got an char, he will be on rax, else - in rax will be pushed before 0
	ret



; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    xor rcx, rcx                            ;clear rcx
    mov r8, rdi                             ;save buffer start to r8
    mov r9, rsi                             ;save buffer size to r9
    xor r10, r10                            ;clear r10

    .read_word_loop:
        call read_char                      ;read char

        cmp al, 0x20 		                ;compare char from rax with 0x20(space)
        je .space_symbol                    ;if equals
        cmp al, 0x9                         ;tab
        je .space_symbol
        cmp al, 0xA			                ;newline
        je .space_symbol

        cmp rax, 0                          ;if we got EOF
        je .return

        mov [r8 + r10], rax                 ;save char to [buffer start + number of symbols]
        inc r10                             ;move to the next symbol

        cmp r10, r9                         ;compare number of gotten symbols and buffer size
        jge .buffer_overflow                ;if we got more symbols than buffer size then this is an overflow
        jmp .read_word_loop                 ; else we start again

	.space_symbol:
        cmp r10, 0                          ;if this is a first symbol
        je .read_word_loop                  ;we jump to the next
        jmp .return                         ;else we already got the word

    .buffer_overflow:
        xor rdx, rdx                        ;clear registers, just because
        xor rax, rax
        ret

    .return:
        mov byte [r8 + r10], 0              ;add null-terminator
        mov rax, r8                         ;save to rax pointer to buffer
        mov rdx, r10                        ;save to rdx size of word
        ret

;Функции принимают аргументы в rdi, rsi, rdx, rcx, r8 и r9
; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
	xor rax, rax                            ;clear rax
    xor rcx, rcx                            ;clear rcx
    xor rdx, rdx                            ;clear rdx
    xor rsi, rsi                            ;clear rsi
    mov r8, 10                              ;set r8 = 10
    .loop:
        mov sil, byte[rdi + rcx]            ;mov to rsi char of string

        cmp sil, '0'
        jl .return                          ;if less than 0(ASCII)
        cmp sil, '9'
        jg .return                          ;or more than 9(ASCII) - we return

        inc rcx                             ;inc length

        sub sil, '0'                        ;transform symbol to number
        mul r8                              ;move rax left
        add rax, rsi			    ;add to rax
        jmp .loop

    .return:
        mov rdx, rcx
        ret



; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был)
; rdx = 0 если число прочитать не удалось
parse_int:
	xor rax, rax
    	cmp byte[rdi], '-'
    	je .signed
    	call parse_uint	
    	jmp .return

    	.signed:
        	inc rdi
        	call parse_uint
        	cmp rdx, 0
        	je .return
        	neg rax
        	inc rdx
    	.return:
        	ret

	

; Принимает указатель на строку rdi, указатель на буфер rsi и длину буфера rdx
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
	xor rax, rax
	call string_length	
	inc rax	
	cmp rax, rdx
	jg .greater

	xor rax, rax
	
	.copy_loop:
		cmp rax, rdx
		jg .greater

		mov r9b, byte[rdi + rax]
		mov [rsi + rax], r9b
		
		cmp byte[rsi + rax], 0
		je .return

		inc rax

		jmp .copy_loop

	.greater:
		xor rax, rax
		ret

	.return:
		inc rax
		ret



















