.text
# Convierte un string (buffer en $a0) a un entero en base 10 en $v0
str_to_dec:
    li $v0, 0
    li $t1, 1 # Signo positivo por defecto (1)

    # Revisar si el primer caracter es un signo negativo '-'
    lb $t0, 0($a0)
    bne $t0, 45, std_loop # '-' es 45 en ASCII. Si no es, iniciar loop normal.
    
    # Si es negativo '-'
    li $t1, -1       # Cambiar el signo a -1
    addi $a0, $a0, 1 # Avanzar puntero para saltarnos el '-'

std_loop:
    # Cargar el byte actual del string (char)
    lb $t0, 0($a0)

    # Loop End (termina con salto de linea o null)
    beq $t0, 10, std_end # \n
    beq $t0, 13, std_end # \r (CR)
    beq $t0, 0, std_end  # 0 (fin de string)

    # Convertir char '0'-'9' a su valor numerico real (0-9)
    addi $t0, $t0, -48

    # $v0 = ($v0 * 10) + $t0
    mul $v0, $v0, 10
    add $v0, $v0, $t0

    # Avanzar puntero al siguiente caracter
    addi $a0, $a0, 1
    j std_loop

std_end:
    # Aplicar el signo evaluado antes de regresar
    mul $v0, $v0, $t1
    jr $ra


# Imprime el valor entero en $a0 como texto en decimal en consola
print_dec:
    move $t2, $a0 # Guardar el valor original a imprimir en $t2
    
    # Manejar caso especifico donde el numero es cero
    bnez $t2, pdec_check_sign
    li $t0, 48 # '0'
    print_char($t0)
    j pdec_end

pdec_check_sign:
    bgtz $t2, pdec_start
    # Si es negativo, imprimir signo '-' y pasarlo a positivo (complemento a 2)
    li $t0, 45 # '-' ASCII
    print_char($t0)
    subu $t2, $zero, $t2 # Negar $t2

pdec_start:
    li $t3, 10 # Base 10 para dividir
    li $t1, 0  # Contador de digitos guardados en la pila

pdec_div_loop:
    beqz $t2, pdec_print_loop  # Cuando $t2 llega a 0, empezar a imprimir
    divu $t2, $t3              # Dividir entre 10
    mflo $t2                   # El nuevo valor sera el cociente
    mfhi $t0                   # El digito actual sera el resto (mod 10)
    
    addi $t0, $t0, 48          # Convertir ese resto/digito a ASCII char
    
    # Push (guardar) en el stack/pila para luego imprimir invertido
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    addi $t1, $t1, 1           # Incrementar contador de digitos en la pila
    j pdec_div_loop

pdec_print_loop:
    # Pop e imprimir cada valor del stack
    beqz $t1, pdec_end
    
    lw $t0, 0($sp)             # Recuperar valor del stack
    addi $sp, $sp, 4           # Restaurar puntero del stack
    
    print_char($t0)            # Imprimir el caracter
    
    addi $t1, $t1, -1          # Decrementar contador de digitos restantes en pila
    j pdec_print_loop

pdec_end:
    jr $ra


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

