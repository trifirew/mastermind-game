/* Betty Zhang, Keisun Wu
 * June 6, 2017
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
var chance : int := 10
% Players
var player : string
var score : int := 0
var highScore : int := minint
var highPlayer : string := ""
var top3Scores : array 1 .. 3 of int := init (minint, minint, minint)
var top3Players : array 1 .. 3 of string := init ("", "", "")
% Buttons
var btnGiveUp, btnMusic : int
var btnRed, btnBlue, btnGreen, btnYellow, btnBlack, btnOrange, btnDone : int
var btnBrown, btnPurple, btnPink : int
var btnContinue, btnExit, btnNewGame : int
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
% Colors
var cLightGreen : int := RGB.AddColor (0.8, 0.95, 0.75)
var colors : array 1 .. 9 of int
colors (1) := brightred
colors (2) := brightblue
colors (3) := brightgreen
colors (4) := yellow
colors (5) := RGB.AddColor (1, 0.6471, 0)
colors (6) := black
%% TODO: Change colors
colors (7) := RGB.AddColor (0.549, 0.2745, 0)
colors (8) := purple
colors (9) := RGB.AddColor (1, 0.451, 1)
% Fonts
var fontSans40 : int := Font.New ("sans serif:40")
var fontSans36 : int := Font.New ("sans serif:36")
var fontSans24 : int := Font.New ("sans serif:24")
var fontSans20 : int := Font.New ("sans serif:20")
var fontSans16 : int := Font.New ("sans serif:16")
var fontSans12 : int := Font.New ("sans serif:12")
var fontMono28 : int := Font.New ("mono:28")
var fontMono20 : int := Font.New ("mono:20")
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
forward proc updateLeaderboard
forward proc initBtn
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
    % Record highest score
    if score > highScore and countPlayer > 0 then
	highScore := score
	highPlayer := player
    end if
    if countPlayer > 0 then
	updateLeaderboard
    end if
    % Get player name
    Anim.Cover (cLightGreen, Anim.LEFT + Anim.RIGHT, 5, 15)
    G.TextCtr ("Enter your name", 300, fontSans24, black)
    G.TextCtr ("Once you are done, hit ENTER", 270, fontSans16, darkgrey)
    drawfillbox (220, 210, 580, 212, darkgrey)
    Font.Draw ("Read Instruction", 16, 16, fontSans12, black)
    Anim.UncoverArea (220, 210, 580, 330, Anim.TOP, 3, 15)
    Anim.UncoverArea (12, 12, 130, 32, Anim.BOTTOM, 2, 15)
    player := ""
    Input.Flush
    loop
	if Input.hasch then
	    % Simulate a "get", with input always at the vertical centre
	    inputChar := getchar
	    Input.Flush
	    if inputChar = KEY_BACKSPACE and length (player) > 0 then
		player := player (1 .. * -1)
		drawfillbox (200, 0, 600, 209, cLightGreen)
	    elsif inputChar not= KEY_BACKSPACE and inputChar not= KEY_ENTER and length (player) < 16 then
		player += inputChar
		drawfillbox (200, 0, 600, 209, cLightGreen)
	    elsif inputChar = KEY_ENTER and length (player) > 0 and player (1) not= " " and player (*) not= " " then
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
	G.TextCtr (player, 220, fontMono28, black)
	View.Update
    end loop
    score := 0
    countPlayer += 1
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
    % Show player info
    topBar
    drawline (480, 0, 480, 440, darkgrey)
    drawline (0, 440, maxx, 440, darkgrey)
    GUI.Show (btnGiveUp)
    GUI.Show (btnMusic)
    GUI.Disable (btnDone)
    for btn : btnRed .. btnDone
	GUI.SetColor (btn, grey)
	GUI.Show (btn)
    end for
    for btn : btnBrown .. btnPink
	GUI.SetColor (btn, grey)
	GUI.Show (btn)
    end for
    Anim.Uncover (Anim.HORI_CENTRE, 5, 15)
    % Reset guess and correct counter
    chance := 10
    guessCount := 0
    correct := 0
    % Set a random color for each dot
    for i : 1 .. 4
	answer (i) := colors (Rand.Int (1, 9))
	guess (i) := white
	answer (i) := brightred      %% FOR TESTING
    end for
    for i : 1 .. chance
	Font.Draw ("Guess#" + intstr (i), 500, i * 33 - 19, fontSans12, black)
    end for
    % Draw dots
    for decreasing i : 4 .. 1
	for j : 0 .. i * 92 + 10 by 2
	    drawoval (j, 328, 32, 32, black)
	    View.Update
	    delay (5)
	    drawfilloval (j, 328, 32, 32, white)
	    % Allow player to skip animation by clicking mouse
	    if buttonmoved ("down") then
		buttonwait ("down", x, y, bn, bud)
		for k : 1 .. 4
		    dot (k, white)
		end for
		View.Update
		View.Set ("nooffscreenonly")
		return
	    end if
	end for
	dot (i, white)
    end for
    View.Set ("nooffscreenonly")
end gameplayScreen

% Show the ending screen
proc endingScreen
    cls
    if score > highScore then
	highScore := score
	highPlayer := player
    end if
    updateLeaderboard
    Pic.Draw (picEnding, 0, 0, picCopy)
    if countPlayer <= 1 then
	G.TextCtr ("Congratulation!", 350, fontSans40, black)
	G.TextCtr ("Player name: " + player, 160, fontMono28, black)
	G.TextCtr ("Final score: " + intstr (score), 100, fontMono28, black)
    elsif countPlayer <= 3 then
	Pic.Draw (picLeaderBoard, 300, 250, picMerge)
	G.TextCtr ("Highest score: " + intstr (highScore), 160, fontMono28, black)
	G.TextCtr ("Player name: " + highPlayer, 100, fontMono28, black)
    else
	Pic.Draw (picLeaderBoard, 300, 250, picMerge)
	Font.Draw ("Player name", 150, 192, fontSans20, black)
	G.TextRight ("Score", 150, 192, fontSans20, black)
	for i : 1 .. 3
	    Font.Draw (top3Players (i), 150, 180 - 40 * i, fontSans16, black)
	    G.TextRight (intstr (top3Scores (i)), 150, 180 - 40 * i, fontMono20, black)
	end for
    end if
    delay (10000)
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
    for btn : btnRed .. btnDone
	GUI.Hide (btn)
    end for
    GUI.Hide (btnMusic)
    drawfillbox (0, 0, maxx, maxy, RGB.AddColor (0.95, 0.95, 0.95))
    % Show the correct pattern
    for i : 1 .. 4
	drawfilloval (i * 100 + 150, 320, 40, 40, answer (i))
	drawoval (i * 100 + 150, 320, 40, 40, black)
    end for
    GUI.Show (btnExit)
    GUI.Show (btnNewGame)
    GUI.Show (btnContinue)
    % Different display for win/lose
    if correct not= 4 and guessCount < chance then
	score -= 100
	fork playSoundEffect ("wrong.wav")
	% Give up display
    elsif correct = 4 then
	score += 100
	fork playSoundEffect ("correct.wav")
	% Correct display
    elsif guessCount >= chance then
	score -= 100
	fork playSoundEffect ("wrong.wav")
	% Out of chance display
    end if
    % Show player info
    G.TextCtr ("Name: " + player + "       " + "Score: " + intstr (score), 400, fontSans16, black)
    Anim.Uncover (Anim.TOP, 2, 5)
    View.Set ("nooffscreenonly")
end resultScreen

% Called when color button is clicked
% Let player to fill a dot with selected color
procedure fillDot
    var dotColor : int
    if GUI.GetEventWidgetID = btnRed then
	dotColor := colors (1)
    elsif GUI.GetEventWidgetID = btnBlue then
	dotColor := colors (2)
    elsif GUI.GetEventWidgetID = btnGreen then
	dotColor := colors (3)
    elsif GUI.GetEventWidgetID = btnYellow then
	dotColor := colors (4)
    elsif GUI.GetEventWidgetID = btnOrange then
	dotColor := colors (5)
    elsif GUI.GetEventWidgetID = btnBlack then
	dotColor := colors (6)
    elsif GUI.GetEventWidgetID = btnBrown then
	dotColor := colors (7)
    elsif GUI.GetEventWidgetID = btnPurple then
	dotColor := colors (8)
    elsif GUI.GetEventWidgetID = btnPink then
	dotColor := colors (9)
    end if
    for btn : btnRed .. btnPink
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
    for btn : btnRed .. btnPink
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
	G.TextRight (intstr (correct), 24, guessCount * 33 - 21, fontSans16, black)
	Pic.Draw (picTick, 780, guessCount * 33 - 22, picCopy)
	Anim.UncoverArea (480, (guessCount - 1) * 33, maxx, guessCount * 33, Anim.BOTTOM, 1, 10)
	View.Set ("nooffscreenonly")
    end if
    if correct = 4 then
	resultScreen
	return
    elsif guessCount = chance and chance < 13 and score >= 300 then
	% Give player one more chance to guess
	GUI.Disable (btnDone)
	Font.Draw ("One more chance?", 500, guessCount * 33 + 14, fontSans12, black)
	drawbox (660, guessCount * 33 + 10, 720, guessCount * 33 + 32, green)
	drawbox (730, guessCount * 33 + 10, 790, guessCount * 33 + 32, red)
	Font.Draw ("YES", 676, guessCount * 33 + 14, fontSans12, green)
	Font.Draw ("NO", 749, guessCount * 33 + 14, fontSans12, red)
	loop
	    buttonwait ("down", x, y, bn, bud)
	    if mouseIn (660, guessCount * 33 + 10, 720, guessCount * 33 + 32) then
		chance += 1
		score -= 300
		topBar
		View.Set ("offscreenonly")
		drawfillbox (481, (chance - 1) * 33, maxx, chance * 33, white)
		Font.Draw ("Guess#" + intstr (chance), 500, chance * 33 - 19, fontSans12, black)
		Anim.UncoverArea (480, (chance - 1) * 33, maxx, chance * 33, Anim.BOTTOM, 1, 10)
		View.Set ("nooffscreenonly")
		GUI.Enable (btnDone)
		return
	    elsif mouseIn (730, guessCount * 33 + 10, 790, guessCount * 33 + 32) then
		resultScreen
		return
	    end if
	end loop
    elsif guessCount = chance then
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

% Show player info at the top of the screen
body proc topBar
    drawfillbox (0, 440, maxx, maxy, cLightGreen)
    Font.Draw (player, 10, 454, fontSans12, black)
    G.TextCtr ("SCORE: " + intstr (score), 454, fontSans12, black)
end topBar

% Draw dot at a given position
body proc dot (pos : int, c : int)
    drawfilloval (pos * 92 + 10, 328, 32, 32, c)
    drawoval (pos * 92 + 10, 328, 32, 32, black)
end dot

body proc updateLeaderboard
    for i : 1 .. 3
	if score > top3Scores (i) then
	    for decreasing j : 3 .. i + 1
		top3Scores (j) := top3Scores (j - 1)
		top3Players (j) := top3Players (j - 1)
	    end for
	    top3Scores (i) := score
	    top3Players (i) := player
	    exit
	end if
    end for
end updateLeaderboard

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
    btnBrown := GUI.CreateButtonFull (100, 100, 80, "BROWN", fillDot, 40, chr (0), false)
    btnPurple := GUI.CreateButtonFull (200, 100, 80, "PURPLE", fillDot, 40, chr (0), false)
    btnPink := GUI.CreateButtonFull (300, 100, 80, "PINK", fillDot, 40, chr (0), false)
    btnContinue := GUI.CreateButtonFull (350, 160, 100, "CONTINUE", gameplayScreen, 40, chr (0), false)
    btnExit := GUI.CreateButtonFull (550, 160, 100, "Exit", endingScreen, 40, chr (0), false)
    btnNewGame := GUI.CreateButtonFull (150, 160, 100, "NEW GAME", newGameScreen, 40, chr (0), false)
    btnMusic := GUI.CreateButton (0, 0, 40, "Music ON/OFF", musicOnOff)
    GUI.SetColor (btnMusic, white)
    for btn : btnGiveUp .. btnMusic
	GUI.Hide (btn)
    end for
end initBtn

% Return if mouse is in an area
% Used after buttonwait (direction, x, y, bn, bud)
body fcn mouseIn (x1, y1, x2, y2 : int) : boolean
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
	result true
    end if
    result false
end mouseIn

initBtn
% openingScreen
% instructionScreen
%% FOR TESTING
% newGameScreen
player := "WWWWwwwwMMMMmmmm"
score := 100
countPlayer += 1
gameplayScreen
% top3Scores (1) := 1000
% top3Scores (2) := 300
% top3Scores (3) := -1000
% top3Players (1) := "WWWWmmmm"
% top3Players (2) := "erverv swwdff"
% top3Players (3) := "oaudufh asu"
% player := "WWWWWWWWWWWWWWWW"
% score := 600
% countPlayer := 4
% endingScreen

% Wait for player to click buttons
loop
    %% FOR TESTING
    % mousewhere (x, y, b)
    % locate (1, 1)
    % put x, " ", y, " ", b
    exit when GUI.ProcessEvent
end loop
