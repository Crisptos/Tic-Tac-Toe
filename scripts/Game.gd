extends Node2D

#board represented as an array
var currentBoard = Array()

#player boolean, true X, false O
var player = "X"
var ai = "O" 

#boolean for the current turn
var currentTurn = true
#turn counter
var turnCounter = 0

#height and width of board
var width = 3 
var height = 3

signal ai_action()

#victory signal
signal victory()

#draw signal
signal tie()

#ready function initializes the board
func _ready():
	currentBoard = updateBoard()
	print(currentBoard)

#constantly update grid and check for win condition	
func _process(delta):
	#constantly update the board
	currentBoard = updateBoard()
	
	#draw case
	if(checkFull(currentBoard) == true && checkWin(currentBoard) == 0):
		emit_signal("tie")
	
	#check for win conditions
	if(checkWin(currentBoard) == 1):
		print("X Wins!")
		emit_signal("victory", "X")
		
	if(checkWin(currentBoard) == 2):
		print("O Wins!")
		emit_signal("victory", "O")
	
	if(currentTurn == false):
		AI()
		currentBoard = updateBoard()
	

func updateBoard():
	var array = []
	var pos = 0
	#Traverses the 3x3 game board
	for i in width:
		array.append([])
		for j in height:
			array[i].append($Grid.get_child(pos).state)
			pos+=1
	return array

#toggles boolean value
func setTurn():
	currentTurn = !currentTurn
	turnCounter+=1

#checks to see if the board is full
func checkFull(currentBoard):
	#count var
	var count = 0
	#traverse through 2d array
	for i in width:
		for j in height:
			#count the number of non _'s, _ is empty space
			if(currentBoard[i][j] != '_'):
				count+=1
	#if there were 9 occupied spaces, return true, else false
	if(count == 9):
		return true
	else:
		return false

#check every column
func checkColumn(currentBoard):
	#count of X's and O's
	var x = 0
	var o = 0
	#column traversal
	for j in height:
		x = 0
		o = 0
		for i in width:
			if(currentBoard[i][j] == 'X'):
				x+=1
			if(currentBoard[i][j] == 'O'):
				o+=1
			if(x == 3):
				return 1
			elif(o == 3):
				return 2

#check every row	
func checkRow(currentBoard):
	#the count of X's and O's
	var x = 0
	var o = 0
	#row traversal
	for i in width:
		x = 0
		o = 0
		for j in height:
			if(currentBoard[i][j] == 'X'):
				x+=1
			if(currentBoard[i][j] == 'O'):
				o+=1
			if(x == 3):
				return 1
			elif(o == 3):
				return 2

#check every diagonal direction for X and O
func checkDiagonals(currentBoard):
	#the count of X's or O's in a diagonal
	var x = 0
	var o = 0
	#diagonal traversal
	if(currentBoard[0][2] == 'X' && currentBoard[1][1] == 'X' && currentBoard[2][0] == 'X'):
		return 1
	if(currentBoard[0][2] == 'O' && currentBoard[1][1] == 'O' && currentBoard[2][0] == 'O'):
		return 2
	if(currentBoard[0][0] == 'X' && currentBoard[1][1] == 'X' && currentBoard[2][2] == 'X'):
		return 1
	if(currentBoard[0][0] == 'O' && currentBoard[1][1] == 'O' && currentBoard[2][2] == 'O'):
		return 2
			
	
#1 is X victory, 2 is O victory
func checkWin(currentBoard):
	#checks every direction for possible X win
	if(checkDiagonals(currentBoard) == 1 || checkColumn(currentBoard) == 1 || checkRow(currentBoard) == 1):
		return 1
	#checks every direction for possible O win
	elif(checkDiagonals(currentBoard) == 2 || checkColumn(currentBoard) == 2 || checkRow(currentBoard) == 2):
		return 2
	#0 is the case of no victory
	return 0
	

#resets the board to blank
func clearBoard():
	var pos = 0
	for i in width:
		for j in height:
			$Grid.get_child(pos).clear()
			pos+=1
	turnCounter = 0
	

