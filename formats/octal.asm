.text

str_to_oct:
    li $v0, 0
    li $t2, 1           # positivo

    lb $t0, 0($a0)
    beq $t0, 45, sto_negative
    beq $t0, 43, sto_positive
    j sto_loop

sto_negative:
    li $t2, -1
    addi $a0, $a0, 1
    j sto_loop

sto_positive:
    addi $a0, $a0, 1    # salta el '+', queda 1
    j sto_loop

sto_loop:
    lb $t0, 0($a0)
    beq $t0, 10, sto_end
    beq $t0, 13, sto_end
    beq $t0, 0, sto_end
    addi $t0, $t0, -48      # convierte char 0-7 a valor 0-7
    sll $v0, $v0, 3         # desplaza 3 bits (multiplica por 8)
    or $v0, $v0, $t0        # inserta el nuevo digito octal (3 bits)
    addi $a0, $a0, 1
    j sto_loop

sto_end:
    mul $v0, $v0, $t2       # aplica el signo
    jr $ra

print_oct:
    move $t9, $ra           # Guarda $ra porque print_char lo destruye
    move $t7, $a0

    # Caso especial: cero
    bnez $t7, poc_check_sign
    li $t0, 43              # '+'
    print_char($t0)
    li $t0, 48              # '0'
    print_char($t0)
    jr $t9

poc_check_sign:
    bgez $t7, poc_positive
    li $t0, 45              # '-'
    print_char($t0)
    neg $t7, $t7            # Valor absoluto
    j poc_convert

poc_positive:
    li $t0, 43              # '+'
    print_char($t0)

poc_convert:
    li $t6, 0               # Contador de dígitos apilados
    move $t5, $t7

poc_push_loop:
    beqz $t5, poc_pop_loop
    andi $t4, $t5, 7        # Extrae los 3 bits menos significativos (0-7)
    addi $t4, $t4, 48       # Convierte a char '0'-'7'
    addi $sp, $sp, -4
    sw $t4, 0($sp)          # Apilar el dígito
    addi $t6, $t6, 1
    srl $t5, $t5, 3         # Desplazar 3 bits a la derecha (dividir entre 8)
    j poc_push_loop

poc_pop_loop:
    beqz $t6, poc_end
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    print_char($t0)
    addi $t6, $t6, -1
    j poc_pop_loop

poc_end:
    jr $t9



