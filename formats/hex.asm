.text

# ============================================================
# STRING A HEXADECIMAL
# ============================================================
str_to_hex:
    li $v0, 0
    li $t2, 1       # Signo positivo por defecto

    # Revisar si el primer caracter es un signo negativo '-'
    lb $t0, 0($a0)
    bne $t0, 45, sth_loop # '-' es 45 en ASCII. Si no es, iniciar loop.
    
    # Si es negativo '-'
    li $t2, -1       # Cambiar el signo
    addi $a0, $a0, 1 # Avanzar puntero para saltarnos el '-'

sth_loop:
    lb $t0, 0($a0)
    
    # Loop End
    beq $t0, 10, sth_end  # \n
    beq $t0, 13, sth_end  # \r (CR)
    beq $t0, 0, sth_end   # \0

    # Determinar si es un numero (0-9)
    blt $t0, 48, sth_invalid # < '0': invalido
    li $t1, 57
    bgt $t0, $t1, sth_alpha_check # > '9': revisar si es letra
    addi $t0, $t0, -48            # Si esta entre 0-9: restamos ascii
    j sth_add

sth_alpha_check:
    # Determinar si es A-F (65-70)
    blt $t0, 65, sth_invalid # Entre 58 y 64: invalidos
    li $t1, 70
    bgt $t0, $t1, sth_lower_check # > 'F': revisar si es a-f
    addi $t0, $t0, -55            # Si es A-F: restamos ascii
    j sth_add

sth_lower_check:
    # Determinar si es a-f (97-102)
    blt $t0, 97, sth_invalid # Entre 71 y 96: invalidos
    li $t1, 102
    bgt $t0, $t1, sth_invalid # > 'f': invalido
    addi $t0, $t0, -87        # Si es a-f: restamos ascii

sth_add:
    sll $v0, $v0, 4         # Desplazar 4 bits a la izquierda (1 nibble)
    or $v0, $v0, $t0        # Añadir el nuevo nibble al final
    
    # Avanzar puntero
    addi $a0, $a0, 1
    j sth_loop

sth_end:
    # Aplicar el signo evaluado antes de regresar
    mul $v0, $v0, $t2
    jr $ra

sth_invalid:
    print_str(msg_error)
    j main


# ============================================================
# HEXADECIMAL A STRING (IMPRIMIR)
# ============================================================
print_hex:
    li $t0, 0         # Contador de iteraciones (8 nibbles para 32 bits)
    move $t2, $a0     # Guardar el valor original de $a0
ph_loop:
    beq $t0, 8, ph_end
    
    # Obtener el nibble más significativo
    srl $t1, $t2, 28
    andi $t1, $t1, 0xF
    
    # Convertir valor 0-15 a char ASCII ('0'-'9' o 'A'-'F')
    li $t3, 9
    bgt $t1, $t3, ph_alpha
    addi $t1, $t1, 48   # 0-9 -> '0'-'9'
    j ph_print
    
ph_alpha:
    addi $t1, $t1, 55   # 10-15 -> 'A'-'F'
    
ph_print:
    print_char($t1)
    
    # Desplazar para el siguiente nibble
    sll $t2, $t2, 4
    addi $t0, $t0, 1
    j ph_loop

ph_end:
    jr $ra