#recieves signal from area nodes
func _on_pressed(space):
	currentBoard = updateBoard()
	if(checkWin(currentBoard) == 2):
		return
	if(currentTurn == true):
		#base case: if state of area is unpressed
		if(space.state == "_"):
			#turn checker, if true X else O
			if(player == "X"):
				space.play_x()
				currentBoard = updateBoard()
				if(checkFull(currentBoard) == false):
					setTurn()
			else:
				space.play_o()
				currentBoard = updateBoard()
				if(checkFull(currentBoard) == false):
					setTurn()

#signal for play as X button
func _on_Play_as_X_pressed():
	clearBoard()
	player = "X"
	ai = "O"
	$"Game Over/Draw".visible = false
	$"Game Over/X Wins".visible = false
	$"Game Over/O Wins".visible = false
	$"Game Over/Buttons".visible = false
	get_tree().paused = false
	
	
func AI():
	var boardCopy = []
	boardCopy = currentBoard
	print("it's my turn!")
	if(ai == 'O'):
		$Grid.get_child(locate(bestMove(boardCopy))).play_o()
	if(ai == 'X'):
		$Grid.get_child(locate(bestMove(boardCopy))).play_x()
	setTurn()
	
	
	
	
func minimaxAB(boardCopy, depth, isMaximizing):
	var score = AIcheckwin(boardCopy)
	
	if(score == 10):
		return score-depth
	if(score == -10):
		return score+depth
	if(checkFull(boardCopy) == true && score != 10 && score != -10):
		return 0
	
	if(isMaximizing):
		var maxEval = -1000000000
		var eval = 0
		for i in width:
			for j in height:
				if(boardCopy[i][j]=='_'):
					boardCopy[i][j] = ai
					eval = minimaxAB(boardCopy, depth+1, true)
					if(eval > maxEval):
						maxEval = eval
					#alpha = max(alpha, eval)
					boardCopy[i][j] = '_'
					#if(beta <= alpha):
						#break
		return maxEval
	
	else:
		var minEval = 1000000000
		var eval = 0
		for i in width:
			for j in height:
				if(boardCopy[i][j]=='_'):
					boardCopy[i][j] = player
					eval = minimaxAB(boardCopy, depth+1, true)
					minEval = min(eval, minEval)
					#beta = min(eval, beta)
					boardCopy[i][j] = '_'
					#if(beta <= alpha):
						#break
		return minEval
	
