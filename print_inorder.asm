print_tree_traversals:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# print inorder tree traversal
	la $a0, output_inorder_tree
	li $v0, 4
	syscall
	
	lw $a0, tree # get a pointer to the head node
	jal print_inorder
	
	la $a0, line
	li $v0, 4
	syscall

	li $v0, 10
	syscall
	
print_inorder:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	beqz $a0, end_print_inorder # if(node != null)
	or $s0, $a0, $zero
	
	lw $a0, 4($s0)
	jal print_inorder
	
	or $a0, $s0, $zero
	jal print_current_node_value	
	
	lw $a0, 8($s0)
	jal print_inorder

end_print_inorder:
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
print_current_node_value:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# print out current item
	lw $a0, 0($a0)	
	ori $v0, $zero, 1
    syscall
	
	la $a0, end_line_prompt
	ori $v0, $zero, 4
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra