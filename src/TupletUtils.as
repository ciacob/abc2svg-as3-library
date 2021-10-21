package {
	import flash.geom.Rectangle;
	
	public class TupletUtils {

		/**
		 * Draws a tuplet bracket and number starting on a given symbol item (note or rest).
		 * @author ciacob
		 */
		public static function drawTuplet (symbol : Object, tupletNumber : int, engine : Abc2Svg) : void {
			
			const DISPLACEMENT_PER_PITCH_STEP : int = 3;
			const HALF_DURATION : int = 512;
			const HORIZONTAL_NEGATIVE_OFFSET : int = -8;
			const HORIZONTAL_POSITIVE_OFFSET : int = 8;
			const NO_STEM_DISPLACEMENT : int = 6;
			const MIDDLE_STAFF_PITCH : int = 20;
			const SHORT_REST_HEIGHT : int = 8;
			const STEM_OFFSET_ABOVE : int = 4;
			const STEM_OFFSET_BELOW : int = 6;
			const TALL_REST_HEIGHT : int = 12;
			
			var bracketTop : Number;
			var rawPitch : int;
			var yDisplacement : int;
			var hasUpStem : Boolean;
			var hasDownStem : Boolean;
			var nextNote : Object;
			var haveSubsequentTupletNote : Boolean;
			
			// Bracket direction. This will follow the direction of the first note stem, if any,
			// or defaut to "above" for first voice and "below" for second voice (if the note has
			// no stem or is a rest).
			var bracketDirection : Number = (symbol.stem == 1)?
				C.SL_ABOVE : (symbol.stem == -1)?
					C.SL_BELOW : (symbol.multi >= 0)?
						C.SL_ABOVE : C.SL_BELOW;
			
			var currStaffBounds : Rectangle = engine.stavesBounds[symbol.st] as Rectangle;
			var currStaffBottom : Number = currStaffBounds.bottom;
			var referenceY : Number = (currStaffBottom + 57);
			var bracketAboveStaff : Boolean = (bracketDirection == C.SL_ABOVE);
			var highestYDisplacement : int = int.MIN_VALUE;
			var lowestYDisplacement : int = int.MAX_VALUE;
			var tmpNote : Object = symbol;
			var leftLimit : int = int.MAX_VALUE;
			var rightLimit : int = int.MIN_VALUE;
			
			while (tmpNote) {
				rawPitch = MIDDLE_STAFF_PITCH;
				if (tmpNote.type == C.NOTE) {
					rawPitch = ((tmpNote.notes[0].pit) as int);
				}
				yDisplacement = (rawPitch * DISPLACEMENT_PER_PITCH_STEP);
				
				if (tmpNote.x < leftLimit) {
					leftLimit = tmpNote.x; 
				}
				if (tmpNote.x > rightLimit) {
					rightLimit = tmpNote.x;
				}
				
				if (bracketAboveStaff) {
					hasUpStem = (tmpNote.stem == 1);
					yDisplacement += hasUpStem? (tmpNote.ys - tmpNote.y) + STEM_OFFSET_ABOVE : NO_STEM_DISPLACEMENT;
					if (tmpNote.type == C.REST) {
						yDisplacement += (tmpNote.dur < HALF_DURATION)? TALL_REST_HEIGHT : SHORT_REST_HEIGHT;
					}
					if (yDisplacement > highestYDisplacement) {
						highestYDisplacement = yDisplacement;
					}
				} else {
					hasDownStem = (tmpNote.stem == -1);
					yDisplacement -= hasDownStem? (tmpNote.y - tmpNote.ys) + STEM_OFFSET_BELOW : NO_STEM_DISPLACEMENT;
					if (tmpNote.type == C.REST) {
						yDisplacement -= (tmpNote.dur < HALF_DURATION)? TALL_REST_HEIGHT : SHORT_REST_HEIGHT;
					}
					if (yDisplacement < lowestYDisplacement) {
						lowestYDisplacement = yDisplacement;
					}
				}
				if (tmpNote == symbol) {
					tmpNote = tmpNote.next;
					continue;
				}
				nextNote = tmpNote.next;
				if (!nextNote) {
					break;
				}
				haveSubsequentTupletNote = (
					(nextNote.type == C.NOTE || nextNote.type == C.REST) &&
					nextNote.in_tuplet &&
					(!('tp0' in nextNote))
				);
				if (haveSubsequentTupletNote) {
					tmpNote = nextNote;
				} else {
					break;
				}
			}
			
			var tupletYDisplacement : Number = (bracketAboveStaff? highestYDisplacement : lowestYDisplacement);
			bracketTop = engine.sy(referenceY - tupletYDisplacement);
			if (bracketAboveStaff) {
				rightLimit += HORIZONTAL_POSITIVE_OFFSET;
			} else {
				leftLimit += HORIZONTAL_NEGATIVE_OFFSET;
			}
			
			// Actually draw the bracket
			engine.out_tubrn (
				leftLimit,
				bracketTop,
				rightLimit - leftLimit,
				0,
				bracketDirection == C.SL_ABOVE,
				tupletNumber.toString()
			);
		}
	}
}