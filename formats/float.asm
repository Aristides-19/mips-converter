# ==============================================================================
# RUTINA FRACCIONARIA: dec_to_bin_frac
# Pide en buffer (ej "12.75") e imprime inmediatamente su contraparte binaria
# con 8 bits decimales de precision garantizada
# ==============================================================================
dec_to_bin_frac:
    move $t8, $a0 # Guardar el puntero en $t8, ya que $a0 es destruido por print_char
    
    # Revisar si el primer caracter es un signo negativo '-'
    lb $t0, 0($t8)
    bne $t0, 45, dbf_start_parse
    
    # Si es negativo '-', lo imprimimos y avanzamos el puntero
    li $t0, 45
    print_char($t0)
    addi $t8, $t8, 1

dbf_start_parse:
    # 1. Parsear la parte entera
    li $t2, 0   # $t2 = valor entero acumulado
dbf_int_loop:
    lb $t0, 0($t8)
    beq $t0, 10, dbf_print_int   # salto de linea
    beq $t0, 13, dbf_print_int   # \r (CR)
    beq $t0, 0, dbf_print_int    # fin de string
    beq $t0, 46, dbf_print_int   # caracter '.'

    addi $t0, $t0, -48           # char a numero
    mul $t2, $t2, 10
    add $t2, $t2, $t0
    
    addi $t8, $t8, 1
    j dbf_int_loop

dbf_print_int:
    # 2. Imprimir la parte entera en binario normal (sin ceros a la izquierda)
    li $t4, 31       # vamos desde el bit 31 al 0
    li $t5, 0        # flag: ¿ya encontramos el primer '1'?
    
    bnez $t2, dbf_pbin_loop      # Si no es 0
    li $t0, 48                   # Si es 0 absoluto, imprimir un '0'
    print_char($t0)
    j dbf_check_frac
    
dbf_pbin_loop:
    bltz $t4, dbf_check_frac
    srlv $t6, $t2, $t4           # Desplazar bit target
    andi $t6, $t6, 1             # Mascara del bit
    
    bnez $t6, dbf_found_1
    # Si es un bit '0', revisar si podemos omitirlo
    beqz $t5, dbf_next_bit       # ignoramos ceros a la izquierda absolutos
    li $t0, 48
    print_char($t0)
    j dbf_next_bit
    
dbf_found_1:
    li $t5, 1                    # Ya vimos el primer '1'
    li $t0, 49
    print_char($t0)

dbf_next_bit:
    addi $t4, $t4, -1
    j dbf_pbin_loop

dbf_check_frac:
    # 3. Revisar si hay parte fraccionaria
    lb $t0, 0($t8)
    bne $t0, 46, dbf_end         # Si no hay '.', terminar todo
    
    li $t0, 46
    print_char($t0)              # Imprimir el punto decimal
    addi $t8, $t8, 1             # Avanzar puntero

    # 4. Parsear la fraccion a numero entero y registrar la base del pow(10)
    li $t2, 0   # Valor fraccionario actual (ej. 25)
    li $t3, 1   # Multiplicador pow(10) (ej. 100)

dbf_frac_parse:
    lb $t0, 0($t8)
    beq $t0, 10, dbf_frac_calc
    beq $t0, 13, dbf_frac_calc
    beq $t0, 0, dbf_frac_calc
    
    addi $t0, $t0, -48
    mul $t2, $t2, 10
    add $t2, $t2, $t0
    mul $t3, $t3, 10            # La base crece junto al numero de digitos
    
    addi $t8, $t8, 1
    j dbf_frac_parse

dbf_frac_calc:
    # 5. Imprimir exactamente 8 bits multiplicando la fraccion decimal * 2
    li $t4, 8   # Max 8 bits de fraccion requeridos

dbf_frac_loop:
    beqz $t4, dbf_end
    mul $t2, $t2, 2             # Multiplicamos el valor * 2
    bge $t2, $t3, dbf_frac_one  # Si pasa el limite pow(10), el bit frac es 1
    
    # El bit es '0'
    li $t0, 48
    print_char($t0)
    j dbf_frac_next
    
dbf_frac_one:
    sub $t2, $t2, $t3           # Restar el exceso multiplicador pow(10) al valor local
    li $t0, 49
    print_char($t0)
    
dbf_frac_next:
    addi $t4, $t4, -1
    j dbf_frac_loop

dbf_end:
    print_str(msg_newline)
    jr $ra