.data
tree: .word 0  ## address
list : .word 50, 25, 75, 12, 33, 66, 83, -9999
queue1_front: .word 0 ##  address
queue1_rear: .word 0
queue2_front: .word 0 ##  address
queue2_rear: .word 0
line: .asciiz "\n"
space: .asciiz " "
x: .asciiz "X"
output_level_order_tree: .asciiz "The numbers in level order:\n"
input_menu: .asciiz "\nMenu\nPlease enter a value\nTo exit 0\nFor insert: 1\nFor find: 2\nFor print: 3\n"
insert_message: .asciiz "What is the value to be inserted\n"
find_message: .asciiz "What is the value to find\n"
not_found_message: .asciiz "The number is NOT FOUND in the tree\n"
found_in_the_tree_message: .asciiz "The number is found at the address "
.text
.globl main

############################################################
### EMRE KILAVUZ 220201019
#############################################################
main: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a1, list  ## load address of list to build the tree
	li $t5, -9999  ## for build finish condition
	lw $a2, tree   ##  load the pointer variable tree from data segment
	
	jal build_beginning   ## call the build function
main_loop:
	jal get_user_input    ## call user input function
	j main_loop
main_exit:  ## exit from the program
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

################################################################
################################################################
###############################################################


#### $a1 = list address, $a2 = tree address	
build_beginning:    ## this function is called at the beginning of program
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $a0, 0($a1)  ## load first list value
	jal initialize_tree_root  ## call tree initializer function

build:
	addi $a1, $a1, 4   ### increment the list index
	lw $a0, 0($a1)   ### load the value from list which at the current index
	beq $a0, $t5, build_exit     ## loop exit condition, if $a0 big negative value then go to exit
	jal insert_beginning         ## insert the value to tree
	
	j build    ### jump back to loop
build_exit:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#############################################################
#############################################################
initialize_tree_root:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal allocate_memory
	
    sw $v0, tree   ## allocated memory address is assigned to tree pointer variable
	
	# store current list value to root node of the tree
	sw $a0, 0($v0)
	
	# initialize head node's parent, left and right nodes to zero
	sw $zero, 4($v0)
	sw $zero, 8($v0)
	sw $zero, 12($v0)
	
    #return
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

insert_beginning:
	# store return address
	addi $sp, $sp, -28
	sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
	sw $s0, 12($sp)
    sw $s1, 16($sp)
    sw $t4, 20($sp)
    sw $a0, 24($sp)
	# load root node of the tree
	lw $t0, tree
	add $t1, $zero, $zero

    lw $a2, tree   ## find function accepts tree variable as argument 2
    jal find       ## call find function
    beq $v0, 0, insert_return   ## if the value already exists in the tree return


## compare, goLeft and goRight functions goes from root node to leaf node to find the address to be linked
compare:
	beq $t0, $zero, create_node   ## if current node is null create it
	lw $s0, 0($t0)    ## load the value of the current node
	slt $t2, $a0, $s0
	beq $t2, $zero, goRight     ## if the value which will be added is greater than the value of the current node, go Right else go Left

goLeft:
	add $t1, $t0, $zero    ## move $t0 to $t1 which is current node 
	lw $t0, 4($t0)    ## load left child
	j compare      ## continue to loop

goRight:
	add $t1, $t0, $zero   ## move $t0 which is current node to $t1
	lw $t0, 8($t0)   ## load right child
	j compare     ## continue to loop
	
create_node:
	jal allocate_memory   ## call allocate memory function
	lw $s1, 0($t1)        ## load the value of the current node
	slt $t4, $a0, $s1
	beq $t4, $zero, link_node_right ## if argument is greater than the node value link to right else link to left
	
link_node_left:
    sw $v0, 4($t1)   ## link allocated memory address to the left of the current node
	j end_attach_if_else
	
link_node_right:
    sw $v0, 8($t1)   ## link allocated memory address to the right of the current node
	
end_attach_if_else:
	# initalize the current node value to the passed in argument on the $f12 register
	sw $a0, 0($v0)  ## store the argument value number to the allocated memory
	
	# initalize the current node next value to null
	sw $zero, 4($v0)  ## left is zero
	sw $zero, 8($v0)   ## right is zero
	sw $zero, 12($v0)  ## parent is zero
	
insert_return:   ## load the changed variables and return
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
	lw $s0, 12($sp)
    lw $s1, 16($sp)
    lw $t4, 20($sp)
    lw $a0, 24($sp)
	addi $sp, $sp, 28
	jr $ra

######################################################
######################################################
allocate_memory:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	li $v0, 9    ### prepare for system call sbrk
	li $a0, 16   ### 16 byte will be allocated
	syscall
	
	## return
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
###########################################
#######################################

