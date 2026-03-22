.text

str_to_packed:
   	li $v0, 0 # Acumulador de bits (valor BCD de 32 bits)

stp_loop:
	lb $t0, 0($a0)
	
	beq $t0, 10, stp_decode # \n => fin de lectura, pasa a decodificar
    	beq $t0, 13, stp_decode # \r =>  fin
    	beq $t0, 0,  stp_decode # \0 =>  fin
    	beq $t0, 32, stp_skip   # Espacio => ignora 

    	addi $t0, $t0, -48      # Char '0'/'1' => valor 0/1
    	sll $v0, $v0, 1         # Hace espacio para el nuevo bit
    	or  $v0, $v0, $t0       # Insertar el bit

	stp_skip:
    	addi $a0, $a0, 1
    	j stp_loop
    	
    	stp_decode:
   	 # Fase 2: decodifica el valor BCD en $v0 a entero decimal
    	move $t5, $v0           # $t5 = valor BCD de 32 bits
    	li $v0, 0               # Reinicia $v0 para el resultado decimal
    	li $t6, 8               # 8 nibbles en 32 bits
    	li $t7, 1               # Multiplicador posicional: 1, 10, 100, 1000...

	stp_bcd_loop:
    	beqz $t6, stp_end

	andi $t4, $t5, 0xF      # Extrae el nibble menos significativo (dígito actual)
    	mul $t4, $t4, $t7       # Valor del dígito × posición decimal
    	add $v0, $v0, $t4       # Acumular en el resultado

    	srl $t5, $t5, 4         # Desplaza para el siguiente nibble
    	mul $t7, $t7, 10        # Siguiente potencia de 10
    	addi $t6, $t6, -1
    	j stp_bcd_loop

	stp_end:
    	jr $ra

	print_packed:
    	move $t9, $ra           # Guardar $ra porque print_char lo modifica

    	move $t7, $a0           # Valor de entrada
    	li $t8, 0               # $t8 = resultado BCD construido
   	li $t6, 0               # Desplazamiento en bits para posicionar cada nibble
    	li $t5, 8               # Máximo 8 dígitos (8 nibbles = 32 bits)

	pp_build_loop:
    	beqz $t5, pp_print      # Se procesaron los 8 dígitos posibles
    	beqz $t7, pp_print      # No quedan más dígitos en el valor

    	li $t3, 10
    	div $t7, $t3
    	mflo $t7                # Cociente=> nuevo valor para la siguiente iteración
    	mfhi $t4                # Resto=> dígito actual (0-9)

   	 sllv $t4, $t4, $t6      # Colocar el nibble en su posición correspondiente
    	or $t8, $t8, $t4        # Insertar el nibble en el valor BCD

    	addi $t6, $t6, 4        # La siguiente posición está 4 bits más arriba
    	addi $t5, $t5, -1
    	j pp_build_loop

	pp_print:
  	  # Imprime los 32 bits de $t8 con espacio cada 4 bits
  	  li $t0, 0               # Contador de bits impresos
  	  move $t2, $t8

	pp_bit_loop:
    	beq $t0, 32, pp_end

    	# Inserta un espacio separadqneo cada 4 bits (excepto antes del primer bit)
    	beqz $t0, pp_no_space
    	andi $t3, $t0, 3        # $t0 % 4: es 0 cada 4 bits
    	bnez $t3, pp_no_space
   	 li $t1, 32            
   	 print_char($t1)

	pp_no_space:
    	srl $t1, $t2, 31        # Extrae el bit más significativo
    	andi $t1, $t1, 1
    	addi $t1, $t1, 48       # Convierte a '0' o '1'
    	print_char($t1)

 	   sll $t2, $t2, 1         # Desplaza para el siguiente bit
  	  addi $t0, $t0, 1
    	j pp_bit_loop

	pp_end:
    	jr $t9
	