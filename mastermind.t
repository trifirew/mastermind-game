/* Betty Zhang, Keisun Wu
 * May 29, 2017
 * Mastermind Game
 */

import GUI, Anim in "Anim.tu", G in "G.tu"
View.Set ("graphics:800;480")
View.Set ("title:Mastermind by Betty & Keisun")
Music.PlayFileLoop ("bgm.wav")

% Types
type Player :
    record
	name : string
	score : int
    end record
type Box :
    record
	x1, y1, x2, y2 : int
    end record
% Dot class
class Dot
    import Box
    export getC,
	drawPattern, drawPatternNoSet,
	getBox

    const ORANGE : int := RGB.AddColor (1, 0.6471, 0)

    var c : int
    var guessC : int := white
    var rectangle : Box
    case Rand.Int (1, 6) of
	label 1 :
	    c := brightred
	label 2 :
	    c := brightblue
	label 3 :
	    c := brightgreen
	label 4 :
	    c := yellow
	label 5 :
	    c := ORANGE
	label 6 :
	    c := black
    end case

    forward proc setBox (x, y, xRadius, yRadius : int)

    function getC : int
	result c
    end getC

    procedure drawPattern (x, y, xRadius, yRadius : int)
	drawfilloval (x, y, xRadius, yRadius, c)
	drawoval (x, y, xRadius, yRadius, black)
	setBox (x, y, xRadius, xRadius)
    end drawPattern

    procedure drawPatternNoSet (x, y, xRadius, yRadius : int)
	drawfilloval (x, y, xRadius, yRadius, c)
	drawoval (x, y, xRadius, yRadius, black)
    end drawPatternNoSet

    function getBox : Box
	result rectangle
    end getBox

    body proc setBox (x, y, xRadius, yRadius : int)
	rectangle.x1 := x - xRadius
	rectangle.y1 := y - yRadius
	rectangle.x2 := x + xRadius
	rectangle.y2 := y + yRadius
    end setBox
end Dot
% Dots
var dots : array 1 .. 4 of pointer to Dot
% Player variables
var player : Player
% Buttons
var btnGiveUp, btnMusic : int
var btnRed, btnBlue, btnGreen, btnYellow, btnBlack, btnOrange : int
var btnContinue, btnExit, btnNewGame : int
% Mouse
var x, y, b, bn, bud : int
% Pictures
var picBoard : int := Pic.FileNew ("Mastermind.jpg")
var picLogo : int := Pic.FileNew ("Mastermind-Logo.jpg")
var picInstruction : int := Pic.FileNew ("instruction.jpg")
var picContinue : int := Pic.FileNew ("continue.gif")
var picThank : int := Pic.FileNew ("thank.jpg")
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
%Counts
var music : int := 0

% Helper procedures
forward proc topBar
forward proc dot (pos : int, c : int)
forward proc initBtn
forward fcn mouseInBox (box : Box) : boolean
forward procedure gameplayScreen

% Show the opening screen
procedure openingScreen
    Pic.Draw (picLogo, 150, 330, picCopy)
    Pic.Draw (picBoard, 250, 80, picCopy)
    G.TextCtr ("Press any key to begin", 50, fontSans12, black)
    locatexy (395, 30)
    var ch : char := getchar
end openingScreen

% Show the instruction screen
procedure instructionScreen
    Pic.Draw (picInstruction, 0, 0, picCopy)
    G.TextCtr ("Instruction", 400, fontSans36, black)
    G.TextCtr ("The computer will randomly choose 4 colours from green, red, blue, yellow, orange and black.", 330, fontSans12, black)
    G.TextCtr ("You guess 4 colours at each turn, the computer then tells you how many you guessed correctly", 300, fontSans12, black)
    G.TextCtr ("The colour and the position must be correct, but it doesn'y tell you which one is correct.", 270, fontSans12, black)
    G.TextCtr ("You have 10 chances total to get the correct pattern.", 240, fontSans12, black)
    G.TextCtr ("Hope you enjoy!", 180, fontSans24, black)
    Pic.Draw (picContinue, 600, 30, picMerge)
    loop
	buttonwait ("down", x, y, bn, bud)
	exit when x >= 600 and x <= 750 and y >= 30 and y <= 100
    end loop
