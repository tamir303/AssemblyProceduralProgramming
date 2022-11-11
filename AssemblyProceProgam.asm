# Title:	Filename:
# Author:	Date:
# Description:
# Input:
# Output:
################# Data segment #####################
.data
array2d:	.space	200		# 200 bytes kepts for 2 dimenstion array
maxElements:    .byte	50		# 200/4

arraySizeError:	.asciiz "\nMax value for Rows*Cols is 50, please re-enter your size information"

askForNumRows: .asciiz "\nPlease enter number of Row at 2D array: "
askForNumCols: .asciiz "\nPlease eîter number of Column at 2D array: "
askForNumber: .asciiz "\nPlease enter number: "
askForReqCol: .asciiz "\nPlease enter the column number to sum (1-m): "
errorColReq: .asciiz "\nWrong column number. It must be between 1 and "
sumOfCol: .asciiz "\nThe sum of columns "
numberInputError: .asciiz "\nNumber most be between -999 to 999"

################# Code segment #####################
.text
.globl main

array_size_error:
	li $v0,4
	la $a0,arraySizeError
	syscall

main:	# main program entry
	
	li $v0,4
	la $a0,askForNumRows
	syscall
	li $v0,5 # gets num of rows from user
	syscall
	ble $v0,0,array_size_error
	move $a1,$v0 # backup number of rows to arg $a1
	
	li $v0,4
	la $a0,askForNumCols
	syscall
	li $v0,5 # gets num of columns from user
	syscall
	ble $v0,0,array_size_error
	move $a2,$v0 # backup number of columns to arg $a2
	
	mul $t0,$a1,$a2
	bgt $t0,50,array_size_error
	
	move $s0,$a1 # backup
	move $s1,$a2 # backup
	
	la $a0,array2d # load array pointer
	jal fillUpArray # fill the array with numbers
	
	la $a0,array2d # load array pointer
	move $a1,$s0 # backup num of rows
	move $a2,$s1 # backup num of columns
	jal printArray
	
        request_column:
	li $v0,4
	la $a0,askForReqCol
	syscall
	li $v0,5
	syscall
	ble $v0,$s1,valid
	li $v0,4
	la $a0,errorColReq
	syscall
	j request_column
	
	valid:             
	move $a3,$v0 # move requested column to $a3
	move $a2,$s1 # backup num of columns
	move $a1,$s0 # backup num of rows
	la $a0,array2d # load array pointer
	jal sumColumn
	move $t0,$v0
	li $v0,4
	la $a0,sumOfCol
	syscall
	li $v0,1
	move $a0,$t0
	syscall
	
li $v0, 10	# Exit program
syscall
	
readValue:
	# calculate requested address (rowIndex*numOfColumns + columnIndex)*sizeOfSegment
	mul $t0,$a1,$a3
	add $t0,$t0,$a2
	mul $t0,$t0,4
	add $t0,$t0,$a0
	move $t9,$a0
	# requesting number from user
	j numbers_in_bound
	Error:
		li $v0,4
		la $a0,numberInputError
		syscall
		numbers_in_bound:
	      	  	li $v0,4
			la $a0,askForNumber
			syscall
			li $v0,5
			syscall
	blt $v0,-999,Error
	bgt $v0,999,Error
	j Exit
	# insert value to requested address
	Exit:
	sw $v0,0($t0)
	move $a0,$t9
	jr $ra
#	$a0 - 2 dim. array pointer (each array element size - word)
#	$a1 - requested row (0 to n-1)
#	$a2 - requested column (0 to m-1)
#	$a3 - number of columns in each row
# Procedure reads from console a value and store it in right array location							
###################################################################################	

getValue:
	# calculate requested address (rowIndex*numOfColumns + columnIndex)*sizeOfSegment
	mul $t0,$a1,$a3
	add $t0,$t0,$a2
	mul $t0,$t0,4
	add $t0,$t0,$a0
	# load value from requested address
	lw $v0,0($t0)
	jr $ra
#	$a0 - 2 dim. array pointer (each array element size - word)
#	$a1 - requested row (0 to n-1)
#	$a2 - requested column (0 to m-1)
#	$a3 - number of columns in each row
# Procedure gets from array, based on requested location, a value and returns it at $v0
###################################################################################

