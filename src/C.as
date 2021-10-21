package {
	
	/**
	 * Constants ported from the C implementation
	 */
	public class C {
		public function C() {};
		
		public static const BLEN : int = 1536;
		
		// symbol types
		public static const BAR : int = 0;
		public static const CLEF : int = 1;
		public static const CUSTOS : int = 2;
		public static const GRACE : int = 4;
		public static const KEY : int = 5;
		public static const METER : int = 6;
		public static const MREST : int = 7;
		public static const NOTE : int = 8;
		public static const PART : int = 9;
		public static const REST : int = 10;
		public static const SPACE : int = 11;
		public static const STAVES : int = 12;
		public static const STBRK : int = 13;
		public static const TEMPO : int = 14;
		public static const BLOCK : int = 16;
		public static const REMARK : int = 17;
		
		// note heads
		public static const FULL : int = 0;
		public static const EMPTY : int = 1;
		public static const OVAL : int = 2;
		public static const OVALBARS : int = 3;
		public static const SQUARE : int = 4;
		
		// slur/tie types (3 + 1 bits)
		public static const SL_ABOVE : int = 0x01;
		public static const SL_BELOW : int = 0x02;
		public static const SL_AUTO : int = 0x03;
		public static const SL_HIDDEN : int = 0x04;
		public static const SL_DOTTED : int = 0x08; // (modifier bit)
	}
}