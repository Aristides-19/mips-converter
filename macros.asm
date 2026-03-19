.macro print_str(%str)
    la $a0, %str
    li $v0, 4
    syscall
.end_macro

.macro read_str(%buf, %size)
    la $a0, %buf
    li $a1, %size
    li $v0, 8
    syscall
.end_macro

.macro print_char(%reg)
    move $a0, %reg
    li $v0, 11
    syscall
.end_macro

.macro read_int(%var)
    li $v0, 5
    syscall
    move %var, $v0
.end_macro