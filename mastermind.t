/* Betty Zhang, Keisun Wu
 * May 29, 2017
 * Mastermind Game
 */

import GUI, Anim in "Anim.tu", G in "G.tu"
View.Set ("graphics:800;480")
View.Set ("title:Mastermind by Betty & Keisun")

% Colours
var cLightGreen : int := RGB.AddColor (0.8, 0.95, 0.75)
% Fonts
var fontSans40 : int := Font.New ("sans serif:40")
var fontSans36 : int := Font.New ("sans serif:36")
var fontSans24 : int := Font.New ("sans serif:24")
var fontSans16 : int := Font.New ("sans serif:16")
var fontSans12 : int := Font.New ("sans serif:12")
var fontMono28 : int := Font.New ("mono:28")
% Player variables
type Player :
    record
	name : string
	score : int
    end record
var player : Player
% Buttons
var btnGiveUp : int

% Helper procedures
forward proc topBar
forward proc dot (pos : int)
forward proc initBtn

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
end newGameScreen

% Show the gameplay(main) screen
procedure gameplayScreen
    % Draw dots
    for i : 1 .. 4
	dot (i)
    end for
    % Show player info
    topBar
    %% TODO: Buttons, previous guess
end gameplayScreen

% Show the result screen
procedure resultScreen
    cls
    put "THIS IS RESULT SCREEN"
    drawbox (150, 300, 650, 400, black)
    drawbox (250, 25, 550, 250, black)
    %% TODO: Result screen
end resultScreen

% Show player info at the top of the screen
body proc topBar
    drawfillbox (0, 440, maxx, maxy, cLightGreen)
    Font.Draw (player.name, 10, 454, fontSans12, black)
    G.TextRight ("SCORE: " + intstr (player.score), 10, 454, fontSans12, black)
end topBar

% Draw dot at a given position
body proc dot
    drawoval (pos * 60, 300, 25, 25, black)
end dot

body proc initBtn
    btnGiveUp := GUI.CreateButton (0, 0, 40, "GIVE UP", resultScreen)
end initBtn

initBtn
% newGameScreen
player.name := "WWWWwwwwMMMMmmmm"
player.score := 1000
gameplayScreen
% put chr (16#AB)+ chr (16#68)

% Wait for player to click buttons
loop
    exit when GUI.ProcessEvent
end loop