end instructionScreen

% Start a new game, let the player enter their name
procedure newGameScreen
    var inputChar : char
    View.Set ("offscreenonly,nocursor")
    % Record highest score
    % if player.right - player.wrong > highestPlayer.right - highestPlayer.wrong then
    %     highestPlayer := player
    % end if
    % Simulate a curtain closing
    Anim.Cover (cLightGreen, Anim.LEFT + Anim.RIGHT, 5, 15)
    delay (100)
    % Get player name
    G.TextCtr ("Enter your name", 300, fontSans24, black)
    G.TextCtr ("Once you are done, hit ENTER", 270, fontSans16, darkgrey)
    drawfillbox (220, 210, 580, 212, darkgrey)
    View.Update
    player.name := ""
    % Simulate a "get", with input always at the vertical centre
    loop
	locate (1, 1)
	Input.Flush
	inputChar := getchar
	if inputChar = KEY_BACKSPACE and length (player.name) > 0 then
	    player.name := player.name (1 .. * -1)
	    drawfillbox (0, 0, maxx, 209, cLightGreen)
	elsif inputChar not= KEY_BACKSPACE and inputChar not= KEY_ENTER and length (player.name) < 16 then
	    player.name += inputChar
	    drawfillbox (0, 0, maxx, 209, cLightGreen)
	elsif inputChar = KEY_ENTER and length (player.name) > 0 and player.name (1) not= " " and player.name (*) not= " " then
	    exit
	else
	    drawfillbox (220, 210, 580, 212, brightred)
	    View.Update
	    delay (200)
	    drawfillbox (220, 210, 580, 212, darkgrey)
	    drawfillbox (0, 0, maxx, 209, cLightGreen)
	    G.TextCtr ("You should not start or end your name with a space.", 160, fontSans12, brightred)
	    G.TextCtr ("Your name should be 1 - 16 characters.", 180, fontSans12, brightred)
	end if
	drawfillbox (0, 213, maxx, 260, cLightGreen)
	G.TextCtr (player.name, 220, fontMono28, black)
	View.Update
    end loop
    player.score := 0
    % Simulate a curtain opening
    delay (500)
    colorback (white)
    cls
    % GUI.Show (btnGuessLetter)
    % GUI.Show (btnGuessWord)
    % GUI.Show (btnNewGame)
    % GUI.Show (btnExit)
    % showScore
    Anim.Uncover (Anim.HORI_CENTRE, 5, 15)
    View.Set ("nooffscreenonly")
    gameplayScreen
end newGameScreen

% Show the gameplay(main) screen
body procedure gameplayScreen
    cls
    GUI.Hide (btnExit)
    GUI.Hide (btnNewGame)
    GUI.Hide (btnContinue)
    % Draw dots
    for i : 1 .. 4
	new Dot, dots (i)
	dots (i) -> drawPattern (i * 92 + 10, 336, 32, 32)
	%% TODO: Should not draw colour
    end for
    drawline (480, 0, 480, 440, black)
    % Show player info
    topBar
    %% TODO: Done button, previous guess
    GUI.Show (btnGiveUp)
    GUI.Show (btnMusic)
    for btn : btnRed .. btnBlack
	GUI.SetColor (btn, grey)
	GUI.Show (btn)
    end for

    for i : 1 .. 4
	dots (i) -> drawPatternNoSet (i * 20 + 600, 344, 8, 8)
    end for
    Font.Draw ("1", 500, 336, fontSans16, black)
    G.TextRight ("4", 20, 336, fontSans16, black)
    for i : 1 .. 13
	drawline (480, i * 30, maxx, i * 30, black)
    end for