func bestMove(boardCopy):
	var bestMove = 0
	var bestVal = -1000000000
	for i in width:
		for j in height:
			#case 1
			if(turnCounter == 1):
				if(boardCopy[2][1] == player):
					bestMove = [0,1]
					return bestMove
				if(boardCopy[1][2] == player):
					bestMove = [0,2]
					return bestMove
				if(boardCopy[0][0] == player):
					bestMove = [1,1]
					return bestMove
				elif(boardCopy[0][2] == player):
					bestMove = [1,1]
					return bestMove
				elif(boardCopy[2][0] == player):
					bestMove = [1,1]
				elif(boardCopy[2][2] == player):
					bestMove = [1,1]
					return bestMove
			#case 2
			elif(turnCounter == 3):
				#case 3
				if(boardCopy[0][0] == player):
					if(boardCopy[1][1] == ai):
						if(boardCopy[2][1] == player):
							bestMove = [1,0]
							return bestMove
				#case 4
				if(boardCopy[0][2] == player):
					if(boardCopy[1][1] == ai):
						if(boardCopy[2][1] == player):
							bestMove = [1,0]
							return bestMove
						elif(boardCopy[2][0] == player):
							bestMove = [0,1]
							return bestMove
				#case 5
				if(boardCopy[0][1] == player):
					if(boardCopy[0][0] == ai):
						if(boardCopy[2][2] == player):
							bestMove = [1,1]
							return bestMove
						if(boardCopy[1][2] == player):
							bestMove = [2,0]
							return bestMove
				#case 6
				if(boardCopy[1][0] == player):
					if(boardCopy[0][0] == ai):
						if(boardCopy[2][2] == player):
							bestMove = [0,2]
							return bestMove
						elif(boardCopy[0][1] == player):
							bestMove = [1,1]
							return bestMove
						elif(boardCopy[2][1] == player):
							bestMove = [0,2]
							return bestMove
				if(boardCopy[1][1] == player):
					if(boardCopy[0][0] == ai):
						if(boardCopy[2][2] == player):
							bestMove = [0,2]
							return bestMove
				if(boardCopy[1][2] == player):
					if(boardCopy[0][2] == ai):
						if(boardCopy[0][1] == player):
							bestMove = [1,0]
							return bestMove
				#case 6
				if(boardCopy[2][1] == player):
					if(boardCopy[0][1] == ai):
						if(boardCopy[0][0] == player):
							bestMove = [2,0]
							return bestMove
						elif(boardCopy[0][2] == player):
							bestMove = [2,0]
							return bestMove
						elif(boardCopy[1][0] == player):
							bestMove = [2,0]
							return bestMove
						elif(boardCopy[1][2] == player):
							bestMove = [2,0]
							return bestMove
				if(boardCopy[2][0] == player):
					if(boardCopy[1][1] == ai):
						if(boardCopy[1][2] == player):
							bestMove = [0,1]
							return bestMove
						
			
			#case 7
			elif(turnCounter == 5):
				if(boardCopy[0][0] == player):
					if(boardCopy[1][1] == ai):
						if(boardCopy[2][1] == player):
							if(boardCopy[1][0] == ai):
								if(boardCopy[1][2] == player):
									bestMove = [0,2]
									return bestMove
						if(boardCopy[1][2] == player):
							if(boardCopy[0][1] == ai):
								if(boardCopy[2][1] == player):
									bestMove = [2,0]
									return bestMove
							
				if(boardCopy[1][2] == player):
					if(boardCopy[0][2] == ai):
						if(boardCopy[0][1] == player):
							if(boardCopy[1][0] == ai):
								if(boardCopy[0][0] == player):
									bestMove = [1,1]
									return bestMove
				if(boardCopy[2][1] == player):
					if(boardCopy[0][1] == ai):
						if(boardCopy[0][0] == player):
							if(boardCopy[2][0] == ai):
								if(boardCopy[0][2] == player):
									bestMove = [1,1]
									return bestMove
								elif(boardCopy[1][0] == player):
									bestMove = [1,1]
									return bestMove
						if(boardCopy[1][2] == player):
							if(boardCopy[2][0] == ai):
								if(boardCopy[0][0] == player):
									bestMove = [1,1]
									return bestMove
							
					
				
			
			if(boardCopy[i][j] == '_'):
				boardCopy[i][j] = ai
				var moveVal = minimaxAB(boardCopy, 0, false)
				
				if(moveVal > bestVal):
					bestMove = [i,j]
					bestVal = moveVal
				boardCopy[i][j] = '_'
	print("best value is ", bestVal)
	print("best move is ", bestMove)
	return bestMove
			
	
	pass

	
func AIcheckwin(boardCopy):
	#row traversal
	for i in width:
		if(boardCopy[i][0] == boardCopy[i][1] && boardCopy[i][1] == boardCopy[i][2]):
			if(boardCopy[i][0] == ai):
				return 10
			elif(boardCopy[i][0] == player):
				return -10
	
	#column traversal
	for j in height:
		if(boardCopy[0][j] == boardCopy[1][j] && boardCopy[1][j] == boardCopy[2][j]):
			if(boardCopy[0][j] == ai):
				return 10
			elif(boardCopy[0][j] == player):
				return -10
	
	#diagonal traversal
	if(boardCopy[0][2] == boardCopy[1][1] && boardCopy[1][1] == boardCopy[2][0]):
		if(boardCopy[0][2] == ai):
			return 10
		elif(boardCopy[0][2] == player):
			return -10
	if(boardCopy[0][0] == boardCopy[1][1] && boardCopy[1][1] == boardCopy[2][2]):
		if(boardCopy[0][0] == ai):
			return 10
		elif(boardCopy[0][0] == player):
			return -10
			
	return 0
	
func locate(array):
	if(array[0] == 0 && array[1] == 0):
		return 0
	if(array[0] == 0 && array[1] == 1):
		return 1
	if(array[0] == 0 && array[1] == 2):
		return 2
	if(array[0] == 1 && array[1] == 0):
		return 3
	if(array[0] == 1 && array[1] == 1):
		return 4
	if(array[0] == 1 && array[1] == 2):
		return 5
	if(array[0] == 2 && array[1] == 0):
		return 6
	if(array[0] == 2 && array[1] == 1):
		return 7
	if(array[0] == 2 && array[1] == 2):
		return 8


	

