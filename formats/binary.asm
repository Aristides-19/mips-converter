.text
# NOTE Ya que se asume que el formato del buffer es correcto, no se hace un contador de bits recorridos
str_to_bin:
    li $v0, 0
stb_loop:
    # Cargar el byte actual del string (char)
    lb $t0, 0($a0)

    # Loop End
    beq $t0, 10, stb_end # \n
    beq $t0, 0, stb_end # 0 (fin de string)

    # Convertir char '0' o '1' a su valor numérico (0 o 1)
    addi $t0, $t0, -48

    sll $v0, $v0, 1
    or $v0, $v0, $t0

    # Avanzar puntero
    addi $a0, $a0, 1
    j stb_loop
stb_end:
    jr $ra

print_bin:
    li $t0, 0 # Contador de iteraciones
    move $t2, $a0 # Guardar el valor original de $a0 para la impresión
pbin_loop:
    beq $t0, 32, pbin_end

    # Desplazar el BMS a la derecha
    srl $t1, $t2, 31
    # Comparar el bit más significativo con 1 para determinar si es 0 o 1
    andi $t1, $t1, 1
    # Si el bit es 1, $t1 será '1'; si es 0, $t1 será '0'
    addi $t1, $t1, 48 # Convertir a char '0' o '1'

    # Desplazar a la izquierda para preparar el siguiente bit
    sll $t2, $t2, 1
    # Incrementar el contador de iteraciones
    addi $t0, $t0, 1

    print_char($t1)
    j pbin_loop
pbin_end:
    jr $ra