end gameplayScreen

%Show the ending screen
proc endingScreen
    %% TODO: Add highest score
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
    cls
    for btn : btnRed .. btnBlack
	GUI.Hide (btn)
    end for
    GUI.Hide (btnMusic)
    G.TextCtr ("Name: " + player.name + "       " + "Score: " + intstr (player.score), 400, fontSans16, black)
    for i : 1 .. 4
	dots (i) -> drawPattern (i * 100 + 150, 320, 40, 40)
    end for
    GUI.Show (btnExit)
    GUI.Show (btnNewGame)
    GUI.Show (btnContinue)
end resultScreen

% Called when color button is clicked
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
    buttonwait ("down", x, y, bn, bud)
    delay (200)
    % mousewhere (x, y, b)
    % if x >= 70 and x <= 134 and y >= 304 and y <= 368 then
    %     dot (1, dotColor)
    % end if
    for i : 1 .. 4
	if mouseInBox (dots (i) -> getBox) then
	    dot (i, dotColor)
	end if
    end for
    for btn : btnRed .. btnBlack
	GUI.SetColor (btn, grey)
    end for
end fillDot

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
    Font.Draw (player.name, 10, 454, fontSans12, black)
    G.TextCtr ("SCORE: " + intstr (player.score), 454, fontSans12, black)
end topBar

% Draw dot at a given position
body proc dot
    drawfilloval (pos * 92 + 10, 336, 32, 32, c)
    drawoval (pos * 92 + 10, 336, 32, 32, black)
end dot

body proc initBtn
    btnGiveUp := GUI.CreateButton (300, 0, 40, "GIVE UP", resultScreen)
    btnRed := GUI.CreateButtonFull (100, 220, 80, "RED", fillDot, 40, chr (0), false)
    btnBlue := GUI.CreateButtonFull (200, 220, 80, "BLUE", fillDot, 40, chr (0), false)
    btnGreen := GUI.CreateButtonFull (300, 220, 80, "GREEN", fillDot, 40, chr (0), false)
    btnYellow := GUI.CreateButtonFull (100, 160, 80, "YELLOW", fillDot, 40, chr (0), false)
    btnOrange := GUI.CreateButtonFull (200, 160, 80, "ORANGE", fillDot, 40, chr (0), false)
    btnBlack := GUI.CreateButtonFull (300, 160, 80, "BLACK", fillDot, 40, chr (0), false)
    btnContinue := GUI.CreateButtonFull (350, 160, 100, "CONTINUE", gameplayScreen, 40, chr (0), false)
    btnExit := GUI.CreateButtonFull (550, 160, 100, "Exit", endingScreen, 40, chr (0), false)
    btnNewGame := GUI.CreateButtonFull (150, 160, 100, "NEW GAME", newGameScreen, 40, chr (0), false)
    btnMusic := GUI.CreateButton (0, 0, 40, "Music ON/OFF", musicOnOff)
    GUI.SetColor (btnMusic, white)
    GUI.Hide (btnGiveUp)
    GUI.Hide (btnRed)
    GUI.Hide (btnBlue)
    GUI.Hide (btnGreen)
    GUI.Hide (btnYellow)
    GUI.Hide (btnOrange)
    GUI.Hide (btnBlack)
    GUI.Hide (btnExit)
    GUI.Hide (btnNewGame)
    GUI.Hide (btnContinue)
    GUI.Hide (btnMusic)
end initBtn

body fcn mouseInBox (box : Box) : boolean
    if x >= box.x1 and x <= box.x2 and y >= box.y1 and y <= box.y2 then
	result true
    end if
    result false
end mouseInBox

initBtn
openingScreen
instructionScreen
newGameScreen
% player.name := "WWWWwwwwMMMMmmmm"
% player.score := 1000
gameplayScreen

% Wait for player to click buttons
loop
    exit when GUI.ProcessEvent
end loop
