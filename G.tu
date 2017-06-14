/* Keisun Wu
 * 20170529
 * G module
 * Some useful graphics procedures
 */

unit
module G
    export TextCtr, TextRight

    % Draw text at the vertical centre of the screen
    % text : text to display
    % y : y coordinate in pixel
    % font : font of text
    % c : color of text
    proc TextCtr (text : string, y : int, font : int, c : int)
	var textWidth : int := Font.Width (text, font) % Get width of text in pixels
	Font.Draw (text, (maxx - textWidth) div 2, y, font, c)
    end TextCtr

    % Draw text aligned on the right side of the screen
    % text : text to display
    % xFromRight : margin from the right side of the screen
    % y : y coordinate in pixel
    % font : font of text
    % c : color of text
    proc TextRight (text : string, xFromRight : int, y : int, font : int, c : int)
	var textWidth : int := Font.Width (text, font) % Get width of text in pixels
	Font.Draw (text, maxx - textWidth - xFromRight, y, font, c)
    end TextRight
end G