allocate_memory_for_queue:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	li $v0, 9    ### prepare for system call sbrk
	li $a0, 8    ### 8 byte will be allocated
	syscall
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
#############################################
#############################################
pop_queue_start_1:    #########FOR QUEUE1,  QUEUE HEAD POINTER AT $A3
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s3, 4($sp)
	sw $t3, 8($sp)
	sw $a3, 12($sp)
pop_body1:
	beqz $a3, pop_queue1_end2  ### if queue head is null
    lw $s3, 4($a3)    ### load the next node of the queue
	lw $v0, 0($a3)    ### load the value of the current node to return value
	sw $s3, queue1_front  ## store the next node as the front of the queue
    beq $s3, $zero, pop_queue1_end2_2  ## if the head is null already make the rear also null
pop_queue_end:   ## load the changed values from stack pointer and return
	lw $a3, 12($sp)
	lw $t3, 8($sp)
	lw $s3, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
pop_queue1_end2:
	li $v0, -9999
	j pop_queue_end
pop_queue1_end2_2:	
    sw $zero, queue1_rear   ## if head is null make the rear null as well
    j pop_queue_end
#############################################
##############################################

#############################################
#############################################
pop_queue_start_2:    ## FOR QUEUE 2,  QUEUE HEAD POINTER AT $A3
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s3, 4($sp)
	sw $t3, 8($sp)
	sw $a3, 12($sp)
pop_body1_2:
	beqz $a3, pop_queue_end2_2  ### if tree head is null
	lw $s3, 4($a3)      ### $s3 = head->next
	lw $v0, 0($a3)		### $v0 = pop(queue)
	sw $s3, queue2_front ## queue2.head = head->next
    beq $zero, $s3, pop_queue2_end_2_2   ## if new front head is null make the rear null also 
pop_queue_end_2:  ## load changed registers back from stack pointer and return
	lw $a3, 12($sp)
	lw $t3, 8($sp)
	lw $s3, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
pop_queue_end2_2:
	li $v0, -9999
	j pop_queue_end_2
pop_queue2_end_2_2:	
    sw $zero, queue2_rear   ## make the rear null if new front is null
    j pop_queue_end_2


#############################################
##############################################

insert_to_queue_start_1: ## QUEUE 1 head pointer AT $A3,  NEW NODE AT $T4, THE VALUE TO BE INSERTED AT $A0
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $t4, 8($sp)
	sw $a3, 12($sp)
    sw $t5, 16($sp)
insert_queue_body:
	jal allocate_memory_for_queue
	move $t4, $v0     ### new allocated address at $t4
    lw $t5, queue1_rear
	beqz $t5, assign_head_queue   ### if queue rear is null assign head of the queue
insert_queue_body2:
	sw $a0, 0($t4)   ## store the argument value which to be inserted as the new node value
	sw $zero, 4($t4)   ## assign next node of new node to null
    sw $t4, 4($t5)     ## link new node as the next node of the rear
	sw $t4, queue1_rear  ## assign new node as the rear
insert_queue_return:   ## load changed variables back and return
    lw $t5, 16($sp)
	lw $a3, 12($sp)
	lw $t4, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra
#########################################
##########################################
assign_head_queue:
    sw $t4, queue1_front   ## assign new allocated variable as front
    sw $t4, queue1_rear    ## assign new allocated variable as rear
	sw $a0, 0($t4)         ## assign the argument variable as new node value number
    sw $zero, 4($t4)       ## assign the next node of the new node as zero
	j insert_queue_return  ## jump return
###########################################
###########################################


#############################################
##############################################
insert_to_queue_start_2:     ### QUEUE head pointer AT $A3, NEW NODE at $t4, THE VALUE AT $A0
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $t4, 8($sp)
	sw $a3, 12($sp)
    sw $t5, 16($sp)
insert_queue_body_2:
	jal allocate_memory_for_queue
	move $t4, $v0   #### move new allocated address to $t4
    lw $t5, queue2_rear  ### load rear of the queue2 to $t5
	beqz $t5, assign_head_queue_2    ## if the rear is null, initialize the queue 2 
insert_queue_body2_2:
	sw $a0, 0($t4)   ##  assign the argument number value as the new node value
	sw $zero, 4($t4)  ## assign the next node of the new node as zero
	sw $t4, 4($t5)    ## assign the new node as the next of the rear
    sw $t4, queue2_rear  ## assign the new node as the rear node
insert_queue_return_2:   ## load changed variables back and return
    lw $t5, 16($sp)
	lw $a3, 12($sp)
	lw $t4, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra
