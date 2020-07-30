IDEAL
MODEL small
STACK 1000h
DATASEG
	errorstr db 255 dup (0)
	board db 		0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0
				
	tmpboard db 	0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0
	mem dw 16 dup (0)
	num_display db 	0000000b, \ ; 0 (empty)
					0010010b, \	; 1
					0111101b, \	; 2
					0111011b, \	; 3
					1011010b, \	; 4
					1101011b, \	; 5
					1101111b, \	; 6
					0110010b, \	; 7
					1111111b, \	; 8
					1111011b	; 9
					
	retarr dw 16 dup (0)
	solve db 1101011b, 1110111b, 1000101b, 1010111b, 1101101b, 1000000b
	
	board_cords dw 10, 10, 190, 190
	solvebtn_cords dw 236, 163, 286, 171
CODESEG
	start:
		mov ax, @data
		mov ds, ax
		
	main:		
		call graphic_mode_on
		
		push 15	; color (white)
		call draw_bg
		
		push 10	; x
		push 10	; y
		push 0	; out color (black)
		push 15	; in color (white)
		push 20	; box length
		push 2	; box line width
		call sdraw_board
		call supdate_board
		
		call init_mouse
		
		push 230
		push 160
		push 0
		push 0Fh
		push offset solve
		call sdraw_solvebtn
		
		; call wait_keypress
		; push 240
		; push 170
		; call mouse_event_handler
		; call wait_keypress
		
		; jmp gameloop_end
		gameloop:
			mov ah, 1h
			int 16h
			jnz gameloop_key_start
			
			mov ax, 3h
			int 33h
			cmp bx, 1b
			jne gameloop_mouse_end
			
			jmp gameloop_mouse_start
			gameloop_mouse_start:
				push 20
				call rect_debug
				
				shr cx, 1
				
				push cx
				push dx
				mov ax, 0
				call mouse_event_handler
				push 30
				call rect_debug
			gameloop_mouse_end:
			
			jmp gameloop_key_end
			gameloop_key_start:
				push 11
				call rect_debug
				
				cmp ax, 02D18h
				je gameloop_end
				jne gameloop
			gameloop_key_end:
		
			push 40
			call rect_debug
		jmp gameloop
		gameloop_end:
		
		; call wait_keypress
		call graphic_mode_off
	
		jmp exit
		
	p_mouse_x	EQU [word ptr bp + 6]
	p_mouse_y	EQU [word ptr bp + 4]
	proc mouse_event_handler
		push bp
		mov bp, sp
		
		push ax
		push bx
		push cx
		push dx
		
		mov ax, [board_cords]
		cmp p_mouse_x, ax
		jl not_board_s
		mov ax, [board_cords + 2]
		cmp p_mouse_y, ax
		jl not_board_s
		mov ax, [board_cords + 4]
		cmp p_mouse_x, ax
		jg not_board_s
		mov ax, [board_cords + 6]
		cmp p_mouse_y, ax
		jg not_board_s
		jmp lboard
			not_board_s:
			jmp not_board_end3
		lboard:
			mov bx, offset board
			
			
			mov ax, p_mouse_y
			sub ax, 10
			mov cx, 20
			div cl
			mov cx, 9
			mul cx
			xor ah, ah
			add bx, ax
			
			mov ax, p_mouse_x
			sub ax, 10
			mov cx, 20
			div cl
			xor ah, ah
			add bx, ax
			
			mov ax, [bx]
			mov dx, [bx]
			or ax, 10000000b
			mov [bx], ax
			call supdate_board
			call get_keypress
			xor ah, ah
			cmp ax, "0"
			jl not_board_end1
			cmp ax, "9"
			jg not_board_end1
				sub ax, "0"
				mov [bx], al
				jmp not_board_end2
			not_board_end1:
				mov [bx], dl
		not_board_end2:
			call supdate_board
		not_board_end3:
		
		mov ax, [solvebtn_cords]
		cmp p_mouse_x, ax
		jl not_solvebtn_s
		mov ax, [solvebtn_cords + 2]
		cmp p_mouse_y, ax
		jl not_solvebtn_s
		mov ax, [solvebtn_cords + 4]
		cmp p_mouse_x, ax
		jg not_solvebtn_s
		mov ax, [solvebtn_cords + 6]
		cmp p_mouse_y, ax
		jg not_solvebtn_s
		jmp lsolvebtn
			not_solvebtn_s:
			jmp not_solvebtn_end
		lsolvebtn:
			push 11
			call rect_debug
			
			push 81
			push offset board
			push offset tmpboard
			call memcpy
			
			push offset tmpboard
			call solve_sudoku
			
			cmp ax, 1
			jne end_solved
				push 81
				push offset tmpboard
				push offset board
				call memcpy
			end_solved:
			
			call supdate_board
		not_solvebtn_end:
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		pop bp
		
		ret 4
	endp mouse_event_handler
		
	proc graphic_mode_on
		push ax
		
		mov ax, 13h
		int 10h 
		
		pop ax
		
		ret
	endp graphic_mode_on
	
	proc graphic_mode_off
		push ax
		
		mov ah, 0
		mov al, 2
		int 10h
		
		pop ax
		
		ret
	endp graphic_mode_off
	
	p_x		EQU [word ptr bp + 8]
	p_y		EQU [word ptr bp + 6]
	p_col	EQU [byte ptr bp + 4]
	proc draw_dot
		push bp
		mov bp, sp
		
		push ax
		push bx
		push cx
		push dx
		
		mov bh, 0h
		mov cx, p_x
		mov dx, p_y
		mov al, p_col
		mov ah, 0ch
		int 10h 
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		pop bp
		
		ret 6
	endp draw_dot
	
	proc wait_keypress
		push ax
		
		mov ah, 00h
		int 16h 
		
		pop ax
		
		ret
	endp wait_keypress
	
	; return AX = key value
	proc get_keypress
		mov ah, 00h
		int 16h 
		
		ret
	endp get_keypress
	
	p_x1	EQU [word ptr bp + 12]
	p_y1	EQU [word ptr bp + 10]
	p_x2	EQU [word ptr bp + 8]
	p_y2	EQU [word ptr bp + 6]
	p_col	EQU [byte ptr bp + 4]
	proc draw_rect
		push bp
		mov bp, sp
		
		push ax
		push cx
		push dx
		
		mov cx, p_y2
		sub cx, p_y1
		
		draw_rect_yloop:
			mov ax, cx
			
			mov cx, p_x2
			sub cx, p_x1
			
			draw_rect_xloop:
				mov dx, cx
				add dx, p_x1
				push dx
				
				mov dx, ax
				add dx, p_y1
				push dx
				
				mov dl, p_col
				mov dh, 0
				push dx
				
				call draw_dot
			loop draw_rect_xloop
			
			mov cx, ax
		loop draw_rect_yloop
		
		pop dx
		pop cx
		pop ax
		
		pop bp
		
		ret 10
	endp draw_rect
	
	p_col	EQU [byte ptr bp + 4]
	proc draw_bg
		push bp
		mov bp, sp
		
		push dx
		
		push -1
		push -1
		push 319
		push 199
		mov dh, 0
		mov dl, p_col
		push dx
		call draw_rect
		
		pop dx
		pop bp
		
		ret 2
	endp draw_bg
	
	p_x			EQU [word ptr bp + 14]
	p_y			EQU [word ptr bp + 12]	
	p_outcolor	EQU [byte ptr bp + 10]
	p_incolor	EQU [byte ptr bp + 8]
	p_boxlen	EQU [word ptr bp + 6]
	p_boxwid	EQU [word ptr bp + 4]
	proc sdraw_cell
		push bp
		mov bp, sp
		
		push dx
		
		outer_cell:
			mov dx, p_x
			push dx
			
			mov dx, p_y
			push dx
			
			mov dx, p_x
			add dx, p_boxlen
			push dx
			
			mov dx, p_y
			add dx, p_boxlen
			push dx
			
			mov dl, p_outcolor
			mov dh, 0
			push dx
			
			call draw_rect
			
		inner_cell:
			mov dx, p_x
			add dx, p_boxwid
			push dx
			
			mov dx, p_y
			add dx, p_boxwid
			push dx
			
			mov dx, p_x
			add dx, p_boxlen
			sub dx, p_boxwid
			push dx
			
			mov dx, p_y
			add dx, p_boxlen
			sub dx, p_boxwid
			push dx
			
			mov dl, p_incolor
			mov dh, 0
			push dx
			
			call draw_rect
		
		pop dx
		
		pop bp
		
		ret 12
	endp sdraw_cell
	
	p_x			EQU [word ptr bp + 14]
	p_y			EQU [word ptr bp + 12]	
	p_outcolor	EQU [byte ptr bp + 10]
	p_incolor	EQU [byte ptr bp + 8]
	p_boxlen	EQU [byte ptr bp + 6]
	p_boxwid	EQU [byte ptr bp + 4]
	proc sdraw_board
		push bp
		mov bp, sp
		
		push bx
		push ax
		push cx
		push dx
		
		mov cx, 9
		sdraw_board_rowsloop:
			mov dx, cx
			mov cx, 9
			
			sdraw_board_colsloop:
				mov al, cl
				mul p_boxlen
				sub ax, 23
				add ax, p_x
				push ax
				
				mov al, dl
				mul p_boxlen
				sub ax, 23
				add ax, p_y
				push ax
				
				mov al, p_outcolor
				mov ah, 0
				push ax
				
				mov al, p_incolor
				mov ah, 0
				push ax
				
				mov al, p_boxlen
				mov ah, 0
				push ax
				
				mov al, p_boxwid
				mov ah, 0
				push ax
				
				call sdraw_cell	
			loop sdraw_board_colsloop
			
			mov cx, dx
		loop sdraw_board_rowsloop
		
		pop dx
		pop cx
		pop ax
		pop bx
		
		pop bp
		
		ret 12
	endp sdraw_board
	
	proc init_mouse
		push ax
		
		mov ax,0h
		int 33h
		
		mov ax,1h
		int 33h 
		
		pop ax
		
		ret
	endp init_mouse
	
	p_x			EQU [word ptr bp + 12]
	p_y			EQU [word ptr bp + 10]
	p_analog	EQU [byte ptr bp + 8]
	p_color		EQU [byte ptr bp + 6]
	p_bgcolor	EQU [byte ptr bp + 4]
	proc draw_analog
		;(6,3), (7, 10)
		;(6,3), (13, 4)
		;(12,3), (13, 11)
		;(6,9), (13, 11)
		;(6,9), (7, 16)
		;(12,9), (13, 16)
		;(6,15), (13, 16)
		push bp
		mov bp, sp
		
		push ax
		push bx
		push cx
		push dx
		
		push 6
		push 3
		push 7
		push 10		
		
		push 6
		push 3
		push 13
		push 4	
		
		push 12
		push 3
		push 13
		push 10
		
		push 6
		push 9
		push 13
		push 10
		
		push 6
		push 9
		push 7
		push 16		
		
		push 12
		push 9
		push 13
		push 16	
		
		push 6
		push 15
		push 13
		push 16
		
		mov cx, 7
		
		
		mov ax, 6
		add ax, p_y
		sub ax, 2
		push ax
		
		mov ax, 3
		add ax, p_x
		sub ax, 2
		push ax
		
		mov ax, 13
		add ax, p_y
		sub ax, 2
		push ax
		
		mov ax, 16
		add ax, p_x
		sub ax, 2
		push ax
	
		mov al, p_bgcolor
		xor ah, ah
		push ax
		call draw_rect
		
		draw_analog_loop:
			mov al, p_analog
			and al, 1
			cmp al, 1
			jne draw_analog_jmp
				pop [retarr + 0]
				pop [retarr + 2]
				pop [retarr + 4]
				pop [retarr + 6]
				
				mov ax, [retarr + 6]
				add ax, p_y
				sub ax, 2
				push ax
				
				mov ax, [retarr + 4]
				add ax, p_x
				sub ax, 2
				push ax
				
				mov ax, [retarr + 2]
				add ax, p_y
				sub ax, 2
				push ax
				
				mov ax, [retarr + 0]
				add ax, p_x
				sub ax, 2
				push ax
				
				mov al, p_color
				xor ah, ah
				push ax
				call draw_rect
				jmp draw_analog_jmp_skip
			draw_analog_jmp:
				pop ax
				pop ax
				pop ax
				pop ax
			draw_analog_jmp_skip:
			
			shr p_analog, 1
		loop draw_analog_loop
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		pop bp
		
		ret 10
	endp draw_analog
	
	; EDIT ON CHANGE OF sdraw_board
	proc supdate_board
		push bp
		mov bp, sp
		
		push ax
		push bx
		push cx
		push dx
		
		mov cx, 9
		
		supdate_board_loop1:
			mov dx, cx
			mov cx, 9
			
			supdate_board_loop2:
				mov al, dl
				dec al
				mov bl, 20
				mul bl
				add ax, 10
				push ax
				
				mov al, cl
				dec al
				mov bl, 20
				mul bl
				add ax, 10
				push ax
				
				
				
				mov al, dl
				dec al
				mov bl, 9
				mul bl
				add al, cl
				dec al
				xor ah, ah
				mov bx, offset board
				add bx, ax
				mov al, [byte ptr bx]
				push ax
				and ax, 01111111b
				add ax, offset num_display
				mov bx, ax
				mov bl, [bx]
				xor bh, bh
				pop ax
				push bx
				
				and al, 10000000b
				cmp al, 10000000b
				jne supdate_board_loop2_coltestjmp
					mov bx, 40
				jmp supdate_board_loop2_coltestskp
				supdate_board_loop2_coltestjmp:
					mov bx, 0
				supdate_board_loop2_coltestskp:
				push bx
				
				mov bx, 0Fh
				push bx
				
				call draw_analog
				; call wait_keypress
			loop supdate_board_loop2
			
			mov cx, dx
		loop supdate_board_loop1
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		pop bp
		
		ret
	endp supdate_board
	
	p_color	EQU [word ptr bp + 4]
	proc rect_debug
		push bp
		mov bp, sp
		
		push ax
		
		; DISABELED FOR PRODUCTION
		; push 0
		; push 0
		; push 10
		; push 10
		; push p_color
		; call draw_rect
		
		pop ax
		
		pop bp
		
		ret 2
	endp rect_debug
	
	; p_str	EQU [word ptr bp + 4]
	; proc strlen
		; push bp
		; mov bp, sp
		
		; push bx
		; push cx
		
		; mov ax, p_str
		; mov cx, 0
		
		; strlen_loop:
			; mov bx, ax
			; add bx, cx
			
			; inc cx
			; cmp [byte ptr bx], 0
		; jne strlen_loop
		
		; mov ax, cx
		; sub ax, 2
		
		; pop cx
		; pop bx
		
		; pop bp
		
		; ret 2
	; endp strlen
	
	p_x		EQU [word ptr bp + 12]
	p_y		EQU [word ptr bp + 10]
	p_fgcol	EQU [word ptr bp + 8]
	p_bgcol	EQU [word ptr bp + 6]
	p_str	EQU [word ptr bp + 4]
	proc sdraw_solvebtn
		push bp
		mov bp, sp
		
		push bx
		push cx
			
		mov ax, p_str
		mov cx, 0
		
		sdraw_solvebtn_loop:
			mov bx, ax
			add bx, cx
			
			push p_y
			push p_x
			push [bx]
			push p_fgcol
			push p_bgcol
			call draw_analog
			
			add p_x, 10
			
			inc cx
			cmp [byte ptr bx + 1], 1000000b
		jne sdraw_solvebtn_loop
		
		mov ax, p_x
		dec ax
		
		pop cx
		pop bx
		
		pop bp
		
		ret 10
	endp sdraw_solvebtn
	
	proc reset_regs
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
	endp reset_regs
	
	p_arr	EQU [word ptr bp + 4]
	proc print_sudoku
		push bp
		mov bp, sp
		
		push ax
		push bx
		push cx
		push dx
		
		mov cx, -1
		
		print_sudoku_loop:
			inc cx
			
			mov bx, p_arr
			add bx, cx
			
			mov ah, 2
			mov dl, [bx]
			add dl, "0"
			int 21h
			mov ah, 2
			mov dl, ' '
			int 21h
			
			mov al, cl
			xor ah, ah
			inc al
			mov bl, 9
			div bl
			cmp ah, 0
			jne print_sudoku_loop_nonewline
			print_sudoku_loop_newline:
				mov ah, 2
				mov dl, 10
				int 21h
			print_sudoku_loop_nonewline:
			
			cmp cx, 80
		jl print_sudoku_loop
		
		mov ah, 2
		mov dl, 10
		int 21h
		mov ah, 2
		mov dl, 10
		int 21h
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		pop bp
		
		ret 2
	endp print_sudoku
		
	p_arr	EQU [word ptr bp + 4]
	v_l1	EQU [word ptr bp - 2]
	v_l2	EQU [word ptr bp - 4]
	v_row	EQU [word ptr bp - 6]
	v_col	EQU [word ptr bp - 8]
	proc solve_sudoku
		push bp
		mov bp, sp
		
		sub sp, 8
		
		push bx
		push cx
		push dx
		
		mov v_l1, 0
		mov v_l2, 0
		nop ;------------------------------------
		
		push p_arr
		lea ax, v_l1
		push ax
		call solve_find_empty_loc
		cmp ax, 0
		jne solve_sudoku_stop
			mov ax, 1
			jmp solve_sudoku_end
		solve_sudoku_stop:
		nop ;------------------------------------
		
		mov ax, v_l1
		mov v_row, ax
		
		mov ax, v_l2
		mov v_col, ax
		nop ;------------------------------------
		
		mov cx, 0
		solve_sudoku_loop:
			inc cx
			
			push p_arr
			push v_row
			push v_col
			push cx
			call solve_location_is_safe
			cmp ax, 1
			jne solve_sudoku_loopifend1
				mov ax, v_row
				mov bl, 9
				mul bl
				add ax, v_col
				xor ah, ah
				mov bx, p_arr
				add bx, ax
				xor ax, ax
				
				mov [bx], cl
				
				push p_arr
				call solve_sudoku
				cmp ax, 1
				jne solve_sudoku_loopifend2
					mov ax, 1
					jmp solve_sudoku_end
				solve_sudoku_loopifend2:
				
				mov [byte ptr bx], 0
			solve_sudoku_loopifend1:
			cmp cx, 9
		jl solve_sudoku_loop
		
		mov ax, 0
		
		solve_sudoku_end:
		
		pop dx
		pop cx
		pop bx
		
		add sp, 8
		
		pop bp
		
		ret 2
	endp solve_sudoku
	
	; 1 if location isnt safe
	p_arr	EQU [word ptr bp + 10]
	p_row	EQU [word ptr bp + 8]
	p_col	EQU [word ptr bp + 6]
	p_num	EQU [word ptr bp + 4]
	proc solve_location_is_safe
		push bp
		mov bp, sp
		
		push bx
		push dx
		xor dx, dx
		
		push p_arr
		push p_row
		push p_num
		call solve_used_in_row
		cmp ax, 1
		je solve_location_is_safe_end
		
		push p_arr
		push p_col
		push p_num
		call solve_used_in_col
		cmp ax, 1
		je solve_location_is_safe_end
		
		push p_arr
		mov ax, p_row
		mov bx, 3
		xor dx, dx
		div bx
		mov ax, p_row
		sub ax, dx
		push ax
		mov ax, p_col
		mov bx, 3
		xor dx, dx
		div bx
		mov ax, p_col
		sub ax, dx
		push ax
		push p_num
		call solve_used_in_box
		cmp ax, 1
		je solve_location_is_safe_end
		
		mov ax, 0
		
		solve_location_is_safe_end:
		
		not ax
		and ax, 1
		
		pop dx
		pop bx
		
		pop bp
		
		ret 8
	endp solve_location_is_safe
	
	p_arr	EQU [word ptr bp + 6]
	p_lptr	EQU [word ptr bp + 4]
	proc solve_find_empty_loc
		push bp
		mov bp, sp
		
		push bx
		push cx
		push dx
		
		mov cx, -1
		
		solve_find_empty_loc_loop:
			inc cx
			mov bx, p_arr
			add bx, cx
			mov al, [bx]
			xor ah, ah
			
			cmp ax, 0
			jne solve_find_empty_loc_ifend
				mov ax, cx
				mov dx, 0
				mov bx, 9
				mov dx, 0
				div bx ; ax = row, dx = col
				
				mov bx, p_lptr
				mov [ss:bx], ax
				sub bx, 2
				mov [ss:bx], dx
				
				mov ax, 1
				jmp solve_find_empty_loc_end
			solve_find_empty_loc_ifend:
			
			cmp cx, 80
		jl solve_find_empty_loc_loop
		
		mov ax, 0
		; call wait_keypress
		
		solve_find_empty_loc_end:
		
		pop dx
		pop cx
		pop bx
		
		pop bp
		
		ret 4
	endp solve_find_empty_loc
	
	p_arr	EQU [word ptr bp + 8]
	p_row	EQU [word ptr bp + 6]
	p_num	EQU [word ptr bp + 4]
	proc solve_used_in_row
		push bp
		mov bp, sp
		
		push bx
		push cx
		push dx
		
		mov cx, 9
		
		solve_used_in_row_loop:
			dec cx
			
			push p_row
			push cx
			call solve_rowcol2offset
			mov bx, ax
			add bx, p_arr
			mov al, [bx]
			xor ah, ah
			cmp ax, p_num
			jne solve_used_in_row_ifend
				mov ax, 1
				jmp solve_used_in_row_end
			solve_used_in_row_ifend:
			
			inc cx
		loop solve_used_in_row_loop
		
		mov ax, 0
		
		solve_used_in_row_end:
		
		pop dx
		pop cx
		pop bx
		
		pop bp
		
		ret 6
	endp solve_used_in_row
	
	p_arr	EQU [word ptr bp + 8]
	p_col	EQU [word ptr bp + 6]
	p_num	EQU [word ptr bp + 4]
	proc solve_used_in_col
		push bp
		mov bp, sp
		
		push bx
		push cx
		push dx
		
		mov cx, 9
		
		solve_used_in_col_loop:
			dec cx
			
			push cx
			push p_col
			call solve_rowcol2offset
			mov bx, p_arr
			add bx, ax
			mov al, [bx]
			xor ah, ah
			cmp ax, p_num
			jne solve_used_in_col_ifend
				mov ax, 1
				jmp solve_used_in_col_end
			solve_used_in_col_ifend:
			
			inc cx
		loop solve_used_in_col_loop
		
		mov ax, 0
		
		solve_used_in_col_end:
		
		pop dx
		pop cx
		pop bx
		
		pop bp
		
		ret 6
	endp solve_used_in_col
	
	p_arr	EQU [word ptr bp + 10]
	p_row	EQU [word ptr bp + 8]
	p_col	EQU [word ptr bp + 6]
	p_num	EQU [word ptr bp + 4]
	proc solve_used_in_box
		push bp
		mov bp, sp
		
		push bx
		push cx
		push dx
		
		mov cx, 3
		
		solve_used_in_box_loop1:
			dec cx
			mov dx, cx
			mov cx, 3
			
			solve_used_in_box_loop2:
				dec cx
				mov ax, p_row
				add ax, dx
				push ax
				
				mov ax, p_col
				add ax, cx
				push ax
				
				call solve_rowcol2offset
				mov bx, p_arr
				add bx, ax
				mov al, [bx]
				xor ah, ah
				cmp ax, p_num
				jne solve_used_in_box_ifend
					mov ax, 1
					jmp solve_used_in_box_end
				solve_used_in_box_ifend:
				
				inc cx
			loop solve_used_in_box_loop2
			
			mov cx, dx
			inc cx
		loop solve_used_in_box_loop1
		
		mov ax, 0
		
		solve_used_in_box_end:
		
		pop dx
		pop cx
		pop bx
		
		pop bp
		
		ret 8
	endp solve_used_in_box
	
	p_row	EQU [word ptr bp + 6]
	p_col	EQU [word ptr bp + 4]
	proc solve_rowcol2offset
		push bp
		mov bp, sp
		
		push dx
		
		mov ax, p_row
		mov dx, 9
		mul dx
		add ax, p_col
		
		pop dx
		
		pop bp
		
		ret 4
	endp solve_rowcol2offset
	
	p_bytes	EQU [word ptr bp + 8]
	p_src	EQU [word ptr bp + 6]
	p_dst	EQU [word ptr bp + 4]
	proc memcpy
		push bp
		mov bp, sp
		
		push ax
		push bx
		push cx
		
		mov cx, -1
		memcpy_loop:
			inc cx
			
			mov bx, p_src
			add bx, cx
			mov ax, [bx]
			
			mov bx, p_dst
			add bx, cx
			mov [bx], ax
			
			cmp cx, p_bytes
		jl memcpy_loop
		
		pop cx
		pop bx
		pop ax
		
		pop bp
		
		ret 6
	endp memcpy
	
	exit:
		mov ax, 4c00h
		int 21h

END start
