/* Keisun Wu
 * 20170519
 * Anim module
 * Animation effects
 */

unit
module Anim
    export LEFT, RIGHT, BOTTOM, TOP, HORI_CENTRE, VERT_CENTRE,
	UncoverArea, Uncover, Cover

    const LEFT : int := 1
    const RIGHT : int := 2
    const BOTTOM : int := 4
    const TOP : int := 8
    const HORI_CENTRE : int := 20
    const VERT_CENTRE : int := 21

    % Animation of uncovering an area
    % x1, y1 : bottom-left corner
    % x2, y2 : top-right corner
    % startSide : starting side of the animation
    % px : pixels each move
    % dl : delay between each move
    proc UncoverArea (x1 : int, y1 : int, x2 : int, y2 : int, startSide : int, px : int, dl : int)
	case startSide of
	    label LEFT :
		for i : x1 .. x2 by px
		    View.UpdateArea (i, y1, i + px, y2)
		    delay (dl)
		end for
	    label RIGHT :
		for decreasing i : x2 .. x1 by px
		    View.UpdateArea (i, y1, i - px, y2)
		    delay (dl)
		end for
	    label BOTTOM :
		for i : y1 .. y2 by px
		    View.UpdateArea (x1, i, x2, i + px)
		    delay (dl)
		end for
	    label TOP :
		for decreasing i : y2 .. y1 by px
		    View.UpdateArea (x1, i, x2, i - px)
		    delay (dl)
		end for
	    label LEFT + RIGHT :
		for i : x1 .. x2 div 2 by px
		    View.UpdateArea (i, y1, i + px, y2)
		    View.UpdateArea (x2 - i, y1, x2 - i - px, y2)
		    delay (dl)
		end for
	    label BOTTOM + TOP :
		for i : y1 .. y2 div 2 by px
		    View.UpdateArea (x1, i, x2, i + px)
		    View.UpdateArea (x1, y2 - i, x2, y2 - i - px)
		    delay (dl)
		end for
	    label HORI_CENTRE :
		for i : x1 .. x2 div 2 by px
		    View.UpdateArea (x2 div 2 - i, y1, x2 div 2 + i, y2)
		    delay (dl)
		end for
	    label VERT_CENTRE :
		for i : y1 .. y2 div 2 by px
		    View.UpdateArea (x1, y2 div 2 - i, x2, y2 div 2 + i)
		end for
	    label :
		Error.Halt ("Invalid uncover direction.")
	end case
    end UncoverArea

    % Animation of uncovering the whole screen
    % startSide : starting side of the animation
    % px : pixels each move
    % dl : delay between each move
    proc Uncover (startSide : int, px : int, dl : int)
	UncoverArea (0, 0, maxx, maxy, startSide, px, dl)
    end Uncover

    % Animation of covering the whole screen with a color
    % c : color
    % startSide : starting side of the animation
    % px : pixels each move
    % dl : delay between each move
    proc Cover (c : int, startSide : int, px : int, dl : int)
	drawfillbox (0, 0, maxx, maxy, c)
	Uncover (startSide, px, dl)
    end Cover
end Anim
