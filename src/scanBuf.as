package {
	public class scanBuf {
		public function scanBuf() {}
		
		public var index : int = 0;
		public var buffer : String;
		
		public function char () : String {
			return buffer.charAt(index) as String;
		}
		
		public function next_char () : String {
			return buffer.charAt(++index);
		}
		
		public function get_int () : int {
			var	val : int = 0;
			var c : String = buffer.charAt(index);
			while (c >= '0' && c <= '9') {
				val = val * 10 + parseInt(c);
				c = buffer.charAt(++index);
			}
			return val;
		}
	}
}