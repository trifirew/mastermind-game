/* Betty Zhang, Keisun Wu
 * June 4, 2017
 * Mastermind Game
 */

import GUI, Anim in "Anim.tu", G in "G.tu"
View.Set ("graphics:800;480")
View.Set ("title:Mastermind by Betty & Keisun")
Music.PlayFileLoop ("bgm.wav")

% Game
var answer : array 1 .. 4 of int
var guess : array 1 .. 4 of int
var guessCount : int
% Players
var name : string
var score : int := 0
var highScore : int := 0
var highPlayer : string := ""
% Buttons
var btnGiveUp, btnMusic : int
var btnRed, btnBlue, btnGreen, btnYellow, btnBlack, btnOrange, btnDone : int
var btnContinue, btnExit, btnNewGame : int
var btnChance : int
% Mouse
var x, y, b, bn, bud : int
% Pictures
var picBoard : int := Pic.FileNew ("Mastermind.jpg")
var picLogo : int := Pic.FileNew ("Mastermind-Logo.jpg")
var picInstruction : int := Pic.FileNew ("instruction.jpg")
var picContinue : int := Pic.FileNew ("continue.gif")
var picEnding : int := Pic.FileNew ("ending.jpg")
var picThank : int := Pic.FileNew ("thank.jpg")
var picTick : int := Pic.FileNew ("tick.gif")
var picLeaderBoard : int := Pic.FileNew ("leaderboard.gif")
% Colours
var cLightGreen : int := RGB.AddColor (0.8, 0.95, 0.75)
var cOrange : int := RGB.AddColor (1, 0.6471, 0)
% Fonts
var fontSans40 : int := Font.New ("sans serif:40")
var fontSans36 : int := Font.New ("sans serif:36")
var fontSans24 : int := Font.New ("sans serif:24")
var fontSans16 : int := Font.New ("sans serif:16")
var fontSans12 : int := Font.New ("sans serif:12")
var fontMono28 : int := Font.New ("mono:28")
var font4 : int := Font.New ("serif:30:italic")
var font5 : int := Font.New ("serif:20:italic")
% Counts
var music : int := 0
var countPlayer : int := 0
var correct : int := 0

process playSoundEffect (fileName : string)
    Music.PlayFile (fileName)
end playSoundEffect

% Pre-declared procedures
forward procedure instructionScreen
forward procedure newGameScreen
forward procedure gameplayScreen
% Helper procedures
forward proc topBar
forward proc dot (pos : int, c : int)
forward proc initBtn
forward fcn randomC : int
forward fcn mouseIn (x1, y1, x2, y2 : int) : boolean

% Show the opening screen
procedure openingScreen
    Pic.Draw (picLogo, 150, 330, picCopy)
    Pic.Draw (picBoard, 250, 80, picCopy)
    G.TextCtr ("Press any key to begin", 50, fontSans12, black)
    locatexy (395, 30)
    var ch : char := getchar
end openingScreen

% Show the instruction screen
body procedure instructionScreen
    View.Set ("offscreenonly")
    Pic.Draw (picInstruction, 0, 0, picCopy)
    G.TextCtr ("Instruction", 400, fontSans36, black)
    G.TextCtr ("The computer will randomly choose 4 colours from green, red, blue, yellow, orange and black.", 330, fontSans12, black)
    G.TextCtr ("You guess 4 colours at each turn, the computer then tells you how many you guessed correctly", 300, fontSans12, black)
    G.TextCtr ("The colour and the position must be correct, but it doesn't tell you which one is correct.", 270, fontSans12, black)
    G.TextCtr ("You have 10 chances total to get the correct pattern.", 240, fontSans12, black)
    G.TextCtr ("Hope you enjoy!", 180, fontSans24, black)
    Pic.Draw (picContinue, 600, 30, picMerge)
    Anim.Uncover (Anim.TOP, 5, 15)
    loop
	buttonwait ("down", x, y, bn, bud)
	exit when x >= 600 and x <= 750 and y >= 30 and y <= 100
    end loop
    newGameScreen
end instructionScreen