fillUpArray:
	# save last jump address and array pointer in stack
	addiu $sp,$sp,-4
	sw $ra,0($sp)
	
	move $a3,$a2 # backup num of columns/size of row
	addi $a1,$a1,-1 # start row index (n-1)
	addi $a2,$a2,-1 # start column index (m-1)
	for_loop1:
		bne $a2,-1,next_Number # if branch taken -> stay in row/ next column
				       # else reset column and move to next row
				       
		addi $a2,$a3,-1 # column reset
		addi $a1,$a1,-1 # next row
		
		beq $a1,-1,end_loop1 # if branch not taken -> continue loop
	  next_Number:
	  
		jal readValue # read value from user and insert it in index [$a1,$a2]
		addi $a2,$a2,-1 # next column
		
		j for_loop1
	  end_loop1:
	  	lw $ra,0($sp)
	  	addiu $sp,$sp,4
	  	jr $ra
#	$a0 - 2 dim. array pointer (each array element size - word)
#	$a1 - number of rows (n)
#	$a2 - number of columns (m)
#
# Procedure reads values for all array elements, by using "readValue" procedure
###################################################################################
	
printArray:
	# save last jump address and array pointer in stack
	move $t0,$a0 # save array pointer
	li $t1,0 # row index
	li $t2,0 # column index
	
	addiu $sp,$sp,-16
	sw $t0,4($sp)
	sw $ra,0($sp)
	
	move $a3,$a2 # save num of columns to arg $a3
	for_loop2:
		bne $t2,$s1,next_index # if branch taken -> stay in row/ next column
			               # else reset column and move to next row
			               
		addi $t1,$t1,1 # next row
		li $t2,0 # reset column
		
		li $v0,11
	   	li $a0,'\n'
	   	syscall
	   	
		beq $t1,$s0,end_loop2
	   next_index:
	        sw $t0,4($sp) # save array pointer
	        sw $t1,8($sp) # save row index
	        sw $t2,12($sp)# save column index
	        
	        move $a0,$t0 # sets array pointer
	   	move $a1,$t1 # sets row index
	   	move $a2,$t2 # sets column index
	   	
	   	jal getValue # get value in index [$a1,$a2]
	   	lw $t1,8($sp)
	        lw $t2,12($sp)
	        
	   	move $a0,$v0
	   	li $v0,1 
	   	syscall # print integer
	   	
	   	li $v0,11
	   	li $a0,'\t'
	   	syscall # backslash Tab
	   	
	   	addi $t2,$t2,1 # next column
	   	lw $t0,4($sp) # array pointer backup
	   	j for_loop2
	   end_loop2:
	   	lw $ra,0($sp) # return address backup
	   	addiu $sp,$sp,16
	   	jr $ra
	   	
#	$a0 - 2 dim. array pointer (each array element size - word)
#	$a1 - number of rows (n)
#	$a2 - number of columns (m)
#
# Procedure get values for all array elements, by using "getValue" procedure
########################################################################

sumColumn:
	addiu $sp,$sp,-16
	li $t0,0 # start row index
	addi $a3,$a3,-1 # (m-1)
	move $t1,$a3 # backup requested column
	li $t2,0 # sum of column
	sw $t2,12($sp)
	sw $t1,8($sp)
	sw $t0,4($sp)
	sw $ra,0($sp)
	
	for_loop3:
		bgt $t0,$s0,all_done
		
		sw $t2,12($sp)
	        sw $t1,8($sp)
	        sw $t0,4($sp)
	        
	        move $a1,$t0 # row index
	        move $a2,$t1 # requested column
	        move $a3,$s1 # size of row
	        
	        jal getValue
	        lw $t2,12($sp)
	        add $t2,$t2,$v0 # sum returned number
	        
	        lw $t0,4($sp)
	        addi $t0,$t0,1 # next row
	        
	        j for_loop3
	 all_done:
	 	lw $ra,0($sp)
	 	lw $v0,12($sp) # return sum $v0
	 	addiu $sp,$sp,16
	 	jr $ra
	
#	$a0 - 2 dim. array pointer (each array element size - word)
#	$a1 - number of rows (n)
#	$a2 - number of columns (m)
#	$a3 - requested column (value between - and (m-1)
#
# Procedure sumerizes the columns' values and returns the sum at $v0 
################################################################