##########################################
assign_head_queue_2:  ### initialize the queue
    sw $t4, queue2_front  ## assign new node as front
    sw $t4, queue2_rear   ## assign new node as rear
	sw $a0, 0($t4)        ## assign argument number value as new node number value
	sw $zero, 4($t4)      ## assign next node of the new node as zero
	j insert_queue_return_2  ## jump return
###########################################
###########################################
get_user_input:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)

	la $a0, input_menu   ## print menu
	li $v0, 4
	syscall

	li $v0, 5   ## take input number from user
	syscall

	move $a0, $v0  ## move the user input to argument

	jal evaluate_user_input   ## call evaluate function

	lw $a0, 4($sp)   ## load changed variables and return
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
##########################################
##########################################
evaluate_user_input:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $a3, 16($sp)
    ## decide with respect to user input
	beq $a0, 0, terminate
	beq $a0, 1, call_insert_on_demand
	beq $a0, 2, call_find_in_tree
	beq $a0, 3, call_print
terminate:     ## terminate program on user demand
	li $v0, 10
	syscall
call_print:
	jal print_level_order    ## call print function
	j evaluate_user_input_end
call_find_in_tree:        
	la $a0, find_message    ## print find message
	li $v0, 4
	syscall

	li $v0, 5    ## get user input
	syscall

	move $a0, $v0   ## move the user input to argument variable
    jal find        ## call find function

    bne $v0, 0, forofor_not_found  ## if $v0 is 0 then find is successful if not then go to forofor not found block
    la $a0, found_in_the_tree_message  ## load found message
    li $v0, 4  
    syscall  ## print load message

    move $a0, $v1  ## load found address to argument
    li $v0, 1
    syscall   ## print the address of the found number

    la $a0, line
    li $v0, 4
    syscall    ## print_new line
    j evaluate_user_input_end  ## jump end of evaluate user input
forofor_not_found:
    la $a0, not_found_message
    li $v0, 4
    syscall   ## print not found message
    j evaluate_user_input_end
call_insert_on_demand:
	la $a0, insert_message
	li $v0, 4
	syscall  ## print insert message

	li $v0, 5
	syscall  ## take user input number, what should be inserted?

	move $a0, $v0  ## move user input to argument
	lw $a2, tree   ## load the tree root pointer
	jal insert_beginning  ## call insert
	j evaluate_user_input_end
evaluate_user_input_end:   ## load changed variables back and return
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $a3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
##############################

	
##############################################################
##############################################################
find:
	addi $sp, $sp, -32    #### $a0 is the value to be found, $a2 tree root
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s0, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)

	move $t0, $a2   ## move tree root to $t0

find_compare:
	beq $t0, $zero, not_found   ## if current node equals to null
	lw $s0, 0($t0)              ## load the number value of current node
	beq $s0, $a0, found         ## if it is equal to argument it means it is found
	slt $t2, $a0, $s0            ## if the value to be found is greater than our current node value, then go right
	beq $t2, $zero, find_goRight

find_goLeft:     ## if the value to be found is less than current node value then go left
	add $t1, $t0, $zero    ## move $t0 to $t1
	lw $t0, 4($t0)         ## load left address to $t0
	j find_compare         ## continue to loop

find_goRight:
	add $t1, $t0, $zero     ## move $t0 to $t1
	lw $t0, 8($t0)          ## load right address
	j find_compare          ## continue to loop
found:
	li $v0, 0               ## if found return 0
	move $v1, $t0           ## and return address
	j find_return

not_found:
	li $v0, 1              ## if not found return 1
	j find_return
find_return:              ## load changed variables back and return
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	addi $sp, $sp, 32
	jr $ra
#######################################################
#######################################################

print_level_order:  
	addi $sp, $sp, -52
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $a0, 8($sp)
	sw $a3, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)
	sw $t6, 36($sp)
	sw $t7, 40($sp)
    sw $s0, 44($sp)
    sw $s1, 48($sp)

	lw $a2, tree             ## a2 is the root of the tree
	beqz $a2, level_return   ### if(root == null)
	lw $a0, 0($a2)           ## $a0 is the value of the root
	lw $a3, queue1_front
	jal insert_to_queue_start_1  ### queue1.add(root)
print_newLine00:
    move $s0, $a0    ## temporarily store $a0 to $s0
    move $s1, $v0    ## temporarily store $v0 to $s1
    la $a0, line     
    li $v0, 4
    syscall          ## print new line
    move $a0, $s0
    move $v0, $s1     ## load back
### while(!queue1.isEmyty && !queue2.isEmpty())
if_condition1:
	lw $t0, queue1_front
	beqz $t0, if_condition2     ### if(queue1.isEmpty())