% Start a new game, let the player enter their name
body procedure newGameScreen
    var inputChar : char
    var onInstructionBtn : boolean := false
    View.Set ("offscreenonly,nocursor")
    countPlayer += 1
    % Record highest score
    if score > highScore then
	highScore := score
	highPlayer := name
    end if
    % Get player name
    Anim.Cover (cLightGreen, Anim.LEFT + Anim.RIGHT, 5, 15)
    G.TextCtr ("Enter your name", 300, fontSans24, black)
    G.TextCtr ("Once you are done, hit ENTER", 270, fontSans16, darkgrey)
    drawfillbox (220, 210, 580, 212, darkgrey)
    Font.Draw ("Read Instruction", 16, 16, fontSans12, black)
    Anim.UncoverArea (220, 210, 580, 330, Anim.TOP, 3, 15)
    Anim.UncoverArea (12, 12, 130, 32, Anim.BOTTOM, 2, 15)
    name := ""
    Input.Flush
    loop
	if Input.hasch then
	    % Simulate a "get", with input always at the vertical centre
	    inputChar := getchar
	    Input.Flush
	    if inputChar = KEY_BACKSPACE and length (name) > 0 then
		name := name (1 .. * -1)
		drawfillbox (200, 0, 600, 209, cLightGreen)
	    elsif inputChar not= KEY_BACKSPACE and inputChar not= KEY_ENTER and length (name) < 16 then
		name += inputChar
		drawfillbox (200, 0, 600, 209, cLightGreen)
	    elsif inputChar = KEY_ENTER and length (name) > 0 and name (1) not= " " and name (*) not= " " then
		exit
	    else
		drawfillbox (220, 210, 580, 212, brightred)
		View.Update
		delay (200)
		drawfillbox (220, 210, 580, 212, darkgrey)
		drawfillbox (200, 0, 600, 209, cLightGreen)
		G.TextCtr ("You should not start or end your name with a space.", 160, fontSans12, brightred)
		G.TextCtr ("Your name should be 1 - 16 characters.", 180, fontSans12, brightred)
	    end if
	    View.Update
	end if
	% Allow user to read instruction again
	mousewhere (x, y, b)
	if mouseIn (12, 12, 130, 32) then
	    drawfillbox (12, 12, 130, 32, black)
	    Font.Draw ("Read Instruction", 16, 16, fontSans12, cLightGreen)
	    % If the mouse is on the button but wasn't before, update the button
	    % Prevent the screen from keeping updating
	    if not onInstructionBtn then
		Anim.UncoverArea (12, 12, 130, 32, Anim.BOTTOM, 2, 15)
		onInstructionBtn := true
	    end if
	else
	    drawfillbox (12, 12, 130, 32, cLightGreen)
	    Font.Draw ("Read Instruction", 16, 16, fontSans12, black)
	    % If the mouse isn't on the button but was before, update the button
	    % Prevent the screen from keeping updating
	    if onInstructionBtn then
		Anim.UncoverArea (12, 12, 130, 32, Anim.BOTTOM, 2, 15)
		onInstructionBtn := false
	    end if
	end if
	if Mouse.ButtonMoved ("down") then
	    % Dump this click
	    Mouse.ButtonWait ("down", x, y, bn, bud)
	    if mouseIn (12, 12, 130, 32) then
		View.Set ("nooffscreenonly")
		instructionScreen
		return
	    end if
	end if
	drawfillbox (0, 213, maxx, 260, cLightGreen)
	G.TextCtr (name, 220, fontMono28, black)
	View.Update
    end loop
    score := 0
    delay (500)
    gameplayScreen
end newGameScreen

% Show the gameplay(main) screen
body procedure gameplayScreen
    View.Set ("offscreenonly")
    cls
    GUI.Hide (btnExit)
    GUI.Hide (btnNewGame)
    GUI.Hide (btnContinue)
    guessCount := 0
    % Show player info
    topBar
    drawline (480, 0, 480, 440, darkgrey)
    drawline (0, 440, maxx, 440, darkgrey)
    %% TODO: Limit number of guess chance
    GUI.Show (btnGiveUp)
    GUI.Show (btnMusic)
    GUI.Show (btnChance)
    GUI.Disable (btnDone)
    for btn : btnRed .. btnDone
	GUI.SetColor (btn, grey)
	GUI.Show (btn)
    end for
    % for i : 1 .. 14
    %     drawline (480, i * 30, maxx, i * 30, black)
    % end for
    Anim.Uncover (Anim.HORI_CENTRE, 5, 15)
    % Draw dots
    for decreasing i : 4 .. 1
	answer (i) := randomC
	answer (i) := brightred     %% SHOULD BE DELETED
	guess (i) := white
	for j : 0 .. i * 92 + 10 by 2
	    drawoval (j, 328, 32, 32, black)
	    View.Update
	    delay (5)
	    drawfilloval (j, 328, 32, 32, white)
	end for
	dot (i, white)
    end for
    View.Set ("nooffscreenonly")
end gameplayScreen

