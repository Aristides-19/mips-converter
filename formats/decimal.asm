.text
# Convierte un string (buffer en $a0) a un entero en base 10 en $v0
str_to_dec:
    li $v0, 0
    li $t1, 1 # Signo positivo por defecto (1)

    # Revisar si el primer caracter es un signo negativo '-'
    lb $t0, 0($a0)
    beq $t0, 45, std_negative # "-" es 45 en ASCII
    beq $t0, 43, std_positive #"+" es 43 en ASCII
    j std_loop
    
std_negative:
    li $t1, -1 # Cambiar el signo a -1
    addi $a0, $a0, 1 # saltar el "-"
    j std_loop

std_positive:
	addi $a0, $a0, 1 #salta el "+", y queda 1
    
    
   
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
    li $t0, 43 #"+"
    print_char($t0)
    li $t0, 48 # '0'
    print_char($t0)
    j pdec_end

pdec_check_sign:
    bgtz $t2, pdec_positive
    # Si es negativo, imprimir signo '-' y pasarlo a positivo (complemento a 2)
    li $t0, 45 # '-' ASCII
    print_char($t0)
    neg $t2, $zero, $t2 # Negar $t2
    j pdec_start
    
pdec_positive:
   li $t0, 43 #"+"
   print_char($t0)

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