inner_condition1:
	lw $t0, queue1_front
	bne $t0, $zero, inner_while1   ### if(!queue1.isEmpty())
	j print_newLine
inner_while1:
	lw $a3, queue1_front
	jal pop_queue_start_1    ### $v0 = pop(queue1)
	move $a0, $v0         
	move $t4, $a0
	beq $a0, -10000, printX     ## if popped value is -10,000 then print X
	li $v0, 1  ### print($a0)
	syscall

	la $a0, space
	li $v0, 4
	syscall       ## print space

	move $a0, $t4
	jal find  ### find poped value of the queue in the tree, address will be at $v1

	beq $v0, 1, inner_condition2     ## if it does not found in the tree

## if popped value is found in the tree address will be at $v1
check_left_queue1:
	lw $t2, 4($v1)    ### left child adress will be at $t2
	beqz $t2, insert_x_q2_left   ### if there is no left child insert X -10,000
	lw $a0, 0($t2)        ### load value of left child
	lw $a3, queue2_front
	jal insert_to_queue_start_2    ## add tree left child to queue2

check_right_queue1:
	lw $t3, 8($v1)    ## right child address will be at $t3
	beqz $t3, insert_x_q2_right    ## if address is null add x to queue 2
	lw $a0, 0($t3)             ## value of the right child
	lw $a3, queue2_front
	jal insert_to_queue_start_2    ## add tree right child to queue 2
    j inner_condition1    ## continue to for loop
print_newLine:
	la $a0, line
	li $v0, 4
	syscall     ## print new line
inner_condition2:
	lw $t1, queue2_front
	bne $t1, $zero, inner_while2   ### if(!queue2.isEmpty())
	j print_newLine00
inner_while2:
	lw $a3, queue2_front
	jal pop_queue_start_2    ### $a0 = pop(queue2)
	move $a0, $v0
	move $t5, $a0
	beq $a0, -10000, printX_2  ## if popped value is -10,000 then print X
	li $v0, 1  ### print($a0)
	syscall

	la $a0, space
	li $v0, 4
	syscall   ## print space

	move $a0, $t5
	jal find  ### find queue root in the tree, address will be at $v1

	beq $v0, 1, inner_condition2    ## if not found check condition in for loop 

check_left_tree2:
	lw $t6, 4($v1)    ### left child adress will be at $t6
	beqz $t6, insert_x_q1_left   ### if there is no left child insert X -10,000
	lw $a0, 0($t6)        ### load value of left child
	lw $a3, queue1_front   
	jal insert_to_queue_start_1    #### insert the value to queue1
check_right_tree2:
	lw $t7, 8($v1)   ## right child address will be at $t7
	beqz $t7, insert_x_q1_right  ## if there is no right child insert X -10,000
	lw $a0, 0($t7)              ## load value of right child
	lw $a3, queue1_front        
	jal insert_to_queue_start_1   #### insert the value to queue 1
    j inner_condition2
level_return:  ## load changed variables back and return
    lw $s1, 48($sp)
    lw $s0, 44($sp)
	lw $t7, 40($sp)
	lw $t6, 36($sp)
	lw $t5, 32($sp)
	lw $t4, 28($sp)
	lw $t3, 24($sp)
	lw $t2, 20($sp)
	lw $t1, 16($sp)
	lw $a3, 12($sp)
	lw $a0, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 52
	jr $ra
if_condition2:  ### if queue2 also empty, then return
	lw $t1, queue2_front
	beqz $t1, level_return
	j inner_condition1
insert_x_q2_left:   #### insert x to queue2 when finish go to check right queue1
	li $a0, -10000
	lw $a3, queue2_front
	jal insert_to_queue_start_2
	j check_right_queue1
insert_x_q2_right:   #### insert x to queue2 when finish go to inner condition2
	li $a0, -10000
	lw $a3, queue2_front
	jal insert_to_queue_start_2
	j inner_condition1
insert_x_q1_left:  #### insert x to queue 1
	li $a0, -10000
	lw $a3, queue1_front
	jal insert_to_queue_start_1
	j check_right_tree2
insert_x_q1_right:  #### insert x to queue 1
	li $a0, -10000
	lw $a3, queue1_front
	jal insert_to_queue_start_1
	j inner_condition2
printX:  ### these blocks prints x and space, because of they are jumps different places, they are seperated
	la $a0, x
	li $v0, 4
	syscall

	la $a0, space
	li $v0, 4
	syscall
	j inner_condition1
printX_2:
	la $a0, x
	li $v0, 4
	syscall

	la $a0, space
	li $v0, 4
	syscall
	j inner_condition2


########################################################
########################################################