%Show the ending screen
proc endingScreen
    cls
    if score > highScore then
	highScore := score
	highPlayer := name
    end if
    Pic.Draw (picEnding, 0, 0, picCopy)
    if countPlayer = 1 then
	G.TextCtr ("Congratulation!", 350, fontSans40, black)
	G.TextCtr ("Player name: " + name, 160, fontMono28, black)
	G.TextCtr ("Final score: " + intstr (score), 100, fontMono28, black)
    else
	Pic.Draw (picLeaderBoard, 300, 250, picMerge)
	G.TextCtr ("Highest score: " + intstr (highScore), 160, fontMono28, black)
	G.TextCtr ("Player name: " + highPlayer, 100, fontMono28, black)
    end if
    delay (5000)
    cls
    %% TODO: Add animation
    Pic.Draw (picThank, 0, 0, picCopy)
    Pic.Draw (picLogo, 150, 300, picCopy)
    G.TextCtr ("Thank you for playing", 230, font4, black)
    G.TextCtr ("By Keisun & Betty", 165, font5, black)
    Music.PlayFileStop
    GUI.Quit
end endingScreen

% Show the result screen
procedure resultScreen
    View.Set ("offscreenonly")
    cls
    for btn : btnRed .. btnBlack
	GUI.Hide (btn)
    end for
    GUI.Hide (btnMusic)
    GUI.Hide (btnChance)
    % Show the correct pattern
    for i : 1 .. 4
	drawfilloval (i * 100 + 150, 320, 40, 40, answer (i))
	drawoval (i * 100 + 150, 320, 40, 40, black)
    end for
    GUI.Show (btnExit)
    GUI.Show (btnNewGame)
    GUI.Show (btnContinue)
    % Different display for win/lose
    if correct not= 4 and guessCount < 10 then
	score -= 100
	fork playSoundEffect ("wrong.wav")
	% Give up display
    elsif correct = 4 then
	score += 100
	fork playSoundEffect ("correct.wav")
	% Correct display
    elsif guessCount >= 10 then
	score -= 100
	fork playSoundEffect ("wrong.wav")
	% Out of chance display
    end if
    % Show player info
    G.TextCtr ("Name: " + name + "       " + "Score: " + intstr (score), 400, fontSans16, black)
    Anim.Uncover (Anim.TOP, 2, 5)
    View.Set ("nooffscreenonly")
end resultScreen

% Called when color button is clicked
% Let player to fill a dot with selected color
procedure fillDot
    var dotColor : int
    if GUI.GetEventWidgetID = btnRed then
	dotColor := brightred
    elsif GUI.GetEventWidgetID = btnBlue then
	dotColor := brightblue
    elsif GUI.GetEventWidgetID = btnGreen then
	dotColor := brightgreen
    elsif GUI.GetEventWidgetID = btnYellow then
	dotColor := yellow
    elsif GUI.GetEventWidgetID = btnOrange then
	dotColor := cOrange
    elsif GUI.GetEventWidgetID = btnBlack then
	dotColor := black
    end if
    for btn : btnRed .. btnBlack
	GUI.SetColor (btn, grey)
    end for
    GUI.SetColor (GUI.GetEventWidgetID, dotColor)
    % When player hover the mouse over the dot, preview the color
    View.Set ("offscreenonly")
    loop
	mousewhere (x, y, b)
	exit when b = 1
	for i : 1 .. 4
	    if mouseIn (i * 92 + 10 - 32, 328 - 32, i * 92 + 10 + 32, 328 + 32) then
		drawfilloval (i * 92 + 10, 328, 32, 32, dotColor)
		drawfilloval (i * 92 + 10, 328, 28, 28, guess (i))
	    else
		dot (i, guess (i))
	    end if
	end for
	View.Update
    end loop
    buttonwait ("down", x, y, bn, bud)
    % Fill the color in and
    % Check if all the dots are filled
    GUI.Enable (btnDone)
    for i : 1 .. 4
	if mouseIn (i * 92 + 10 - 32, 328 - 32, i * 92 + 10 + 32, 328 + 32) then
	    dot (i, dotColor)
	    guess (i) := dotColor
	end if
	if guess (i) = white then
	    GUI.Disable (btnDone)
	end if
    end for
    % Reset button color
    for btn : btnRed .. btnBlack
	GUI.SetColor (btn, grey)
    end for
    View.Update
    View.Set ("nooffscreenonly")
end fillDot

% Check if player guess correctly
procedure checkAnswer
    correct := 0
    guessCount += 1
    for i : 1 .. 4
	if guess (i) = answer (i) then
	    correct += 1
	end if
    end for
    % Show player's previous guesses
    if guessCount > 0 then
	View.Set ("offscreenonly")
	for i : 1 .. 4
	    drawfilloval (i * 20 + 600, guessCount * 33 - 14, 8, 8, guess (i))
	    drawoval (i * 20 + 600, guessCount * 33 - 14, 8, 8, black)
	end for
	Font.Draw ("Guess#" + intstr (guessCount), 500, guessCount * 33 - 19, fontSans12, black)
	G.TextRight (intstr (correct), 24, guessCount * 33 - 21, fontSans16, black)
	Pic.Draw (picTick, 780, guessCount * 33 - 22, picCopy)
	Anim.UncoverArea (480, (guessCount - 1) * 33, maxx, guessCount * 33, Anim.BOTTOM, 1, 10)
	View.Set ("nooffscreenonly")
    end if
    if correct = 4 or guessCount >= 10 then
	resultScreen
	return
    end if
end checkAnswer

% Turn on/off the background music
proc musicOnOff
    music := music + 1
    if music mod 2 = 0 then
	Music.PlayFileLoop ("bgm.wav")
    else
	Music.PlayFileStop
    end if
end musicOnOff

% Give player one more chance to guess
proc moreChance
end moreChance

% Show player info at the top of the screen
body proc topBar
    drawfillbox (0, 440, maxx, maxy, cLightGreen)
    Font.Draw (name, 10, 454, fontSans12, black)
    G.TextCtr ("SCORE: " + intstr (score), 454, fontSans12, black)
end topBar

% Draw dot at a given position
body proc dot (pos : int, c : int)
    drawfilloval (pos * 92 + 10, 328, 32, 32, c)
    drawoval (pos * 92 + 10, 328, 32, 32, black)
end dot

% Initialize all buttons
% In order to avoid "Cannot find button"
body proc initBtn
    btnGiveUp := GUI.CreateButton (400, 0, 80, "GIVE UP", resultScreen)
    GUI.SetColor (btnGiveUp, white)
    btnRed := GUI.CreateButtonFull (100, 220, 80, "RED", fillDot, 40, chr (0), false)
    btnBlue := GUI.CreateButtonFull (200, 220, 80, "BLUE", fillDot, 40, chr (0), false)
    btnGreen := GUI.CreateButtonFull (300, 220, 80, "GREEN", fillDot, 40, chr (0), false)
    btnYellow := GUI.CreateButtonFull (100, 160, 80, "YELLOW", fillDot, 40, chr (0), false)
    btnOrange := GUI.CreateButtonFull (200, 160, 80, "ORANGE", fillDot, 40, chr (0), false)
    btnBlack := GUI.CreateButtonFull (300, 160, 80, "BLACK", fillDot, 40, chr (0), false)
    btnDone := GUI.CreateButtonFull (100, 384, 280, "DONE!", checkAnswer, 40, chr (0), false)
    btnContinue := GUI.CreateButtonFull (350, 160, 100, "CONTINUE", gameplayScreen, 40, chr (0), false)
    btnExit := GUI.CreateButtonFull (550, 160, 100, "Exit", endingScreen, 40, chr (0), false)
    btnNewGame := GUI.CreateButtonFull (150, 160, 100, "NEW GAME", newGameScreen, 40, chr (0), false)
    btnChance := GUI.CreateButtonFull (680, 440, 120, "More chances", moreChance, 40, chr (0), false)
    GUI.SetColor (btnChance, cLightGreen)
    btnMusic := GUI.CreateButton (0, 0, 40, "Music ON/OFF", musicOnOff)
    GUI.SetColor (btnMusic, white)
    for btn : btnGiveUp .. btnMusic
	GUI.Hide (btn)
    end for
end initBtn

% Return a random color
body fcn randomC : int
    case Rand.Int (1, 6) of
	label 1 :
	    result brightred
	label 2 :
	    result brightblue
	label 3 :
	    result brightgreen
	label 4 :
	    result yellow
	label 5 :
	    result cOrange
	label 6 :
	    result black
    end case
end randomC

% Return if mouse is in an area
% Used after buttonwait (direction, x, y, bn, bud)
body fcn mouseIn (x1, y1, x2, y2 : int) : boolean
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
	result true
    end if
    result false
end mouseIn

initBtn
openingScreen
instructionScreen
% For testing
% newGameScreen
% name := "WWWWwwwwMMMMmmmm"
% score := 0
% gameplayScreen

% Wait for player to click buttons
loop
    % mousewhere (x, y, b)
    % locate (1, 1)
    % put x, " ", y, " ", b
    exit when GUI.ProcessEvent
end loop
