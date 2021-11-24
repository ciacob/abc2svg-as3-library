package {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ro.ciacob.utils.Strings;
	import ro.ciacob.utils.constants.CommonStrings;

	public class Abc2Svg  {
		
		internal var ENGINE : Abc2Svg;
		
		private static const DEBUG : Object = {
			recursionLimit : NaN,
			recursionCounter : 0
		};
		
		private var user : Object;
		
		// Storage for deffered operations. Accepts Array items, where the first item in the nested
		// Array is the function to call, and the rest are arguments to that function.
		private var _deferredOperations : Array = [];
		
		// Storage for rectangles representing the space occupied on screen by every staff. They are 
		// indexed the same as inside `staff_tb`.
		internal var stavesBounds : Array = [];
		
		
		public function Abc2Svg (user : Object = null) {
			ENGINE = this;
			this.user = user || {};
			
			// initialize
			font_init();
			init_tune();
			
			this.anno_start = user.anno_start ? a_start : empty_function;
			this.anno_stop = user.anno_stop ? a_stop : empty_function;
		}

		private const SVG_DEF_BODY : String = '<path id="brace" class="fill" d="M4.93,49.85v-0.19c3.399-1.539,5.11-4.459,5.11-8.76c0-3.47-1.131-8.279-3.371-14.449c-1.16-3.66-1.729-7.16-1.729-10.5 c0-6.551,2.79-11.69,8.38-15.41c-4.041,3.21-6.07,7.22-6.07,12.039c0,2.181,0.67,5.101,2.021,8.771 c2.38,6.229,3.56,11.81,3.56,16.761c0,6.229-2.471,10.109-7.42,11.649c4.94,1.54,7.42,5.591,7.42,12.14 c0,4.881-1.188,10.4-3.56,16.57c-1.351,3.66-2.021,6.68-2.021,9.051c0,4.75,2.021,8.729,6.07,11.939 c-5.59-3.72-8.38-8.859-8.38-15.41c0-3.34,0.58-6.84,1.729-10.5c2.25-6.17,3.371-10.979,3.371-14.449 C10.041,54.47,8.34,51.391,4.93,49.85z"/>\
			<path id="utclef" class="fill" d="m-50 -90 c-72 -41 -72 -158 52 -188 150 -10 220 188 90 256 -114 52 -275 0 -293 -136 -15 -181 93 -229 220 -334 88 -87 79 -133 62 -210 -51 33 -94 105 -89 186 17 267 36 374 49 574 6 96 -19 134 -77 135 -80 1 -126 -93 -61 -133 85 -41 133 101 31 105 23 17 92 37 90 -92 -10 -223 -39 -342 -50 -617 0 -90 0 -162 96 -232 56 72 63 230 22 289 -74 106 -257 168 -255 316 9 153 148 185 252 133 86 -65 29 -192 -80 -176 -71 12 -105 67 -59 124"/>\
			<use id="tclef" transform="translate(0,6) scale(0.045)" xlink:href="#utclef"/>\
			<use id="stclef" transform="translate(0,5.4) scale(0.037)" xlink:href="#utclef"/>\
			<path id="ubclef" class="fill" d="m-200 -87 c124 -35 222 -78 254 -236 43 -228 -167 -246 -192 -103 59 -80 157 22 92 78 -62 47 -115 -22 -106 -88 21 -141 270 -136 274 52 -1 175 -106 264 -322 297 m357 -250 c0 -36 51 -34 51 0 0 37 -51 36 -51 0 m-2 -129 c0 -36 51 -34 51 0 0 38 -51 37 -51 0"/>\
			<use id="bclef" transform="translate(0,18) scale(0.045)" xlink:href="#ubclef"/>\
			<use id="sbclef" transform="translate(0,14.5) scale(0.037)" xlink:href="#ubclef"/>\
			<path id="ucclef" class="fill" d=" m-51 -264 v262 h-13 v-529 h13 v256 c25 -20 41 -36 63 -109 14 31 13 51 56 70 90 34 96 -266 -41 -185 52 19 27 80 -11 77 -90 -38 33 -176 139 -69 72 79 1 241 -134 186 l-16 39 16 38 c135 -55 206 107 134 186 -106 108 -229 -31 -139 -69 38 -3 63 58 11 77 137 81 131 -219 41 -185 -43 19 -45 30 -56 64 -22 -73 -38 -89 -63 -109 m-99 -267 h57 v529 h-57 v-529"/>\
			<use id="cclef" transform="translate(0,12) scale(0.045)" xlink:href="#ucclef"/>\
			<use id="scclef" transform="translate(0,9.5) scale(0.037)" xlink:href="#ucclef"/>\
			<path id="pclef" d="m-2.7 9h5.4v-18h-5.4v18" class="stroke" stroke-width="1.4"/>\
			<g id="oct" transform="translate(-2,-10) scale(0.07)"><path d="M41.86,51.55c12.21,8.96,18.32,16.42,18.32,22.39c0,4.621-1.36,8.75-4.07,12.42c-2.71,3.66-6.38,5.5-10.99,5.5 c-4.34,0-8.35-2.039-12.01-6.109s-5.5-8.82-5.5-14.25C27.61,63.63,32.36,56.98,41.86,51.55z M59.36,10.43 c4.07,0,7.399,1.36,9.97,4.07c2.58,2.71,3.87,6.11,3.87,10.18c0,8.96-4.75,14.93-14.25,17.92c-8.69-6.79-13.03-13.3-13.03-19.54 c0-3.8,1.29-6.85,3.87-9.16C52.37,11.58,55.56,10.43,59.36,10.43z M45.93,100c10.31,0,19-2.58,26.06-7.74S82.58,80.18,82.58,71.5 c0-7.33-5.43-15.34-16.29-24.02C82.58,43.14,90.72,36.21,90.72,26.71c0-7.6-3.66-13.57-10.99-17.92S63.85,2.28,54.08,2.28 c-8.14,0-14.93,2.31-20.359,6.92c-5.431,4.61-8.141,10.45-8.141,17.51c0,4.34,0.811,7.8,2.44,10.38s4.75,5.9,9.359,9.98 c-9.229,2.99-16.22,6.241-20.97,9.77c-4.75,3.53-7.13,8.42-7.13,14.66c0,8.141,3.6,14.93,10.79,20.359 C27.27,97.29,35.88,100,45.93,100z"/></g>\
			<ellipse id="hd" rx="4.1" ry="2.9" transform="rotate(-20)" class="fill"/>\
			<path id="Hd" class="fill" d="m3 -1.6 c-1 -1.8 -7 1.4 -6 3.2 1 1.8 7 -1.4 6 -3.2 m0.5 -0.3 c2 3.8 -5 7.6 -7 3.8 -2 -3.8 5 -7.6 7 -3.8"/>\
			<path id="HD" class="fill" d="m-2.7 -1.4 c1.5 -2.8 6.9 0 5.3 2.7 -1.5 2.8 -6.9 0 -5.3 -2.7 m8.3 1.4 c0 -1.5 -2.2 -3 -5.6 -3 -3.4 0 -5.6 1.5 -5.6 3 0 1.5 2.2 3 5.6 3 3.4 0 5.6 -1.5 5.6 -3"/>\
			<g id="HDD"> <use xlink:href="#HD"/> <path d="m-6 -4v8m12 0v-8" class="stroke"/> </g>\
			<g id="breve" class="stroke"> <path d="m-6 -2.7h12m0 5.4h-12" stroke-width="2.5"/> <path d="m-6 -5v10m12 0v-10"/> </g>\
			<g id="longa" class="stroke"> <path d="m-6 2.7h12m0 -5.4h-12" stroke-width="2.5"/> <path d="m-6 5v-10m12 0v16"/> </g>\
			<path id="ghd" class="fill" d="m2.2 -1.5 c-1.32 -2.31 -5.94 0.33 -4.62 2.64 1.32 2.31 5.94 -0.33 4.62 -2.64"/>\
			<rect id="r00" class="fill" x="-1.6" y="-6" width="3" height="12"/>\
			<rect id="r0" class="fill" x="-1.6" y="-6" width="3" height="6"/>\
			<rect id="r1" class="fill" x="-3.5" y="-6" width="7" height="3"/>\
			<rect id="r2" class="fill" x="-3.5" y="-3" width="7" height="3"/>\
			<path id="r4" class="fill" d="m-1 -8.5 l3.6 5.1 -2.1 5.2 2.2 4.3 c-2.6 -2.3 -5.1 0 -2.4 2.6 -4.8 -3 -1.5 -6.9 1.4 -4.1 l-3.1 -4.5 1.9 -5.1 -1.5 -3.5"/>\
			<path id="r8e" class="fill" d="m 0 0 c-1.5 1.5 -2.4 2 -3.6 2 2.4 -2.8 -2.8 -4 -2.8 -1.2 c0 2.7 4.3 2.4 5.9 0.6"/>\
			<g id="r8"> <path d="m3.3 -4l-3.4 9.6" class="stroke"/> <use x="3.4" y="-4" xlink:href="#r8e"/> </g>\
			<g id="r16"> <path d="m3.3 -4l-4 15.6" class="stroke"/> <use x="3.4" y="-4" xlink:href="#r8e"/> <use x="1.9" y="2" xlink:href="#r8e"/> </g>\
			<g id="r32"> <path d="m4.8 -10l-5.5 21.6" class="stroke"/> <use x="4.9" y="-10" xlink:href="#r8e"/> <use x="3.4" y="-4" xlink:href="#r8e"/> <use x="1.9" y="2" xlink:href="#r8e"/> </g>\
			<g id="r64"> <path d="m4.8 -10 l-7 27.6" class="stroke"/> <use x="4.9" y="-10" xlink:href="#r8e"/> <use x="3.4" y="-4" xlink:href="#r8e"/> <use x="1.9" y="2" xlink:href="#r8e"/> <use x="0.4" y="8" xlink:href="#r8e"/> </g>\
			<g id="r128"> <path d="m5.8 -16 l-8.5 33.6" class="stroke"/> <use x="5.9" y="-16" xlink:href="#r8e"/> <use x="4.4" y="-10" xlink:href="#r8e"/> <use x="2.9" y="-4" xlink:href="#r8e"/> <use x="1.4" y="2" xlink:href="#r8e"/> <use x="0.1" y="8" xlink:href="#r8e"/> </g>\
			<g id="mrest" class="stroke"> <path d="m-20 6v-12m40 0v12"/> <path d="m-20 0h40" stroke-width="5"/> </g>\
			<path id="usharp" class="fill" d=" m136 -702 v890 h32 v-890 m128 840 h32 v-888 h-32 m-232 286 v116 l338 -96 v-116 m-338 442 v116 l338 -98 v-114"/>\
			<path id="uflat" class="fill" d=" m100 -746 h32 v734 l-32 4 m32 -332 c46 -72 152 -90 208 -20 100 110 -120 326 -208 348 m0 -28 c54 0 200 -206 130 -290 -50 -60 -130 -4 -130 34"/>\
			<path id="unat" class="fill" d=" m96 -750 h-32 v716 l32 -8 182 -54 v282 h32 v-706 l-34 10 -180 50 v-290 m0 592 v-190 l182 -52 v188"/>\
			<path id="udblesharp" class="fill" d=" m240 -282 c40 -38 74 -68 158 -68 v-96 h-96 c0 84 -30 118 -68 156 -40 -38 -70 -72 -70 -156 h-96 v96 c86 0 120 30 158 68 -38 38 -72 68 -158 68 v96 h96 c0 -84 30 -118 70 -156 38 38 68 72 68 156 h96 v-96 c-84 0 -118 -30 -158 -68"/>\
			<path id="udbleflat" class="fill" d=" m20 -746 h24 v734 l-24 4 m24 -332 c34 -72 114 -90 156 -20 75 110 -98 326 -156 348 m0 -28 c40 0 150 -206 97 -290 -37 -60 -97 -4 -97 34 m226 -450 h24 v734 l-24 4 m24 -332 c34 -72 114 -90 156 -20 75 110 -98 326 -156 348 m0 -28 c40 0 150 -206 97 -290 -37 -60 -97 -4 -97 34"/>\
			<use id="sh0" transform="translate(-4,5) scale(0.018)" xlink:href="#usharp"/>\
			<use id="ft0" transform="translate(-3.5,3.5) scale(0.018)" xlink:href="#uflat"/>\
			<use id="nt0" transform="translate(-3,5) scale(0.018)" xlink:href="#unat"/>\
			<use id="dsh0" transform="translate(-4,5) scale(0.018)" xlink:href="#udblesharp"/>\
			<use id="dft0" transform="translate(-4,3.5) scale(0.018)" xlink:href="#udbleflat"/>\
			<g id="sh1"> <path d="M0 7.8v-15.4" class="stroke"/> <path class="fill" d="M-1.8 2.7l3.6 -1.1v2.2l-3.6 1.1v-2.2z M-1.8 -3.7l3.6 -1.1v2.2l-3.6 1.1v-2.2"/> </g>\
			<g id="sh513"> <path d="M-2.5 8.7v-15.4M0 7.8v-15.4M2.5 6.9v-15.4" class="stroke"/> <path class="fill" d="M-3.7 3.1l7.4 -2.2v2.2l-7.4 2.2v-2.2z M-3.7 -3.2l7.4 -2.2v2.2l-7.4 2.2v-2.2"/> </g>\
			<g id="ft1" transform="scale(-1,1)"> <use xlink:href="#ft0"/> </g>\
			<g id="ft513"> <path class="fill" d="M0.6 -2.7 c-5.7 -3.1 -5.7 3.6 0 6.7c-3.9 -4 -4 -7.6 0 -5.8 M1 -2.7c5.7 -3.1 5.7 3.6 0 6.7c3.9 -4 4 -7.6 0 -5.8"/> <path d="M1.6 3.5v-13M0 3.5v-13" class="stroke" stroke-width=".6"/> </g>\
			<g id="pshhd"> <use xlink:href="#dsh0"/> </g>\
			<g id="pfthd"> <use xlink:href="#dsh0"/> <circle r="4" class="stroke"/> </g>\
			<path id="csig" class="fill" d=" m6 -5.3 c0.9 0 2.3 0.7 2.4 2.2 -1.2 -2 -3.6 0.1 -1.6 1.7 2 1 3.8 -3.5 -0.8 -4.7 -2 -0.4 -6.4 1.3 -5.8 7 0.4 6.4 7.9 6.8 9.1 0.7 -2.3 5.6 -6.7 5.1 -6.8 0 -0.5 -4.4 0.7 -7.5 3.5 -6.9"/>\
			<g id="ctsig"> <use xlink:href="#csig"/> <path d="m5 8v-16" class="stroke"/> </g>\
			<path id="pmsig" class="stroke" stroke-width=".8" d="M0 -7a5 5 0 0 1 0 -10a5 5 0 0 1 0 10"/>\
			<g id="pMsig"> <use xlink:href="#pmsig"/> <path class="fill" d="M0 -10a2 2 0 0 1 0 -4a2 2 0 0 1 0 4"/> </g>\
			<path id="imsig" class="stroke" stroke-width=".8" d="M3 -8a5 5 0 1 1 0 -8"/>\
			<g id="iMsig"> <use xlink:href="#imsig"/> <path class="fill" d="M0 -10a2 2 0 0 1 0 -4a2 2 0 0 1 0 4"/> </g>\
			<path id="hl" class="stroke" d="m-6 0h12"/>\
			<path id="hl1" class="stroke" d="m-7 0h14"/>\
			<path id="hl2" class="stroke" d="m-9 0h18"/>\
			<path id="ghl" class="stroke" d="m-3.5 0h7"/>\
			<g id="rdots" class="fill"> <circle cx="0" cy="-9" r="1.2"/> <circle cx="0" cy="-15" r="1.2"/> </g>\
			<circle id="dot" class="fill" cx="0" cy="-0.5" r="1.2"/>\
			<path id="srep" class="fill" d="M-1 6l11 -12h3l-11 12h-3"/>\
			<path id="mrep" class="fill" d="M-5 -4.5a1.5 1.5 0 0 1 0 3a1.5 1.5 0 0 1 0 -3 M4.5 2a1.5 1.5 0 0 1 0 3a1.5 1.5 0 0 1 0 -3 M-7 6l11 -12h3l-11 12h-3"/>\
			<g id="mrep2" class="fill"> <path d="M-5.5 -7.5a1.5 1.5 0 0 1 0 3a1.5 1.5 0 0 1 0 -3 M5 4.5a1.5 1.5 0 0 1 0 3a1.5 1.5 0 0 1 0 -3"/> <path d="M-7 8l14 -10m-14 4l14 -10" class="stroke" stroke-width="1.8"/> </g>\
			<g id="accent" class="stroke" stroke-width="1.2"> <path d="m-4 0l8 -2l-8 -2"/> </g>\
			<path id="umrd" class="fill" d="m0 -4 l2.2 -2.2 2.1 2.9 0.7 -0.7 0.2 0.2 -2.2 2.2 -2.1 -2.9 -0.7 0.7 -2.2 2.2 -2.1 -2.9 -0.7 0.7 -0.2 -0.2 2.2 -2.2 2.1 2.9 0.7 -0.7"/>\
			<g id="lmrd"> <use xlink:href="#umrd"/> <line x1="0" y1="0" x2="0" y2="-8" class="stroke" stroke-width=".6"/> </g>\
			<path id="grm" class="fill" d=" m-5 -2.5 c5 -8.5 5.5 4.5 10 -2 -5 8.5 -5.5 -4.5 -10 2"/>\
			<circle id="stc" class="fill" cx="0" cy="-3" r="1.2"/>\
			<path id="sld" class="fill" d=" m-7.2 4.8 c1.8 0.7 4.5 -0.2 7.2 -4.8 -2.1 5 -5.4 6.8 -7.6 6"/>\
			<path id="emb" d="m-2.5 -3h5" class="stroke" stroke-width="1.2" stroke-linecap="round"/>\
			<g id="hld" class="fill"> <circle cx="0" cy="-3" r="1.3"/> <path d="m-7.5 -1.5 c0 -11.5 15 -11.5 15 0 h-0.25 c-1.25 -9 -13.25 -9 -14.5 0"/> </g>\
			<path id="cpu" class="fill" d=" m-6 0 c0.4 -7.3 11.3 -7.3 11.7 0 c-1.3 -6 -10.4 -6 -11.7 0"/>\
			<path id="upb" class="stroke" d=" m-2.6 -9.4 l2.6 8.8 2.6 -8.8"/>\
			<g id="dnb"> <path d="M-3.2 -2v-7.2m6.4 0v7.2" class="stroke"/> <path d="M-3.2 -6.8v-2.4l6.4 0v2.4" class="fill"/> </g>\
			<g id="sgno"> <path class="fill" d="m0 -3 c1.5 1.7 6.4 -0.3 3 -3.7 -10.4 -7.8 -8 -10.6 -6.5 -11.9 4 -1.9 5.9 1.7 4.2 2.6 -1.3 0.7 -2.9 -1.3 -0.7 -2 -1.5 -1.7 -6.4 0.3 -3 3.7 10.4 7.8 8 10.6 6.5 11.9 -4 1.9 -5.9 -1.7 -4.2 -2.6 1.3 -0.7 2.9 1.3 0.7 2"/> <line x1="-6" y1="-4.2" x2="6.6" y2="-16.8" class="stroke"/> <circle cx="-6" cy="-10" r="1.2"/> <circle cx="6" cy="-11" r="1.2"/> </g>\
			<g id="coda" class="stroke"> <path d="m0 -2v-20m-10 10h20"/> <circle cx="0" cy="-12" r="6" stroke-width="1.7"/> </g>\
			<path id="dplus" class="stroke" stroke-width="1.7" d="m0 -0.5v-6m-3 3h6"/>\
			<path id="lphr" class="stroke" stroke-width="1.2" d="m0 0v18"/>\
			<path id="mphr" class="stroke" stroke-width="1.2" d="m0 0v12"/>\
			<path id="sphr" class="stroke" stroke-width="1.2" d="m0 0v6"/>\
			<circle id="opend" class="stroke" cx="0" cy="-3" r="2.5"/>\
			<path id="snap" class="stroke" d="M-3 -6 c0 -5 6 -5 6 0 c0 5 -6 5 -6 0 M0 -5v6"/>\
			<path id="thumb" class="stroke" d="M-2.5 -7 c0 -6 5 -6 5 0 c0 6 -5 6 -5 0 M-2.5 -9v4"/>\
			<path id="turn" class="fill" d=" m5.2 -8 c1.4 0.5 0.9 4.8 -2.2 2.8 l-4.8 -3.5 c-3 -2 -5.8 1.8 -3.6 4.4 1 1.1 2 0.8 2.1 -0.1 0.1 -0.9 -0.7 -1.2 -1.9 -0.6 -1.4 -0.5 -0.9 -4.8 2.2 -2.8 l4.8 3.5 c3 2 5.8 -1.8 3.6 -4.4 -1 -1.1 -2 -0.8 -2.1 0.1 -0.1 0.9 0.7 1.2 1.9 0.6"/>\
			<g id="turnx"> <use xlink:href="#turn"/> <path d="M0 -1.5v-9" class="stroke"/> </g>\
			<path id="wedge" class="fill" d="M0 -1l-1.5 -5h3l-1.5 5"/>\
			<path id="ltr" class="fill" d="m0 -0.4c2 -1.5 3.4 -1.9 3.9 0.4 c0.2 0.8 0.7 0.7 2.1 -0.4 v0.8c-2 1.5 -3.4 1.9 -3.9 -0.4 c-0.2 -0.8 -0.7 -0.7 -2.1 0.4z"/>\
			<g id="custos"> <path d="M-4 0l2 2.5l2 -2.5l2 2.5l2 -2.5 l-2 -2.5l-2 2.5l-2 -2.5l-2 2.5" class="fill"/> <path d="M3.5 0l5 -7" class="stroke"/> </g>\
			<circle id="showerror" r="30" stroke="#ffc0c0" stroke-width="2.5" fill="none"/>\
			<path id="meter0" d="M30.046,49.995c0,12.791,1.37,23.108,4.109,30.938c2.74,7.83,6.4,11.75,10.96,11.75c4.439,0,8.06-3.949,10.869-11.85 	c2.811-7.9,4.211-18.181,4.211-30.841c0-13.18-1.271-23.59-3.82-31.229c-2.541-7.64-6.301-11.45-11.259-11.45 	c-4.83,0-8.55,3.85-11.16,11.551C31.356,26.565,30.046,36.946,30.046,49.995z M3.026,49.415c0-13.449,4.08-24.869,12.24-34.27 	c8.158-9.401,18.108-14.1,29.858-14.1s21.699,4.73,29.859,14.199c8.16,9.461,12.24,21.051,12.24,34.75 	c0,13.711-4.08,25.291-12.24,34.761c-8.16,9.46-18.109,14.2-29.859,14.2s-21.7-4.762-29.858-14.29 	C7.106,75.126,3.026,63.376,3.026,49.415z"/>\
			<path id="meter1" d="M1.062,50L20.976,0.216h24.891v89.611l12.945,5.975v3.982H11.019v-3.982l12.943-5.975v-59.74L1.062,50z"/>\
			<path id="meter2" d="M39.731,0.95c26.15,0,39.229,8.24,39.229,24.72c0,3.399-0.329,6.021-0.979,7.851c-1.699,4.319-4.319,7.979-7.85,10.979 c-3.53,3.01-7.391,5.46-11.57,7.359s-9.91,5.07-17.16,9.511c-7.25,4.438-14.42,9.608-21.479,15.5c2.479-1.57,5.82-2.351,10-2.351 c3.53,0,8.57,1.141,15.101,3.431c6.54,2.29,11.641,3.43,15.3,3.43c3.141,0,6.671-0.92,10.591-2.75c0.649-0.39,1.5-1.01,2.55-1.86 c1.051-0.85,1.96-1.629,2.75-2.35c0.78-0.72,1.24-1.08,1.37-1.08c-0.13,0.65-0.359,1.7-0.689,3.141L75.913,80.8 c0,0-0.229,0.921-0.689,2.75c-0.92,5.36-2.42,8.96-4.511,10.79c-3.399,3.141-7.779,4.71-13.14,4.71c-3.4,0-8.891-1.28-16.479-3.829 c-7.591-2.551-12.751-3.83-15.501-3.83c-4.05,0-8.89,1.239-14.52,3.729c-5.62,2.479-8.57,3.729-8.83,3.729 c-0.92,0-1.37-1.051-1.37-3.141c0-0.13-0.07-0.33-0.2-0.59c0.26-4.32,1.83-8.73,4.71-13.24s6.34-8.6,10.4-12.26 c4.05-3.66,8.398-7.45,13.04-11.381c4.64-3.92,8.93-7.521,12.85-10.789c3.921-3.271,7.189-6.73,9.811-10.4 c2.62-3.66,3.92-7.061,3.92-10.2c0-12.819-5.43-19.29-16.279-19.42c-10.2,0-17,3.47-20.4,10.4c3.66,0,6.83,1.21,9.511,3.63 s4.021,5.59,4.021,9.51c0,4.051-1.8,7.42-5.39,10.1c-3.602,2.681-7.36,4.021-11.28,4.021c-9.94,0-14.91-6.74-14.91-20.2 c0-5.23,1.96-9.71,5.88-13.439c3.92-3.73,8.761-6.41,14.521-8.041C26.851,1.771,33.061,0.95,39.731,0.95z"/>\
			<path id="meter3" d="M20.875,16.42c3.56,0,6.45,0.92,8.689,2.771c2.239,1.84,3.359,4.279,3.359,7.31c0,3.55-1.28,6.479-3.85,8.79 c-2.57,2.3-6.021,3.46-10.37,3.46c-3.551,0-6.98-1.421-10.271-4.25c-3.29-2.83-4.938-6.55-4.938-11.16 c0-6.19,2.04-10.99,6.119-14.42c6.711-5.53,15.931-8.29,27.649-8.29c9.22,0,16.332,1.25,21.332,3.75 c8.949,4.48,13.43,11.449,13.43,20.93c0,6.061-2.301,11.32-6.909,15.801c-4.611,4.479-10.931,7.439-18.962,8.89 c8.16,1.45,14.91,4.439,20.24,8.99c5.33,4.539,8,9.779,8,15.699c0,8.82-4.938,15.801-14.811,20.931 c-4.738,2.5-12.181,3.75-22.32,3.75c-5.13,0-10.569-0.722-16.29-2.17c-5.729-1.45-10.17-3.49-13.33-6.12 c-4.608-3.82-6.909-8.23-6.909-13.23s1.649-9.02,4.939-12.049c3.29-3.031,7.04-4.541,11.26-4.541c4.48,0,8.102,1.09,10.86,3.26 c2.759,2.171,4.149,5.041,4.149,8.591c0,3.29-1.221,5.92-3.649,7.899c-2.44,1.971-5.431,2.961-8.99,2.961 c1.58,5.399,6.521,8.1,14.811,8.1c4.741,0,8.521-1.609,11.36-4.84c2.84-3.229,4.25-7.41,4.25-12.54c0-5-2.369-9.41-7.108-13.229 c-4.741-3.82-10.142-6.25-16.191-7.311c-2.899-0.529-4.34-1.91-4.34-4.15c0-2.239,1.45-3.619,4.34-4.149 c6.189-1.19,11.75-3.59,16.691-7.21c4.938-3.62,7.409-8.061,7.409-13.33s-1.352-9.48-4.051-12.64c-2.699-3.16-6.42-4.74-11.16-4.74 C27.394,7.93,22.594,10.76,20.875,16.42z"/>\
			<path id="meter4" d="M74.019,90.166l9.608,7.879H45.199l9.611-7.879v-9.42H11.57v-7.691c18.83-31,28.25-54.7,28.25-71.1h31.32l-50.151,71.1 H54.81L55,44.236L74.02,16.375v56.689h14.41v7.691H74.02L74.019,90.166L74.019,90.166z"/>\
			<path id="meter5" d="M5.675,68.8c3.681-4.2,7.681-6.3,12.011-6.3c3.54,0,6.699,1.05,9.449,3.148c2.761,2.102,4.131,4.66,4.131,7.682 c0,3.68-1.051,6.561-3.149,8.66c-2.101,2.1-4.99,3.148-8.66,3.148c3.41,4.33,7.479,6.5,12.21,6.5c6.431,0,11.489-1.97,15.159-5.91 c2.49-2.629,4.041-4.959,4.631-6.988c0.59-2.03,0.892-5.15,0.892-9.352c0-7.479-1.972-13.06-5.91-16.74 c-3.681-3.409-8.141-5.119-13.391-5.119c-10.239,0-20.08,3.479-29.54,10.439l1.971-57.1h69.71c-1.441,4.729-3.91,8.99-7.381,12.8 c-3.47,3.81-7.65,5.71-12.5,5.71h-41.94l-1.18,23.83c7.479-3.94,15.561-5.91,24.22-5.91c10.89,0,19.56,2.029,25.99,6.1 c4.33,2.76,7.91,6.271,10.729,10.541c2.82,4.271,4.23,8.83,4.23,13.681c0,10.37-4.4,18.64-13.191,24.81 c-2.889,2.1-6.43,3.67-10.629,4.73c-4.199,1.05-7.711,1.64-10.541,1.77c-2.819,0.131-6.659,0.2-11.519,0.2 c-7.88,0-14.641-1.312-20.28-3.94c-2.1-1.18-4.13-3.409-6.1-6.698c-1.971-3.28-2.95-6.101-2.95-8.472 C2.135,75.43,3.315,71.689,5.675,68.8z"/>\
			<path id="meter6" d="M51.452,90.652c5.291,0,9.39-2.228,12.293-6.678c2.903-4.453,4.355-9.521,4.355-15.197c0-4.389-1.355-8.131-4.065-11.229 c-2.71-3.098-6.646-4.646-11.809-4.646c-5.68,0-11.615,2.389-17.811,7.162C35.319,80.457,40.999,90.652,51.452,90.652z M78.553,10.315c3.483,3.355,5.228,7.485,5.228,12.389c0,3.228-1.13,6.131-3.388,8.713c-2.26,2.58-4.938,3.871-8.034,3.871 c-3.872,0-6.904-0.967-9.1-2.903c-2.194-1.936-3.291-4.646-3.291-8.131c0-1.55,0.871-3.291,2.612-5.228 c1.742-1.936,3.646-2.904,5.711-2.904c-2.839-4.517-7.808-6.774-14.904-6.774c-6.841,0-11.776,3.872-14.811,11.615 c-3.032,7.743-4.549,17.745-4.549,30.006c2.71-1.419,4.84-2.453,6.389-3.097c1.549-0.646,3.774-1.258,6.68-1.84 c2.903-0.58,6.292-0.871,10.163-0.871c9.81,0,17.263,2.065,22.358,6.194c5.099,4.129,7.646,9.681,7.646,16.648 c0,8.775-3.646,16.035-10.938,21.779c-7.292,5.742-15.584,8.613-24.876,8.613c-12.519,0-22.068-4.193-28.65-12.584 C16.218,77.423,12.862,65.486,12.734,50c0.129-13.551,3.678-25.006,10.646-34.361C30.35,6.282,39.707,1.604,51.45,1.604 c6.194,0,11.324,0.581,15.391,1.742C70.907,4.507,74.811,6.831,78.553,10.315z"/>\
			<path id="meter7" d="M19.945,18.746c-2.6,0-4.739,0.159-6.42,0.489c-1.689,0.32-3.18,0.94-4.479,1.851c-1.299,0.911-2.239,1.649-2.819,2.239 c-0.58,0.591-1.431,1.75-2.53,3.5s-1.979,3.021-2.63,3.801l1.95-22.58c0.13-0.13,0.58-0.55,1.359-1.26 c0.779-0.711,1.229-1.141,1.359-1.27c0.13-0.131,0.55-0.49,1.271-1.07c0.71-0.58,1.229-0.91,1.561-0.971 c0.32-0.06,0.84-0.289,1.561-0.68c0.71-0.391,1.359-0.62,1.949-0.68c0.58-0.061,1.301-0.19,2.141-0.391 c0.841-0.199,1.78-0.33,2.82-0.39c1.039-0.07,2.14-0.101,3.311-0.101c6.1,0,12.939,1.23,20.54,3.701 c7.6,2.469,13.659,3.699,18.2,3.699c3.369,0,6.979-0.75,10.8-2.24c3.829-1.49,6.85-3.149,9.051-4.959 c-3.5,8.699-7.49,18.459-11.972,29.299c-4.48,10.84-7.561,18.36-9.25,22.58c-1.688,4.222-3.5,9.312-5.448,15.281 c-1.951,5.969-3.183,11.1-3.701,15.379c-0.521,4.281-0.779,9.211-0.779,14.791h-25.31c0.13-8.951,0.71-15.18,1.75-18.688 c2.21-7.013,10.06-19.271,23.55-36.791c3.889-5.061,8.76-11.29,14.6-18.69c-2.211,1.3-5.26,1.95-9.149,1.95 c-4.799,0-10.32-1.3-16.549-3.891C30.455,20.045,24.875,18.746,19.945,18.746z"/>\
			<path id="meter8" d="M31.185,58.34c-7.141,3.311-12.17,6.15-15.08,8.529c-2.91,2.381-4.37,5.361-4.37,8.932c0,3.84,2.91,7.34,8.729,10.521 c5.819,3.18,11.641,4.76,17.46,4.76c5.56,0,10.421-1.358,14.591-4.069c4.17-2.709,6.25-6.119,6.25-10.222 c0-1.851-0.5-3.539-1.49-5.06c-0.99-1.52-2.551-2.881-4.66-4.069c-2.121-1.188-4.131-2.222-6.051-3.08s-4.5-1.92-7.74-3.17 C35.585,60.16,33.034,59.131,31.185,58.34z M46.265,41.669c6.75-3.439,11.278-6.279,13.59-8.529c2.319-2.25,3.469-5.23,3.469-8.93 c0-3.84-2.25-7.34-6.75-10.521c-4.5-3.18-9.459-4.76-14.879-4.76s-9.82,1.319-13.201,3.97c-3.369,2.65-5.06,6.09-5.06,10.32 c0,1.98,0.33,3.74,0.989,5.26c0.66,1.52,1.921,2.91,3.771,4.17c1.851,1.26,3.37,2.221,4.561,2.881 c1.189,0.659,3.41,1.689,6.649,3.079C42.664,39.98,44.945,41.01,46.265,41.669z M22.055,53.18c-6.48-3.18-11.08-6.75-13.79-10.719 C5.555,38.49,4.195,33,4.195,25.99c0-6.75,3.37-12.67,10.12-17.76s15.021-7.71,24.811-7.84c9.919,0,18.221,2.32,24.91,6.949 c6.689,4.631,10.021,10.25,10.021,16.871c0,5.16-1.392,9.459-4.17,12.899c-2.779,3.44-7.341,6.681-13.689,9.72 c7.67,3.44,13.16,7.081,16.469,10.911c3.312,3.83,4.961,9.26,4.961,16.27c0,7.279-3.871,13.359-11.608,18.26 c-7.74,4.892-16.701,7.34-26.891,7.34c-10.051,0-18.979-2.379-26.79-7.139s-11.71-10.32-11.71-16.67c0-4.762,1.891-8.9,5.659-12.4 S15.315,56.49,22.055,53.18z"/>\
			<path id="meter9" d="M38.32,8.405c-5.42,0-9.61,2.28-12.58,6.83c-2.97,4.561-4.46,9.74-4.46,15.55c0,4.49,1.39,8.32,4.16,11.49 c2.77,3.17,6.8,4.75,12.08,4.75c5.81,0,11.89-2.44,18.22-7.33C54.83,18.844,49.019,8.405,38.32,8.405z M10.59,90.625 c-3.568-3.43-5.35-7.66-5.35-12.68c0-3.301,1.16-6.271,3.47-8.91c2.312-2.641,5.05-3.961,8.221-3.961 c3.961,0,7.069,0.99,9.311,2.971c2.25,1.98,3.37,4.75,3.37,8.32c0,1.58-0.891,3.369-2.67,5.35c-1.78,1.98-3.73,2.971-5.84,2.971 c2.908,4.619,7.988,6.931,15.25,6.931c6.999,0,12.05-3.961,15.158-11.892c3.102-7.92,4.66-18.16,4.66-30.708 c-2.77,1.45-4.949,2.509-6.54,3.169c-1.59,0.66-3.859,1.289-6.83,1.879c-2.97,0.591-6.438,0.892-10.398,0.892 c-10.04,0-17.66-2.108-22.88-6.34c-5.222-4.229-7.82-9.899-7.82-17.04c0-8.979,3.729-16.41,11.19-22.289 c7.46-5.881,15.948-8.811,25.46-8.811c12.81,0,22.579,4.29,29.318,12.88c6.74,8.58,10.17,20.8,10.301,36.649 c-0.131,13.871-3.761,25.591-10.899,35.16c-7.131,9.58-16.71,14.36-28.72,14.36c-6.342,0-11.592-0.59-15.75-1.78 C18.41,96.564,14.42,94.186,10.59,90.625z"/>\
			<text id="sfz" style="font:italic 14px serif_embedded" x="-5" y="-7">s<tspan font-size="16" font-weight="bold">f</tspan>z</text>\
			<text id="trl" style="font:italic bold 16px serif_embedded" x="-2" y="-4">tr</text>\
			<path id="marcato" d="m-3 0l3 -7l3 7l-1.5 0l-1.8 -4.2l-1.7 4.2"/>\
			<text id="ped" font-family="serif_embedded" font-size="16" font-style="italic" x="-10" y="-4">Ped</text>\
			<text id="pedoff" font-family="serif_embedded" font-size="16" font-style="italic" x="-5" y="-4">*</text>';

		// staff system
		private const OPEN_BRACE : Number = 0x01;
		private const CLOSE_BRACE : Number = 0x02;
		private const OPEN_BRACKET : Number = 0x04;
		private const CLOSE_BRACKET : Number = 0x08;
		private const OPEN_PARENTH : Number = 0x10;
		private const CLOSE_PARENTH : Number = 0x20;
		private const STOP_BAR : Number = 0x40;
		private const FL_VOICE : Number = 0x80;
		private const OPEN_BRACE2 : Number = 0x0100;
		private const CLOSE_BRACE2 : Number = 0x0200;
		private const OPEN_BRACKET2 : Number = 0x0400;
		private const CLOSE_BRACKET2 : Number = 0x0800;
		private const MASTER_VOICE : Number = 0x1000;
			
		private const IN : Number = 96;		// resolution 96 PPI
		private const CM : Number = 37.8;	// 1 inch = 2.54 centimeter
		private const YSTEP : Number = 256;	// number of steps for y offsets
		
		/**
		 * Requested page height in pixels. Page height is set in the ABC markup
		 * via something like "%%pageheight 29.7cm";
		 */
		private var pageHeight : Number;
		
		/**
		 * The Y coordinate of the topmost element of the page (always the title).
		 * This is indirectly set in ABC via %%topspace and %%titlespace
		 */
		private var pageY : Number;
		
		// error texts
		private var errs : Object = {
			bad_char: "Bad character '$1'",
			bad_val: "Bad value in $1",
			bar_grace: "Cannot have a bar in grace notes",
			ignored: "$1: inside tune - ignored",
			misplaced: "Misplaced '$1' in %%staves",
			must_note: "!$1! must be on a note",
			must_note_rest: "!$1! must be on a note or a rest",
			nonote_vo: "No note in voice overlay",
			not_enough_n: 'Not enough notes/rests for %%repeat',
			not_enough_m: 'Not enough measures for %%repeat',
			not_ascii: "Not an ASCII character"
		}
			
		// needed for modules (?)
		private var self : Object = this;
			
		private var glovar : Object = {
			meter: {
				type: C.METER,	// meter in tune header
				wmeasure: 1,	// no M:
				a_meter: []		// default: none
			}
		};
			
		// information fields
		private var info : Object = {};
		
		// macros (m:)
		private var mac : Object = {};
		
		// first letter of macros
		private var maci : Vector.<int> = new Vector.<int>(128);
			
		private var	parse : Object = {
			ctx: {},
			prefix: '%',
			state: 0,
			line: new scanBuf()
		};
			
		// PostScript
		private var psvg : Object;
			
		// Utilities
		// ---------
		private function clone (obj : Object, lvl : Number = 0) : Object {
			if (!obj) {
				return obj;
			}
			var tmp : Object = new obj.constructor();
			for (var k : String in obj) { 
				if (obj.hasOwnProperty(k)) {
					if (lvl > 0 && (obj[k] is Object)) {
						tmp[k] = clone(obj[k], lvl - 1);
					} else {
						tmp[k] = obj[k];
					}
				}
			}
			return tmp;
		}
			
		private function errbld (sev : Number, txt : String, fn : String = null, idx : Number = -1) : void {
			var i : Number;
			var j : Number;
			var l : Number;
			var c : Number;
			var h : String;
			if (idx >= 0) {
				i = l = 0;
				while (1) { 
					j = parse.file.indexOf('\n', i);
					if (j < 0 || j > idx) {
						break;
					}
					l++;
					i = j + 1;
				}
				c = idx - i;
			}
			h = "";
			if (fn) {
				h = fn;
				if (l) {
					h += ":" + (l + 1) + ":" + (c + 1);
				}
				h += " ";
			}
			switch (sev) {
				case 0:
					h += "Warning: ";
					break
				case 1: 
					h += "Error: ";
					break;
				default:
					h += "Internal bug: ";
					break;
			}
			if (user.errmsg) {
				user.errmsg(h + txt, l, c);
			} else {
				trace (h + txt, l, c);
			}
		}
			
		private function error (sev : Number, s : Object, msg : String, a1 : String = null, a2 : String = null, a3 : String = null, a4 : String = null) : void {
			var tmp : String;
			if (user.textrans) {
				tmp = user.textrans[msg];
				if (tmp) {
					msg = tmp;
				}
			}
			if (a1 || a2 || a3 || a4) {
				msg = msg.replace(/\$./g, function(a : String, ...args) : String {
					switch (a) {
						case '$1':
							return a1;
						case '$2':
							return a2;
						case '$3':
							return a3;
						default:
							return a4;
					}
				});
			}	
			if (s && s.fname) {
				errbld (sev, msg, s.fname, s.istart);
			}
			else {
				errbld (sev, msg);
			}
		}
			
		// Scanning functions
		// ------------------
		private function syntax (sev : Number, msg : String, a1 : String = null, a2 : String = null, a3 : String = null, a4 : String = null) : void {
			var	s : Object = {
				fname: parse.fname,
				istart: parse.istart + parse.line.index
			}
			error (sev, s, msg, a1, a2, a3, a4);
		}
			
			
		// Decorations
		// --------------------------------------
		private var	dd_tb : Object = {};
		
		// Array of the decoration elements
		private var a_de : Array;
		
		// Ottava: index = type + staff, value = counter + voice number
		private var od : Object;
			
		// Decorations - populate with standard decorations
		private var decos : Object = {
			'dot' : "0 stc 5 1 1",
			'tenuto' : "0 emb 5 3 3",
			'slide' : "1 sld 3 7 0",
			'arpeggio' : "2 arp 12 10 0",
			'roll' : "3 roll 7 6 6",
			'fermata' : "3 hld 12 7 7",
			'emphasis' : "3 accent 7 4 4",
			'lowermordent' : "3 lmrd 10 5 5",
			'coda' : "3 coda 24 10 10",
			'uppermordent' : "3 umrd 10 5 5",
			'segno' : "3 sgno 22 8 8",
			'trill' : "3 trl 14 5 5",
			'upbow' : "3 upb 10 5 5",
			'downbow' : "3 dnb 9 5 5",
			'gmark' : "3 grm 6 5 5",
			'wedge' : "3 wedge 8 3 3", // (staccatissimo or spiccato)
			'turnx' : "3 turnx 10 0 5",
			'breath' : "3 brth 0 1 20",
			'longphrase' : "3 lphr 0 1 1",
			'mediumphrase' : "3 mphr 0 1 1",
			'shortphrase' : "3 sphr 0 1 1",
			'invertedfermata' : "3 hld 12 7 7",
			'invertedturn' : "3 turn 10 0 5",
			'invertedturnx' : "3 turnx 10 0 5",
			'0' : "3 fng 8 3 3 0",
			'1' : "3 fng 8 3 3 1",
			'2' : "3 fng 8 3 3 2",
			'3' : "3 fng 8 3 3 3",
			'4' : "3 fng 8 3 3 4",
			'5' : "3 fng 8 3 3 5",
			'plus' : "3 dplus 7 3 3",
			'+' : "3 dplus 7 3 3",
			'accent' : "3 accent 7 4 4",
			'>' : "3 accent 7 4 4",
			'marcato' : "3 marcato 9 3 3",
			'^' : "3 marcato 9 3 3",
			'mordent' : "3 lmrd 10 5 5",
			'open' : "3 opend 10 3 3",
			'snap' : "3 snap 14 3 3",
			'thumb' : "3 thumb 14 3 3",
			'dacapo' : "3 dacs 16 20 20 Da Capo",
			'dacoda' : "3 dacs 16 20 20 Da Coda",
			'D.C.' : "3 dcap 16 10 10",
			'D.S.' : "3 dsgn 16 10 10",
			'D.C.alcoda' : "3 dacs 16 38 38 D.C. al Coda",
			'D.S.alcoda' : "3 dacs 16 38 38 D.S. al Coda",
			'D.C.alfine' : "3 dacs 16 38 38 D.C. al Fine",
			'D.S.alfine' : "3 dacs 16 38 38 D.S. al Fine",
			'fine' : "3 dacs 16 10 10 Fine",
			'turn' : "3 turn 10 0 5",
			'trill(' : "3 ltr 8 0 0",
			'trill)' : "3 ltr 8 0 0",
			'f' : "6 f 18 1 7",
			'ff' : "6 ff 18 2 10",
			'fff' : "6 fff 18 4 13",
			'ffff' : "6 ffff 18 6 16",
			'mf' : "6 mf 18 6 13",
			'mp' : "6 mp 18 6 16",
			'p' : "6 p 18 2 8",
			'pp' : "6 pp 18 5 14",
			'ppp' : "6 ppp 18 8 20",
			'pppp' : "6 pppp 18 10 25",
			'pralltriller' : "3 umrd 10 5 5",
			'sfz' : "6 sfz 18 4 10",
			'ped' : "4 ped 20 0 0",
			'ped-up' : "4 pedoff 20 0 0",
			'crescendo(' : "7 cresc 18 0 0",
			'crescendo)' : "7 cresc 18 0 0",
			'<(' : "7 cresc 18 0 0",
			'<)' : "7 cresc 18 0 0",
			'diminuendo(' : "7 dim 18 0 0",
			'diminuendo)' : "7 dim 18 0 0",
			'>(' : "7 dim 18 0 0",
			'>)' : "7 dim 18 0 0",
			'-(' : "8 gliss 0 0 0",
			'-)' : "8 gliss 0 0 0",
			'~(' : "8 glisq 0 0 0",
			'~)' : "8 glisq 0 0 0",
			'8va(' : "3 8va 10 0 0",
			'8va)' : "3 8va 10 0 0",
			'8vb(' : "4 8vb 10 0 0",
			'8vb)' : "4 8vb 10 0 0",
			'15ma(' : "3 15ma 10 0 0",
			'15ma)': "3 15ma 10 0 0",
			'15mb(' : "4 15mb 10 0 0",
			'15mb)' : "4 15mb 10 0 0",
			
			// internal
			'invisible' : "32 0 0 0 0",
			'beamon' : "33 0 0 0 0",
			'trem1' : "34 0 0 0 0",
			'trem2' : "34 0 0 0 0",
			'trem3' : "34 0 0 0 0",
			'trem4' : "34 0 0 0 0",
			'xstem' : "35 0 0 0 0",
			'beambr1' : "36 0 0 0 0",
			'beambr2' : "36 0 0 0 0",
			'rbstop' : "37 0 0 0 0",
			'/' : "38 0 0 6 6",
			'//' : "38 0 0 6 6",
			'///' : "38 0 0 6 6",
			'beam-accel' : "39 0 0 0 0",
			'beam-rall' : "39 0 0 0 0",
			'stemless' : "40 0 0 0 0",
			'rbend' : "41 0 0 0 0"
		};
				
		// Types of decoration per function
		private var f_near : Array = [true, true, true];
		private var f_note : Array = [false, false, false, true, true, true, false, false, true];
		private var f_staff : Array = [false, false, false, false, false, false, true, true];
			
		/**
		 * Gets the max/min vertical offset
		 */
		private function y_get (st : Object, up : Boolean, x : Number, w : Number) : Number {
			var	y : Number;
			var p_staff : Object = staff_tb[st];
			var i : Number = (x / realwidth * YSTEP) | 0;
			var j : Number = ((x + w) / realwidth * YSTEP) | 0;
			
			if (i < 0) {
				i = 0;
			}
			if (j >= YSTEP) {
				j = YSTEP - 1;
				if (i > j) {
					i = j;
				}
			}
			if (up) {
				y = p_staff.top[i++];
				while (i <= j) { 
					if (y < p_staff.top[i]) {
						y = p_staff.top[i];
					}
					i++;
				}
			} else {
				y = p_staff.bot[i++];
				while (i <= j) { 
					if (y > p_staff.bot[i]) {
						y = p_staff.bot[i];
					}
					i++;
				}
			}
			return y;
		}
			
		/* Adjust the vertical offsets */
		private function y_set(st : Number, up : Boolean, x : Number, w : Number, y : Number) : *  {
			var	p_staff : Object = staff_tb[st];
			var i : Number = (x / realwidth * YSTEP) | 0;
			var j : Number = ((x + w) / realwidth * YSTEP) | 0;
			
			/* (may occur when annotation on 'y' at start of an empty staff) */
			if (i < 0)
				i = 0
			if (j >= YSTEP) {
				j = YSTEP - 1
				if (i > j)
					i = j
			}
			if (up) {
				while (i <= j) { 
					if (p_staff.top[i] < y)
						p_staff.top[i] = y;
					i++
				}
			} else {
				while (i <= j) { 
					if (p_staff.bot[i] > y)
						p_staff.bot[i] = y;
					i++
				}
			}
		}
			
		/* Get the staff position of the dynamic and volume marks */
		private function up_p(s : Object, pos : Number) : *  {
			switch (pos) {
				case C.SL_ABOVE:
					return true;
				case C.SL_BELOW:
					return false;
			}
			if (s.multi && s.multi != 0) {
				return s.multi > 0
			}
			if (!s.p_v.have_ly) {
				return false;
			}
			
			/* above if the lyrics are below the staff */
			return s.pos.voc != C.SL_ABOVE;
		}
			
		// DRAWING FUNCTIONS
		// -----------------
		
		/* 2: special case for arpeggio */
		private function d_arp(de) : *  {
			var	m;
			var h;
			var dx;
			var s = de.s;
			var dd = de.dd;
			var xc = 5;
			
			if (s.type == C.NOTE) {
				for (m = 0; m <= s.nhd; m++) { 
					if (s.notes[m].acc) {
						dx = (5 + s.notes[m].shac);
					} else {
						dx = (6 - s.notes[m].shhd);
						switch (s.head) {
							case C.SQUARE:
								dx += 3.5;
								break;
							case C.OVALBARS:
							case C.OVAL:
								dx += 2;
								break;
						}
					}
					if (dx > xc) {
						xc = dx;
					}
				}
			}
			h = (3 * (s.notes[s.nhd].pit - s.notes[0].pit) + 4);
			m = dd.h			/* minimum height */
			if (h < m)
				h = m;
			
			de.has_val = true;
			de.val = h;
			//	de.x = s.x - xc;
			de.x -= xc;
			de.y = 3 * (s.notes[0].pit - 18) - 3
		}
			
		/* 7: special case for crescendo/diminuendo */
		private function d_cresc(de) : *  {
			// skip start of deco
			if (de.ldst) {
				return;
			}
			var	s;
			var dd;
			var dd2;
			var up;
			var x;
			var dx;
			var x2;
			var i;
			var s2 = de.s;
			
			/* start of the deco */
			var de2 = de.start;
			var de2_prev;
			var de_next;
			s = de2.s;
			x = s.x + 3;
			i = de2.ix;
			if (i > 0) {
				de2_prev = a_de[i - 1];
			}
			de.st = s2.st;

			/* old behaviour */
			de.lden = false;		
			de.has_val = true;
			up = up_p(s2, s2.pos.dyn);
			if (up) {
				de.up = true;
			}
			
			// Shift the starting point if any dynamic mark on the left
			if (de2_prev && de2_prev.s == s && ((de.up && !de2_prev.up) || (!de.up && de2_prev.up))) {
				dd2 = de2_prev.dd;

				// if dynamic mark
				if (f_staff[dd2.func]) {
					x2 = de2_prev.x + de2_prev.val + 4;
					if (x2 > x) {
						x = x2;
					}
				}
			}
			
			/* if no decoration end */
			if (de.defl.noen) {
				dx = de.x - x;
				if (dx < 20) {
					x = de.x - 20 - 3;
					dx = 20;
				}
			} else {
				
				// shift the ending point if any dynamic mark on the right
				x2 = s2.x;
				de_next = a_de[de.ix + 1];
				if (de_next
					&& de_next.s == s
					&& ((de.up && !de_next.up) || (!de.up && de_next.up))) {
					dd2 = de_next.dd;

					// if dynamic mark
					if (f_staff[dd2.func]) {
						x2 -= 5;
					}
				}
				dx = x2 - x - 4;
				if (dx < 20) {
					x -= (20 - dx) * .5;
					dx = 20;
				}
			}
			de.val = dx;
			de.x = x;
			de.y = y_get (de.st, up, x, dx);
			if (!up) {
				dd = de.dd;
				de.y -= dd.h;
			}
			/* (y_set is done later in draw_deco_staff) */
		}
			
		/* 0: near the note (dot, tenuto) */
		private function d_near(de) : *  {
			var	y;
			var up;
			var s = de.s;
			var dd = de.dd;
			
			// annotation like decoration
			if (dd.str) {
				// de.x = s.x;
				// de.y = s.y;
				return;
			}
			if (s.multi) {
				up = s.multi > 0;
			} else {
				up = s.stem < 0;
			}
			if (up) {
				y = s.ymx | 0;
			} else {
				y = (s.ymn - dd.h) | 0;
			}
			if (y > -6 && y < 24) {
				if (up) {
					y += 3;
				}

				/* between lines */
				y = (((y + 6) / 6) | 0) * 6 - 6;
			}
			if (up) {
				s.ymx = y + dd.h;
			}
			else {
				s.ymn = y;
			}
			de.y = y;
			//	de.x = s.x + s.notes[s.stem >= 0 ? 0 : s.nhd].shhd
			if (s.type == C.NOTE) {
				de.x += s.notes[(s.stem >= 0)? 0 : s.nhd].shhd;
			}
			if (dd.name[0] == 'd'			/* if dot decoration */
				&& s.nflags >= -1) {		/* on stem */
				if (up) {
					if (s.stem > 0) {
						de.x += 3.5;
					} // stem_xoff
				} else {
					if (s.stem < 0) {
						de.x -= 3.5;
					}
				}
			}
		}
			
		/* 6: dynamic marks */
		private function d_pf (de) : *  {
			var	dd2;
			var x2;
			var x;
			var up;
			var s = de.s;
			var dd = de.dd;
			var de_prev;
			
			de.val = dd.wl + dd.wr;
			up = up_p (s, s.pos.vol);
			if (up) {
				de.up = true;
			}
			x = s.x - dd.wl;
			if (de.ix > 0) {
				de_prev = a_de[de.ix - 1];
				if (de_prev.s == s
					&& ((de.up && !de_prev.up)
					|| (!de.up && de_prev.up))) {
					dd2 = de_prev.dd;

					/* if dynamic mark */
					if (f_staff[dd2.func]) {
						x2 = de_prev.x + de_prev.val + 4;
						if (x2 > x) {
							x = x2;
						}
					}
				}
			}
			de.x = x;
			de.y = y_get(s.st, up, x, de.val);
			if (!up) {
				de.y -= dd.h;
			}
			/* (y_set is done later in draw_deco_staff) */
		}
			
		/* 1: special case for slide */
		private function d_slide(de) : *  {
			var	m;
			var dx;
			var s = de.s;
			var yc = s.notes[0].pit;
			var xc = 5;
			
			for (m = 0; m <= s.nhd; m++) { 
				if (s.notes[m].acc) {
					dx = 4 + s.notes[m].shac;
				} else {
					dx = 5 - s.notes[m].shhd;
					switch (s.head) {
						case C.SQUARE:
							dx += 3.5;
							break;
						case C.OVALBARS:
						case C.OVAL:
							dx += 2
							break
					}
				}
				if (s.notes[m].pit <= yc + 3 && dx > xc)
					xc = dx
			}
			//	de.x = s.x - xc;
			de.x -= xc;
			de.y = 3 * (yc - 18)
		}
			
		/* 5: special case for long trill */
		private function d_trill(de) : *  {
			if (de.ldst) {
				return;
			}
			var	dd;
			var up;
			var y;
			var w;
			var tmp;
			var s2 = de.s;
			var st = s2.st;
			var s = de.start.s;
			var x = s.x;
			
			if (de.prev) { // hack 'tr~~~~~'
				x = de.prev.x + 10;
				y = de.prev.y;
			}
			de.st = st;
			
			if (de.dd.func != 4) { // if not below
				switch (de.dd.glyph) {
					case "8va":
					case "15ma":
						up = 1
						break
					default:
						up = s2.multi >= 0
						break
				}
			}

			/* if no decoration end */
			if (de.defl.noen) {
				w = de.x - x
				if (w < 20) {
					x = de.x - 20 - 3;
					w = 20;
				}
			} else {
				w = s2.x - x - 6;
				if (s2.type == C.NOTE) {
					w -= 6;
				}
				if (w < 20) {
					x -= (20 - w) * .5;
					w = 20;
				}
			}
			dd = de.dd;
			if (!y) {
				y = y_get(st, up, x, w);
			}
			if (up) {
				tmp = staff_tb[s.st].topbar + 2;
				if (y < tmp) {
					y = tmp;
				}
			} else {
				y -= dd.h;
				tmp = staff_tb[s.st].botbar - 2;
				if (y > tmp) {
					y = tmp;
				}
			}
			de.lden = false;
			de.has_val = true;
			de.val = w;
			de.x = x;
			de.y = y
			if (up) {
				y += dd.h;
			}
			y_set (st, up, x, w, y);
			if (up) {
				s.ymx = s2.ymx = y;
			}
			else {
				s.ymn = s2.ymn = y;
			}
		}
			
		/* 3, 4: above (or below) the staff */
		private function d_upstaff(de) : *  {
			
			// don't treat here the long decorations
			if (de.ldst) { // if long deco start
				return;
			}
			if (de.start) { // if long decoration
				d_trill (de);
				return;
			}
			var	yc;
			var up;
			var inv;
			var s = de.s;
			var dd = de.dd;
			var x = s.x;
			var w = dd.wl + dd.wr;
			var stafft = staff_tb[s.st].topbar + 2;
			var staffb = staff_tb[s.st].botbar - 2;
			if (s.nhd) {
				x += s.notes[s.stem >= 0 ? 0 : s.nhd].shhd;
			}
			up = -1;
			if (dd.func == 4) { // below
				up = 0;
			} else if (s.pos) {
				switch (s.pos.orn) {
					case C.SL_ABOVE:
						up = 1;
						break;
					case C.SL_BELOW:
						up = 0;
						break;
				}
			}
			
			switch (dd.glyph) {
				case "accent":
				case "roll":
					if (!up || (up < 0 && (s.multi < 0 || (!s.multi && s.stem > 0)))) {
						yc = y_get(s.st, false, s.x - dd.wl, w) - 2;
						if (yc > staffb) {
							yc = staffb;
						}
						yc -= dd.h;
						y_set(s.st, false, s.x, 0, yc);
						inv = true;
						s.ymn = yc;
					} else {
						yc = y_get(s.st, true, s.x - dd.wl, w) + 2;
						if (yc < stafft) {
							yc = stafft;
						}
						y_set (s.st, true, s.x - dd.wl, w, yc + dd.h);
						s.ymx = yc + dd.h;
					}
					break;
				case "brth":
				case "lphr":
				case "mphr":
				case "sphr":
					yc = stafft + 1;
					if (dd.glyph == "brth" && yc < s.ymx) {
						yc = s.ymx;
					}
					for (s = s.ts_next; s; s = s.ts_next) { 
						if (s.seqst) {
							break;
						}
					}
					x += ((s ? s.x : realwidth) - x) * .45;
					break;
				default:
					if (dd.name.indexOf("invert") == 0) {
						inv = true;
					}
					if (dd.name != "invertedfermata" && (up > 0 || (up < 0 && s.multi >= 0))) {
						yc = y_get (s.st, true, s.x - dd.wl, w) + 2;
						if (yc < stafft) {
							yc = stafft;
						}
						y_set (s.st, true, s.x - dd.wl, w, yc + dd.h);
						s.ymx = yc + dd.h
					} else {
						yc = y_get (s.st, false, s.x - dd.wl, w) - 2;
						if (yc > staffb) {
							yc = staffb;
						}
						yc -= dd.h;
						y_set (s.st, false, s.x - dd.wl, w, yc);
						if (dd.name == "fermata") {
							inv = true;
						}
						s.ymn = yc;
					}
					break;
			}
			if (inv) {
				yc += dd.h;
				de.inv = true;
			}
			de.x = x;
			de.y = yc
		}
			
		/* Decoration function table */
		private var func_tb = [
			d_near,		/* 0 - near the note */
			d_slide,	/* 1 */
			d_arp,		/* 2 */
			d_upstaff,	/* 3 - tied to note */
			d_upstaff,	/* 4 (below the staff) */
			d_trill,	/* 5 */
			d_pf,		/* 6 - tied to staff (dynamic marks) */
			d_cresc		/* 7 */
		];
			
		/*
		* Adds a decoration.
		* Syntax:
		* %%deco <name> <c_func> <glyph> <h> <wl> <wr> [<str>]
		*/
		private function deco_add(param) : *  {
			var dv = param.match(/(\S*)\s+(.*)/);
			decos[dv[1]] = dv[2];
		}
			
		/* Defines a decoration */
		private function deco_def (nm) : *  {
			var a;
			var dd;
			var dd2;
			var name2;
			var c;
			var i;
			var elts;
			var str;
			var text = decos[nm];
			
			if (!text) {
				if (cfmt.decoerr) {
					error (1, null, "Unknown decoration '$1'", nm);
				}
				return; // undefined
			}
			
			// Extract the values
			a = text.match(/(\d+)\s+(.+?)\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)/);
			if (!a) {
				error (1, null, "Invalid decoration '$1'", nm);
				return; // undefined
			}
			var	c_func = Number(a[1]);
			var glyph = a[2];
			var h = parseFloat(a[3]);
			var wl = parseFloat(a[4]);
			var wr = parseFloat(a[5]);
			if (isNaN (c_func)) {
				error (1, null, "%%deco: bad C function value '$1'", a[1]);
				return; // undefined
			}
			if ((c_func < 0 || c_func > 10) && (c_func < 32 || c_func > 41)) {
				error (1, null, "%%deco: bad C function index '$1'", c_func);
				return // undefined
			}
			if (h < 0 || wl < 0 || wr < 0) {
				error (1, null, "%%deco: cannot have a negative value '$1'", text);
				return // undefined
			}
			if (h > 50 || wl > 80 || wr > 80) {
				error (1, null, "%%deco: abnormal h/wl/wr value '$1'", text);
				return // undefined
			}
			
			// Create/redefine the decoration
			dd = dd_tb[nm];
			if (!dd) {
				dd = {
					name: nm
				}
				dd_tb[nm] = dd
			}
			
			// Set the values
			dd.func = dd.name.indexOf("head-") == 0 ? 9 : c_func;
			dd.glyph = a[2];
			dd.h = h;
			dd.wl = wl;
			dd.wr = wr;
			str = text.replace (a[0], '').trim();
			if (str) { // optional string
				if (str[0] == '"') {
					str = str.slice(1, -1);
				}
				dd.str = str;
			}
			
			// Compatibility
			if (dd.func == 6 && dd.str == undefined) {
				dd.str = dd.name;
			}
			
			// Link the start and end of long decorations
			c = dd.name.slice(-1);
			if (c == '(' || (c == ')' && dd.name.indexOf('(') < 0)) {
				name2 = dd.name.slice(0, -1) + (c == '(' ? ')' : '(');
				dd2 = dd_tb[name2];
				if (dd2) {
					if (c == '(') {
						dd.dd_en = dd2;
						dd2.dd_st = dd
					} else {
						dd.dd_st = dd2;
						dd2.dd_en = dd
					}
				} else {
					dd2 = deco_def (name2);
					if (!dd2) {
						return; // undefined
					}
				}
			}
			return dd;
		}
			
		/* Convert the decorations */
		private function deco_cnv(a_dcn, s, prev = null) : *  {
			var	i;
			var j;
			var dd;
			var dcn;
			var note;
			var nd = a_dcn.length;
			for (i = 0; i < nd; i++) { 
				dcn = a_dcn[i];
				dd = dd_tb[dcn];
				if (!dd) {
					dd = deco_def(dcn);
					if (!dd) {
						continue;
					}
				}
				
				// Special decorations
				switch (dd.func) {
					case 0: // near
						if (s.type == C.BAR && dd.name == "dot") {
							s.bar_dotted = true;
							break;
						}
						// fall thru
					case 1: // slide
					case 2: // arp
						if (!s.notes) {
							error (1, s, errs.must_note_rest, dd.name);
							continue;
						}
						break;
					case 8: // gliss
						if (s.type != C.NOTE) {
							error (1, s, errs.must_note, dd.name);
							continue;
						}
						note = s.notes[s.nhd]; // move to the upper note of the chord
						if (!note.a_dcn) {
							note.a_dcn = [];
						}
						note.a_dcn.push (dd.name);
						continue;
					case 9: // alternate head
						if (!s.notes) {
							error(1, s, errs.must_note_rest, dd.name);
							continue;
						}
						
						// Move the alternate head of the chord to the notes
						for (j = 0; j <= s.nhd; j++) { 
							note = s.notes[j];
							if (!note.a_dcn) {
								note.a_dcn = [];
							}
							note.a_dcn.push (dd.name);
						}
						continue;
					default:
						break;
					case 10: /* color */
						if (s.notes) {
							for (j = 0; j <= s.nhd; j++) { 
								s.notes[j].color = dd.name;
							}
						} else {
							s.color = dd.name;
						}
						continue;
					case 32: /* invisible */
						s.invis = true;
						continue;
					case 33: /* beamon */
						if (s.type != C.BAR) {
							error (1, s, "!beamon! must be on a bar");
							continue;
						}
						s.beam_on = true;
						continue;
					case 34: /* trem1..trem4 */
						if (s.type != C.NOTE || !prev || prev.type != C.NOTE || s.nflags != prev.nflags) {
							error(1, s, "!$1! must be on the last of a couple of notes", dd.name)
							continue;
						}
						s.trem2 = true;
						s.beam_end = true;
						prev.trem2 = true;
						prev.beam_st = true;
						s.ntrem = prev.ntrem = Number(dd.name[4]);
						prev.nflags = --s.nflags;
						prev.head = ++s.head;
						if (s.nflags > 0) {
							s.nflags += s.ntrem;
						} else {
							if (s.nflags <= -2) {
								s.stemless = true;
								prev.stemless = true
							}
							s.nflags = s.ntrem;
						}
						prev.nflags = s.nflags;
						for (j = 0; j <= s.nhd; j++) { 
							s.notes[j].dur *= 2;
						}
						for (j = 0; j <= prev.nhd; j++) { 
							prev.notes[j].dur *= 2;
						}
						continue;
					case 35: /* xstem */
						if (s.type != C.NOTE) {
							error (1, s, "!xstem! must be on a note");
							continue;
						}
						s.xstem = true;
						s.nflags = 0; // beam break
						continue;
					case 36: /* beambr1 / beambr2 */
						if (s.type != C.NOTE) {
							error (1, s, errs.must_note, dd.name);
							continue;
						}
						if (dd.name[6] == '1') {
							s.beam_br1 = true;
						}
						else {
							s.beam_br2 = true;
						}
						continue;
					case 37: /* rbstop */
						s.rbstop = 1; // open
						continue;
					case 38: /* /, // and /// = tremolo */
						if (s.type != C.NOTE) {
							error(1, s, errs.must_note, dd.name);
							continue;
						}
						s.trem1 = true;
						s.ntrem = dd.name.length /* 1, 2 or 3 */
						if (s.nflags > 0) {
							s.nflags += s.ntrem;
						}
						else {
							s.nflags = s.ntrem;
						}
						continue;
					case 39: /* beam-accel/beam-rall */
						if (s.type != C.NOTE) {
							error (1, s, errs.must_note, dd.name);
							continue;
						}
						s.feathered_beam = dd.name[5] == 'a' ? 1 : -1;
						continue;
					case 40: /* stemless */
						s.stemless = true;
						continue;
					case 41: /* rbend */
						s.rbstop = 2; // with end
						continue;
				}
				
				// Add the decoration in the symbol
				if (!s.a_dd) {
					s.a_dd = [];
				}
				s.a_dd.push (dd);
			}
		}
			
		/*
		 * Updates the x position of a decoration.
		 * Used to center the rests.
		 */
		private function deco_update (s, dx) : *  {
			var	i;
			var de;
			var nd = a_de.length;
			for (i = 0; i < nd; i++) { 
				de = a_de[i];
				if (de.s == s) {
					de.x += dx;
				}
			}
		}
			
		/**
		* Adjusts the width of a decoration symbol.
		*/
		private function deco_width(s) : *  {
			var	dd;
			var i;
			var wl = 0;
			var a_dd = s.a_dd;
			var nd = a_dd.length;

			for (i = 0; i < nd; i++) { 
				dd = a_dd[i];
				switch (dd.func) {
					case 1: /* slide */
						if (wl < 7) {
							wl = 7;
						}
						break;
					case 2: /* arpeggio */
						if (wl < 14) {
							wl = 14;
						}
						break;
					case 3:
						switch (dd.glyph) {
							case "brth":
							case "lphr":
							case "mphr":
							case "sphr":
								if (s.wr < 20) {
									s.wr = 20;
								}
								break;
						}
						break;
				}
			}
			if (wl != 0 && s.prev && s.prev.type == C.BAR) {
				wl -= 3;
			}
			return wl;
		}
			
		/*
		 * Draws the decorations (the staves are defined).
		 */
		private function draw_all_deco() : *  {
			if (a_de.length == 0) {
				return;
			}
			var	de;
			var de2;
			var dd;
			var s;
			var note;
			var f;
			var st;
			var x;
			var y;
			var y2;
			var ym;
			var uf;
			var i;
			var str;
			var a;
			var new_de = [];
			var ymid = [];
			if (!cfmt.dynalign) {
				st = nstaff;
				y = staff_tb[st].y
				while (--st >= 0) { 
					y2 = staff_tb[st].y;
					ymid[st] = (y + 24 + y2) * .5;
					y = y2;
				}
			}
			
			while (true) { 
				de = a_de.shift();
				if (!de) {
					break;
				}
				dd = de.dd;
				if (!dd) {
					continue; // deleted
				}
				if (dd.dd_en) { // start of long decoration
					continue;
				}

				// Handle the stem direction
				s = de.s;
				f = dd.glyph;
				i = f.indexOf('/');
				if (i > 0) {
					if (s.stem >= 0) {
						f = f.slice (0, i);
					} else {
						f = f.slice (i + 1);
					}
				}
				
				// No voice scale if staff decoration
				if (f_staff[dd.func]) {
					set_sscale(s.st);
				} else {
					set_scale(s);
				}
				
				st = de.st;
				if (!staff_tb[st].topbar) {
					continue; // invisible staff
				}
				x = de.x;
				y = de.y + staff_tb[st].y;
				
				// Update the coordinates if head decoration
				if (de.m != undefined) {
					note = s.notes[de.m];
					x += note.shhd * stv_g.scale;
				} 
					
				/*
				 * Center the dynamic marks between two staves.
				 * FIXME: KO when deco on other voice and same direction.
				 */
				else if (f_staff[dd.func] && !cfmt.dynalign && ((de.up && st > 0) || (!de.up && st < nstaff))) {
					if (de.up) {
						ym = ymid[--st];
					} else {
						ym = ymid[st++];
					}
					ym -= dd.h * .5;
					if ((de.up && y < ym) || (!de.up && y > ym)) {
						y2 = y_get (st, !de.up, de.x, de.val) + staff_tb[st].y;
						if (de.up) {
							y2 -= dd.h;
						}

						// FIXME: y_set is not used later!
						if ((de.up && y2 > ym) || (!de.up && y2 < ym)) {
							y = ym;
						}
					}
				}
				
				// Check if user JS decoration
				// FIXME: likely this will never be the case. Investigate and delete if not needed.
				uf = user[f];
				if (uf && typeof(uf) == "private function") {
					uf (x, y, de);
					continue;
				}
				
				// Check if user PS definition
				// FIXME: likely this will never be the case. Investigate and delete if not needed.
				if (self.psdeco(f, x, y, de)) {
					continue;
				}
				anno_start (s, 'deco');
				if (de.inv) {
					g_open (x, y, 0, 1, -1);
					x = y = 0;
				}
				if (de.has_val) {
					if (dd.func != 2		// if not !arpeggio!
						|| stv_g.st < 0) {	// or not staff scale
						out_deco_val (x, y, f, de.val / stv_g.scale, de.defl);
					} else {
						out_deco_val (x, y, f, de.val, de.defl);
					}
					if (de.defl.noen) {
						new_de.push (de.start);	// decoration is to be continued on next line
					}
				} else if (dd.str != undefined && dd.str != 'sfz') {
					str = dd.str;
					if (str[0] == '@') {
						a = str.match (/^@([0-9.-]+),([0-9.-]+);?/);
						x += Number(a[1]);
						y += Number(a[2]);
						str = str.replace(a[0], "");
					}
					out_deco_str (x, y,	// - dd.h * .2,
						f, str);
				} else if (de.lden) {
					out_deco_long (x, y, de);
				} else {
					xygl (x, y, f);
				}
				if (stv_g.g) {
					g_close();
				}
				anno_stop (s, 'deco');
			}
			
			// Keep the long decorations which continue on the next line
			a_de = new_de;
		}

		private var	ottava = {
			"8va("  : 1,
			"8va)"  : 1,
			"15ma(" : 1,
			"15ma)" : 1,
			"8vb("  : 1,
			"8vb)"  : 1,
			"15mb(" : 1,
			"15mb)" : 1
		};
		

		/*
		 * Update starting old decorations.
		 */
		private function ldeco_update(s) : *  {
			var	i;
			var de;
			var x = s.x - s.wl;
			var nd = a_de.length;
			for (i = 0; i < nd; i++) { 
				de = a_de[i];
				de.ix = i;
				de.s.x = de.x = x;
				de.defl.nost = true;
			}
		}

		/*
		 * Creates the deco elements, and treats the near ones.
		 */
		private function create_deco(s) : *  {
			var	dd; 
			var k;
			var l;
			var pos;
			var de;
			var x;
			var nd = s.a_dd.length;
			
			// FIXME: pb with decorations above the staff
			for (k = 0; k < nd; k++) { 
				dd = s.a_dd[k];
				
				// check if hidden
				switch (dd.func) {
					default:
						pos = 0;
						break;
					case 3: // d_upstaff
					case 4: // fixme: trill (does not work yet)
					case 5:	// fixme: trill (does not work yet)
						if (ottava[dd.name]) { // only one ottava per staff
							x = dd.name.slice(0, -1) + s.st.toString();
							if (od[x]) {
								if (dd.name[dd.name.length - 1] == '(') {
									od[x]++;
									continue;
								}
								od[x]--;
								if (s.v + 1 != od[x] >> 8 || !od[x]) {
									continue;
								}
								od[x] &= 0xff;
							} else if (dd.name[dd.name.length - 1] == '(') {
								od[x] = 1 + ((s.v + 1) << 8);
							}
						}
						pos = s.pos.orn;
						break;
					case 6: /* d_pf */
						pos = s.pos.vol;
						break;
					case 7: /* d_cresc */
						pos = s.pos.dyn;
						break;
				}
				if (pos == C.SL_HIDDEN) {
					continue;
				}
				de = {
					s: s,
					dd: dd,
					st: s.st,
					ix: a_de.length,
					defl: {},
					x: s.x,
					y: s.y
				}
				a_de.push(de);

				if (dd.dd_en) {
					de.ldst = true;
				} else if (dd.dd_st) {
					// FIXME: pb with "()"
					de.lden = true;
					de.defl.nost = true;
				}
				
				// If not near the note
				if (!f_near[dd.func]) {
					continue;
				}
				func_tb[dd.func](de);
			}
		}

		// Create the decorations of note heads
		private function create_dh (s, m) : *  {
			var	f;
			var str;
			var de;
			var uf;
			var k;
			var dcn;
			var dd;
			var note = s.notes[m];
			var nd = note.a_dcn.length;
			
			for (k = 0; k < nd; k++) { 
				dcn = note.a_dcn[k];
				dd = dd_tb[dcn];
				if (!dd) {
					dd = deco_def(dcn);
					if (!dd) {
						continue;
					}
				}
				
				switch (dd.func) {
					case 0:
					case 1:
					case 3:
					case 4:
					case 8: // gliss
						break;
					default:
						// arpeggio
						// trill
						// d_cresc
						error (1, null, "Cannot have !$1! on a head", dd.name);
						continue;
					case 9: // head replacement
						note.invis = true
						break;
					case 10: // color
						note.color = dd.name;
						continue;
					case 32: // invisible
						note.invis = true;
						continue;
					case 40: // stemless chord (abcm2ps behaviour)
						s.stemless = true;
						continue;
				}
				
				// FIXME: check if hidden?
				de = {
					s: s,
					dd: dd,
					st: s.st,
					m: m,
					ix: 0,
					defl: {},
					x: s.x,
					y: 3 * (note.pit - 18)
				}
				a_de.push(de);
				if (dd.dd_en) {
					de.ldst = true;
				} else if (dd.dd_st) {
					de.lden = true;
					de.defl.nost = true;
				}
			}
		}

		/*
		 * Creates all decoration of a note (chord and heads).
		 */
		private function create_all (s) : *  {
			var m;
			if (s.a_dd) {
				create_deco (s);
			}
			if (s.notes) {
				for (m = 0; m < s.notes.length; m++) { 
					if (s.notes[m].a_dcn) {
						create_dh (s, m);
					}
				}
			}
		}

		/* 
		 * Links the long decorations.
		 */
		private function ll_deco () : *  {
			var	i; 
			var j;
			var de;
			var de2;
			var dd;
			var dd2;
			var v;
			var s;
			var st;
			var n_de = a_de.length;
			
			// Add ending decorations
			for (i = 0; i < n_de; i++) { 
				de = a_de[i];
				if (!de.ldst) {	// Not the start of long decoration
					continue;
				}
				dd = de.dd;
				dd2 = dd.dd_en;
				s = de.s;
				v = s.v; // Search later in the voice
				for (j = i + 1; j < n_de; j++) { 
					de2 = a_de[j];
					if (!de2.start && de2.dd == dd2 && de2.s.v == v) {
						break;
					}
				}
				if (j == n_de) { // No end, search in the staff
					st = s.st;
					for (j = i + 1; j < n_de; j++) { 
						de2 = a_de[j];
						if (!de2.start && de2.dd == dd2 && de2.s.st == st) {
							break;
						}
					}
				}
				if (j == n_de) { // No end, insert one
					de2 = {
						s: de.s,
						st: de.st,
						dd: dd2,
						ix: a_de.length - 1,
						x: realwidth - 6,
						y: de.s.y,
						lden: true,
						defl: {
							noen: true
						}
					}
					if (de2.x < s.x + 10) {
						de2.x = s.x + 10;
					}
					if (de.m != undefined) {
						de2.m = de.m;
					}
					a_de.push (de2);
				}
				de2.start = de;
				de2.defl.nost = de.defl.nost
				
				// Handle 'tr~~~~~'
				if (dd.name == "trill(" && i > 0 && a_de[i - 1].dd.name == "trill") {
					de2.prev = a_de[i - 1];
				}
			}
			
			// Add starting decorations
			for (i = 0; i < n_de; i++) { 
				de2 = a_de[i];
				if (!de2.lden		// not the end of long decoration
					|| de2.start) {	// start already found
					continue;
				}
				s = de2.s;
				de = {
					s: prev_scut(s),
					st: de2.st,
					dd: de2.dd.dd_st,
					ix: a_de.length - 1,
					y: s.y,
					ldst: true
				}
				de.x = de.s.x;
				if (de2.m != undefined) {
					de.m = de2.m;
				}
				a_de.push (de);
				de2.start = de;
			}
		}

		/*
		 * Creates the decorations and define the ones near the notes
		 * (the staves are not yet defined).
		 * Delayed output: this function must be called first, as it builds
		 * the deco element table.
		 */
		private function draw_deco_near() : *  {
			var	s;
			var g;

			// Update the long decorations started in the previous line
			for (s = tsfirst ; s; s = s.ts_next) { 
				switch (s.type) {
					case C.CLEF:
					case C.KEY:
					case C.METER:
						continue;
				}
				break;
			}
			if (a_de.length != 0) {
				ldeco_update (s);
			}
			
			for ( ; s; s = s.ts_next) { 
				switch (s.type) {
					case C.BAR:
					case C.MREST:
					case C.NOTE:
					case C.REST:
					case C.SPACE:
						break;
					case C.GRACE:
						for (g = s.extra; g; g = g.next) { 
							create_all(g);
						}
					default:
						continue;
				}
				create_all(s);
			}
			// Link the long decorations
			ll_deco();
		}
			
		/*
		 * Defines the decorations tied to a note (the staves are not yet defined).
		 * Delayed output.
		 */
		private function draw_deco_note() : *  {
			var	i;
			var de;
			var dd;
			var f;
			var nd = a_de.length;
			for (i = 0; i < nd; i++) { 
				de = a_de[i];
				dd = de.dd;
				f = dd.func;
				if (f_note[f] && de.m == undefined) {
					func_tb[f](de);
				}
			}
		}

		/*
		* Draws the repeat brackets.
		*/
		private function draw_repbra (p_voice) : *  {
			var s; 
			var s1;
			var x;
			var y;
			var y2;
			var i;
			var p;
			var w;
			var wh;
			var first_repeat;
			
			// Search the max y offset
			// `20` (vert bar) + `5` (room)
			y = staff_tb[p_voice.st].topbar + 25;	
			for (s = p_voice.sym; s; s = s.next) { 
				if (s.type != C.BAR) {
					continue;
				}
				if (!s.rbstart || s.norepbra) {
					continue;
				}

				// FIXME: line cut on repeat!
				if (!s.next) {
					break;
				}
				if (!first_repeat) {
					first_repeat = s;
					set_font("repeat");
				}
				s1 = s;
				while (true) { 
					if (!s.next) {
						break;
					}
					s = s.next;
					if (s.rbstop) {
						break;
					}
				}
				y2 = y_get (p_voice.st, true, s1.x, s.x - s1.x);
				if (y < y2) {
					y = y2;
				}
				
				// Reserve room for the repeat numbers
				if (s1.text) {
					wh = strwh (s1.text);
					y2 = y_get (p_voice.st, true, s1.x + 4, wh[0]);
					y2 += wh[1];
					if (y < y2) {
						y = y2;
					}
				}
				if (s.rbstart) {
					s = s.prev;
				}
			}
			
			// Draw the repeat indications
			s = first_repeat;
			if (!s) {
				return;
			}
			set_dscale (p_voice.st, true);
			y2 =  y * staff_tb[p_voice.st].staffscale;
			while ((s = s.next)) {
				if (!s.rbstart || s.norepbra) {
					continue;
				}
				s1 = s;
				while (1) { 
					if (!s.next) {
						break;
					}
					s = s.next;
					if (s.rbstop) {
						break;
					}
				}
				if (s1 == s) {
					break;
				}
				x = s1.x;
				if (s.type != C.BAR) {
					w = s.rbstop? 0 : s.x - realwidth + 4;
				}

				// If complex bar
				else if ((s.bar_type.length > 1	&& s.bar_type != "[]") || s.bar_type == "]") {

					// FIXME :%%staves: cur_sy moved?
					if (s1.st > 0 && !(cur_sy.staves[s1.st - 1].flags & STOP_BAR)) {
						w = s.wl;
					}
					else if (s.bar_type.slice(-1) == ':') {
						w = 12;
					}

					// Explicit repeat end
					else if (s.bar_type[0] != ':') {
						w = 0;
					}
					else {
						w = 8;
					}
				} else {
					w = s.rbstop ? 0 : 8;
				}
				w = (s.x - x - w);
				
				// 2nd ending at end of line: continue on next line
				if (!s.next && !s.rbstop && !p_voice.bar_start) {
					p_voice.bar_start = clone(s);
					p_voice.bar_start.type = C.BAR;
					p_voice.bar_start.bar_type = "["
					delete p_voice.bar_start.text;
					p_voice.bar_start.rbstart = 1;
					delete p_voice.bar_start.a_gch;
				}
				if (s1.text) {
					xy_str (x + 4, y2 - gene.curfont.size - 3, s1.text);
				}
				xypath (x, y2);
				if (s1.rbstart == 2) {
					output += 'm0 20v-20';
				}
				output += 'h' + w.toFixed(2);
				if (s.rbstop == 2) {
					output += 'v20';
				}
				output += '"/>\n';
				y_set (s1.st, true, x, w, y + 2);
				if (s.rbstart) {
					s = s.prev;
				}
			}
		}

			
		/*
		* Defines the music elements tied to the staff:
		*	- decoration tied to the staves;
		*	- chord symbols;
		*	- repeat brackets.
		* The staves are not yet defined.
		* Unscaled delayed output.
		*/
		private function draw_deco_staff() : *  {
			var	s; 
			var first_gchord;
			var p_voice;
			var x;
			var y;
			var w;
			var i;
			var v;
			var de;
			var dd;
			var gch;
			var gch2;
			var ix;
			var top;
			var bot;
			var minmax = new Array (nstaff);
			var nd = a_de.length;

			// Create the decorations tied to the staves
			for (i = 0; i <= nstaff; i++) { 
				minmax[i] = {
					ymin: 0,
					ymax: 0
				}
			}
			for (i = 0; i < nd; i++) { 
				de = a_de[i];
				dd = de.dd;

				// If error
				if (!dd) {
					continue;
				}
				
				// If not tied to the staff or head decoration
				// TODO: rephrase
				if (!f_staff[dd.func] || de.m != undefined) {
					continue;
				}
				func_tb[dd.func](de);

				// If start
				if (dd.dd_en) {
					continue;
				}
				if (cfmt.dynalign) {
					if (de.up) {
						if (de.y > minmax[de.st].ymax) {
							minmax[de.st].ymax = de.y;
						}
					} else {
						if (de.y < minmax[de.st].ymin) {
							minmax[de.st].ymin = de.y;
						}
					}
				}
			}
			
			// And, if wanted, set them at a same vertical offset
			for (i = 0; i < nd; i++) { 
				de = a_de[i];
				dd = de.dd;

				// If error
				if (!dd) {
					continue;
				}

				// If start
				if (dd.dd_en || !f_staff[dd.func]) {
					continue;
				}
				if (cfmt.dynalign) {
					if (de.up) {
						y = minmax[de.st].ymax;
					}
					else {
						y = minmax[de.st].ymin;
					}
					de.y = y;
				} else {
					y = de.y;
				}
				if (de.up) {
					y += dd.h;
				}
				y_set (de.st, de.up, de.x, de.val, y);
			}
			
			// Search the vertical offset for the chord symbols
			for (i = 0; i <= nstaff; i++) { 
				minmax[i] = {
					ymin: 0,
					ymax: 24
				}
			}
			for (s = tsfirst; s; s = s.ts_next) { 
				if (!s.a_gch) {
					continue;
				}
				if (!first_gchord) {
					first_gchord = s;
				}
				gch2 = null;
				for (ix = 0; ix < s.a_gch.length; ix++) { 
					gch = s.a_gch[ix];
					if (gch.type != 'g') {
						continue;
					}
					
					// Chord closest to the staff
					gch2 = gch;
					if (gch.y < 0) {
						break;
					}
				}
				if (gch2) {
					w = gch2.w;
					if (gch2.y >= 0) {
						y = y_get(s.st, true, s.x, w);
						if (y > minmax[s.st].ymax) {
							minmax[s.st].ymax = y;
						}
					} else {
						y = y_get(s.st, false, s.x, w);
						if (y < minmax[s.st].ymin) {
							minmax[s.st].ymin = y;
						}
					}
				}
			}
			
			// Draw the chord symbols if any
			if (first_gchord) {
				for (i = 0; i <= nstaff; i++) { 
					bot = staff_tb[i].botbar;
					if (minmax[i].ymin > bot - 4) {
						minmax[i].ymin = bot - 4;
					}
					top = staff_tb[i].topbar;
					if (minmax[i].ymax < top + 4) {
						minmax[i].ymax = top + 4;
					}
				}

				// Restore the scale parameters
				set_dscale(-1);
				for (s = first_gchord; s; s = s.ts_next) { 
					if (!s.a_gch) {
						continue;
					}
					self.draw_gchord (s, minmax[s.st].ymin, minmax[s.st].ymax);
				}
			}
			
			// Draw the repeat brackets
			for (v = 0; v < voice_tb.length; v++) { 
				p_voice = voice_tb[v];
				if (p_voice.second || !p_voice.sym) {
					continue;
				}
				draw_repbra (p_voice);
			}
		}
			
		/*
		 * Draws the measure bar numbers.
		 * Scaled delayed output.
		 */
		private function draw_measnb() : *  {
			var	s : Object;
			var st : int;
			var bar_num : int;
			var x : Number;
			var y : Number;
			var w : Number;
			var any_nb : Boolean;
			var font_size : Number;
			var sy : Object = cur_sy;
			
			// Search the top staff
			for (st = 0; st <= nstaff; st++) { 
				if (sy.st_print[st]) {
					break;
				}
			}

			// No visible staff
			if (st > nstaff) {
				return;		
			}
			set_dscale (st);
			
			// leave the measure numbers as unscaled
			if (staff_tb[st].staffscale != 1) {
				font_size = get_font("measure").size;
				param_set_font("measurefont", "* " + (font_size / staff_tb[st].staffscale).toString());
			}
			set_font("measure");
			
			// Clef
			s = tsfirst;
			bar_num = gene.nbar;
			if (bar_num > 1) {
				if (cfmt.measurenb == 0) {
					any_nb = true;
					
					// Ciacob: we will always show the measure number only once, to the left of the staff system,
					// excluding the first staff. Therefore, computing the vertical offset in order to "avoid" other
					// staff elements will not be needed, as nothing else is displayed there anyway.
					// y = y_get(st, true, 0, 20);
					// if (y < staff_tb[st].topbar + 14) {
					//	y = staff_tb[st].topbar + 14;
					//}
					
					y = staff_tb[st].topbar;  
					if (cfmt.measurebox) {
						xy_str_b (0, y, bar_num.toString());
					}
					else {
						xy_str (0, y, bar_num.toString());
					}
					y_set (st, true, 0, 20, y + gene.curfont.size + 2);
				} else if (bar_num % cfmt.measurenb == 0) {
					while ((s = s.ts_next)) {
						switch (s.type) {
							case C.METER:
							case C.CLEF:
							case C.KEY:
							case C.STBRK:
								continue;
						}
						break;
					}
					while (s.st != st) { 
						s = s.ts_next;
					}
					
					// Don't display the number twice
					if (s.type != C.BAR || !s.bar_num) {
						if (s.prev && s.prev.type != C.CLEF) {
							s = s.prev;
						}
						x = s.x - s.wl;
						any_nb = true;
						w = cwid('0') * gene.curfont.swfac;
						if (bar_num >= 10) {
							w *= bar_num >= 100 ? 3 : 2;
						}
						if (cfmt.measurebox) {
							w += 4;
						}
						y = y_get(st, true, x, w);
						if (y < staff_tb[st].topbar + 6) {
							y = staff_tb[st].topbar + 6;
						}
						y += 2;
						if (cfmt.measurebox) {
							xy_str_b(x, y, bar_num.toString());
							y += 2;
							w += 3;
						} else {
							xy_str(x, y, bar_num.toString());
						}
						y += gene.curfont.size;
						y_set (st, true, x, w, y);
						s.ymx = y;
					}
				}
			}
			
			while ((s = s.ts_next)) {
				switch (s.type) {
					case C.STAVES:
						sy = s.sy;
						for (st = 0; st < nstaff; st++) { 
							if (sy.st_print[st]) {
								break;
							}
						}
						set_sscale(st);
						continue;
					default:
						continue;
					case C.BAR:
						if (!s.bar_num) {
							continue;
						}
						break;
				}
				
				bar_num = s.bar_num;
				if (cfmt.measurenb == 0 || (bar_num % cfmt.measurenb) != 0 || !s.next) {
					continue;
				}
				if (!any_nb) {
					any_nb = true;
				}
				w = cwid('0') * gene.curfont.swfac;
				if (bar_num >= 10) {
					w *= bar_num >= 100 ? 3 : 2;
				}
				if (cfmt.measurebox) {
					w += 4;
				}
				x = s.x - w * .4;
				y = y_get (st, true, x, w);
				if (y < staff_tb[st].topbar + 6) {
					y = staff_tb[st].topbar + 6;
				}
				if (s.next.type == C.NOTE) {
					if (s.next.stem > 0) {
						if (y < s.next.ys - gene.curfont.size) {
							y = s.next.ys - gene.curfont.size;
						}
					} else {
						if (y < s.next.y) {
							y = s.next.y;
						}
					}
				}
				y += 2;
				if (cfmt.measurebox) {
					xy_str_b (x, y, bar_num.toString());
					y += 2;
					w += 3;
				} else {
					xy_str (x, y, bar_num.toString());
				}
				y += gene.curfont.size;
				y_set (st, true, x, w, y);
				s.ymx = y;
			}
			gene.nbar = bar_num;
			
			if (font_size) {
				param_set_font ("measurefont", "* " + font_size.toString());
			}
		}
			
		/*
		 * Draws the note of the tempo.
		 */
		private function draw_notempo (s, x, y, dur, sc) : *  {
			var	dx; 
			var p;
			var dotx;
			var elts = identify_note (s, dur);
			var head = elts[0];
			var dots = elts[1];
			var nflags = elts[2];
			
			out_XYAB ('<g class="note-tempo" transform="translate(X,Y) scale(F)">\n', x + 4, y + 5, sc);
			switch (head) {
				case C.OVAL:
					p = "HD";
					break;
				case C.EMPTY:
					p = "Hd";
					break;
				default:
					p = "hd";
					break;
			}
			xygl (-posx, posy, p);
			dx = 4;
			if (dots) {
				dotx = 9;
				if (nflags > 0) {
					dotx += 4;
				}
				switch (head) {
					case C.SQUARE:
						dotx += 3;
						break;
					case C.OVALBARS:
					case C.OVAL:
						dotx += 2;
						break;
					case C.EMPTY:
						dotx += 1;
						break;
				}
				dx = dotx * dots;
				dotx -= posx;
				while (--dots >= 0) { 
					xygl (dotx, posy, "dot");
					dotx += 3.5;
				}
			}
			if (dur < C.BLEN) {
				if (nflags <= 0) {

					// Stem height
					out_stem (-posx, posy, 21);
				} else {
					out_stem (-posx, posy, 21, false, nflags);
					if (dx < 6) {
						dx = 6;
					}
				}
			}
			output += '</g>\n';
			return (dx + 15) * sc;
		}
			
		/*
		 * Estimates the tempo width.
		 */
		private function tempo_width (s) : *  {
			var	w = 0;
			set_font("tempo");
			if (s.tempo_str1) {
				w = strwh (s.tempo_str1)[0];
			}
			if (s.tempo_ca) {
				w += strwh(s.tempo_ca)[0];
			}
			if (s.tempo_notes) {
				w += 10 * s.tempo_notes.length + 6 + cwid(' ') * gene.curfont.swfac * 6 + 10;
			}
			if (s.tempo_str2) {
				w += strwh(s.tempo_str2)[0];
			}
			return w;
		}
			
		/*
		 * Outputs a tempo.
		 */
		private function write_tempo (s, x, y) : *  {
			var	j;
			var dx;
			var sc = .6 * gene.curfont.size / 15.0; // FIXME: 15.0 = initial tempofont
			set_font ("tempo");
			if (s.tempo_str1) {
				xy_str (x, y, s.tempo_str1);
				x += strwh(s.tempo_str1)[0] + 3;
			}
			if (s.tempo_notes) {
				for (j = 0; j < s.tempo_notes.length; j++) { 
					x += draw_notempo(s, x, y, s.tempo_notes[j], sc);
				}
				xy_str (x, y, "=");
				x += strwh("= ")[0];
				if (s.tempo_ca) {
					xy_str(x, y, s.tempo_ca);
					x += strwh(s.tempo_ca)[0];
				}
				if (s.tempo) {
					xy_str (x, y, s.tempo.toString());
					dx = cwid('0') * gene.curfont.swfac;
					x += dx + 5;
					if (s.tempo >= 10) {
						x += dx;
						if (s.tempo >= 100) {
							x += dx;
						}
					}
				} else {
					x += draw_notempo(s, x, y, s.new_beat, sc);
				}
			}
			if (s.tempo_str2) {
				xy_str (x, y, s.tempo_str2);
			}
			
			// Don't display anymore
			s.del = true;
		}
			
		/*
		 * Draws the parts and the tempo information.
		 * The staves are being defined.
		 */
		private function draw_partempo (st, top) : *  {
			var	s;
			var some_part;
			var some_tempo;
			var h;
			var w;
			var y;

			// Put the tempo indication at top
			var dy = 0;
			var ht = 0;
			
			// Get the minimal y offset
			var	ymin = staff_tb[st].topbar + 8;
			var dosh = 0;
			var shift = 1;
			var x = 0;
			for (s = tsfirst; s; s = s.ts_next) { 
				if (s.type != C.TEMPO || s.del) {
					continue;
				}
				if (!some_tempo) {
					some_tempo = s;
				}
				w = tempo_width (s);

				// At start of tune, shift the tempo over the key signature
				if (s.time == 0) {
					s.x = 40;
				}
				y = y_get (st, true, s.x - 16, w);
				if (y > ymin) {
					ymin = y;
				}
				if (x >= s.x - 16 && !(dosh & (shift >> 1))) {
					dosh |= shift;
				}
				shift <<= 1;
				x = s.x - 16 + w;
			}
			if (some_tempo) {
				set_sscale(-1);
				set_font("tempo");
				ht = gene.curfont.size + 2 + 2;
				y = 2 - ht;
				h = y - ht;
				if (dosh != 0) {
					ht *= 2;
				}
				if (top < ymin + ht) {
					dy = ymin + ht - top;
				}
				
				// Draw the tempo indications
				for (s = some_tempo; s; s = s.ts_next) { 

					// (displayed by %%titleformat)
					if (s.type != C.TEMPO || s.del) {
						continue;
					}
					if (user.anno_start || user.anno_stop) {
						s.wl = 16;
						s.wr = 30;
						s.ymn = (dosh & 1) ? h : y;
						s.ymx = s.ymn + 14;
						anno_start (s);
					}
					write_tempo (s, s.x - 16, (dosh & 1) ? h : y);
					anno_stop(s);
					dosh >>= 1;
				}
			}
			
			// Then, put the parts
			// FIXME: should reduce vertical space if parts don't overlap tempo
			ymin = staff_tb[st].topbar + 8;
			for (s = tsfirst; s; s = s.ts_next) { 
				if (s.type != C.PART) {
					continue;
				}
				if (!some_part) {
					some_part = s;
					set_font("parts");
					h = gene.curfont.size + 2 + 2
				}
				w = strwh(s.text)[0];
				y = y_get (st, true, s.x - 10, w + 3);
				if (ymin < y) {
					ymin = y;
				}
			}
			if (some_part) {
				set_sscale (-1);
				if (top < ymin + h + ht) {
					dy = ymin + h + ht - top;
				}
				
				for (s = some_part; s; s = s.ts_next) { 
					if (s.type != C.PART) {
						continue;
					}
					s.x -= 10;
					if (user.anno_start || user.anno_stop) {
						w = strwh(s.text)[0];
						s.wl = 0;
						s.wr = w;
						s.ymn = -ht - h;
						s.ymx = s.ymn + h;
						anno_start(s);
					}
					if (cfmt.partsbox) {
						xy_str_b(s.x, 2 - ht - h, s.text);
					}
					else {
						xy_str(s.x, 2 - ht - h, s.text);
					}
					anno_stop(s);
				}
			}
			return dy;
		}
			
			
		// DRAW FUNCTIONS
		// --------------
		
		// min stem height under beams
		private const STEM_MIN : Number = 16;

		// ... for notes with two beams
		private const STEM_MIN2 : Number = 14;

		/* ... for notes with three beams */
		private const STEM_MIN3 : Number = 12;

		/* ... for notes with four beams */
		private const STEM_MIN4 : Number = 10;

		/* min stem height for chords under beams */
		private const STEM_CH_MIN : Number = 14;

		/* ... for notes with two beams */
		private const STEM_CH_MIN2 : Number = 10;

		/* ... for notes with three beams */
		private const STEM_CH_MIN3 : Number = 9;

		/* ... for notes with four beams */
		private const STEM_CH_MIN4 : Number = 9;

		/* width of a beam stroke */
		private const BEAM_DEPTH : Number = 3.2;

		/* pos of flat beam relative to staff line */
		private const BEAM_OFFSET : Number = 0.25;

		/* shift of second and third beams */
		private const BEAM_SHIFT : Number = 5;

		/* max slope of a beam */
		private const BEAM_SLOPE : Number = 0.4;

		/* length of stub for flag under beam */
		private const BEAM_STUB : Number = 8;

		/* max slope of a slur */
		private const SLUR_SLOPE : Number = 0.5;

		/* grace note stem length */
		private const GSTEM : Number = 15;

		/* x offset for grace note stem */
		private const GSTEM_XOFF : Number = 2.3;

		private var cache;
		
		/*
		 * Computes an up/down shift, needed to get k*6 
		 */
		private function rnd6 (y) : *  {
			var iy = Math.round((y + 12) / 6) * 6 - 12;
			return iy - y;
		}

		/* 
		 * Computes the best vertical offset for the beams
		 */
		private function b_pos (grace, stem, nflags, b) : *  {
			var	$top;
			var bot;
			var d1;
			var d2;
			var $shift = !grace ? BEAM_SHIFT : 3.5;
			var depth = !grace ? BEAM_DEPTH : 1.8;

			if (stem > 0) {
				bot = b - (nflags - 1) * $shift - depth;
				if (bot > 26) {
					return 0;
				}
				$top = b;
			} else {
				$top = b + (nflags - 1) * $shift + depth;
				if ($top < -2) {
					return 0;
				}
				bot = b;
			}
			
			d1 = rnd6 ($top - BEAM_OFFSET);
			d2 = rnd6 (bot + BEAM_OFFSET);
			return (d1 * d1 > d2 * d2)? d2 : d1;
		}
			
		/*
		 * Duplicate a note for beaming continuation
		 */
		private function sym_dup (s_orig) : *  {
			var	m;
			var note;
			var s = clone(s_orig);
			
			s.invis = true;
			delete s.text;
			delete s.a_gch;
			delete s.a_ly;
			delete s.a_dd;
			s.notes = clone (s_orig.notes);
			for (m = 0; m <= s.nhd; m++) { 
				note = s.notes[m] = clone(s_orig.notes[m]);
				delete note.a_dcn;
			}
			return s;
		}
			
		private var min_tb = [
			[STEM_MIN, STEM_MIN, STEM_MIN2, STEM_MIN3, STEM_MIN4, STEM_MIN4],
			[STEM_CH_MIN, STEM_CH_MIN, STEM_CH_MIN2, STEM_CH_MIN3, STEM_CH_MIN4, STEM_CH_MIN4]
		];
		
		/*
		 * Calculates a beam.
		 * The staves may be defined or not.
		 * Possible hook.
		 */
		private function calculate_beam (bm, s1) : *  {
			var	s;
			var s2;
			var notes;
			var nflags;
			var st;
			var v;
			var two_staves;
			var two_dir;
			var x;
			var y;
			var ys;
			var a;
			var b;
			var stem_err;
			var max_stem_err;
			var p_min;
			var p_max;
			var s_closest;
			var stem_xoff;
			var scale;
			var visible;
			var dy;
			
			// Beam from previous music line
			if (!s1.beam_st) {
				s = sym_dup(s1);
				lkvsym (s, s1);
				lktsym (s, s1);
				s.x -= 12;
				if (s.x > s1.prev.x + 12) {
					s.x = s1.prev.x + 12;
				}
				s.beam_st = true;
				delete s.beam_end;
				s.tmp = true;
				delete s.slur_start;
				delete s.slur_end;
				s1 = s;
			}
			
			// Search last note in beam
			// Set x positions, count notes and flags
			notes = nflags = 0;	
			two_staves = two_dir = false;
			st = s1.st;
			v = s1.v;
			stem_xoff = s1.grace? GSTEM_XOFF : 3.5;
			for (s2 = s1;  ;s2 = s2.next) { 
				if (s2.type == C.NOTE) {
					if (s2.nflags > nflags) {
						nflags = s2.nflags;
					}
					notes++;
					if (s2.st != st) {
						two_staves = true;
					}
					if (s2.stem != s1.stem) {
						two_dir = true;
					}
					if (!visible && !s2.invis && (!s2.stemless || s2.trem2)) {
						visible = true;
					}
					if (s2.beam_end) {
						break;
					}
				}

				// Beam towards next music line
				if (!s2.next) {
					while ((s2 = s2.prev)) {
						if (s2.type == C.NOTE) {
							break;
						}
					}
					s = sym_dup(s2);
					s.next = s2.next;
					if (s.next) {
						s.next.prev = s;
					}
					s2.next = s;
					s.prev = s2;
					s.ts_next = s2.ts_next;
					if (s.ts_next) {
						s.ts_next.ts_prev = s;
					}
					s2.ts_next = s;
					s.ts_prev = s2;
					delete s.beam_st;
					s.beam_end = true;
					s.tmp = true;
					delete s.slur_start;
					delete s.slur_end;
					s.x += 12;
					if (s.x < realwidth - 12) {
						s.x = realwidth - 12;
					}
					s2 = s;
					notes++;
					break;
				}
			}
			
			// At least, we must have one visible note with a stem
			if (!visible) {
				return false;
			}
			
			// Don't display the flags
			bm.s2 = s2;

			// Staves not defined
			if (staff_tb[st].y == 0) {
				if (two_staves) {
					return false;
				}
			}

			// Staves defined
			else {
				if (!two_staves) {

					// Beam already calculated
					bm.s1 = s1;
					bm.a = (s1.ys- s2.ys) / (s1.xs - s2.xs);
					bm.b = s1.ys - s1.xs * bm.a + staff_tb[st].y;
					bm.nflags = nflags;
					return true;
				}
			}
			
			s_closest = s1;
			p_min = 100;
			p_max = 0;
			for (s = s1; ; s = s.next) { 
				if (s.type != C.NOTE) {
					continue;
				}
				if ((scale = s.p_v.scale) == 1) {
					scale = staff_tb[s.st].staffscale;
				}
				if (s.stem >= 0) {
					x = stem_xoff + s.notes[0].shhd;
					if (s.notes[s.nhd].pit > p_max) {
						p_max = s.notes[s.nhd].pit;
						s_closest = s;
					}
				} else {
					x = (-stem_xoff + s.notes[s.nhd].shhd);
					if (s.notes[0].pit < p_min) {
						p_min = s.notes[0].pit;
						s_closest = s;
					}
				}
				s.xs = s.x + x * scale;
				if (s == s2) {
					break;
				}
			}
			
			// Have flat beams when asked
			if (cfmt.flatbeams) {
				a = 0;
			}
				
			// If a note inside the beam is the closest to the beam, the beam is flat
			else if (!two_dir && notes >= 3 && s_closest != s1 && s_closest != s2) {
				a = 0;
			}
			y = (s1.ys + staff_tb[st].y);
			if (a == undefined) {
				a = (s2.ys + staff_tb[s2.st].y - y) / (s2.xs - s1.xs);
			}
			if (a != 0) {
				if (a > 0) {
					// Max steepness for beam
					a = BEAM_SLOPE * a / (BEAM_SLOPE + a);
				}
				else {
					a = BEAM_SLOPE * a / (BEAM_SLOPE - a);
				}
			}
			b = y - a * s1.xs;
			
			// Provide room for the symbols in the staff.
			// Check stem lengths.
			// FIXME: have a look again
			max_stem_err = 0;
			s = s1;

			// 2 directions
			if (two_dir) {

				// FIXME: more to do
				ys = ((s1.grace ? 3.5 : BEAM_SHIFT) * (nflags - 1) + BEAM_DEPTH) * .5;
				if (s1.stem != s2.stem && s1.nflags < s2.nflags) {
					ys *= s2.stem;
				} else {
					ys *= s1.stem;
				}
				b += ys;
			}

			// Normal notes
			else if (!s1.grace) {
				var beam_h = BEAM_DEPTH + BEAM_SHIFT * (nflags - 1);

				// FIXME: added for abc2svg
				while (s.ts_prev && s.ts_prev.type == C.NOTE && s.ts_prev.time == s.time && s.ts_prev.x > s1.xs) { 
					s = s.ts_prev;
				}
				
				for (; s && s.time <= s2.time; s = s.ts_next) { 
					if (s.type != C.NOTE || s.invis || (s.st != st && s.v != v)) {
						continue;
					}
					x = (s.v == v)? s.xs : s.x;
					ys = a * x + b - staff_tb[s.st].y;
					if (s.v == v) {
						stem_err = min_tb[(s.nhd == 0)? 0 : 1][s.nflags];
						if (s.stem > 0) {
							if (s.notes[s.nhd].pit > 26) {
								stem_err -= 2;
								if (s.notes[s.nhd].pit > 28) {
									stem_err -= 2;
								}
							}
							stem_err -= ys - 3 * (s.notes[s.nhd].pit - 18);
						} else {
							if (s.notes[0].pit < 18) {
								stem_err -= 2;
								if (s.notes[0].pit < 16) {
									stem_err -= 2;
								}
							}
							stem_err -= 3 * (s.notes[0].pit - 18) - ys;
						}
						stem_err += BEAM_DEPTH + BEAM_SHIFT * (s.nflags - 1);
					} else {

						// FIXME: KO when two_staves
						if (s1.stem > 0) {
							if (s.stem > 0) {

								// FIXME: KO when the voice numbers are inverted
								if (s.ymn > ys + 4 || s.ymx < ys - beam_h - 2) {
									continue;
								}
								if (s.v > v) {
									stem_err = s.ymx - ys;
								}
								else {
									stem_err = s.ymn + 8 - ys;
								}
							} else {
								stem_err = s.ymx - ys;
							}
						} else {
							if (s.stem < 0) {
								if (s.ymx < ys - 4 || s.ymn > ys - beam_h - 2) {
									continue;
								}
								if (s.v < v) {
									stem_err = ys - s.ymn;
								}
								else {
									stem_err = ys - s.ymx + 8;
								}
							} else {
								stem_err = ys - s.ymn;
							}
						}
						stem_err += 2 + beam_h;
					}
					if (stem_err > max_stem_err) {
						max_stem_err = stem_err;
					}
				}
			} 

			// Grace notes
			else {
				while ((s = s.next)) {
					ys = a * s.xs + b - staff_tb[s.st].y;
					stem_err = GSTEM - 2;
					if (s.stem > 0) {
						stem_err -= ys - (3 * (s.notes[s.nhd].pit - 18));
					}
					else {
						stem_err += ys - (3 * (s.notes[0].pit - 18));
					}
					stem_err += 3 * (s.nflags - 1);
					if (stem_err > max_stem_err) {
						max_stem_err = stem_err
					}
					if (s == s2) {
						break;
					}
				}
			}
			
			// Shift beam if stems too short
			if (max_stem_err > 0) {
				b += s1.stem * max_stem_err;
			}
			
			// Have room for the gracenotes, bars and clefs
			// FIXME: test
			if (!two_staves && !two_dir) {
				for (s = s1.next; ; s = s.next) { 
					var g;
					switch (s.type) {

						// Cannot move rests in multi-voices
						// FIXME: too much vertical shift if some space above the note
						// FIXME: this does not fix rest under beam in second voice (ts_prev)
						case C.REST:
							g = s.ts_next;
							if (!g || g.st != st || (g.type != C.NOTE && g.type != C.REST)) {
								break;
							}
							// fall thru
						case C.BAR:
							if (s.invis) {
								break;
							}
							// fall thru
						case C.CLEF:
							y = a * s.x + b;
							if (s1.stem > 0) {
								y = s.ymx - y + BEAM_DEPTH + BEAM_SHIFT * (nflags - 1) + 2;
								if (y > 0) {
									b += y;
								}
							} else {
								y = s.ymn - y - BEAM_DEPTH - BEAM_SHIFT * (nflags - 1) - 2
								if (y < 0) {
									b += y;
								}
							}
							break;
						case C.GRACE:
							for (g = s.extra; g; g = g.next) { 
								y = a * g.x + b;
								if (s1.stem > 0) {
									y = g.ymx - y + BEAM_DEPTH + BEAM_SHIFT * (nflags - 1) + 2;
									if (y > 0) {
										b += y;
									}
								} else {
									y = g.ymn - y - BEAM_DEPTH - BEAM_SHIFT * (nflags - 1) - 2;
									if (y < 0) {
										b += y;
									}
								}
							}
							break;
					}
					if (s == s2) {
						break;
					}
				}
			}
			
			// Shift flat beams onto staff lines
			if (a == 0) {
				b += b_pos(s1.grace, s1.stem, nflags, b - staff_tb[st].y);
			}
			
			// Adjust final stems and rests under beam
			for (s = s1; ; s = s.next) { 
				switch (s.type) {
					case C.NOTE:
						s.ys = a * s.xs + b - staff_tb[s.st].y;
						if (s.stem > 0) {
							s.ymx = s.ys + 2.5;

							// FIXME: hack
							if (s.ts_prev && s.ts_prev.stem > 0 && s.ts_prev.st == s.st && s.ts_prev.ymn < s.ymx && s.ts_prev.x == s.x
								&& s.notes[0].shhd == 0) {
								
								// Fix stem clash
								s.ts_prev.x -= 3; 
								s.ts_prev.xs -= 3;
							}
						} else {
							s.ymn = s.ys - 2.5;
						}
						break;
					case C.REST:
						y = a * s.x + b - staff_tb[s.st].y;
						dy = BEAM_DEPTH + BEAM_SHIFT * (nflags - 1) + (s.head != C.FULL ? 4 : 9);
						if (s1.stem > 0) {
							y -= dy;
							if (s1.multi == 0 && y > 12) {
								y = 12;
							}
							if (s.y <= y) {
								break;
							}
						} else {
							y += dy;
							if (s1.multi == 0 && y < 12) {
								y = 12;
							}
							if (s.y >= y) {
								break;
							}
						}
						if (s.head != C.FULL) {
							y = (((y + 3 + 12) / 6) | 0) * 6 - 12;
						}
						s.y = y;
						break;
				}
				if (s == s2) {
					break;
				}
			}
			
			// Save beam parameters
			// If staves were not yet defined, exit
			if (staff_tb[st].y == 0) {
				return false;
			}
			bm.s1 = s1;
			bm.a = a;
			bm.b = b;
			bm.nflags = nflags;
			return true;
		}
			

		/*
		 * Draws a single beam.
		 * @param	n Beam number (1..n);
		 */
		private function draw_beam (x1, x2, dy, h, bm, n) : *  {
			var	y1;
			var dy2;
			var s = bm.s1;
			var nflags = s.nflags;
			
			if (s.ntrem) {
				nflags -= s.ntrem;
			}
			if (s.trem2 && n > nflags) {
				if (s.dur >= C.BLEN / 2) {
					x1 = s.x + 6;
					x2 = bm.s2.x - 6;
				} else if (s.dur < C.BLEN / 4) {
					x1 += 5;
					x2 -= 6;
				}
			}
			
			y1 = bm.a * x1 + bm.b - dy;
			x2 -= x1;

			// FIXME: scale (bm.a already scaled!)
			x2 /= stv_g.scale;
			dy2 = bm.a * x2 * stv_g.scale;
			xypath (x1, y1, true);
			output += ('l' + x2.toFixed(2) + ' ' + (-dy2).toFixed(2) +
							'v' + h.toFixed(2) +
							'l' + (-x2).toFixed(2) + ' ' + dy2.toFixed(2) +
							'z"/>\n');
		}



			/* -- draw the beams for one word -- */
			/* (the staves are defined) */
		private function draw_beams(bm) : *  {
				var	s, i, beam_dir, shift, bshift, bstub, bh, da,
				k, k1, k2, x1,
				s1 = bm.s1,
					s2 = bm.s2
				

				
				anno_start(s1, 'beam')
				/*fixme: KO if many staves with different scales*/
				//	set_scale(s1)
				if (!s1.grace) {
					bshift = BEAM_SHIFT;
					bstub = BEAM_STUB;
					shift = .34;		/* (half width of the stem) */
					bh = BEAM_DEPTH
				} else {
					bshift = 3.5;
					bstub = 3.2;
					shift = .29;
					bh = 1.8
				}
				
				/*fixme: quick hack for stubs at end of beam and different stem directions*/
				beam_dir = s1.stem
				if (s1.stem != s2.stem
					&& s1.nflags < s2.nflags)
					beam_dir = s2.stem
				if (beam_dir < 0)
					bh = -bh;
				
				/* make first beam over whole word and adjust the stem lengths */
				draw_beam(s1.xs - shift, s2.xs + shift, 0, bh, bm, 1);
				da = 0
				for (s = s1; ; s = s.next) { 
					if (s.type == C.NOTE
						&& s.stem != beam_dir)
						s.ys = bm.a * s.xs + bm.b
							- staff_tb[s.st].y
							+ bshift * (s.nflags - 1) * s.stem
							- bh
					if (s == s2)
						break
				}
				
				if (s1.feathered_beam) {
					da = bshift / (s2.xs - s1.xs)
					if (s1.feathered_beam > 0) {
						da = -da;
						bshift = da * s1.xs
					} else {
						bshift = da * s2.xs
					}
					da = da * beam_dir
				}
				
				/* other beams with two or more flags */
				shift = 0
				for (i = 2; i <= bm.nflags; i++) { 
					shift += bshift
					if (da != 0)
						bm.a += da
					for (s = s1; ; s = s.next) { 
						if (s.type != C.NOTE
							|| s.nflags < i) {
							if (s == s2)
								break
							continue
						}
						if (s.trem1
							&& i > s.nflags - s.ntrem) {
							x1 = (s.dur >= C.BLEN / 2) ? s.x : s.xs;
							draw_beam(x1 - 5, x1 + 5,
								(shift + 2.5) * beam_dir,
								bh, bm, i)
							if (s == s2)
								break
							continue
						}
						k1 = s
						while (1) { 
							if (s == s2)
								break
							k = s.next
							if (k.type == C.NOTE || k.type == C.REST) {
								if (k.trem1){
									if (k.nflags - k.ntrem < i)
										break
								} else if (k.nflags < i) {
									break
								}
							}
							if (k.beam_br1
								|| (k.beam_br2 && i > 2))
								break
							s = k
						}
						k2 = s
						while (k2.type != C.NOTE) { 
							k2 = k2.prev;
						}
						x1 = k1.xs
						if (k1 == k2) {
							if (k1 == s1) {
								x1 += bstub
							} else if (k1 == s2) {
								x1 -= bstub
							} else if (k1.beam_br1
								|| (k1.beam_br2
									&& i > 2)) {
								x1 += bstub
							} else {
								k = k1.next
								while (k.type != C.NOTE) { 
									k = k.next;
								}
								if (k.beam_br1
									|| (k.beam_br2 && i > 2)) {
									x1 -= bstub
								} else {
									k1 = k1.prev
									while (k1.type != C.NOTE) { 
										k1 = k1.prev;
									}
									if (k1.nflags < k.nflags
										|| (k1.nflags == k.nflags
											&& k1.dots < k.dots))
										x1 += bstub
									else
										x1 -= bstub
								}
							}
						}
						draw_beam(x1, k2.xs,
							shift * beam_dir,
							bh, bm, i)
						if (s == s2)
							break
					}
				}
				if (s1.tmp)
					unlksym(s1)
				else if (s2.tmp)
					unlksym(s2)
				anno_stop(s1, 'beam')
			}
			
			/**
			 * Draws the left side of the staves
			 */
			private function draw_lstaff(x) : void {

				var	i; 
				var j; 
				var yb; 
				var h;
				var nst = cur_sy.nstaff;
				var l = 0;
				
				/* -- draw a system brace or bracket -- */
				function draw_sysbra (x, st, flag) : void {
					var i; 
					var st_end; 
					var yt; 
					var yb;
					
					while (!cur_sy.st_print[st]) { 
						if (cur_sy.staves[st].flags & flag) {
							return;
						}
						st++;
					}
					i = st_end = st;
					while (true) { 
						if (cur_sy.st_print[i]) {
							st_end = i;
						}
						if (cur_sy.staves[i].flags & flag) {
							break;
						}
						i++;
					}
					yt = staff_tb[st].y + staff_tb[st].topbar * staff_tb[st].staffscale;
					yb = staff_tb[st_end].y + staff_tb[st_end].botbar * staff_tb[st_end].staffscale
					if (flag & (CLOSE_BRACE | CLOSE_BRACE2)) {
						out_brace(x, yt, yt - yb);
					}
					else {
						if (flag & CLOSE_BRACKET2) {
							out_line_bracket(x, yt, yt - yb);
						} else {
							out_bracket(x, yt, yt - yb);
						}
					}
				}
				
				for (i = 0; ; i++) { 
					if (cur_sy.staves[i].flags & (OPEN_BRACE | OPEN_BRACKET)) {
						l++;
					}
					if (cur_sy.st_print[i]) {
						break;
					}
					if (cur_sy.staves[i].flags & (CLOSE_BRACE | CLOSE_BRACKET)) {
						l--;
					}
					if (i == nst) {
						break;
					}
				}
				for (j = nst; j > i; j--) { 
					if (cur_sy.st_print[j]) {
						break;
					}
				}
				if (i == j && l == 0) {
					return;
				}
				yb = staff_tb[j].y + staff_tb[j].botbar * staff_tb[j].staffscale;
				h = staff_tb[i].y + staff_tb[i].topbar * staff_tb[i].staffscale - yb;
				xypath (x, yb);
				output += "v" + (-h).toFixed(2) + '"/>\n';
				for (i = 0; i <= nst; i++) { 
					if (cur_sy.staves[i].flags & OPEN_BRACE) {
						draw_sysbra(x, i, CLOSE_BRACE);
					}
					if (cur_sy.staves[i].flags & OPEN_BRACKET) {
						draw_sysbra(x, i, CLOSE_BRACKET);
					}
					if (cur_sy.staves[i].flags & OPEN_BRACE2) {
						draw_sysbra(x - 6, i, CLOSE_BRACE2);
					}
					if (cur_sy.staves[i].flags & OPEN_BRACKET2) {
						draw_sysbra(x - 6, i, CLOSE_BRACKET2);
					}
				}
			}
			
			/**
			 * Draws the time signature.
			 */
			private function draw_meter (x : Number, s : Object) : void {
				if (!s.a_meter) {
					return;
				}
				
				const SYMBOL_SCALE : Number = 0.12;
				const SYMBOL_H : Number = 80;
				const GROUP_Y_OFFSET : Number = 2;
				const SYMBOL_Y_OFFSET : Number = 3;
				const SYMBOL_X_OFFSET : Number = -6;
				
				var i : int; 
				var j : int;
				var fractionChar : String;
				var	f : String;
				var meter : Object;
				var xOffset : int;
				var charInfo : Object;
				var charId : String;
				var charW : Number;
				var charH : Number;
				var scaledSymbolW : Number;
				var symbolY : Number;
				
				var st : int = s.st;
				var p_staff : Object = staff_tb[st];
				var y : Number = p_staff.y + GROUP_Y_OFFSET;
				var scaledSymbolH : Number = SYMBOL_SCALE * SYMBOL_H;
				
				// Adjust the vertical offset according to the staff definition
				if (p_staff.stafflines != '|||||') {
					y += (p_staff.topbar + p_staff.botbar) / 2 - 12;
				}
				
				// Compile and output the needed SVG
				for (i = 0; i < s.a_meter.length; i++) { 
					meter = s.a_meter[i];
					x = s.x + s.x_meter[i] + SYMBOL_X_OFFSET;
					
					// (a) Time signature is a fraction
					// Grab numerator and denominator chars and render them using SVG paths
					// TODO: center the fraction's numerator/denominator numbers in respect to one each other
					if (meter.bot) {
						var fractionSlots : Array = [meter.top, meter.bot];
						for (var k:int = 0; k < fractionSlots.length; k++) { 
							var slot : String = fractionSlots[k] as String;
							xOffset = x;
							symbolY = (k == 0)? y + (scaledSymbolH * 2) + SYMBOL_Y_OFFSET : y + scaledSymbolH;
							for (j = 0; j < slot.length; j++) { 
								fractionChar = slot.charAt(j);
								charInfo = tgls['meter' + fractionChar];
								if (charInfo) {
									charId = charInfo.def;
									charW = charInfo.defW;
									scaledSymbolW = charW * SYMBOL_SCALE;
									out_XYAB('<g class="time-signature" transform="translate(X,Y) scale(A,A)"><use xlink:href="B"/></g>\n',
										xOffset, symbolY, SYMBOL_SCALE, charId);
									xOffset += scaledSymbolW;
								}
							}
						}
					}
					
					// (b) Time signature is a symbol
					// FIXME: (RE) IMPLEMENT
//					else {
//						switch (meter.top.charAt(0)) {
//							case 'C':
//								f = meter.top.charAt(1) != '|' ? "csig" : "ctsig";
//								x -= 5;
//								y += 12;
//								break;
//							case 'c':
//								f = meter.top.charAt(1) != '.' ? "imsig" : "iMsig";
//								break;
//							case 'o':
//								f = meter.top.charAt(1) != '.' ? "pmsig" : "pMsig";
//								break;
//							default:
//								tmp1 = '';
//								for (j = 0; j < meter.top.length; j++) {
//									tmp1 += tgls["meter" + meter.top.charAt(j)].c;
//								}
//								out_XYAB('<text x="X" y="Y" text-anchor="middle">A</text>\n', x, y + 12, tmp1);
//								break;
//						}
//					}
//					if (f) {
//						xygl (x, y, f);
//					}
				}
			}
			
			// Draw an accidental
			private function draw_acc(x, y, acc, micro_n, micro_d, noteIds : Array = null) : void {
				if (micro_n) {
					
					// flat? double flat : sharp
					if (micro_n == micro_d) {
						acc = (acc == -1)? -2 : 2;
					} else if (micro_n * 2 != micro_d) {
						xygl (x, y, "acc" + acc + '_' + micro_n + '_' + micro_d, noteIds);
						return;
					}
				}
				xygl (x, y, "acc" + acc, noteIds);
			}
			
			// draw helper lines between yl and yu
			//fixme: double lines when needed for different voices
			private function draw_hl(x, yl, yu, st, hltype) : *  {
				var	i, j,
				p_staff = staff_tb[st],
					staffb = p_staff.y,
					stafflines = p_staff.stafflines,
					top = (stafflines.length - 1) * 6,
					bot = p_staff.botline
				
				// no helper if no line
				if (!/[\[|]/.test(stafflines))
					return
				
				if (yl % 6)
					yl += 3
				if (yu % 6)
					yu -= 3
				if (stafflines.indexOf('-') >= 0	// if forced helper lines ('-')
					&& ((yl > bot && yl < top) || (yu > bot && yu < top)
						|| (yl <= bot && yu >= top))) {
					i = yl;
					j = yu
					while (i > bot && stafflines[i / 6] == '-') { 
						i -= 6;
					}
					while (j < top && stafflines[j / 6] == '-') { 
						j += 6;
					}
					for ( ; i < j; i += 6) { 
						if (stafflines[i / 6] == '-')
							xygl(x, staffb + i, hltype)	// hole
					}
				}
				for (; yl < bot; yl += 6) { 
					xygl(x, staffb + yl, hltype);
				}
				for (; yu > top; yu -= 6) { 
					xygl(x, staffb + yu, hltype);
				}
			}
			
			/* -- draw a key signature -- */
			private var	sharp_cl : Vector.<int> = Vector.<int> ([24, 9, 15, 21, 6, 12, 18]);
			private var flat_cl : Vector.<int> = Vector.<int> ([12, 18, 24, 9, 15, 21, 6]);
			private var sharp1 : Vector.<int> = Vector.<int> ([-9, 12, -9, -9, 12, -9]);
			private var sharp2 : Vector.<int> = Vector.<int> ([12, -9, 12, -9, 12, -9]);
			private var flat1 : Vector.<int> = Vector.<int> ([9, -12, 9, -12, 9, -12]);
			private var flat2 : Vector.<int> = Vector.<int> ([-12, 9, -12, 9, -12, 9]);
			
			private function draw_keysig(p_voice, x, s) : *  {
				if (s.k_none)
					return
				var	old_sf = s.k_old_sf,
					st = p_voice.st,
					staffb = staff_tb[st].y,
					i, shift, p_seq,
					clef_ix = s.k_y_clef
				
				if (clef_ix & 1)
					clef_ix += 7;
				clef_ix /= 2
				while (clef_ix < 0) { 
					clef_ix += 7;
				}
				clef_ix %= 7
				
				/* normal accidentals */
				if (!s.k_a_acc) {
					
					/* put neutrals if 'accidental cancel' */
					if (cfmt.cancelkey || s.k_sf == 0) {
						
						/* when flats to sharps, or sharps to flats, */
						if (s.k_sf == 0
							|| old_sf * s.k_sf < 0) {
							
							/* old sharps */
							shift = sharp_cl[clef_ix];
							p_seq = shift > 9 ? sharp1 : sharp2
							for (i = 0; i < old_sf; i++) { 
								xygl(x, staffb + shift, "acc3");
								shift += p_seq[i];
								x += 5.5
							}
							
							/* old flats */
							shift = flat_cl[clef_ix];
							p_seq = shift < 18 ? flat1 : flat2
							for (i = 0; i > old_sf; i--) { 
								xygl(x, staffb + shift, "acc3");
								shift += p_seq[-i];
								x += 5.5
							}
							if (s.k_sf != 0)
								x += 3		/* extra space */
						}
					}
					
					/* new sharps */
					if (s.k_sf > 0) {
						shift = sharp_cl[clef_ix];
						p_seq = shift > 9 ? sharp1 : sharp2
						for (i = 0; i < s.k_sf; i++) { 
							xygl(x, staffb + shift, "acc1");
							shift += p_seq[i];
							x += 5.5
						}
						if (cfmt.cancelkey && i < old_sf) {
							x += 2
							for (; i < old_sf; i++) { 
								xygl(x, staffb + shift, "acc3");
								shift += p_seq[i];
								x += 5.5
							}
						}
					}
					
					/* new flats */
					if (s.k_sf < 0) {
						shift = flat_cl[clef_ix];
						p_seq = shift < 18 ? flat1 : flat2
						for (i = 0; i > s.k_sf; i--) { 
							xygl(x, staffb + shift, "acc-1");
							shift += p_seq[-i];
							x += 5.5
						}
						if (cfmt.cancelkey && i > old_sf) {
							x += 2
							for (; i > old_sf; i--) { 
								xygl(x, staffb + shift, "acc3");
								shift += p_seq[-i];
								x += 5.5
							}
						}
					}
				} else if (s.k_a_acc.length) {
					
					/* explicit accidentals */
					var	acc,
					last_acc = s.k_a_acc[0].acc,
						last_shift = 100
					
					for (i = 0; i < s.k_a_acc.length; i++) { 
						acc = s.k_a_acc[i];
						shift = (s.k_y_clef	// clef shift
							+ acc.pit - 18) * 3
						if (i != 0
							&& (shift > last_shift + 18
								|| shift < last_shift - 18))
							x -= 5.5		// no clash
						else if (acc.acc != last_acc)
							x += 3;
						last_acc = acc.acc;
						draw_hl(x, shift, shift, st, "hl");
						last_shift = shift;
						draw_acc(x, staffb + shift,
							acc.acc, acc.micro_n, acc.micro_d);
						x += 5.5
					}
				}
			}
			
			/* -- convert the standard measure bars -- */
			private function bar_cnv(bar_type) : *  {
				switch (bar_type) {
					case "[":
					case "[]":
						return ""			/* invisible */
					case "|:":
					case "|::":
					case "|:::":
						return "[" + bar_type		/* |::: -> [|::: */
					case ":|":
					case "::|":
					case ":::|":
						return bar_type + "]"		/* :..| -> :..|] */
					case "::":
						return cfmt.dblrepbar		/* :: -> double repeat bar */
					case '||:':
						return '[|:'
				}
				return bar_type
			}
			
			/**
			 * Draws a measure bar.
			 */
			private function draw_bar (s, bot, h) : void {
				var	i : int; 
				var s2 : Object; 
				var yb : Number;
				var bar_type : String = s.bar_type;
				var st : Number = s.st;
				var p_staff : Object = staff_tb[st];
				var x : Number = s.x;
				var ids : Array = s.notes[0].ids;
				
				// Invisible bar
				if (!bar_type) {
					return;
				}
				
				// Don't draw a bar between staves if the staff above has no bars
				// FIXME (when floating voice in lower staff):
				// 's.ts_prev.st != st - 1' && (s.ts_prev.type != C.BAR || s.ts_prev.st != st - 1))
				if (st != 0 && s.ts_prev && s.ts_prev.type != C.BAR) {
					h = p_staff.topbar * p_staff.staffscale;
				}
				s.ymx = s.ymn + h;
				set_sscale (-1);
				anno_start (s)
				
				// Compute the middle vertical offset of the staff
				yb = p_staff.y + 12;
				if (p_staff.stafflines != '|||||') {
					
					// Bottom
					yb += (p_staff.topbar + p_staff.botbar) / 2 - 12;
				}
				
				// If using "repeat one measure" notation (ABC "mrep"), draw the "%" using glyphs
				if (s.bar_mrep) {
					set_sscale (st);
					if (s.bar_mrep == 1) {
						
						// Advance to first `s2` that is not a rest
						for (s2 = s.prev; s2.type != C.REST; s2 = s2.prev) { 
						}
						xygl (s2.x, yb, "mrep");
					} else {
						xygl (x, yb, "mrep2");
						if (s.v == cur_sy.top_voice) {
							set_font("annotation");
							xy_str (x, yb + p_staff.topbar - 9, s.bar_mrep.toString(), "c");
						}
					}
				}
				
				for (i = bar_type.length; --i >= 0; ) { 
					switch (bar_type.charAt(i)) {
						
						// Output a normal bar
						case "|":
							set_sscale (-1);
							out_bar (x, bot, h, s.bar_dotted, ids);
							break;
						
						// Output a thick bar, i.e.: ABC "[" or "]"
						default:
							x -= 3;
							set_sscale (-1);
							out_thbar (x, bot, h, ids);
							break;
						
						// Repetition marks (two dots centered on staff), i.e., ABC "rdots";
						case ":":
							x -= 2;
							set_sscale (st);
							xygl (x + 1, yb - 12, "rdots", ids);
							break;
					}
					x -= 3
				}
				set_sscale (-1);
				anno_stop (s);
				
				// Discard the IDs, if any, so that they cannot be accidentally reused by other
				// elements
				if (ids) {
					ids.length = 0;
				}
			}
			
			/**
			 * Table with rest symbols, arranged from very short to very long
			 */
			private var rest_tb : Array = [ "r128", "r64", "r32", "r16", "r8", "r4", "r2", "r1", "r0", "r00" ];
			
			/**
			 * Draws a rest.
			 * (the staves are defined).
			 */
			private function draw_rest (s) : void {
				var	s2 : Object; 
				var i : int; 
				var j : int; 
				var x : Number; 
				var y : Number;
				var yb : Number;
				var p_staff : Object = staff_tb[s.st];
				
				// Don't display the rests of invisible staves.
				// (must do this here for voices out of their normal staff)
				if (!p_staff.topbar) {
					return;
				}
				
				// If the measure or measure repeat contains a single rest, center it
				if (s.dur == s.p_v.meter.wmeasure || (s.rep_nb && s.rep_nb >= 0)) {
					
					// Don't use next/prev: there is no bar in voice overlay
					s2 = s.ts_next;
					while (s2 && s2.time != s.time + s.dur) { 
						s2 = s2.ts_next;
					}
					x = s2 ? s2.x : realwidth;
					s2 = s;
					while (!s2.seqst) { 
						s2 = s2.ts_prev;
					}
					s2 = s2.ts_prev;
					x = (x + s2.x) / 2;
					
					// Center the associated decorations
					if (s.a_dd) {
						deco_update(s, x - s.x);
					}
					s.x = x;
				}
				
				// Otherwise, left align it
				else {
					x = s.x;
					if (s.notes[0].shhd) {
						x += s.notes[0].shhd * stv_g.scale;
					}
				}
				if (s.invis) {
					return;
				}
				
				// Bottom of staff
				yb = p_staff.y;
				if (s.rep_nb) {
					set_sscale (s.st);
					anno_start (s);
					if (p_staff.stafflines == '|||||') {
						yb += 12;
					}
					else {
						yb += (p_staff.topbar + p_staff.botbar) / 2;
					}
					if (s.rep_nb < 0) {
						xygl (x, yb, "srep");
					} else {
						xygl (x, yb, "mrep");
						if (s.rep_nb > 2 && s.v == cur_sy.top_voice) {
							set_font("annotation");
							xy_str(x, yb + p_staff.topbar - 9, s.rep_nb.toString(), "c");
						}
					}
					anno_stop(s);
					return;
				}
				set_scale(s);
				anno_start(s);
				y = s.y;
				i = 5 - s.nflags;
				
				// Semibreve a bit lower
				if (i == 7 && y == 12 && p_staff.stafflines.length <= 2) {
					y -= 6;
				}
				
				// Draw the rest
				var ids : Array = s.notes[0].ids;
				var id : String = ids? ids[0] as String : null;
				var glyphName : String = s.notes[0].head? s.notes[0].head as String : rest_tb[i] as String;
				xygl (x, y + yb, glyphName, ids || ['ghost-rest']);
				if (id) {
					var glyphDef : Object = tgls[glyphName] as Object;
					var hotspotW : Number = (glyphDef.w as Number);
					var hotspotH : Number = (glyphDef.h as Number);
					var hotspotX : Number = (sx(x) - hotspotW * .45) + glyphDef.hsX;
					var hotspotY : Number = (sy(y + yb) - hotspotH * .5) + glyphDef.hsY;
					addHotspot ('cluster', hotspotX, hotspotY, hotspotW, hotspotH, id);
				}
				
				// Output ledger line(s) when greater than "minim"
				if (i >= 6) {
					j = y / 6;
					switch (i) {
						default:
							switch (p_staff.stafflines[j + 1]) {
								case '|':
								case '[':
									break;
								default:
									xygl (x, y + 6 + yb, "hl1", ids || ['ghost-rest']);
									break;
							}
							
							// "longa"
							if (i == 9) {
								y -= 6;
								j--;
							}
							break;
						
						// "semibreve"
						case 7:
							y += 6;
							j++;
							
						// "minim"
						case 6:
							break;
					}
					switch (p_staff.stafflines.charAt(j)) {
						case '|':
						case '[':
							break;
						default:
							xygl (x, y + yb, "hl1", ids || ['ghost-rest']);
							break;
					}
				}
				
				// Draw the dots
				x += 8;
				y += yb + 3;
				for (i = 0; i < s.dots; i++) { 
					xygl (x, y, "dot", ids);
					x += 3.5;
				}
				anno_stop(s);
				
				// Discard the rest ID after drawing, so that "ghost rests" have no id
				if (ids) {
					ids.length = 0;
				}
			}
			
			/**
			 * Draw grace notes
			 * (the staves are defined)
			 */
			private function draw_gracenotes (s : Object) : void {
				var	yy; 
				var x0; 
				var y0; 
				var x1; 
				var y1; 
				var x2; 
				var y2; 
				var x3; 
				var y3; 
				var bet1; 
				var bet2;
				var dy1; 
				var dy2; 
				var g; 
				var last; 
				var note;
				var bm : Object = {};
				
				/* draw the notes */
				//	bm.s2 = undefined			/* (draw flags) */
				for (g = s.extra; g; g = g.next) { 
					if (g.beam_st && !g.beam_end) {
						if (self.calculate_beam(bm, g))
							draw_beams(bm)
					}
					anno_start(g);
					draw_note(g, !bm.s2)
					if (g == bm.s2)
						bm.s2 = null			/* (draw flags again) */
					anno_stop(g)
					if (!g.next)
						break			/* (keep the last note) */
				}
				
				// if an acciaccatura, draw a bar
				if (s.sappo) {
					g = s.extra
					if (!g.next) {			/* if one note */
						x1 = 9;
						y1 = g.stem > 0 ? 5 : -5
					} else {			/* many notes */
						x1 = (g.next.x - g.x) * .5 + 4;
						y1 = (g.ys + g.next.ys) * .5 - g.y
						if (g.stem > 0)
							y1 -= 1
						else
							y1 += 1
					}
					note = g.notes[g.stem < 0 ? 0 : g.nhd];
					out_acciac(x_head(g, note), y_head(g, note),
						x1, y1, g.stem > 0)
				}
				
				/* slur */
				//fixme: have a full key symbol in voice
				if (s.p_v.key.k_bagpipe			/* no slur when bagpipe */
					|| !cfmt.graceslurs
					|| s.slur_start			/* explicit slur */
					|| !s.next
					|| s.next.type != C.NOTE)
					return
				last = g
				if (last.stem >= 0) {
					yy = 127
					for (g = s.extra; g; g = g.next) { 
						if (g.y < yy) {
							yy = g.y;
							last = g
						}
					}
					x0 = last.x;
					y0 = last.y - 5
					if (s.extra != last) {
						x0 -= 4;
						y0 += 1
					}
					s = s.next;
					x3 = s.x - 1
					if (s.stem < 0)
						x3 -= 4;
					y3 = 3 * (s.notes[0].pit - 18) - 5;
					dy1 = (x3 - x0) * .4
					if (dy1 > 3)
						dy1 = 3;
					dy2 = dy1;
					bet1 = .2;
					bet2 = .8
					if (y0 > y3 + 7) {
						x0 = last.x - 1;
						y0 += .5;
						y3 += 6.5;
						x3 = s.x - 5.5;
						dy1 = (y0 - y3) * .8;
						dy2 = (y0 - y3) * .2;
						bet1 = 0
					} else if (y3 > y0 + 4) {
						y3 = y0 + 4;
						x0 = last.x + 2;
						y0 = last.y - 4
					}
				} else {
					yy = -127
					for (g = s.extra; g; g = g.next) { 
						if (g.y > yy) {
							yy = g.y;
							last = g
						}
					}
					x0 = last.x;
					y0 = last.y + 5
					if (s.extra != last) {
						x0 -= 4;
						y0 -= 1
					}
					s = s.next;
					x3 = s.x - 1
					if (s.stem >= 0)
						x3 -= 2;
					y3 = 3 * (s.notes[s.nhd].pit - 18) + 5;
					dy1 = (x0 - x3) * .4
					if (dy1 < -3)
						dy1 = -3;
					dy2 = dy1;
					bet1 = .2;
					bet2 = .8
					if (y0 < y3 - 7) {
						x0 = last.x - 1;
						y0 -= .5;
						y3 -= 6.5;
						x3 = s.x - 5.5;
						dy1 = (y0 - y3) * .8;
						dy2 = (y0 - y3) * .2;
						bet1 = 0
					} else if (y3 < y0 - 4) {
						y3 = y0 - 4;
						x0 = last.x + 2;
						y0 = last.y + 4
					}
				}
				
				x1 = bet1 * x3 + (1 - bet1) * x0 - x0;
				y1 = bet1 * y3 + (1 - bet1) * y0 - dy1 - y0;
				x2 = bet2 * x3 + (1 - bet2) * x0 - x0;
				y2 = bet2 * y3 + (1 - bet2) * y0 - dy2 - y0;
				
				anno_start(s, 'slur');
				xypath(x0, y0 + staff_tb[s.st].y);
				output += 'c' + x1.toFixed(2) + ' ' + (-y1).toFixed(2) +
					' ' + x2.toFixed(2) + ' ' + (-y2).toFixed(2) +
					' ' + (x3 - x0).toFixed(2) + ' ' + (-y3 + y0).toFixed(2) + '"/>\n';
				anno_stop(s, 'slur')
			}
			
			/* -- set the y offset of the dots -- */
			private function setdoty(s, y_tb) : *  {
				var m, m1, y
				
				/* set the normal offsets */
				for (m = 0; m <= s.nhd; m++) { 
					y = 3 * (s.notes[m].pit - 18)	/* note height on staff */
					if ((y % 6) == 0) {
						if (s.dot_low)
							y -= 3
						else
							y += 3
					}
					y_tb[m] = y
				}
				/* dispatch and recenter the dots in the staff spaces */
				for (m = 0; m < s.nhd; m++) { 
					if (y_tb[m + 1] > y_tb[m])
						continue
					m1 = m
					while (m1 > 0) { 
						if (y_tb[m1] > y_tb[m1 - 1] + 6)
							break
						m1--
					}
					if (3 * (s.notes[m1].pit - 18) - y_tb[m1]
						< y_tb[m + 1] - 3 * (s.notes[m + 1].pit - 18)) {
						while (m1 <= m) { 
							y_tb[m1++] -= 6;
						}
					} else {
						y_tb[m + 1] = y_tb[m] + 6
					}
				}
			}
			
			// get the x and y position of a note head
			// (when the staves are defined)
			private function x_head(s, note) : *  {
				return s.x + note.shhd * stv_g.scale
			}
			private function y_head(s, note) : *  {
				return staff_tb[s.st].y + 3 * (note.pit - 18)
			}
			
			/**
			 * Draws m-th head with accidentals and dots.
			 * Notes: the staves are defined
			 * Notes: sets {x,y}_note
			 */
			private function draw_basic_note (x, s, m, y_tb, noteIds : Array = null) : void {
				var	i : int; 
				var p : String; 
				var yy : Number; 
				var dotx : Number; 
				var doty : Number;
				var old_color : Boolean = false;
				var note : Object = s.notes[m];
					
				// Bottom of staff
				var staffb : Number = staff_tb[s.st].y;
					
				// Note height on staff
				var y : Number = 3 * (note.pit - 18);
				var shhd : Number = note.shhd * stv_g.scale;
				var x_note : Number = x + shhd;
				var y_note : Number = y + staffb;
				var	elts : Array = identify_note(s, note.dur);
				var head : int = elts[0];
				var dots : int = elts[1];
				
				// Output a ledger line if horizontal shift / chord and note on a line
				if (y % 6 == 0 && shhd != (s.stem > 0 ? s.notes[0].shhd : s.notes[s.nhd].shhd)) {
					yy = 0;
					if (y >= 30) {
						yy = y;
						if (yy % 6) {
							yy -= 3;
						}
					} else if (y <= -6) {
						yy = y;
						if (yy % 6) {
							yy += 3;
						}
					}
					if (yy) {
						xygl (x_note, yy + staffb, "hl", noteIds);
					}
				}
				
				// Draw the head
				if (note.invis) {
					;
				}
				
				// Don't apply %%map to grace notes
				else if (s.grace) {
					p = "ghd";
					x_note -= 4.5 * stv_g.scale;
				} else if (note.map && note.map[0]) {
					i = s.head;
					
					// Heads
					p = note.map[0][i];
					if (!p) {
						p = note.map[0][note.map[0].length - 1];
					}
					i = p.indexOf ('/');
					
					// Stem dependant
					if (i >= 0) {
						if (s.stem >= 0) {
							p = p.slice (0, i);
						} else {
							p = p.slice (i + 1);
						}
					}
				} else if (s.type == C.CUSTOS) {
					p = "custos";
				} else {
					switch (head) {
						case C.OVAL:
							p = "HD"
							break;
						case C.OVALBARS:
							if (s.head != C.SQUARE) {
								p = "HDD";
								break;
							}
							// fall thru
						case C.SQUARE:
							p = note.dur < C.BLEN * 4 ? "breve" : "longa";
							
							// don't display dots on last note of the tune
							// if (!tsnext && s.next && s.next.type == C.BAR && !s.next.next) {
							//	dots = 0;
							// }
							break;
						case C.EMPTY:
							
							// White note
							p = "Hd"; 
							break;
						
						// Black note
						default:
							p = "hd";
							break;
					}
				}
				if (note.color != undefined) {
					old_color = set_color (note.color);
				}
				else if (note.map && note.map[2]) {
					old_color = set_color(note.map[2]);
				}
				if (p) {
					if (!self.psxygl (x_note, y_note, p)) {
						
						// Also passing the ordinal index `m` as an argument 
						// when drawing note heads
						xygl (x_note, y_note, p, noteIds, m);
						
						// Drawing a hotspot over each note head. A fair approximation of the note size will do
						if (noteIds) {
							var noteIndex : int = s.notes.length - 1 - m;
							var noteId : String = (noteIds[0] as String) + '_' + noteIndex;
							var hotspotW : Number = 10;
							var hotspotH : Number = 8;
							var hotspotX : Number = sx(x_note) - hotspotW * .5;
							var hotspotY : Number = sy(y_note) - hotspotH * .5;
						}
						addHotspot ('note', hotspotX, hotspotY, hotspotW, hotspotH, noteId);
					}
				}
				
				// Draw the dots
				// FIXME: do we need dots for grace notes?
				if (dots) {
					dotx = x + (7.7 + s.xmx) * stv_g.scale;
					if (y_tb[m] == undefined) {
						y_tb[m] = 3 * (s.notes[m].pit - 18);
						if ((s.notes[m].pit & 1) == 0) {
							y_tb[m] += 3;
						}
					}
					doty = y_tb[m] + staffb;
					while (--dots >= 0) { 
						xygl (dotx, doty, "dot", noteIds, m);
						dotx += 3.5;
					}
				}
				
				// Draw the accidentals
				if (note.acc) {
					x -= note.shac * stv_g.scale;
					if (!s.grace) {
						draw_acc (x, y + staffb, note.acc, note.micro_n, note.micro_d, noteIds);
					} else {
						g_open (x, y + staffb, 0, .75);
						draw_acc (0, 0, note.acc, note.micro_n, note.micro_d, noteIds);
						g_close();
					}
				}
				if (old_color != false) {
					set_color (old_color);
				}
			}
			
			/**
			 * Draws a note or a chord.
			 * (the staves are defined)  
			 */
			private function draw_note (s : Object, fl : Boolean) : void {
				var	s2 : Object; 
				var m : int; 
				var staffb : Number; 
				var slen : Number; 
				var hltype : String; 
				var nflags : int;
				var x : Number; 
				var y : Number; 
				var note : Object;
				var y_tb : Array = new Array (s.nhd + 1);
				var noteIds : Array;
				var stemlessHeight : Number;
				
				if (s.dots) {
					setdoty (s, y_tb);
				}
				
				// Master note head
				note = s.notes[s.stem < 0 ? s.nhd : 0];
				noteIds = s.notes[0].ids;
				x = x_head (s, note);
				staffb = staff_tb[s.st].y;
				
				// Output the ledger lines
				if (s.grace) {
					hltype = "ghl";
				} else {
					switch (s.head) {
						default:
							hltype = "hl";
							break;
						case C.OVAL:
						case C.OVALBARS:
							hltype = "hl1";
							break;
						case C.SQUARE:
							hltype = "hl2";
							break;
					}
				}
				draw_hl (x, 3 * (s.notes[0].pit - 18), 3 * (s.notes[s.nhd].pit - 18), s.st, hltype);
				
				// Draw the stem and flags
				stemlessHeight = (s.ys - s.y + 15);
				y = y_head (s, note);
				if (!s.stemless) {
					slen = s.ys - s.y;
					nflags = s.nflags;
					if (s.ntrem) {
						nflags -= s.ntrem;
					}
					
					// Stem only
					if (!fl || nflags <= 0) {
						
						// Fix for PS low resolution
						if (s.nflags > 0) {	
							if (s.stem >= 0) {
								slen -= 1;
							} else {
								slen += 1;
							}
						}
						out_stem (x, y, slen, s.grace, NaN, false, noteIds);
					}
					
					// Stem and flags
					else {				
						out_stem (x, y, slen, s.grace, nflags, cfmt.straightflags, noteIds);
					}
				} 
				
				// Cross-staff stem
				else if (s.xstem) {
					s2 = s.ts_prev;
					slen = (s2.stem > 0 ? s2.y : s2.ys) - s.y;
					slen += staff_tb[s2.st].y - staffb;
					
					// Fixme: KO when different scales
					slen /= s.p_v.scale;
					out_stem (x, y, slen, false, NaN, false, noteIds);
				}
				
				// Draw hotspot: a raw aproximation of the note area will do
				var hotspotId : String;
				if (noteIds) {
					hotspotId = noteIds[0] as String;
				}
				if (hotspotId) {
					var hotspotX : Number = sx(x) - 6;
					var hotspotH : Number = -(slen * 1.3 || stemlessHeight || 15);
					var hotspotW : Number = 15;
					// `(slen > 0)` means up stem; `(slen < 0)` means up stem;
					// when `slen` is `0`, there is no stem (e.g., whole notes)
					var hotspotY : Number = sy(y)-((slen > 0)? -5 : (slen < 0)? 5 : -7);
					if (hotspotH < 0) {
						hotspotH *= -1;
						hotspotY -= hotspotH;
					}
					addHotspot('cluster', hotspotX, hotspotY, hotspotW, hotspotH, hotspotId);
				}
				
				// Draw the tremolo bars
				if (fl && s.trem1) {
					var	ntrem : int = s.ntrem || 0;
					var x1 : Number = x;
					slen = 3 * (s.notes[s.stem > 0 ? s.nhd : 0].pit - 18);
					if (s.head == C.FULL || s.head == C.EMPTY) {
						x1 += (s.grace ? GSTEM_XOFF : 3.5) * s.stem;
						if (s.stem > 0) {
							slen += 6 + 5.4 * ntrem;
						}
						else {
							slen -= 6 + 5.4;
						}
					} else {
						if (s.stem > 0) {
							slen += 5 + 5.4 * ntrem;
						}
						else {
							slen -= 5 + 5.4;
						}
					}
					slen /= s.p_v.scale;
					out_trem (x1, staffb + slen, ntrem);
				}
				
				// Draw the note heads
				x = s.x;
				for (m = 0; m <= s.nhd; m++) { 
					draw_basic_note (x, s, m, y_tb, noteIds);
				}
				
				// Discard the note IDs after all stems, notes and accidentals have been drawn
				// (so that no other element can accidentally use these IDs)
				if (noteIds) {
					noteIds.length = 0;
				}
				
			}
			
			/**
			 * Finds where to terminate/start a slur.
			 */
			private function next_scut (s : Object) : Object {
				var prev : Object = s;
				
				for (s = s.next; s; s = s.next) { 
					if (s.rbstop) {
						return s;
					}
					prev = s;
				}
				
				// FIXME: KO when no note for this voice at end of staff
				return prev;
			}
			
			/**
			 * TODO: DOCUMENT
			 */
			private function prev_scut (s : Object) : Object {
				while (s.prev) { 
					s = s.prev
					if (s.rbstart)
						return s
				}
				
				// Return a symbol of any voice starting before the start of the voice
				s = s.p_v.sym;
				while (s.type != C.CLEF) { 
					
					// Search a main voice
					s = s.ts_prev;
				}
				if (s.next && s.next.type == C.KEY) {
					s = s.next;
				}
				if (s.next && s.next.type == C.METER) {
					return s.next;
				}
				return s;
			}
			
			/* -- decide whether a slur goes up or down -- */
			private function slur_direction(k1, k2) : *  {
				var s, some_upstem, low
				
				if (k1.grace && k1.stem > 0)
					return -1
				
				for (s = k1; ; s = s.next) { 
					if (s.type == C.NOTE) {
						if (!s.stemless) {
							if (s.stem < 0)
								return 1
							some_upstem = true
						}
						if (s.notes[0].pit < 22)	/* if under middle staff */
							low = true
					}
					if (s == k2)
						break
				}
				if (!some_upstem && !low)
					return 1
				return -1
			}
			
			/* -- output a slur / tie -- */
			private function slur_out(x1, y1, x2, y2, dir, height, dotted) : *  {
				var	dx, dy, dz,
				alfa = .3,
					beta = .45;
				
				/* for wide flat slurs, make shape more square */
				dy = y2 - y1
				if (dy < 0)
					dy = -dy;
				dx = x2 - x1
				if (dx > 40. && dy / dx < .7) {
					alfa = .3 + .002 * (dx - 40.)
					if (alfa > .7)
						alfa = .7
				}
				
				/* alfa, beta, and height determine Bezier control points pp1,pp2
				*
				*           X====alfa===|===alfa=====X
				*	    /		 |	       \
				*	  pp1		 |	        pp2
				*	  /	       height		 \
				*	beta		 |		 beta
				*      /		 |		   \
				*    p1		 m		     p2
				*
				*/
				
				var	mx = .5 * (x1 + x2),
					my = .5 * (y1 + y2),
					xx1 = mx + alfa * (x1 - mx),
					yy1 = my + alfa * (y1 - my) + height;
				xx1 = x1 + beta * (xx1 - x1);
				yy1 = y1 + beta * (yy1 - y1)
				
				var	xx2 = mx + alfa * (x2 - mx),
					yy2 = my + alfa * (y2 - my) + height;
				xx2 = x2 + beta * (xx2 - x2);
				yy2 = y2 + beta * (yy2 - y2);
				
				dx = .03 * (x2 - x1);
				//	if (dx > 10.)
				//		dx = 10.
				//	dy = 1.6 * dir
				dy = 2 * dir;
				dz = .2 + .001 * (x2 - x1)
				if (dz > .6)
					dz = .6;
				dz *= dir
				
				var scale_y = stv_g.v ? stv_g.scale : 1
				if (!dotted) {
					output += '<path class="fill" d="M';
				} else {
					output += '<path class="stroke" stroke-dasharray="5,5" d="M';
				}
				out_sxsy(x1, ' ', y1);
				output += 'c' +
					((xx1 - x1) / stv_g.scale).toFixed(2) + ' ' +
					((y1 - yy1) / scale_y).toFixed(2) + ' ' +
					((xx2 - x1) / stv_g.scale).toFixed(2) + ' ' +
					((y1 - yy2) / scale_y).toFixed(2) + ' ' +
					((x2 - x1) / stv_g.scale).toFixed(2) + ' ' +
					((y1 - y2) / scale_y).toFixed(2)
				
				if (!dotted)
					output += ' v' +
						(-dz).toFixed(2) + 'c' +
						((xx2 - dx - x2) / stv_g.scale).toFixed(2) + ' ' +
						((y2 + dz - yy2 - dy) / scale_y).toFixed(2) + ' ' +
						((xx1 + dx - x2) / stv_g.scale).toFixed(2) + ' ' +
						((y2 + dz - yy1 - dy) / scale_y).toFixed(2) + ' ' +
						((x1 - x2) / stv_g.scale).toFixed(2) + ' ' +
						((y2 + dz - y1) / scale_y).toFixed(2);
				output += '"/>\n'
			}
			
			/* -- check if slur sequence in a multi-voice staff -- */
			private function slur_multi(k1, k2) : *  {
				while (1) { 
					if (k1.multi)		/* if multi voice */
						/*fixme: may change*/
						return k1.multi
					if (k1 == k2)
						break
					k1 = k1.next
				}
				return 0
			}
			
			/* -- draw a phrasing slur between two symbols -- */
			/* (the staves are not yet defined) */
			/* (delayed output) */
			/* (not a pretty routine, this) */
			private function draw_slur(k1_o, k2, m1, m2, slur_type) : *  {
				var	k1 = k1_o,
					k, g, x1, y1, x2, y2, height, addy,
					a, y, z, h, dx, dy, dir
				
				while (k1.v != k2.v) { 
					k1 = k1.ts_next;
				}
				/*fixme: if two staves, may have upper or lower slur*/
				switch (slur_type & 0x07) {	/* (ignore dotted flag) */
					case C.SL_ABOVE: dir = 1; break
					case C.SL_BELOW: dir = -1; break
					default:
						dir = slur_multi(k1, k2)
						if (!dir)
							dir = slur_direction(k1, k2)
						break
				}
				
				var	nn = 1,
					upstaff = k1.st,
					two_staves = false
				
				if (k1 != k2) {
					k = k1.next
					while (1) { 
						if (k.type == C.NOTE || k.type == C.REST) {
							nn++
							if (k.st != upstaff) {
								two_staves = true
								if (k.st < upstaff)
									upstaff = k.st
							}
						}
						if (k == k2)
							break
						k = k.next
					}
				}
				/*fixme: KO when two staves*/
				if (two_staves) error(2, k1, "*** multi-staves slurs not treated yet");
				
				/* fix endpoints */
				x1 = k1_o.x
				if (k1_o.notes && k1_o.notes[0].shhd)
					x1 += k1_o.notes[0].shhd
				if (k1_o != k2) {
					x2 = k2.x
					if (k2.notes)
						x2 += k2.notes[0].shhd
				} else {		/* (the slur starts on last note of the line) */
					for (k = k2.ts_next; k; k = k.ts_next) { 
						//fixme: must check if the staff continues
						if (k.type == C.STAVES) {
							break;
						}
					}
					x2 = k ? k.x : realwidth
				}
				
				if (m1 >= 0) {
					y1 = 3 * (k1.notes[m1].pit - 18) + 5 * dir
				} else {
					y1 = dir > 0 ? k1.ymx + 2 : k1.ymn - 2
					if (k1.type == C.NOTE) {
						if (dir > 0) {
							if (k1.stem > 0) {
								x1 += 5
								if (k1.beam_end
									&& k1.nflags >= -1	/* if with a stem */
									//fixme: check if at end of tuplet
									&& !k1.in_tuplet) {
									//					  || k1.ys > y1 - 3)) {
									if (k1.nflags > 0) {
										x1 += 2;
										y1 = k1.ys - 3
									} else {
										y1 = k1.ys - 6
									}
									// don't clash with decorations
									//					} else {
									//						y1 = k1.ys + 3
								}
								//				} else {
								//					y1 = k1.y + 8
							}
						} else {
							if (k1.stem < 0) {
								x1 -= 1
								if (k2.grace) {
									y1 = k1.y - 8
								} else if (k1.beam_end
									&& k1.nflags >= -1
									&& (!k1.in_tuplet
										|| k1.ys < y1 + 3)) {
									if (k1.nflags > 0) {
										x1 += 2;
										y1 = k1.ys + 3
									} else {
										y1 = k1.ys + 6
									}
									//					} else {
									//						y1 = k1.ys - 3
								}
								//				} else {
								//					y1 = k1.y - 8
							}
						}
					}
				}
				if (m2 >= 0) {
					y2 = 3 * (k2.notes[m2].pit - 18) + 5 * dir
				} else {
					y2 = dir > 0 ? k2.ymx + 2 : k2.ymn - 2
					if (k2.type == C.NOTE) {
						if (dir > 0) {
							if (k2.stem > 0) {
								x2 += 1
								if (k2.beam_st
									&& k2.nflags >= -1
									&& !k2.in_tuplet)
									//						|| k2.ys > y2 - 3))
									y2 = k2.ys - 6
								//					else
								//						y2 = k2.ys + 3
								//				} else {
								//					y2 = k2.y + 8
							}
						} else {
							if (k2.stem < 0) {
								x2 -= 5
								if (k2.beam_st
									&& k2.nflags >= -1
									&& !k2.in_tuplet)
									//						|| k2.ys < y2 + 3))
									y2 = k2.ys + 6
								//					else
								//						y2 = k2.ys - 3
								//				} else {
								//					y2 = k2.y - 8
							}
						}
					}
				}
				
				if (k1.type != C.NOTE) {
					y1 = y2 + 1.2 * dir;
					x1 = k1.x + k1.wr * .5
					if (x1 > x2 - 12)
						x1 = x2 - 12
				}
				
				if (k2.type != C.NOTE) {
					if (k1.type == C.NOTE)
						y2 = y1 + 1.2 * dir
					else
						y2 = y1
					if (k1 != k2)
						x2 = k2.x - k2.wl * .3
				}
				
				if (nn >= 3) {
					if (k1.next.type != C.BAR
						&& k1.next.x < x1 + 48) {
						if (dir > 0) {
							y = k1.next.ymx - 2
							if (y1 < y)
								y1 = y
						} else {
							y = k1.next.ymn + 2
							if (y1 > y)
								y1 = y
						}
					}
					if (k2.prev
						&& k2.prev.type != C.BAR
						&& k2.prev.x > x2 - 48) {
						if (dir > 0) {
							y = k2.prev.ymx - 2
							if (y2 < y)
								y2 = y
						} else {
							y = k2.prev.ymn + 2
							if (y2 > y)
								y2 = y
						}
					}
				}
				
				a = (y2 - y1) / (x2 - x1)		/* slur steepness */
				if (a > SLUR_SLOPE || a < -SLUR_SLOPE) {
					a = a > SLUR_SLOPE ? SLUR_SLOPE : -SLUR_SLOPE
					if (a * dir > 0)
						y1 = y2 - a * (x2 - x1)
					else
						y2 = y1 + a * (x2 - x1)
				}
				
				/* for big vertical jump, shift endpoints */
				y = y2 - y1
				if (y > 8)
					y = 8
				else if (y < -8)
					y = -8
				z = y
				if (z < 0)
					z = -z;
				dx = .5 * z;
				dy = .3 * y
				if (y * dir > 0) {
					x2 -= dx;
					y2 -= dy
				} else {
					x1 += dx;
					y1 += dy
				}
				
				/* special case for grace notes */
				if (k1.grace)
					x1 = k1.x - GSTEM_XOFF * .5
				if (k2.grace)
					x2 = k2.x + GSTEM_XOFF * 1.5;
				
				h = 0;
				a = (y2 - y1) / (x2 - x1)
				if (k1 != k2
					&& k1.v == k2.v) {
					addy = y1 - a * x1
					for (k = k1.next; k != k2 ; k = k.next) { 
						if (k.st != upstaff)
							continue
						switch (k.type) {
							case C.NOTE:
							case C.REST:
								if (dir > 0) {
									y = 3 * (k.notes[k.nhd].pit - 18) + 6
									if (y < k.ymx)
										y = k.ymx;
									y -= a * k.x + addy
									if (y > h)
										h = y
								} else {
									y = 3 * (k.notes[0].pit - 18) - 6
									if (y > k.ymn)
										y = k.ymn;
									y -= a * k.x + addy
									if (y < h)
										h = y
								}
								break
							case C.GRACE:
								for (g = k.extra; g; g = g.next) { 
									if (dir > 0) {
										y = 3 * (g.notes[g.nhd].pit - 18) + 6
										if (y < g.ymx)
											y = g.ymx;
										y -= a * g.x + addy
										if (y > h)
											h = y
									} else {
										y = 3 * (g.notes[0].pit - 18) - 6
										if (y > g.ymn)
											y = g.ymn;
										y -= a * g.x + addy
										if (y < h)
											h = y
									}
								}
								break
						}
					}
					y1 += .45 * h;
					y2 += .45 * h;
					h *= .65
				}
				
				if (nn > 3)
					height = (.08 * (x2 - x1) + 12) * dir
				else
					height = (.03 * (x2 - x1) + 8) * dir
				if (dir > 0) {
					if (height < 3 * h)
						height = 3 * h
					if (height > 40)
						height = 40
				} else {
					if (height > 3 * h)
						height = 3 * h
					if (height < -40)
						height = -40
				}
				
				y = y2 - y1
				if (y < 0)
					y = -y
				if (dir > 0) {
					if (height < .8 * y)
						height = .8 * y
				} else {
					if (height > -.8 * y)
						height = -.8 * y
				}
				height *= cfmt.slurheight;
				
				//	anno_start(k1_o, 'slur');
				slur_out(x1, y1, x2, y2, dir, height, slur_type & C.SL_DOTTED);
				//	anno_stop(k1_o, 'slur');
				
				/* have room for other symbols */
				dx = x2 - x1;
				a = (y2 - y1) / dx;
				/*fixme: it seems to work with .4, but why?*/
				addy = y1 - a * x1 + .4 * height
				if (k1.v == k2.v)
					for (k = k1; k != k2; k = k.next) { 
						if (k.st != upstaff)
							continue
						y = a * k.x + addy
						if (k.ymx < y)
							k.ymx = y
						else if (k.ymn > y)
							k.ymn = y
						if (k.next == k2) {
							dx = x2
							if (k2.sl1)
								dx -= 5
						} else {
							dx = k.next.x
						}
						if (k != k1)
							x1 = k.x;
						dx -= x1;
						y_set(upstaff, dir > 0, x1, dx, y)
					}
				return (dir > 0 ? C.SL_ABOVE : C.SL_BELOW) | (slur_type & C.SL_DOTTED)
			}
			
			/* -- draw the slurs between 2 symbols --*/
			private function draw_slurs(first, last) : *  {
				var	s1, k, gr1, gr2, i, m1, m2, slur_type, cont,
				s = first
				
				while (1) { 
					if (!s || s == last) {
						if (!gr1
							|| !(s = gr1.next)
							|| s == last)
							break
						gr1 = null
					}
					if (s.type == C.GRACE) {
						gr1 = s;
						s = s.extra
						continue
					}
					if ((s.type != C.NOTE && s.type != C.REST
						&& s.type != C.SPACE)
						|| (!s.slur_start && !s.sl1)) {
						s = s.next
						continue
					}
					k = null;		/* find matching slur end */
					s1 = s.next
					var gr1_out = false
					while (1) { 
						if (!s1) {
							if (gr2) {
								s1 = gr2.next;
								gr2 = null
								continue
							}
							if (!gr1 || gr1_out)
								break
							s1 = gr1.next;
							gr1_out = true
							continue
						}
						if (s1.type == C.GRACE) {
							gr2 = s1;
							s1 = s1.extra
							continue
						}
						if (s1.type == C.BAR
							&& (s1.bar_type[0] == ':'
								|| s1.bar_type == "|]"
								|| s1.bar_type == "[|"
								|| (s1.text && s1.text[0] != '1'))) {
							k = s1
							break
						}
						if (s1.type != C.NOTE && s1.type != C.REST
							&& s1.type != C.SPACE) {
							s1 = s1.next
							continue
						}
						if (s1.slur_end || s1.sl2) {
							k = s1
							break
						}
						if (s1.slur_start || s1.sl1) {
							if (gr2) {	/* if in grace note sequence */
								for (k = s1; k.next; k = k.next) { 
									;
								}
								k.next = gr2.next
								if (gr2.next)
									gr2.next.prev = k;
								//					gr2.slur_start = C.SL_AUTO
								k = null
							}
							draw_slurs(s1, last)
							if (gr2
								&& gr2.next) {
								gr2.next.prev.next = null;
								gr2.next.prev = gr2
							}
						}
						if (s1 == last)
							break
						s1 = s1.next
					}
					if (!s1) {
						k = next_scut(s)
					} else if (!k) {
						s = s1
						if (s == last)
							break
						continue
					}
					
					/* if slur in grace note sequence, change the linkages */
					if (gr1) {
						for (s1 = s; s1.next; s1 = s1.next) { 
							;
						}
						s1.next = gr1.next
						if (gr1.next)
							gr1.next.prev = s1;
						gr1.slur_start = C.SL_AUTO
					}
					if (gr2) {
						gr2.prev.next = gr2.extra;
						gr2.extra.prev = gr2.prev;
						gr2.slur_start = C.SL_AUTO
					}
					if (s.slur_start) {
						slur_type = s.slur_start & 0x0f;
						s.slur_start >>= 4;
						m1 = -1
					} else {
						for (m1 = 0; m1 <= s.nhd; m1++) { 
							if (s.notes[m1].sl1) {
								break;
							}
						}
						slur_type = s.notes[m1].sl1 & 0x0f;
						s.notes[m1].sl1 >>= 4;
						s.sl1--
					}
					m2 = -1;
					cont = 0
					if ((k.type == C.NOTE || k.type == C.REST || k.type == C.SPACE) &&
						(k.slur_end || k.sl2)) {
						if (k.slur_end) {
							k.slur_end--
						} else {
							for (m2 = 0; m2 <= k.nhd; m2++) { 
								if (k.notes[m2].sl2) {
									break;
								}
							}
							k.notes[m2].sl2--;
							k.sl2--
						}
					} else {
						if (k.type != C.BAR
							|| (k.bar_type[0] != ':'
								&& k.bar_type != "|]"
								&& k.bar_type != "[|"
								&& (!k.text || k.text[0] == '1')))
							cont = 1
					}
					slur_type = draw_slur(s, k, m1, m2, slur_type)
					if (cont) {
						if (!k.p_v.slur_start)
							k.p_v.slur_start = 0;
						k.p_v.slur_start <<= 4;
						k.p_v.slur_start += slur_type
					}
					
					/* if slur in grace note sequence, restore the linkages */
					if (gr1
						&& gr1.next) {
						gr1.next.prev.next = null;
						gr1.next.prev = gr1
					}
					if (gr2) {
						gr2.prev.next = gr2;
						gr2.extra.prev = null
					}
					
					if (s.slur_start || s.sl1)
						continue
					if (s == last)
						break
					s = s.next
				}
			}
			
			/* -- draw a tuplet -- */
			/* (the staves are not yet defined) */
			/* (delayed output) */
			/* See http://moinejf.free.fr/abcm2ps-doc/tuplets.xhtml
			* for the value of 'tf' */
			private function draw_tuplet(s1,
										 lvl) : *  {	// nesting level
				var	s2, s3, g, upstaff, nb_only, some_slur,
				x1, x2, y1, y2, xm, ym, a, s0, yy, yx, dy, b, dir,
				p, q, r
				
				// check if some slurs and treat the nested tuplets
				upstaff = s1.st
				for (s2 = s1; s2; s2 = s2.next) { 
					if (s2.type != C.NOTE && s2.type != C.REST) {
						if (s2.type == C.GRACE) {
							for (g = s2.extra; g; g = g.next) { 
								if (g.slur_start || g.sl1)
									some_slur = true
							}
						}
						continue
					}
					if (s2.slur_start || s2.slur_end /* if slur start/end */
						|| s2.sl1 || s2.sl2)
						some_slur = true
					if (s2.st < upstaff)
						upstaff = s2.st
					if (lvl == 0) {
						if (s2.tp1)
							draw_tuplet(s2, 1)
						if (s2.te0)
							break
					} else if (s2.te1)
						break
				}
				
				if (!s2) {
					error(1, s1, "No end of tuplet in this music line")
					if (lvl == 0)
						s1.tp0 = 0
					else
						s1.tp1 = 0
					return
				}
				
				/* draw the slurs fully inside the tuplet */
				if (some_slur) {
					draw_slurs(s1, s2)
					
					// don't draw the tuplet when a slur starts or stops inside it
					if (s1.slur_start || s1.sl1)
						return
					for (s3 = s1.next; s3 != s2; s3 = s3.next) { 
						if (s3.slur_start || s3.slur_end
							|| s3.sl1 || s3.sl2)
							return
					}
					
					if (s2.slur_end || s2.sl2)
						return
				}
				
				if (lvl == 0) {
					p = s1.tp0;
					s1.tp0 = 0;
					q = s1.tq0
				} else {
					p = s1.tp1;
					s1.tp1 = 0
					q = s1.tq1
				}
				
				if (s1.tf[0] == 1)			/* if 'when' == never */
					return
				
				dir = s1.tf[3]				/* 'where' (C.SL_xxx) */
				if (!dir)
					dir = s1.stem > 0 ? C.SL_ABOVE : C.SL_BELOW
				
				if (s1 == s2) {				/* tuplet with 1 note (!) */
					nb_only = true
				} else if (s1.tf[1] == 1) {			/* 'what' == slur */
					nb_only = true;
					draw_slur(s1, s2, -1, -1, dir)
				} else {
					
					/* search if a bracket is needed */
					if (s1.tf[0] == 2		/* if 'when' == always */
						|| s1.type != C.NOTE || s2.type != C.NOTE) {
						nb_only = false
					} else {
						nb_only = true
						for (s3 = s1; ; s3 = s3.next) { 
							if (s3.type != C.NOTE
								&& s3.type != C.REST) {
								if (s3.type == C.GRACE
									|| s3.type == C.SPACE)
									continue
								nb_only = false
								break
							}
							if (s3 == s2)
								break
							if (s3.beam_end) {
								nb_only = false
								break
							}
						}
						if (nb_only
							&& !s1.beam_st
							&& !s1.beam_br1
							&& !s1.beam_br2) {
							for (s3 = s1.prev; s3; s3 = s3.prev) { 
								if (s3.type == C.NOTE
									|| s3.type == C.REST) {
									if (s3.nflags >= s1.nflags)
										nb_only = false
									break
								}
							}
						}
						if (nb_only && !s2.beam_end) {
							for (s3 = s2.next; s3; s3 = s3.next) { 
								if (s3.type == C.NOTE
									|| s3.type == C.REST) {
									if (!s3.beam_br1
										&& !s3.beam_br2
										&& s3.nflags >= s2.nflags)
										nb_only = false
									break
								}
							}
						}
					}
				}
				
				/* if number only, draw it */
				if (nb_only) {
					if (s1.tf[2] == 1)		/* if 'which' == none */
						return
					xm = (s2.x + s1.x) / 2
					if (s1 == s2)			/* tuplet with 1 note */
						a = 0
					else
						a = (s2.ys - s1.ys) / (s2.x - s1.x);
					b = s1.ys - a * s1.x;
					yy = a * xm + b
					if (dir == C.SL_ABOVE) {
						ym = y_get(upstaff, 1, xm - 4, 8)
						if (ym > yy)
							b += ym - yy;
						b += 2
					} else {
						ym = y_get(upstaff, 0, xm - 4, 8)
						if (ym < yy)
							b += ym - yy;
						b -= 10
					}
					for (s3 = s1; ; s3 = s3.next) { 
						if (s3.x >= xm)
							break
					}
					if (s1.stem * s2.stem > 0) {
						if (s1.stem > 0)
							xm += 1.5
						else
							xm -= 1.5
					}
					ym = a * xm + b
						
					/* if 'which' == number */
					if (s1.tf[2] == 0) {
						// out_bnum (xm, ym, p);
					} else {
						// out_bnum (xm, ym, p + ':' +  q);
					}
					if (dir == C.SL_ABOVE) {
						ym += 10
						if (s3.ymx < ym)
							s3.ymx = ym;
						y_set(upstaff, true, xm - 3, 6, ym)
					} else {
						if (s3.ymn > ym)
							s3.ymn = ym;
						y_set(upstaff, false, xm - 3, 6, ym)
					}
					return
				}
				
				if (s1.tf[1] != 0)				/* if 'what' != square */
					error(2, s1, "'what' value of %%tuplets not yet coded")
				
				/*fixme: two staves not treated*/
				/*fixme: to optimize*/
				dir = s1.tf[3]				// 'where'
				if (!dir)
					dir = s1.multi >= 0 ? C.SL_ABOVE : C.SL_BELOW
				if (dir == C.SL_ABOVE) {
					
					/* sole or upper voice: the bracket is above the staff */
					if (s1.st == s2.st) {
						y1 = y2 = staff_tb[upstaff].topbar + 4
					} else {
						y1 = s1.ymx;
						y2 = s2.ymx
					}
					
					x1 = s1.x - 4;
					if (s1.st == upstaff) {
						for (s3 = s1; !s3.dur; s3 = s3.next) { 
							;
						}
						ym = y_get(upstaff, 1, s3.x - 4, 8)
						if (ym > y1)
							y1 = ym
						if (s1.stem > 0)
							x1 += 3
					}
					
					if (s2.st == upstaff) {
						for (s3 = s2; !s3.dur; s3 = s3.prev) { 
							;
						}
						ym = y_get(upstaff, 1, s3.x - 4, 8)
						if (ym > y2)
							y2 = ym
					}
					
					/* end the backet according to the last note duration */
					if (s2.dur > s2.prev.dur) {
						if (s2.next)
							x2 = s2.next.x - s2.next.wl - 5
						else
							x2 = realwidth - 6
					} else {
						x2 = s2.x + 4;
						r = s2.stem >= 0 ? 0 : s2.nhd
						if (s2.notes[r].shhd > 0)
							x2 += s2.notes[r].shhd
						if (s2.st == upstaff
							&& s2.stem > 0)
							x2 += 3.5
					}
					
					xm = .5 * (x1 + x2);
					ym = .5 * (y1 + y2);
					
					a = (y2 - y1) / (x2 - x1);
					s0 = 3 * (s2.notes[s2.nhd].pit - s1.notes[s1.nhd].pit) / (x2 - x1)
					if (s0 > 0) {
						if (a < 0)
							a = 0
						else if (a > s0)
							a = s0
					} else {
						if (a > 0)
							a = 0
						else if (a < s0)
							a = s0
					}
					if (a * a < .1 * .1)
						a = 0
					
					/* shift up bracket if needed */
					dy = 0
					for (s3 = s1; ; s3 = s3.next) { 
						if (!s3.dur			/* not a note or a rest */
							|| s3.st != upstaff) {
							if (s3 == s2)
								break
							continue
						}
						yy = ym + (s3.x - xm) * a;
						yx = y_get(upstaff, 1, s3.x - 4, 8) + 2
						if (yx - yy > dy)
							dy = yx - yy
						if (s3 == s2)
							break
					}
					
					ym += dy;
					y1 = ym + a * (x1 - xm);
					y2 = ym + a * (x2 - xm);
					
					/* shift the slurs / decorations */
					ym += 8
					for (s3 = s1; ; s3 = s3.next) { 
						if (s3.st == upstaff) {
							yy = ym + (s3.x - xm) * a
							if (s3.ymx < yy)
								s3.ymx = yy
							if (s3 == s2)
								break
							y_set(upstaff, true, s3.x, s3.next.x - s3.x, yy)
						} else if (s3 == s2) {
							break
						}
					}
					
				} else {	/* lower voice of the staff: the bracket is below the staff */
					/*fixme: think to all of that again..*/
					x1 = s1.x - 7
					if (s2.dur > s2.prev.dur) {
						if (s2.next)
							x2 = s2.next.x - s2.next.wl - 8
						else
							x2 = realwidth - 6
					} else {
						x2 = s2.x + 2
						if (s2.notes[s2.nhd].shhd > 0)
							x2 += s2.notes[s2.nhd].shhd
					}
					if (s1.stem >= 0) {
						x1 += 2;
						x2 += 2
					}
					
					if (s1.st == upstaff) {
						for (s3 = s1; !s3.dur; s3 = s3.next) { 
							;
						}
						y1 = y_get(upstaff, 0, s3.x - 4, 8)
					} else {
						y1 = 0
					}
					if (s2.st == upstaff) {
						for (s3 = s2; !s3.dur; s3 = s3.prev) { 
							;
						}
						y2 = y_get(upstaff, 0, s3.x - 4, 8)
					} else {
						y2 = 0
					}
					
					xm = .5 * (x1 + x2);
					ym = .5 * (y1 + y2);
					
					a = (y2 - y1) / (x2 - x1);
					s0 = 3 * (s2.notes[0].pit - s1.notes[0].pit) / (x2 - x1)
					if (s0 > 0) {
						if (a < 0)
							a = 0
						else if (a > s0)
							a = s0
					} else {
						if (a > 0)
							a = 0
						else if (a < s0)
							a = s0
					}
					if (a * a < .1 * .1)
						a = 0
					
					/* shift down the bracket if needed */
					dy = 0
					for (s3 = s1; ; s3 = s3.next) { 
						if (!s3.dur			/* not a note nor a rest */
							|| s3.st != upstaff) {
							if (s3 == s2)
								break
							continue
						}
						yy = ym + (s3.x - xm) * a;
						yx = y_get(upstaff, 0, s3.x - 4, 8)
						if (yx - yy < dy)
							dy = yx - yy
						if (s3 == s2)
							break
					}
					
					ym += dy - 10;
					y1 = ym + a * (x1 - xm);
					y2 = ym + a * (x2 - xm);
					
					/* shift the slurs / decorations */
					ym -= 2
					for (s3 = s1; ; s3 = s3.next) { 
						if (s3.st == upstaff) {
							if (s3 == s2)
								break
							yy = ym + (s3.x - xm) * a
							if (s3.ymn > yy)
								s3.ymn = yy;
							y_set(upstaff, false, s3.x, s3.next.x - s3.x, yy)
						}
						if (s3 == s2)
							break
					}
				} /* lower voice */
				
				if (s1.tf[2] == 1) {			/* if 'which' == none */
					// out_tubr(x1, y1 + 4, x2 - x1, y2 - y1, dir == C.SL_ABOVE);
					return;
				}
				// out_tubrn (x1, y1, x2 - x1, y2 - y1, dir == C.SL_ABOVE, s1.tf[2] == 0 ? p.toString() : p + ':' +  q);
				
				yy = .5 * (y1 + y2)
				if (dir == C.SL_ABOVE)
					y_set(upstaff, true, xm - 3, 6, yy + 9)
				else
					y_set(upstaff, false, xm - 3, 6, yy)
			}
			
			/* -- draw the ties between two notes/chords -- */
			private function draw_note_ties(k1, k2, mhead1, mhead2, job) : *  {
				var i, dir, m1, m2, p, p2, y, st, k, x1, x2, h, sh, time
				
				for (i = 0; i < mhead1.length; i++) { 
					m1 = mhead1[i];
					p = k1.notes[m1].pit;
					m2 = mhead2[i];
					p2 = job != 2 ? k2.notes[m2].pit : p;
					dir = (k1.notes[m1].ti1 & 0x07) == C.SL_ABOVE ? 1 : -1;
					
					x1 = k1.x;
					sh = k1.notes[m1].shhd		/* head shift */
					if (dir > 0) {
						if (m1 < k1.nhd && p + 1 == k1.notes[m1 + 1].pit)
							if (k1.notes[m1 + 1].shhd > sh)
								sh = k1.notes[m1 + 1].shhd
					} else {
						if (m1 > 0 && p == k1.notes[m1 - 1].pit + 1)
							if (k1.notes[m1 - 1].shhd > sh)
								sh = k1.notes[m1 - 1].shhd
					}
					x1 += sh * .6;
					
					x2 = k2.x
					if (job != 2) {
						sh = k2.notes[m2].shhd
						if (dir > 0) {
							if (m2 < k2.nhd && p2 + 1 == k2.notes[m2 + 1].pit)
								if (k2.notes[m2 + 1].shhd < sh)
									sh = k2.notes[m2 + 1].shhd
						} else {
							if (m2 > 0 && p2 == k2.notes[m2 - 1].pit + 1)
								if (k2.notes[m2 - 1].shhd < sh)
									sh = k2.notes[m2 - 1].shhd
						}
						x2 += sh * .6
					}
					
					st = k1.st
					switch (job) {
						case 0:
							if (p != p2 && !(p & 1))
								p = p2
							break
						case 3:				/* clef or staff change */
							dir = -dir
							// fall thru
						case 1:				/* no starting note */
							x1 = k1.x
							if (x1 > x2 - 20)
								x1 = x2 - 20;
							p = p2;
							st = k2.st
							break
						/*		case 2:				 * no ending note */
						default:
							if (k1 != k2) {
								x2 -= k2.wl
								if (k2.type == C.BAR)
									x2 += 5
							} else {
								time = k1.time + k1.dur
								for (k = k1.ts_next; k; k = k.ts_next) { 
									//(fixme: must check if the staff continues??)
									if (k.time > time) {
										break;
									}
								}
								x2 = k ? k.x : realwidth;
							}
							if (x2 < x1 + 16)
								x2 = x1 + 16
							break
					}
					if (x2 - x1 > 20) {
						x1 += 3.5;
						x2 -= 3.5
					} else {
						x1 += 1.5;
						x2 -= 1.5
					}
					
					y = 3 * (p - 18)
					
					h = (.04 * (x2 - x1) + 10) * dir;
					//		anno_start(k1, 'slur');
					slur_out(x1, staff_tb[st].y + y,
						x2, staff_tb[st].y + y,
						dir, h, k1.notes[m1].ti1 & C.SL_DOTTED)
					//		anno_stop(k1, 'slur')
				}
			}
			
			/* -- draw ties between neighboring notes/chords -- */
			private function draw_ties(k1, k2,
							   job) : *  {	// 0: normal
				// 1: no starting note
				// 2: no ending note
				// 3: no start for clef or staff change
				var	k3, i, j, m1, pit, pit2, tie2,
				mhead1 = [],
					mhead2 = [],
					mhead3 = [],
					nh1 = k1.nhd,
					time = k1.time + k1.dur
				
				/* half ties from last note in line or before new repeat */
				if (job == 2) {
					for (i = 0; i <= nh1; i++) { 
						if (k1.notes[i].ti1)
							mhead3.push(i)
					}
					draw_note_ties(k1, k2 || k1, mhead3, mhead3, job)
					return
				}
				
				/* set up list of ties to draw */
				for (i = 0; i <= nh1; i++) { 
					if (!k1.notes[i].ti1)
						continue
					tie2 = -1;
					pit = k1.notes[i].opit || k1.notes[i].pit
					for (m1 = k2.nhd; m1 >= 0; m1--) { 
						pit2 = k2.notes[m1].opit || k2.notes[m1].pit
						switch (pit2 - pit) {
							case 1:			/* maybe ^c - _d */
							case -1:		/* _d - ^c */
								if (k1.notes[i].acc != k2.notes[m1].acc)
									tie2 = m1
							default:
								continue
							case 0:
								tie2 = m1
								break
						}
						break
					}
					if (tie2 >= 0) {		/* 1st or 2nd choice */
						mhead1.push(i);
						mhead2.push(tie2)
					} else {
						mhead3.push(i)		/* no match */
					}
				}
				
				/* draw the ties */
				draw_note_ties(k1, k2, mhead1, mhead2, job)
				
				/* if any bad tie, try an other voice of the same staff */
				if (!mhead3.length)
					return				/* no bad tie */
				
				k3 = k1.ts_next
				while (k3 && k3.time < time) { 
					k3 = k3.ts_next;
				}
				while (k3 && k3.time == time) { 
					if (k3.type != C.NOTE
						|| k3.st != k1.st) {
						k3 = k3.ts_next
						continue
					}
					mhead1.length = 0;
					mhead2.length = 0
					for (i = mhead3.length; --i >= 0; ) { 
						j = mhead3[i];
						pit = k1.notes[j].opit || k1.notes[j].pit
						for (m1 = k3.nhd; m1 >= 0; m1--) { 
							pit2 = k3.notes[m1].opit || k3.notes[m1].pit
							if (pit2 == pit) {
								mhead1.push(j);
								mhead2.push(m1);
								mhead3[i] = mhead3.pop()
								break
							}
						}
					}
					if (mhead1.length > 0) {
						draw_note_ties(k1, k3,
							mhead1, mhead2,
							job == 1 ? 1 : 0)
						if (mhead3.length == 0)
							return
					}
					k3 = k3.ts_next
				}
				
				if (mhead3.length != 0)
					error(1, k1, "Bad tie")
			}
			
			/* -- try to get the symbol of a ending tie when combined voices -- */
			private function tie_comb(s) : *  {
				var	s1, time, st;
				
				time = s.time + s.dur;
				st = s.st
				for (s1 = s.ts_next; s1; s1 = s1.ts_next) { 
					if (s1.st != st)
						continue
					if (s1.time == time) {
						if (s1.type == C.NOTE)
							return s1
						continue
					}
					if (s1.time > time)
						return s		// bad tie
				}
				return //null				// no ending tie
			}
			
			/* -- draw all ties between neighboring notes -- */
			private function draw_all_ties(p_voice) : *  {
				var s1, s2, s3, clef_chg, time, s_rtie, s_tie, x, dx
				
				function draw_ties_g(s1, s2, job)  :* {
					var g
					
					if (s1.type == C.GRACE) {
						for (g = s1.extra; g; g = g.next) { 
							if (g.ti1)
								draw_ties(g, s2, job)
						}
					} else {
						draw_ties(s1, s2, job)
					}
				} // draw_ties_g()
				
				for (s1 = p_voice.sym; s1; s1 = s1.next) { 
					switch (s1.type) {
						case C.CLEF:
						case C.KEY:
						case C.METER:
							continue
					}
					break
				}
				s_rtie = p_voice.s_rtie			/* tie from 1st repeat bar */
				for (s2 = s1; s2; s2 = s2.next) { 
					if (s2.dur
						|| s2.type == C.GRACE)
						break
					if (s2.type != C.BAR
						|| !s2.text)			// not a repeat bar
						continue
					if (s2.text[0] == '1')		/* 1st repeat bar */
						s_rtie = p_voice.s_tie
					else
						p_voice.s_tie = s_rtie
				}
				if (!s2)
					return
				if (p_voice.s_tie) {			/* tie from previous line */
					p_voice.s_tie.x = s1.x + s1.wr;
					s1 = p_voice.s_tie;
					p_voice.s_tie = null;
					s1.st = s2.st;
					s1.ts_next = s2.ts_next;	/* (for tie to other voice) */
					s1.time = s2.time - s1.dur;	/* (if after repeat sequence) */
					draw_ties(s1, s2, 1)		/* tie to 1st note */
				}
				
				/* search the start of ties */
				//	clef_chg = false
				while (1) { 
					for (s1 = s2; s1; s1 = s1.next) { 
						if (s1.ti1)
							break
						if (!s_rtie)
							continue
						if (s1.type != C.BAR
							|| !s1.text)			// not a repeat bar
							continue
						if (s1.text[0] == '1') {	/* 1st repeat bar */
							s_rtie = null
							continue
						}
						if (s1.bar_type == '|')
							continue		// not a repeat
						for (s2 = s1.next; s2; s2 = s2.next)
							if (s2.type == C.NOTE) {
								break;
							}
						if (!s2) {
							s1 = null
							break
						}
						s_tie = clone(s_rtie);
						s_tie.x = s1.x;
						s_tie.next = s2;
						s_tie.st = s2.st;
						s_tie.time = s2.time - s_tie.dur;
						draw_ties(s_tie, s2, 1)
					}
					if (!s1)
						break
					
					/* search the end of the tie
					* and notice the clef changes (may occur in an other voice) */
					time = s1.time + s1.dur
					for (s2 = s1.next; s2; s2 = s2.next) { 
						if (s2.dur)
							break
						if (s2.type == C.BAR && s2.text) {	// repeat bar
							if (s2.text[0] != '1')
								break
							s_rtie = s1		/* 1st repeat bar */
						}
					}
					if (!s2) {
						for (s2 = s1.ts_next; s2; s2 = s2.ts_next) { 
							if (s2.st != s1.st)
								continue
							if (s2.time < time)
								continue
							if (s2.time > time) {
								s2 = null
								break
							}
							if (s2.dur)
								break
						}
						if (!s2) {
							draw_ties_g(s1, null, 2);
							p_voice.s_tie = s1
							break
						}
					} else {
						if (s2.type != C.NOTE
							&& s2.type != C.BAR) {
							error(1, s1, "Bad tie")
							continue
						}
						if (s2.time != time) {
							s3 = tie_comb(s1)
							if (s3 == s1) {
								error(1, s1, "Bad tie")
								continue
							}
							s2 = s3
						}
					}
					for (s3 = s1.ts_next; s3; s3 = s3.ts_next) { 
						if (s3.st != s1.st)
							continue
						if (s3.time > time)
							break
						if (s3.type == C.CLEF) {
							clef_chg = true
							continue
						}
					}
					
					/* ties with clef or staff change */
					if (clef_chg || s1.st != s2.st) {
						clef_chg = false;
						dx = (s2.x - s1.x) * .4;
						x = s2.x;
						s2.x -= dx
						if (s2.x > s1.x + 32.)
							s2.x = s1.x + 32.;
						draw_ties_g(s1, s2, 2);
						s2.x = x;
						x = s1.x;
						s1.x += dx
						if (s1.x < s2.x - 24.)
							s1.x = s2.x - 24.;
						draw_ties(s1, s2, 3);
						s1.x = x
						continue
					}
					draw_ties_g(s1, s2, s2.type == C.NOTE ? 0 : 2)
				}
				p_voice.s_rtie = s_rtie
			}
			
			/* -- draw all phrasing slurs for one staff -- */
			/* (the staves are not yet defined) */
			private function draw_all_slurs(p_voice) : *  {
				var	k, i, m2,
				s = p_voice.sym,
					slur_type = p_voice.slur_start,
					slur_st = 0
				
				if (!s)
					return
				
				/* the starting slur types are inverted */
				if (slur_type) {
					p_voice.slur_start = 0
					while (slur_type != 0) { 
						slur_st <<= 4;
						slur_st |= (slur_type & 0x0f);
						slur_type >>= 4
					}
				}
				
				/* draw the slurs inside the music line */
				draw_slurs(s, undefined)
				
				/* do unbalanced slurs still left over */
				for ( ; s; s = s.next) { 
					while (s.slur_end || s.sl2) { 
						if (s.slur_end) {
							s.slur_end--;
							m2 = -1
						} else {
							for (m2 = 0; m2 <= s.nhd; m2++) { 
								if (s.notes[m2].sl2) {
									break;
								}
							}
							s.notes[m2].sl2--;
							s.sl2--
						}
						slur_type = slur_st & 0x0f;
						k = prev_scut(s);
						draw_slur(k, s, -1, m2, slur_type)
						if (k.type != C.BAR
							|| (k.bar_type[0] != ':'
								&& k.bar_type != "|]"
								&& k.bar_type != "[|"
								&& (!k.text || k.text[0] == '1')))
							slur_st >>= 4
					}
				}
				s = p_voice.sym
				while (slur_st != 0) { 
					slur_type = slur_st & 0x0f;
					slur_st >>= 4;
					k = next_scut(s);
					draw_slur(s, k, -1, -1, slur_type)
					if (k.type != C.BAR
						|| (k.bar_type[0] != ':'
							&& k.bar_type != "|]"
							&& k.bar_type != "[|"
							&& (!k.text || k.text[0] == '1'))) {
						if (!p_voice.slur_start)
							p_voice.slur_start = 0;
						p_voice.slur_start <<= 4;
						p_voice.slur_start += slur_type
					}
				}
			}
			
			/**
			 * Draws note-related symbols (the staves are not yet defined).
			 * 
			 * ORDER
			* - scaled:
			*   - beams;
			*   - decorations/annotations near the notes;
			*   - measure bar numbers;
			*   - n-plets;
			*   - decorations tied to the notes;
			*   - slurs.
			* - not scaled:
			*   - guitar chords;
			*   - staff decorations;
			*   - lyrics;
			*   - measure numbers.
			* The output is buffered until the staff systems are defined.
			*/
			private function draw_sym_near() : void {
				var p_voice : Object; 
				var p_st : Object; 
				var s : Object; 
				var v : int; 
				var st : int; 
				var y : Number; 
				var g : Object; 
				var w : Number; 
				var i : int;
				var dx : Number; 
				var top : Number; 
				var bot : Number; 
				var output_sav : String;
				var first_note : Boolean;
						
				output_sav = output;
				output = "";
				
				// Calculate the beams but don't draw them (the staves are not yet defined)
				for (v = 0; v < voice_tb.length; v++) { 
					var	bm : Object = {};
					first_note = true;
					p_voice = voice_tb[v];
					
					for (s = p_voice.sym; s; s = s.next) { 
						switch (s.type) {
							case C.GRACE:
								for (g = s.extra; g; g = g.next) { 
									if (g.beam_st && !g.beam_end) {
										self.calculate_beam(bm, g);
									}
								}
								break;
							case C.NOTE:
								if ((s.beam_st && !s.beam_end) || (first_note && !s.beam_st)) {
									first_note = false;
									self.calculate_beam (bm, s);
								}
								break;
						}
					}
				}
				
				// Initialize the min/max vertical offsets
				for (st = 0; st <= nstaff; st++) { 
					p_st = staff_tb[st];
					if (!p_st.top) {
						p_st.top = new Vector.<Number>(YSTEP);
						p_st.bot = new Vector.<Number>(YSTEP);
					}
					for (i = 0; i < YSTEP; i++) { 
						p_st.top[i] = 0;
						p_st.bot[i] = 24
					}
				}
				set_tie_room();
				draw_deco_near();
				
				// Set the min/max vertical offsets
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.invis) {
						continue;
					}
					switch (s.type) {
						case C.GRACE:
							for (g = s.extra; g; g = g.next) { 
								y_set (s.st, true, g.x - 2, 4, g.ymx + 1);
								y_set (s.st, false, g.x - 2, 4, g.ymn - 1);
							}
							continue;
						case C.MREST:
							y_set (s.st, true, s.x + 16, 32, s.ymx + 2);
							continue;
						default:
							y_set (s.st, true, s.x - s.wl, s.wl + s.wr, s.ymx + 2);
							y_set (s.st, false, s.x - s.wl, s.wl + s.wr, s.ymn - 2);
							continue;
						case C.NOTE:
							break;
					}
					
					// Allow closer staves
					if (s.stem > 0) {
						if (s.beam_st) {
							dx = 3;
							w = s.beam_end ? 4 : 10;
						} else {
							dx = -8;
							w = s.beam_end ? 11 : 16;
						}
						y_set (s.st, true, s.x + dx, w, s.ymx);
						y_set (s.st, false, s.x - s.wl, s.wl + s.wr, s.ymn);
					} else {
						y_set (s.st, true, s.x - s.wl, s.wl + s.wr, s.ymx);
						if (s.beam_st) {
							dx = -6;
							w = s.beam_end ? 4 : 10;
						} else {
							dx = -8;
							w = s.beam_end ? 5 : 16;
						}
						dx += s.notes[0].shhd;
						y_set (s.st, false, s.x + dx, w, s.ymn);
					}
					
					// Reserve room for the accidentals
					if (s.notes[s.nhd].acc) {
						y = s.y + 8;
						if (s.ymx < y) {
							s.ymx = y;
						}
						y_set (s.st, true, s.x, 0, y);
					}
					if (s.notes[0].acc) {
						y = s.y;
						
						// `1` is `sharp`, `3` is `natural`
						if (s.notes[0].acc == 1 || s.notes[0].acc == 3) {
							y -= 7;
						} else {
							y -= 5;
						}
						if (s.ymn > y) {
							s.ymn = y;
						}
						y_set (s.st, false, s.x, 0, y);
					}
				}
				
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					s = p_voice.sym;
					if (!s) {
						continue;
					}
					set_color (s.color);
					st = p_voice.st;
					set_dscale (st);
					
					// Draw the tuplets near the notes
					for ( ; s; s = s.next) { 
						if (s.tp0) {
							_deferredOperations.push ([TupletUtils.drawTuplet, s, s.tp0, ENGINE]); // Custom function: does fine drawing.
							draw_tuplet (s, 0); // Default function: broken for drawing, but does good job on reseving vertical space;
						}
					}
					draw_all_slurs (p_voice);
					
					// Draw the tuplets over the slurs
					// for (s = p_voice.sym; s; s = s.next) {
					// 	if (s.tp0) {
					// 		_deferredOperations.push ([draw_tuplet, s, 0]);
					//	}
					// }
				}
				
				// Set the top and bottom out of the staves
				// TODO: rephrase
				for (st = 0; st <= nstaff; st++) { 
					p_st = staff_tb[st];
					top = p_st.topbar + 2;
					bot = p_st.botbar - 2;
					
					// Fixme:should handle stafflines changes
					for (i = 0; i < YSTEP; i++) { 
						if (top > p_st.top[i]) { 
							p_st.top[i] = top;
						}
						if (bot < p_st.bot[i]) {
							p_st.bot[i] = bot;
						}
					}
				}
				
				set_color (undefined);
				draw_deco_note ();
				draw_deco_staff ();
				
				// If there are lyrics, draw them now as unscaled
				set_dscale (-1);
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					if (p_voice.have_ly) {
						draw_all_lyrics();
						break;
					}
				}
				
				// Draw measure numbers
				if (cfmt.measurenb >= 0) {
					draw_measnb();
				}
				set_dscale (-1);
				
				// Commit output
				output = output_sav;
			}
			
			/**
			 * Draws the name/subname of the voices/parts
			 */
			private function draw_vname (indent) : void {
				var	p_voice : Object;
				var n : int;
				var st : int;
				var v : int;
				var a_p : Array;
				var p : String;
				var y : Number;
				var name_type : int;
				var staff_d : Array = [];
				var partId : String;
				var nameSegments : Array;
				
				for (st = cur_sy.nstaff; st >= 0; st--) { 
					if (cur_sy.st_print[st]) {
						break;
					}
				}
				if (st < 0) {
					return;
				}
				
				// Check if full or sub names
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					if (!p_voice.sym) {
						continue;
					}
					st = cur_sy.voices[v].st;
					if (!cur_sy.st_print[st]) {
						continue;
					}
					if (p_voice.new_name) {
						name_type = 2;
						break;
					}
					if (p_voice.snm) {
						name_type = 1;
					}
				}
				if (!name_type) {
					return;
				}
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					if (!p_voice.sym) {
						continue;
					}
					st = cur_sy.voices[v].st;
					if (!cur_sy.st_print[st]) {
						continue;
					}
					if (p_voice.new_name) {
						delete p_voice.new_name;
					}
					p = (name_type == 2)? p_voice.nm : p_voice.snm;
					if (!p) {
						continue;
					}
					if (cur_sy.staves[st].flags & CLOSE_BRACE2) {
						while (!(cur_sy.staves[st].flags & OPEN_BRACE2)) {
							st--;
						}
					} else if (cur_sy.staves[st].flags & CLOSE_BRACE) {
						while (!(cur_sy.staves[st].flags & OPEN_BRACE)) {
							st--;
						}
					}
					if (!staff_d[st]) {
						staff_d[st] = p;
					}
					else {
						staff_d[st] += "\\n" + p;
					}
				}
				if (staff_d.length == 0) {
					return;
				}
				set_font ("voice");
				
				// Center
				indent = -indent * .5;
				for (st = 0; st < staff_d.length; st++) { 
					if (!staff_d[st]) {
						continue;
					}
					a_p = staff_d[st].split('\\n');
					y = staff_tb[st].y
						+ staff_tb[st].topbar * .5
						* staff_tb[st].staffscale
						+ 9 * (a_p.length - 1)
						- gene.curfont.size * .3;
					n = st;
					if (cur_sy.staves[st].flags & OPEN_BRACE2) {
						while (!(cur_sy.staves[n].flags & CLOSE_BRACE2)) {
							n++;
						}
					} else if (cur_sy.staves[st].flags & OPEN_BRACE) {
						while (!(cur_sy.staves[n].flags & CLOSE_BRACE)) {
							n++;
						}
					}
					if (n != st) {
						y -= (staff_tb[st].y - staff_tb[n].y) * .5;
					}
					for (n = 0; n < a_p.length; n++) { 
						p = a_p[n];
						
						// If this part name is encoded with an ID, separate them and
						// tag the resulting SVG text element with the ID
						if (p.indexOf('¦') != -1) {
							nameSegments = p.split ('¦');
							partId = nameSegments[0] as String;
							p = nameSegments.pop() as String;
						}
						xy_str (indent, y, p, "c", NaN, partId);
						y -= 18;
					}
				}
			}
			
			// -- set the y offset of the staves and return the height of the whole system --
			private function set_staff() : *  {
				var	s, i, st, prev_staff, v,
				y, staffsep, dy, maxsep, mbot, val, p_voice, p_staff
				
				/* set the scale of the voices */
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					if (p_voice.scale != 1)
						p_voice.scale_str =
							'transform="scale(' + p_voice.scale.toFixed(2) + ')"'
				}
				
				// search the top staff
				for (st = 0; st <= nstaff; st++) { 
					if (gene.st_print[st])
						break
				}
				y = 0
				if (st > nstaff) {
					st--;			/* one staff, empty */
					p_staff = staff_tb[st]
				} else {
					p_staff = staff_tb[st]
					for (i = 0; i < YSTEP; i++) { 
						val = p_staff.top[i]
						if (y < val)
							y = val
					}
				}
				
				/* draw the parts and tempo indications if any */
				y += draw_partempo(st, y)
				
				if (!gene.st_print[st])
					return y;
				
				/* set the vertical offset of the 1st staff */
				y *= p_staff.staffscale;
				staffsep = cfmt.staffsep * .5 +
					p_staff.topbar * p_staff.staffscale
				if (y < staffsep)
					y = staffsep
				if (y < p_staff.ann_top)	// absolute annotation
					y = p_staff.ann_top;
				p_staff.y = -y;
				
				/* set the offset of the other staves */
				prev_staff = st
				var sy_staff_prev = cur_sy.staves[prev_staff]
				for (st++; st <= nstaff; st++) { 
					p_staff = staff_tb[st]
					if (!gene.st_print[st])
						continue
					staffsep = sy_staff_prev.sep || cfmt.sysstaffsep;
					maxsep = sy_staff_prev.maxsep || cfmt.maxsysstaffsep;
					
					dy = 0
					if (p_staff.staffscale == staff_tb[prev_staff].staffscale) {
						for (i = 0; i < YSTEP; i++) { 
							val = p_staff.top[i] -
								staff_tb[prev_staff].bot[i]
							if (dy < val)
								dy = val
						}
						dy *= p_staff.staffscale
					} else {
						for (i = 0; i < YSTEP; i++) { 
							val = p_staff.top[i] * p_staff.staffscale
								- staff_tb[prev_staff].bot[i]
								* staff_tb[prev_staff].staffscale
							if (dy < val)
								dy = val
						}
					}
					staffsep += p_staff.topbar * p_staff.staffscale
					if (dy < staffsep)
						dy = staffsep;
					maxsep += p_staff.topbar * p_staff.staffscale
					if (dy > maxsep)
						dy = maxsep;
					y += dy;
					p_staff.y = -y;
					
					prev_staff = st;
					sy_staff_prev = cur_sy.staves[prev_staff]
				}
				mbot = 0
				for (i = 0; i < YSTEP; i++) { 
					val = staff_tb[prev_staff].bot[i]
					if (mbot > val)
						mbot = val
				}
				if (mbot > p_staff.ann_bot) 	// absolute annotation
					mbot = p_staff.ann_bot;
				mbot *= staff_tb[prev_staff].staffscale
				
				/* output the staff offsets */
				for (st = 0; st <= nstaff; st++) { 
					p_staff = staff_tb[st];
					dy = p_staff.y
					if (p_staff.staffscale != 1) {
						p_staff.scale_str =
							'transform="translate(0,' +
							(posy - dy).toFixed(2) + ') ' +
							'scale(' + p_staff.staffscale.toFixed(2) + ')"'
					}
				}
				
				if (mbot == 0) {
					for (st = nstaff; st >= 0; st--) { 
						if (gene.st_print[st])
							break
					}
					if (st < 0)		/* no symbol in this system ! */
						return y
				}
				dy = -mbot;
				staffsep = cfmt.staffsep * .5
				if (dy < staffsep)
					dy = staffsep;
				maxsep = cfmt.maxstaffsep * .5
				if (dy > maxsep)
					dy = maxsep;
				
				// return the height of the whole staff system
				return y + dy
			}
			
			/**
			 * Draws the staff systems and the measure bars.
			 **/
			private function draw_systems (indent) : void {
				var	s : Object; 
				var s2 : Object; 
				var st : int; 
				var x : Number; 
				var x2 : Number; 
				var _sy : Object;
				var staves_bar : Number; 
				var bar_force : Number;
				var xstaff : Array = [];
				var bar_bot : Array = [];
				var bar_height : Array = [];
				stavesBounds = [];
				var barsBounds : Array = [];
				var barsIds : Array = [];
				
				// Sets the bottom and height of the measure bars
				// Nested function
				// TODO: externalize
				function bar_set () : void {
					var	st : int;
					var staffscale : Number;
					var top : Number;
					var bot : Number;
					var dy : Number = 0;
					for (st = 0; st <= cur_sy.nstaff; st++) { 
						if (xstaff[st] < 0) {
							bar_bot[st] = bar_height[st] = 0;
							continue;
						}
						staffscale = staff_tb[st].staffscale;
						top = staff_tb[st].topbar * staffscale;
						bot = staff_tb[st].botbar * staffscale;
						if (dy == 0) {
							dy = staff_tb[st].y + top;
						}
						bar_bot[st] = staff_tb[st].y + bot;
						bar_height[st] = dy - bar_bot[st];
						dy = (cur_sy.staves[st].flags & STOP_BAR)? 0 : bar_bot[st];
					}
				}
				
				// Draws a staff
				// Nested function
				// TODO: externalize
				function draw_staff (st : int, x1 : Number, x2 : Number) : void {
					var	w : Number; 
					var ws : Number; 
					var i : Number;
					var id : String;
					var dy : Number;
					var dYTotal : Number;
					var ty : String;
					var y : Number = 0;
					var ln : String = "";
					var stafflines : String = cur_sy.staves[st].stafflines;
					var l : int = stafflines.length;
					var staffBound : Rectangle;
					
					// Exit if this is a no line staff
					if (!/[\[|]/.test(stafflines)) {
						return;
					}
					w = x2 - x1;
					set_sscale (st);
					ws = w / stv_g.scale;
					
					// Check if default staff
					if (cache && cache.st_l == stafflines && cache.st_ws == ws) {
						xygl (x1, staff_tb[st].y, 'stdef' + cfmt.fullsvg);
						return;
					}
					for (i = 0; i < l; i++, y -= 6) { 
						if (stafflines.charAt(i) == '.') {
							continue;
						}
						dy = 0;
						dYTotal = 6;
						for (; i < l; i++, y -= 6, dy -= 6, dYTotal -= 6) { 
							switch (stafflines.charAt(i)) {
								case '.':
								case '-':
									continue;
								case ty:
									ln += 'm-' + ws.toFixed(2) +
									' ' + dy +
									'h' + ws.toFixed(2);
									dy = 0;
									continue;
							}
							if (ty) {
								ln += '"/>\n';
							}
							ty = stafflines.charAt(i);
							ln += '<path class="stroke staff-bar" '
								
							// Draw a thick staff bar if requested
							if (ty == '[') {
								ln += ' stroke-width="1.5"';
							}
							ln += ' d="m0 ' + y + 'h' + ws.toFixed(2);
							dy = 0;
						}
						ln += '"/>\n';
					}
					y = staff_tb[st].y;
					if (!cache && w == get_lwidth()) {
						cache = {
							st_l: stafflines,
							st_ws: ws
						}
						id = 'stdef' + cfmt.fullsvg;
						glyphs[i] = '<g id="' + id + '">\n' + ln + '</g>';
						xygl (x1, y, id);
						return;
					}
					out_XYAB ('<g transform="translate(X, Y)">\n' + ln + '</g>\n', x1, y);
					staffBound = new Rectangle (sx(x1), sy(y) + dYTotal, ws, Math.abs (dYTotal));
					stavesBounds.push (staffBound);
					
					
					
					// Draw the tuplet brackets for this staff. They need to be drawn AFTER the staff,
					// itself is drawn, so we can position them reliably.
					for (var i4:int = 0; i4 < _deferredOperations.length; i4++) {
						var operationInfo : Array = (_deferredOperations[i4] as Array);
						var functionToCall : Function = (operationInfo[0] as Function);
						if (functionToCall == TupletUtils.drawTuplet) {
							var args : Array = operationInfo.slice (1);
							if (args.length > 0) {
								var symbol : Object = args[0];
								var relatedStaffIndex : int = symbol.st as int;
								if (relatedStaffIndex == st) {
									functionToCall.apply (this, args);
									
									// Remove the deferred operation once it was run
									_deferredOperations[i4] = null;
								}
							}
						}
					}
					
					// Cleanup the deferred operations list
					_deferredOperations.sort (function (a : Object, b : Object) : int {
						return (a === null && b !== null)? 1 : (a !== null && b === null)? -1 : 0;
					});
					while (_deferredOperations[_deferredOperations.length - 1] === null) {
						_deferredOperations.length -= 1;
					}
				}
				
				// Draw the staff voice name
				draw_vname (indent);
				
				// Draw the staff, skipping the staff breaks
				var measureId : String;
				var measureIdSegments : Array;
				for (st = 0; st <= nstaff; st++) { 
					xstaff[st] = !cur_sy.st_print[st] ? -1 : 0;
				}
				bar_set();
				draw_lstaff (0);
				for (s = tsfirst; s; s = s.ts_next) { 
					if (bar_force && s.time != bar_force) {
						bar_force = 0;
						for (st = 0; st <= nstaff; st++) { 
							if (!cur_sy.st_print[st]) {
								xstaff[st] = -1;
							}
						}
						bar_set();
					}
					switch (s.type) {
						case C.STAVES:
							staves_bar = (s.ts_prev.type == C.BAR)? s.ts_prev.x : 0;
							if (!staves_bar) {
								for (s2 = s.ts_next; s2; s2 = s2.ts_next) { 
									if (s2.time != s.time) {
										break;
									}
									switch (s2.type) {
										case C.BAR:
										case C.CLEF:
										case C.KEY:
										case C.METER:
											staves_bar = s2.x;
											continue;
									}
									break;
								}
								if (!s2) {
									staves_bar = realwidth;
								}
							}
							_sy = s.sy;
							for (st = 0; st <= nstaff; st++) { 
								x = xstaff[st];
								
								// No staff yet
								if (x < 0) {
									if (_sy.st_print[st]) {
										xstaff[st] = staves_bar? staves_bar : (s.x - s.wl - 2);
									}
									continue;
								}
								
								// (???) If not staff stop
								if (_sy.st_print[st] && _sy.staves[st].stafflines == cur_sy.staves[st].stafflines) {
									continue;
								}
								if (staves_bar) {
									x2 = staves_bar;
									bar_force = s.time;
								} else {
									x2 = s.x - s.wl - 2;
									xstaff[st] = -1;
								}
								draw_staff (st, x, x2);
								if (_sy.st_print[st]) {
									xstaff[st] = x2;
								}
							}
							cur_sy = _sy;
							bar_set ();
							continue;
							
						case C.BAR:
							st = s.st;
							if (s.second || s.invis) {
								break;
							}
							
							// We deliberately leave out the "part index" segment of the id, because we want
							// to only record one entry per measure stack so that, e.g., a 8 bars Piano and Violin
							// score will report 8 measure boundaries, not 16.
							var firstNoteIds : Array = (s.notes[0].ids as Array);
							if (firstNoteIds) {
								measureId = (firstNoteIds[0] as String);
								measureIdSegments = measureId.split ('_');
								measureIdSegments.splice (-2, 1, '0');
								measureId = measureIdSegments.join ('_');
							}

							// When more than one staff are involved in a score, measure bars are drawn
							// from several segments; all segments will have the same ID, therefore we
							// need to make sure to only record one measure boundary per segment ID
							if (barsIds.indexOf (measureId) == -1) {
								barsIds.push (measureId);
								var right : Number = sx(s.x);
								var barBounds : Rectangle = new Rectangle;
								barBounds.right = right;
								barsBounds.push (barBounds);
							}
							draw_bar (s, bar_bot[st], bar_height[st]);
							break;
						case C.STBRK:
							if (cur_sy.voices[s.v].range == 0) {
								if (s.xmx > 14) {
									
									// (???) Draw the left system if stbrk ("staff break" ?) in all voices
									var nv : int = 0;
									for (var i : int = 0; i < voice_tb.length; i++) { 
										if (cur_sy.voices[i].range > 0) {
											nv++;
										}
									}
									for (s2 = s.ts_next; s2; s2 = s2.ts_next) { 
										if (s2.type != C.STBRK) {
											break;
										}
										nv--;
									}
									if (nv == 0) {
										draw_lstaff (s.x);
									}
								}
							}
							s2 = s.prev;
							if (!s2) {
								break;
							}
							x2 = s2.x;
							if (s2.type != C.BAR) {
								x2 += s2.wr;
							}
							st = s.st;
							x = xstaff[st];
							if (x >= 0) {
								if (x >= x2) {
									continue;
								}
								draw_staff (st, x, x2);
							}
							xstaff[st] = s.x;
							break;
					}
				}
				
				// Draw the end of the staves
				for (st = 0; st <= nstaff; st++) {
					if (bar_force && !cur_sy.st_print[st]) {
						continue;
					}
					x = xstaff[st];
					if (x < 0 || x >= realwidth) {
						continue;
					}
					draw_staff (st, x, realwidth);
				}
								
				// The ABC parser naturally groups Voices by index (first all `Voice 1` nodes for all
				// Part nodes, then all `Voice 2` nodes for all Part nodes) but we need them to be grouped by Part
				// and by staff, so we clone the voices table and reorder it.
				// We take this oportunity to also build a map with part names and their span (top and bottom
				// staves, where each staff is represented as a 0-based index). 
				var i2 : int;
				var i3 : int;
				var voice : Object;
				var prevVoice : Object;
				var testVoice : Object;
				var id : String;
				var voiceId : String;
				var testVoiceId : String;
				var partId : String;
				var prevPartId : String;
				var partIds : Array = [];
				var partsMap : Object = {};
				var topStaffIndex : int;
				var bottomStaffIndex : int;
				var isDifferentPart : Boolean;
				var sortedVoices : Array = voice_tb.concat ();
				for (i2 = 0; i2 < sortedVoices.length; i2++) {
					voice = sortedVoices[i2];

					// Stamp the ABC "voice" with its uid, if available. In case of braced Parts
					// (e.g., Piano, in its default display mode of two braced staves) MAIDENS
					// only assigns a name (and, hence, uid) to the first staff; if this is the
					// case, we want to propagate the uid of the first ABC "voice" to all subsequent
					// "voices" that have no name/uid.
					voice.uid = null;
					if (voice.nm) {
						voice.uid = voice.nm.split(CommonStrings.BROKEN_VERTICAL_BAR)[0];
					}
					if (!voice.uid && prevVoice && prevVoice.uid) {
						voice.uid = prevVoice.uid;
					}

					// Determine whether this "voice" begins, or belongs to a "new", or
					// different Part than the voice before it.
					isDifferentPart = (!prevVoice ||
							(prevVoice && voice.uid && voice.uid != prevVoice.uid));
					prevVoice = voice;

					// The index we add an ABC "partId" to the "partIds" Array determines
					// how many "Voices" (in MAIDENS parlance) hotspots are assigned
					// to the current Part. If we add a new "partId" too early, higher Voices
					// of that Part will become unselectable in MAIDENS' score. We definitely
					// DO NOT want to add a "partId" for each "voice" (in ABC/abc2svg
					// library parlance) that has a "snm" field set, because in MAIDENS,
					// there can be staves of the same Part that have their own, meaningfull
					// names, e.g., the third staff of Organ is usually labeled "Pedal", and
					// that would create an ABC new "voice", by the "snm" of "Ped.".
					partId = voice.uid as String;
					if (partId) {
						partsMap[partId] = (partsMap[partId] || {});
						if (isDifferentPart) {
							partIds.push (partId);
							topStaffIndex = Math.floor (i2 * .5) as int;
							partsMap[partId].topStaff = topStaffIndex;
						}
						if (partIds.length > 1) {
							prevPartId = partIds[partIds.length - 2] as String;
							bottomStaffIndex = (topStaffIndex - 1);
							partsMap[prevPartId].bottomStaff = bottomStaffIndex;
						}
					}
					voiceId = voice.id as String;
					for (i3 = i2 + 1; i3 < sortedVoices.length; i3++) { 
						testVoice = sortedVoices[i3];
						testVoiceId = testVoice.id as String;
						if (Strings.beginsWith (testVoiceId, voiceId)) {
							if (i3 - i2 == 1) {
								continue;
							}
							sortedVoices.splice (i3, 1);
							sortedVoices.splice (i2 + 1, 0, testVoice);
							i2++;
							break;
						}
					}
				}
				partId = partIds[partIds.length - 1] as String;
				bottomStaffIndex = Math.floor ((sortedVoices.length - 1) * .5) as int;
				partsMap[partId].bottomStaff = bottomStaffIndex;

				// We will draw a hotspot for each Measure/Part entity and two more hotspots for
				// each of the two Voices of each staff of each Part.
				var currentMeasureRect : Rectangle; 
				var lastMeasureRect : Rectangle;
				var currentStaffRect : Rectangle;
				var firstStaffRect : Rectangle = stavesBounds[0] as Rectangle;
				var lastStaffRect : Rectangle = stavesBounds[stavesBounds.length - 1] as Rectangle;
				var partTopStaffRect : Rectangle;
				var partBottomStaffRect : Rectangle;
				var j : int;
				var k : int;
				var L : int;
				var internalVoiceCounter : int;
				var externalVoiceCounter : int;
				var partIndex : int;
				var measureIndex : int;
				var staffIndex : int;
				var idSegments : Array;
				var voiceUid : String;
				var partInfo : Object;

				// Measure hotspots
				for (j = 0; j < barsBounds.length; j++) { 
					currentMeasureRect = barsBounds[j] as Rectangle;
					currentMeasureRect.left = lastMeasureRect? lastMeasureRect.right : firstStaffRect.left;
					currentMeasureRect.top = firstStaffRect.top;
					currentMeasureRect.bottom = lastStaffRect.bottom;
					lastMeasureRect = currentMeasureRect;
					id = barsIds[j] as String;
					if (id) {
						idSegments = id.split ('_');
						measureIndex = idSegments.pop();
						idSegments.length -= 1;
					}
					for (L = 0; L < partIds.length; L++) {
						
						partId = partIds[L] as String;
						partInfo = (partsMap[partId] as Object);
						topStaffIndex = partInfo.topStaff as int;
						bottomStaffIndex = partInfo.bottomStaff as int;
						partTopStaffRect = stavesBounds[topStaffIndex] as Rectangle;
						partBottomStaffRect = stavesBounds[bottomStaffIndex] as Rectangle;
						if (idSegments) {
							measureId = idSegments.join ('_') + '_' + L + '_' + measureIndex;
						}
						if (partTopStaffRect && partBottomStaffRect) {
							addHotspot ('measure', currentMeasureRect.left + 2,
								partTopStaffRect.top - 6, currentMeasureRect.width - 4, 
								partBottomStaffRect.bottom - partTopStaffRect.top + 12, measureId);
						}
					}

					// Voice hotspots
					partId = partIds[0] as String;
					internalVoiceCounter = 0;
					externalVoiceCounter = 0;
					for (internalVoiceCounter = 0; internalVoiceCounter < sortedVoices.length; internalVoiceCounter++) { 
						voice = sortedVoices[internalVoiceCounter] as Object;
						voiceUid = voice.uid;
						if (voiceUid) {
							partIndex = partIds.indexOf (voiceUid);
							if (partId != voiceUid) {
								partId = voiceUid;
								externalVoiceCounter = 0;
							}
						}
						if (idSegments) {
							voiceId = idSegments.join('_') + '_' + partIndex + '_' + measureIndex + '_' + externalVoiceCounter;
						}
						staffIndex = Math.floor (internalVoiceCounter * .5) as int;
						currentStaffRect = stavesBounds[staffIndex] as Rectangle;
						if (currentStaffRect && currentStaffRect.intersects (currentMeasureRect)) {
							
							// Draw "voice 1" hotspot: upper half of the staff
							var isFirstVoice : Boolean = (externalVoiceCounter % 2 == 0);
							if (isFirstVoice) {
								addHotspot ('voice voice-1', currentMeasureRect.left, currentStaffRect.top, currentMeasureRect.width,
									currentStaffRect.height * .5, voiceId);
							} 
							
							// Draw "voice 2" hotspot: lower half of the staff
							else {
								addHotspot ('voice voice-2', currentMeasureRect.left, currentStaffRect.top + currentStaffRect.height * .5,
									currentMeasureRect.width, currentStaffRect.height * .5, voiceId);
							}
						}
						externalVoiceCounter++;
					}
				}
			}
			
			
			/**
			 * Draws remaining symbols when the staves are defined.
			 * (possible hook)
			 */
			private function draw_symbols (p_voice : Object) : void {
				var	bm : Object = {};
				var s : Object;
				var x : Number;
				var y : Number;
				var st : int;
				
				for (s = p_voice.sym; s; s = s.next) { 
					if (s.invis) {
						switch (s.type) {
							case C.KEY:
								p_voice.key = s;
							default:
								continue;
								
							// Beams may start on invisible notes
							case C.NOTE:
								break;
						}
					}
					x = s.x;
					set_color (s.color);
					switch (s.type) {
						case C.NOTE:
							
							// FIXME: recall set_scale if different staff
							set_scale (s);
							if (s.beam_st && !s.beam_end) {
								if (self.calculate_beam (bm, s)) {
									draw_beams (bm);
								}
							}
							if (!s.invis) {
								anno_start (s);
								draw_note (s, !bm.s2);
								anno_stop (s);
							}
							if (s == bm.s2) {
								bm.s2 = null;
							}
							break;
						case C.REST:
							draw_rest(s);
							break;
						// Drawn in `draw_systems()`
						case C.BAR:
							break;
						case C.CLEF:
							st = s.st;
							if (s.time > staff_tb[st].clef.time) {
								staff_tb[st].clef = s;
							}
							
							// Only one clef per staff
							if (s.second) {
								break;
							}
							
							if (!staff_tb[s.st].topbar) {
								break;
							}
							set_color (undefined);
							set_sscale (st);
							anno_start (s);
							y = staff_tb[st].y;
							if (s.clef_name) {
								xygl(x, y + s.y, s.clef_name);
							}
							else if (!s.clef_small) {
								xygl (x, y + s.y, s.clef_type + "clef");
							}
							else {
								xygl (x, y + s.y, "s" + s.clef_type + "clef");
							}
							if (s.clef_octave) {
								// (???) FIXME: break the compatibility and avoid strange numbers
								if (s.clef_octave > 0) {
									y += s.ymx - 10;
									if (s.clef_small) {
										y -= 1;
									}
								} else {
									y += s.ymn + 6;
									if (s.clef_small) {
										y += 1;
									}
								}
								xygl (x - 2, y, "oct");
							}
							anno_stop(s);
							break;
						case C.METER:
							p_voice.meter = s;
							if (s.second || !staff_tb[s.st].topbar) {
								break;
							}
							if (cfmt.alignbars && s.st != 0) {
								break;
							}
							set_color (undefined);
							set_sscale (s.st);
							anno_start (s);
							draw_meter (x, s);
							anno_stop (s)
							break;
						
						case C.KEY:
							p_voice.key = s;
							if (s.second || !staff_tb[s.st].topbar) {
								break;
							}
							set_color (undefined);
							set_sscale (s.st);
							anno_start (s);
							draw_keysig (p_voice, x, s);
							anno_stop (s);
							break
						case C.MREST:
							set_scale (s);
							x += 32;
							anno_start (s);
							xygl (x, staff_tb[s.st].y + 12, "mrest");
							out_XYAB ('<text style="font:bold 15px serif_embedded" x ="X" y="Y" text-anchor="middle">A</text>\n',
								x, staff_tb[s.st].y + 28, s.nmes);
							anno_stop (s);
							break;
						
						case C.GRACE:
							set_scale (s);
							draw_gracenotes (s);
							break;
						
						case C.SPACE:
						case C.STBRK:
							break;
						
						// Nothing
						case C.CUSTOS:
							set_scale (s);
							draw_note (s, 0);
							break;
						
						// No width
						case C.BLOCK:
						case C.PART:
						case C.REMARK:
						case C.STAVES:
						case C.TEMPO:
							break;
						default:
							error (2, s, "draw_symbols - Cannot draw symbol " + s.type);
							break;
					}
				}
				set_scale (p_voice.sym);
				draw_all_ties (p_voice);
				set_color (undefined);
			}
			
			/* -- draw all symbols -- */
			private function draw_all_sym() : *  {
				var	p_voice, v,
				n = voice_tb.length
				
				for (v = 0; v < n; v++) { 
					p_voice = voice_tb[v]
					if (p_voice.sym
						&& p_voice.sym.x != undefined)
						self.draw_symbols(p_voice)
				}
				
				draw_all_deco();
				set_sscale(-1)				/* restore the scale */
			}
			
			/* -- set the tie directions for one voice -- */
			private function set_tie_dir(sym) : *  {
				var s, i, ntie, dir, sec, pit, ti
				
				for (s = sym; s; s = s.next) { 
					if (!s.ti1)
						continue
					
					/* if other voice, set the ties in opposite direction */
					if (s.multi != 0) {
						dir = s.multi > 0 ? C.SL_ABOVE : C.SL_BELOW
						for (i = 0; i <= s.nhd; i++) { 
							ti = s.notes[i].ti1;
							if (!((ti & 0x07) == C.SL_AUTO))
								continue
							s.notes[i].ti1 = (ti & C.SL_DOTTED) | dir
						}
						continue
					}
					
					/* if one note, set the direction according to the stem */
					sec = ntie = 0;
					pit = 128
					for (i = 0; i <= s.nhd; i++) { 
						if (s.notes[i].ti1) {
							ntie++
							if (pit < 128
								&& s.notes[i].pit <= pit + 1)
							sec++;
							pit = s.notes[i].pit
						}
					}
					if (ntie <= 1) {
						dir = s.stem < 0 ? C.SL_ABOVE : C.SL_BELOW
						for (i = 0; i <= s.nhd; i++) { 
							ti = s.notes[i].ti1
							if (ti) {
								if ((ti & 0x07) == C.SL_AUTO)
									s.notes[i].ti1 =
										(ti & C.SL_DOTTED) | dir
								break
							}
						}
						continue
					}
					if (sec == 0) {
						if (ntie & 1) {
							/* in chords with an odd number of notes, the outer noteheads are paired off
							* center notes are tied according to their position in relation to the
							* center line */
							ntie = (ntie - 1) / 2;
							dir = C.SL_BELOW
							for (i = 0; i <= s.nhd; i++) { 
								ti = s.notes[i].ti1
								if (ti == 0)
									continue
								if (ntie == 0) {	/* central tie */
									if (s.notes[i].pit >= 22)
										dir = C.SL_ABOVE
								}
								if ((ti & 0x07) == C.SL_AUTO)
									s.notes[i].ti1 =
										(ti & C.SL_DOTTED) | dir
								if (ntie-- == 0)
									dir = C.SL_ABOVE
							}
							continue
						}
						/* even number of notes, ties divided in opposite directions */
						ntie /= 2;
						dir = C.SL_BELOW
						for (i = 0; i <= s.nhd; i++) { 
							ti = s.notes[i].ti1
							if (ti == 0)
								continue
							if ((ti & 0x07) == C.SL_AUTO)
								s.notes[i].ti1 =
									(ti & C.SL_DOTTED) | dir
							if (--ntie == 0)
								dir = C.SL_ABOVE
						}
						continue
					}
					/*fixme: treat more than one second */
					/*		if (nsec == 1) {	*/
					/* When a chord contains the interval of a second, tie those two notes in
					* opposition; then fill in the remaining notes of the chord accordingly */
					pit = 128
					for (i = 0; i <= s.nhd; i++) { 
						if (s.notes[i].ti1) {
							if (pit < 128
								&& s.notes[i].pit <= pit + 1) {
								ntie = i
								break
							}
							pit = s.notes[i].pit
						}
					}
					dir = C.SL_BELOW
					for (i = 0; i <= s.nhd; i++) { 
						ti = s.notes[i].ti1
						if (ti == 0)
							continue
						if (ntie == i)
							dir = C.SL_ABOVE
						if ((ti & 0x07) == C.SL_AUTO)
							s.notes[i].ti1 = (ti & C.SL_DOTTED) | dir
					}
					/*fixme..
					continue
					}
					..*/
					/* if a chord contains more than one pair of seconds, the pair farthest
					* from the center line receives the ties drawn in opposition */
				}
			}
			
			/* -- have room for the ties out of the staves -- */
			private function set_tie_room() : *  {
				var p_voice, s, s2, v, dx, y, dy
				
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					s = p_voice.sym
					if (!s)
						continue
					s = s.next
					if (!s)
						continue
					set_tie_dir(s)
					for ( ; s; s = s.next) { 
						if (!s.ti1)
							continue
						if (s.notes[0].pit < 20
							&& (s.notes[0].ti1 & 0x07) == C.SL_BELOW)
							;
						else if (s.notes[s.nhd].pit > 24
							&& (s.notes[s.nhd].ti1 & 0x07) == C.SL_ABOVE)
							;
						else
							continue
						s2 = s.next
						while (s2 && s2.type != C.NOTE) { 
							s2 = s2.next;
						}
						if (s2) {
							if (s2.st != s.st)
								continue
							dx = s2.x - s.x - 10
						} else {
							dx = realwidth - s.x - 10
						}
						if (dx < 100)
							dy = 9
						else if (dx < 300)
							dy = 12
						else
							dy = 16
						if (s.notes[s.nhd].pit > 24) {
							y = 3 * (s.notes[s.nhd].pit - 18) + dy
							if (s.ymx < y)
								s.ymx = y
							if (s2 && s2.ymx < y)
								s2.ymx = y;
							y_set(s.st, true, s.x + 5, dx, y)
						}
						if (s.notes[0].pit < 20) {
							y = 3 * (s.notes[0].pit - 18) - dy
							if (s.ymn > y)
								s.ymn = y
							if (s2 && s2.ymn > y)
								s2.ymn = y;
							y_set(s.st, false, s.x + 5, dx, y)
						}
					}
				}
			}
			
			// ---------------------------------
			
			
			// abc2svg - format.js - formatting functions
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			private var	defined_font : Object = {};
			private var font_tb : Object = {};
			private var fid : int = 1;
			private var font_scale_tb : Object = {
				serif_embedded: 1.05,
				serif_embeddedBold: 1.05,
				'sans_embedded': 1.1,
				//'sans_embeddedBold': 1.1,
				//Palatino: 1.1,
				Mono: 1.35
				};
			private var fmt_lock : Object = {};
			
			private var cfmt : Object = {
				aligncomposer: 1,
				//	botmargin: .7 * IN,		// != 1.8 * CM,
				breaklimit: .7,
				breakoneoln: true,
				cancelkey: true,
				composerspace: 6,
				//	contbarnb: false,
				dblrepbar: ':][:',
				decoerr: true,
				dynalign: true,
				fullsvg: '',
				gracespace: Vector.<Number> ([4, 8, 11]), // left, inside, right
				graceslurs: true,
				hyphencont: true,
				indent: 0,
				infoname: 'R "Rhythm: "\n\
				B "Book: "\n\
				S "Source: "\n\
				D "Discography: "\n\
				N "Notes: "\n\
				Z "Transcription: "\n\
				H "History: "',
				infospace: 0,
				keywarn: true,
				leftmargin: 1.4 * CM,
					lineskipfac: 1.1,
					linewarn: true,
					maxshrink: .65,
					maxstaffsep: 2000,
					maxsysstaffsep: 2000,
					measurefirst: 1,
					measurenb: -1,
					musicspace: 6,
					//	notespacingfactor: 1.414,
					parskipfac: .4,
					partsspace: 8,
					//	pageheight: 29.7 * CM,
					pagewidth: 21 * CM,
					//	pos: {
					//		dyn: 0,
					//		gch: 0,
					//		gst: 0,
					//		orn: 0,
					//		stm: 0,
					//		voc: 0,
					//		vol: 0
					//	},
					printmargin: 0,
					rightmargin: 1.4 * CM,
					rbdbstop: true,
					rbmax: 4,
					rbmin: 2,
					scale: 1,
					slurheight: 1.0,
					staffsep: 46,
					stemheight: 21,			// one octave
					stretchlast: .25,
					stretchstaff: true,
					subtitlespace: 3,
					sysstaffsep: 34,
					//	textoption: undefined,
					textspace: 14,
					//	titleleft: false,
					titlespace: 6,
					titletrim: true,
					//	transp: 0,			// global transpose
					//	topmargin: .7 * IN,
					topspace: 22,
					tuplets: [0, 0, 0, 0],
					vocalspace: 10,
					//	voicescale: 1,
					writefields: "CMOPQsTWw",
					wordsspace: 5
			}
			
			private function get_bool(param) : *  {
				return !param || !/^(0|n|f)/i.test(param) // accept void as true !
			}
			
			/**
			 * Computes and stores font scale based on given font parameter.
			 * %%font <font> [<encoding>] [<scale>]
			 */
			private function get_font_scale(param) : void  {
				
				// a[0] = font name
				var	a : Array = param.split(/\s+/);	
				if (a.length <= 1) {
					return;
				}
				var scale : Number = parseFloat(a[a.length - 1]);
				if (isNaN (scale) || a.length == 0) {
					syntax (1, "Bad scale value in %%font");
					return;
				}
				font_scale_tb[a[0]] = scale;
				for (var fn : String in font_tb) { 
					if (!font_tb.hasOwnProperty(fn)) {
						continue;
					}
					var font : Object = font_tb[fn];
					if (font.name == a[0]) {
						font.swfac = font.size * scale;
					}
				}
			}
			
			// %%xxxfont fontname|* [encoding] [size|*]
			private function param_set_font(xxxfont : String, param : String) : void {
				var font; 
				var fn; 
				var old_fn; 
				var n; 
				var a; 
				var new_name; 
				var new_fn;
				var new_size; 
				var scale; 
				var cl;
				
				// "setfont-<n>" goes to "u<n>font"
				if (xxxfont.charAt(xxxfont.length - 2) == '-') {
					n = xxxfont[xxxfont.length - 1]
					if (n < '1' || n > '9')
						return
					xxxfont = "u" + n + "font"
				}
				fn = cfmt[xxxfont]
				if (fn) {
					font = font_tb[fn]
					if (font) {
						old_fn = font.name + "." + font.size
						if (font['class'])
							old_fn += '.' + font['class']
								}
				}
				
				n = param.indexOf('class=')
				if (n >= 0) {
					n += 6;
					a = param.indexOf(' ', n)
					if (a > 0)
						cl = param.slice(n, a)
					else
						cl = param.slice(n);
					param = Strings.trim( param.replace(new RegExp('class=' + cl), ''));
				}
				
				a = param.split(/\s+/);
				new_name = a[0]
				if (new_name == "*"
					&& font) {
					new_name = font.name
				} else {
					new_name = new_name.replace('Times-Roman', 'serif_embedded');
					new_name = new_name.replace('Times', 'serif_embedded');
					new_name = new_name.replace('Helvetica', 'sans_embedded');
					// new_name = new_name.replace('Courier', 'sans_embedded')
				}
				if (a.length > 1) {
					new_size = a[a.length - 1]
					if (new_size == '*' && font)
						new_size = font.size
				} else if (font) {
					new_size = font.size
				}
				if (!new_size) {
					// error ?
					return;
				}
				new_fn = new_name + "." + new_size
				if (cl)
					new_fn += '.' + cl
				if (new_fn == old_fn)
					return;
				font = font_tb[new_fn]
				if (!font) {
					scale = font_scale_tb[new_name]
					if (!scale)
						scale = 1.1;
					font = {
						name: new_name,
						size: Number(new_size),
						swfac: new_size * scale
					}
					font_tb[new_fn] = font
				}
				if (cl)
					font['class'] = cl;
						cfmt[xxxfont] = new_fn
			}
			
			// get a length with a unit - return the number of pixels
			private function get_unit(param) : *  {
				var v = parseFloat(param)
				
				switch (param.slice(-2)) {
					case "CM":
					case "cm":
						v *= CM
						break
					case "IN":
					case "in":
						v *= IN
						break
					case "PT":		// paper point in 1/72 inch
					case "pt":
						v *= .75
						break
					//	default:  // ('px')	// screen pixel in 1/96 inch
				}
				return v
			}
			
			// set the infoname
			private function set_infoname(param) : *  {
				//fixme: check syntax: '<letter> ["string"]'
				var	tmp = cfmt.infoname.split("\n"),
					letter = param[0]
				
				for (var i = 0; i < tmp.length; i++) { 
					var infoname = tmp[i]
					if (infoname[0] != letter)
						continue
					if (param.length == 1)
						tmp.splice(i, 1)
					else
						tmp[i] = param
					cfmt.infoname = tmp.join('\n')
					return
				}
				cfmt.infoname += "\n" + param
			}
			
			// get the text option
			private var textopt = {
				align: 'j',
				center: 'c',
				fill: 'f',
				justify: 'j',
				ragged: 'f',
				right: 'r',
				skip: 's'
			}
			private function get_textopt(param) : *  {
				return textopt[param]
			}
			
			/* -- position of a voice element -- */
			private var posval = {
				above: C.SL_ABOVE,
					auto: 0,		// !! not C.SL_AUTO !!
					below: C.SL_BELOW,
					down: C.SL_BELOW,
					hidden: C.SL_HIDDEN,
					opposite: C.SL_HIDDEN,
					under: C.SL_BELOW,
					up: C.SL_ABOVE
			}
			
			/* -- set the position of elements in a voice -- */
			private function set_pos(k, v) : *  {		// keyword, value
				k = k.slice(0, 3)
				if (k == "ste")
					k = "stm"
				self.set_v_param("pos", k + ' ' + v)
			}
			
			// set/unset the fields to write
			private function set_writefields(parm) : *  {
				var	c, i,
				a = parm.split(/\s+/)
				
				if (get_bool(a[1])) {
					for (i = 0; i < a[0].length; i++) { 	// set
						c = a[0][i]
						if (cfmt.writefields.indexOf(c) < 0)
							cfmt.writefields += c
					}
				} else {
					for (i = 0; i < a[0].length; i++) { 	// unset
						c = a[0][i]
						if (cfmt.writefields.indexOf(c) >= 0)
							cfmt.writefields = cfmt.writefields.replace(c, '')
					}
				}
			}
			
			// set a voice specific parameter
			// (possible hook)
			private function set_v_param(k, v) : *  {
				if (curvoice) {
					self.set_vp([k + '=', v])
					return
				}
				k = [k + '=', v];
				var vid = '*'
				if (!info.V)
					info.V = {}
				if (info.V[vid])
					Array.prototype.push.apply(info.V[vid], k)
				else
					info.V[vid] = k
			}
			
			/**
			 * TODO: DOCUMENT
			 */
			private function set_page() : void {
				if (!img.chg) {
					return;
				}
				img.chg = false;
				img.lm = cfmt.leftmargin - cfmt.printmargin;
				if (img.lm < 0) {
					img.lm = 0;
				}
				img.rm = cfmt.rightmargin - cfmt.printmargin;
				if (img.rm < 0) {
					img.rm = 0;
				}
				img.width = cfmt.pagewidth - 2 * cfmt.printmargin;
				
				// Must have 100pt at least as the staff width
				if (img.width - img.lm - img.rm < 100) {
					error (0, undefined, "Bad staff width");
					img.width = img.lm + img.rm + 150;
				}
				set_posx();
			}
			
			// set a format parameter
			// (possible hook)
			private function set_format(cmd, param, lock) : *  {
				var f, f2, v, box, i
				
				//fixme: should check the type and limits of the parameter values
				if (lock) {
					fmt_lock[cmd] = true
				} else if (fmt_lock[cmd])
					return
				
				if (/.+font(-[\d])?$/.test(cmd)) {
					if (param.slice(-4) == " box") {
						box = true;
						param = param.slice(0, -4)
					}
					param_set_font(cmd, param)
					switch (cmd) {
						case "gchordfont":
							cfmt.gchordbox = box
							break
						//		case "annotationfont":
						//			cfmt.annotationbox = box
						//			break
						case "measurefont":
							cfmt.measurebox = box
							break
						case "partsfont":
							cfmt.partsbox = box
							break
					}
					return
				}
				
				switch (cmd) {
					case "aligncomposer":
					case "barsperstaff":
					case "infoline":
					case "measurefirst":
					case "measurenb":
					case "rbmax":
					case "rbmin":
					case "shiftunison":
						v = parseInt(param)
						if (isNaN(v)) {
							syntax(1, "Bad integer value");
							break
						}
						cfmt[cmd] = v
						break
					case "microscale":
						f = parseInt(param)
						if (isNaN(f) || f < 4 || f > 256 || f % 1) {
							syntax(1, errs.bad_val, "%%" + cmd)
							break
						}
						self.set_v_param("uscale", f)
						break
					case "bgcolor":
					case "fgcolor":
					case "dblrepbar":
					case "titleformat":
						cfmt[cmd] = param
						break
					case "breaklimit":			// float values
					case "lineskipfac":
					case "maxshrink":
					case "pagescale":
					case "parskipfac":
					case "scale":
					case "slurheight":
					case "stemheight":
					case "stretchlast":
						f = parseFloat(param)
						if (isNaN(f)) {
							syntax(1, errs.bad_val, '%%' + cmd)
							break
						}
						switch (cmd) {
							case "scale":			// old scale
								f /= .75
							case "pagescale":
								cmd = "scale";
								img.chg = true
								break
						}
						cfmt[cmd] = f
						break
					case "bstemdown":
					case "breakoneoln":
					case "cancelkey":
					case "contbarnb":
					case "custos":
					case "decoerr":
					case "dynalign":
					case "flatbeams":
					case "gchordbox":
					case "graceslurs":
					case "graceword":
					case "hyphencont":
					case "keywarn":
					case "linewarn":
					case "measurebox":
					case "partsbox":
					case "rbdbstop":
					case "singleline":
					case "squarebreve":
					case "straightflags":
					case "stretchstaff":
					case "timewarn":
					case "titlecaps":
					case "titleleft":
						cfmt[cmd] = get_bool(param)
						break
					case "chordnames":
						v = param.split(',')
						cfmt.chordnames = {}
						for (i = 0; i < v.length; i++) { 
							cfmt.chordnames['CDEFGAB'[i]] = v[i];
						}
						break;
					case "composerspace":
					case "indent":
					case "infospace":
					case "maxstaffsep":
					case "maxsysstaffsep":
					case "musicspace":
					case "partsspace":
					case "staffsep":
					case "subtitlespace":
					case "sysstaffsep":
					case "textspace":
					case "titlespace":
					case "topspace":
					case "vocalspace":
					case "wordsspace":
						f = get_unit(param)	// normally, unit in points - 72 DPI accepted
						if (isNaN(f))
							syntax(1, errs.bad_val, '%%' + cmd)
						else
							cfmt[cmd] = f
						break
					case "print-leftmargin":	// to remove
						syntax(0, "$1 is deprecated - use %%printmargin instead", '%%' + cmd)
						cmd = "printmargin"
						// fall thru
					case "printmargin":
						//	case "botmargin":
					case "leftmargin":
						//	case "pageheight":
					case "pagewidth":
					case "rightmargin":
						//	case "topmargin":
						f = get_unit(param)	// normally unit in cm or in - 96 DPI
						if (isNaN(f)) {
							syntax(1, errs.bad_val, '%%' + cmd)
							break
						}
						cfmt[cmd] = f;
						img.chg = true
						break
					case "concert-score":
						if (cfmt.sound != "play")
							cfmt.sound = "concert"
						break
					case "writefields":
						set_writefields(param)
						break
					case "dynamic":
					case "gchord":
					case "gstemdir":
					case "ornament":
					case "stemdir":
					case "vocal":
					case "volume":
						set_pos(cmd, param)
						break
					case "font":
						get_font_scale(param)
						break
					case "fullsvg":
						if (parse.state != 0) {
							syntax(1, "Cannot have %%fullsvg inside a tune")
							break
						}
						//fixme: should check only alpha, num and '_' characters
						cfmt[cmd] = param
						break
					case "gracespace":
						v = param.split(/\s+/)
						for (i = 0; i < 3; i++)
							if (isNaN(Number(v[i]))) {
								syntax(1, errs.bad_val, "%%gracespace")
								break
							}
						for (i = 0; i < 3; i++) { 
							cfmt[cmd] = Number(v[i]);
						}
						break;
					break
					case "tuplets":
						cfmt[cmd] = param.split(/\s+/);
						v = cfmt[cmd][3]
						if (v			// if 'where'
							&& (posval[v]))	// translate the keyword
							cfmt[cmd][3] = posval[v]
						break
					case "infoname":
						set_infoname(param)
						break
					case "notespacingfactor":
						f = parseFloat(param)
						if (isNaN(f) || f < 1 || f > 2) {
							syntax(1, errs.bad_val, "%%" + cmd)
							break
						}
						i = 5;				// index of crotchet
						f2 = space_tb[i]
						for ( ; --i >= 0; ) { 
							f2 /= f;
							space_tb[i] = f2
						}
						i = 5;
						f2 = space_tb[i]
						for ( ; ++i < space_tb.length; ) { 
							f2 *= f;
							space_tb[i] = f2
						}
						break
					case "play":
						cfmt.sound = "play"		// without clef
						break
					case "pos":
						cmd = param.split(/\s+/);
						set_pos(cmd[0], cmd[1])
						break
					case "sounding-score":
						if (cfmt.sound != "play")
							cfmt.sound = "sounding"
						break
					case "staffwidth":
						v = get_unit(param)
						if (isNaN(v)) {
							syntax(1, errs.bad_val, '%%' + cmd)
							break
						}
						if (v < 100) {
							syntax(1, "%%staffwidth too small")
							break
						}
						v = cfmt.pagewidth - v - cfmt.leftmargin
						if (v < 2) {
							syntax(1, "%%staffwidth too big")
							break
						}
						cfmt.rightmargin = v;
						img.chg = true
						break
					case "textoption":
						cfmt[cmd] = get_textopt(param)
						break
					case "titletrim":
						v = Number(param)
						if (isNaN(v))
							cfmt[cmd] = get_bool(param)
						else
							cfmt[cmd] = v
						break
					case "combinevoices":
						syntax(1, "%%combinevoices is deprecated - use %%voicecombine instead")
						break
					case "voicemap":
						self.set_v_param("map", param)
						break
					case "voicescale":
						self.set_v_param("scale", param)
						break
					default:		// memorize all global commands
						if (parse.state == 0)		// (needed for modules)
							cfmt[cmd] = param
						break
				}
			}
			
			// font stuff
			
			// initialize the default fonts
			private function font_init () : void {
				param_set_font("annotationfont", "sans_embedded 10");
				param_set_font("composerfont", "serif_embeddedItalic 13");
				param_set_font("footerfont", "serif_embedded 16");
				param_set_font("gchordfont", "sans_embedded 12");
				param_set_font("headerfont", "serif_embedded 16");
				param_set_font("historyfont", "serif_embedded 16");
				param_set_font("infofont", "serif_embeddedItalic 14");
				param_set_font("measurefont", "sans_embedded 8");
				param_set_font("partsfont", "serif_embedded 15");
				param_set_font("repeatfont", "serif_embedded 13");
				param_set_font("subtitlefont", "serif_embedded 16");
				param_set_font("tempofont", "serif_embeddedBold 15");
				param_set_font("textfont", "serif_embedded 16");
				param_set_font("titlefont", "serif_embedded 20");
				param_set_font("vocalfont", "serif_embeddedBold 13");
				param_set_font("voicefont", "serif_embeddedBold 13");
				param_set_font("wordsfont", "serif_embedded 16")
			}
			
			/**
			 * Builds and returns a dedicated CSS class based on a given font name and size
			 * in the format <font_name>.<size>, e.g., "serif_embedded.20".
			 */
			private function style_font (fontInfo : String) : String  {
				var segments : Array = fontInfo.split('.');
				fontInfo = segments[0].toLowerCase();
				var size : String = segments[1] as String;
				var	out : String = ''; 
				var sepIndex : int;
				var tokenIndex : int;
				
				sepIndex = fontInfo.indexOf ('-');
				if (sepIndex < 0) {
					sepIndex = fontInfo.length;
				}
				tokenIndex = fontInfo.indexOf ('italic');
				if (tokenIndex == -1) {
					tokenIndex = fontInfo.indexOf ('oblique');
				}
				if (tokenIndex >= 0) {
					out += 'font-style: italic;\n';
					if (tokenIndex < sepIndex) {
						sepIndex = tokenIndex;
					}
				}
				tokenIndex = fontInfo.indexOf('bold');
				if (tokenIndex >= 0) {
					out += 'font-weight: bold;\n';
					if (tokenIndex < sepIndex) {
						sepIndex = tokenIndex;
					}
				}
				if (sepIndex > 0) {
					fontInfo = fontInfo.slice (0, sepIndex);
				}
				out += 'font-family: ' + fontInfo + ';\n';
				out += 'font-size: ' + size + ';\n';
				return out;
			}
			
			
			/**
			 * Builds a font class
			 */
			private function font_class(font) : String  {
				if (font['class']) {
					return 'f' + font.fid + cfmt.fullsvg + ' ' + font['class'];
				}
				return 'f' + font.fid + cfmt.fullsvg;
			}
			
			/**
			 * Outputs a font style
			 */
			private function style_add_font(font) : void  {
				font_style += "\n.f" + font.fid + cfmt.fullsvg + " {\n" + style_font(font.name + '.' + font.size) + "}";
			}
			
			/**
			 * Employs a font
			 */
			private function use_font(font) : void  {
				if (!defined_font[font.fid]) {
					defined_font[font.fid] = true;
					style_add_font(font);
				}
			}
			
			// get the font of the 'xxxfont' parameter
			private function get_font(xxx) : *  {
				xxx += "font"
				var	fn = cfmt[xxx],
					font = font_tb[fn]
				if (!font) {
					syntax(1, "Unknown font $1", xxx);
					font = gene.curfont
				}
				if (!font.fid)
					font.fid = fid++;
				use_font(font)
				return font
			}
			
			// ------------------------
			
			
			// abc2svg - front.js - ABC parsing front-end
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			// translation table from the ABC draft version 2.2
			private var abc_utf : Object = {
				"=D": "Đ",
				"=H": "Ħ",
				"=T": "Ŧ",
				"=d": "đ",
				"=h": "ħ",
				"=t": "ŧ",
				"/O": "Ø",
				"/o": "ø",
				//	"/D": "Đ",
				//	"/d": "đ",
				"/L": "Ł",
				"/l": "ł",
				"vL": "Ľ",
				"vl": "ľ",
				"vd": "ď",
				".i": "ı",
				"AA": "Å",
				"aa": "å",
				"AE": "Æ",
				"ae": "æ",
				"DH": "Ð",
				"dh": "ð",
				//	"ng": "ŋ",
				"OE": "Œ",
				"oe": "œ",
				"ss": "ß",
				"TH": "Þ",
				"th": "þ"
			}
			
			// accidentals as octal values (abcm2ps compatibility)
			private var oct_acc = {
				"1": "\u266f",
				"2": "\u266d",
				"3": "\u266e",
				"4": "&#x1d12a;",
				"5": "&#x1d12b;"
			}
			
			// convert the escape sequences to utf-8
			private function cnv_escape(src) : *  {
				var	c, c2,
				dst = "",
					i, j = 0, codeUnits
				
				while (1) { 
					i = src.indexOf('\\', j)
					if (i < 0)
						break
					dst += src.slice(j, i);
					c = src.charAt (++i);
					if (!c)
						return dst + '\\'
					switch (c) {
						case '0':
						case '2':
							if (src[i + 1] != '0')
								break
							c2 = oct_acc[src[i + 2]]
							if (c2) {
								dst += c2;
								j = i + 3
								continue
							}
							break
						case 'u':
							j = Number("0x" + src.slice(i + 1, i + 5));
							if (isNaN(j) || j < 0x20) {
								dst += src[++i] + "\u0306"	// breve
								j = i + 1
								continue
							}
							codeUnits = [j]
							if (j >= 0xd800 && j <= 0xdfff) {	// surrogates
								j = Number("0x" + src.slice(i + 7, i + 11));
								if (isNaN(j))
									break		// bad surrogate
								codeUnits.push(j);
								j = i + 11
							} else {
								j = i + 5
							}
							dst += String.fromCharCode.apply(null, codeUnits)
							continue
						case 't':			// TAB
							dst += ' ';
							j = i + 1
							continue
						default:
							c2 = abc_utf[src.slice(i, i + 2)]
							if (c2) {
								dst += c2;
								j = i + 2
								continue
							}
							
							// try unicode combine characters
							switch (c) {
								case '`':
									dst += src[++i] + "\u0300"	// grave
									j = i + 1
									continue
								case "'":
									dst += src[++i] + "\u0301"	// acute
									j = i + 1
									continue
								case '^':
									dst += src[++i] + "\u0302"	// circumflex
									j = i + 1
									continue
								case '~':
									dst += src[++i] + "\u0303"	// tilde
									j = i + 1
									continue
								case '=':
									dst += src[++i] + "\u0304"	// macron
									j = i + 1
									continue
								case '_':
									dst += src[++i] + "\u0305"	// overline
									j = i + 1
									continue
								case '.':
									dst += src[++i] + "\u0307"	// dot
									j = i + 1
									continue
								case '"':
									dst += src[++i] + "\u0308"	// dieresis
									j = i + 1
									continue
								case 'o':
									dst += src[++i] + "\u030a"	// ring
									j = i + 1
									continue
								case 'H':
									dst += src[++i] + "\u030b"	// hungarumlaut
									j = i + 1
									continue
								case 'v':
									dst += src[++i] + "\u030c"	// caron
									j = i + 1
									continue
									//			case ',':
									//				dst += src[++i] + "\u0326"	// comma below
									//				j = i + 1
									//				continue
								case 'c':
									dst += src[++i] + "\u0327"	// cedilla
									j = i + 1
									continue
								case ';':
									dst += src[++i] + "\u0328"	// ogonek
									j = i + 1
									continue
							}
							break
					}
					dst += '\\' + c;
					j = i + 1
				}
				return dst + src.slice(j)
			}
			
			// ABC include
			private var $include : int = 0;
				
			private function do_include(fn) : *  {
				var file, parse_sav
				
				if (!user.read_file) {
					syntax(1, "No read_file support")
					return
				}
				if ($include > 2) {
					syntax(1, "Too many $include levels")
					return
				}
				$include++;
				file = user.read_file(fn)
				if (!file) {
					syntax(1, "Cannot read file '$1'", fn)
					return
				}
				parse_sav = clone(parse);
				tosvg(fn, file);
				parse = parse_sav;
				$include--
			}
			
			/**
			 * Check if a tune is selected
			 */
			private function tune_selected (file, bol, eof, proxy) : Boolean {
				var	re : RegExp; 
				var res : Object;
				var i : int = file.indexOf('K:', bol);
				
				if (i < 0) {
					return false
				}
				i = file.indexOf('\n', i);
				if (parse.select.test (file.slice (parse.bol, i))) {
					return true;
				}
				re = /\n\w*\n/;
				re.lastIndex = i;
				res = re.exec (file);
				if (res) {
					proxy.eol = re.lastIndex
				} else {
					proxy.eol = eof;
				}
				return false;
			}
			
			/**
			 *  Remove the comment at end of text
			 */
			private function uncomment (src : String, do_escape : Boolean) : String {
				if (src.indexOf('%') >= 0) {
					src = src.replace(/([^\\])%.*/, '$1').replace(/\\%/g, '%');
				}
				src = src.replace(/\s+$/, '');
				if (do_escape && src.indexOf('\\') >= 0) {
					return cnv_escape(src);
				}
				return src;
			}
			
			/**
			 * TODO: Document
			 */
			private function end_tune (cfmt_sav, info_sav, char_tb_sav, glovar_sav, maps_sav, mac_sav, maci_sav) : void {				
				generate();
				
				if (info.W) {
					put_words(info.W);
				}
				put_history();
				blk_flush();
				parse.state = 0;		// file header
				cfmt = cfmt_sav;
				info = info_sav;
				char_tb = char_tb_sav;
				glovar = glovar_sav;
				maps = maps_sav;
				mac = mac_sav;
				maci = maci_sav;
				init_tune()
				img.chg = true;
				set_page();
			}
			
			
			
			/**
			 * Parses given ABC markup and returns an Object containing renderable SVG markup
			 * and related metadata.  
			 */
			public function getSvg (abcMarkup : String) : Object {
				var output : Object = {
					info : { numPages: 0 },
					pages : []
				};
				var currPageHeight : Number = 0;
				var currPage : Object;
				
				// Consolidates all SVG lines gathered so far in one SVG page
				var sealPageData : Function = function () : void {
					if (!currPage) {
						return;
					}
					var fullSVG : String = '';
					var i:int;
					var lines : Array = currPage.lines as Array;
					var line : Object;
					var prevLine : Object;
					var prevLineHeight : Number;
					var vOffset : Number;
					var prevStaffIndex : int;
					
					for (i = 0; i < lines.length; i++) { 
						line = lines[i] as Object;
						
						// First line
						if (i == 0) {
							fullSVG += line.svgHead.replace ('%HEIGHT%', pageHeight.toFixed(2));
							fullSVG += '\n<g id="staff_' + (i + 1) + '">';
						}
						
						// Subsequent lines. Compute the ammount of vertical offset to apply
						if (i > 0) {
							vOffset = 0;
							prevStaffIndex = (i - 1);
							do { 
								prevLine = lines[prevStaffIndex] as Object;
								prevLineHeight = (prevLine.height as Number);
								
								// For first line, we subtract the page Y coordinate from its reported height
								// (or else, the second line would be offset down by that ammount).
								if (prevStaffIndex == 0) {
									prevLineHeight -= pageY;
								}
								vOffset += (prevLineHeight as Number);
								prevStaffIndex--;
							} while (prevStaffIndex >= 0);
							fullSVG += '\n<g id="staff_' + (i + 1) + '" transform="translate(0, ' + vOffset.toFixed(2) + ')">';
						}
						
						// Any line
						fullSVG += line.svgBody;
						fullSVG += '\n</g>\n';
						
						// Last line
						if (i == lines.length - 1) {
							fullSVG += line.svgFooter;
						}
					}
					currPage.fullSVG = fullSVG;
					output.info.numPages++;
					output.pages.push (currPage);
					currPage = null;
					currPageHeight = 0;
				}
				
				// Gathers as many SVG lines as can fit on one page
				var svgReporter : Function = function (lineHeight : Number, head : String, body : String, footer : String) : void {
					var testHeight : Number = currPageHeight + lineHeight;
				
					// (Case 1) The curent staff system is so tall that it cannot fit on the page by itself;
					// we force it onto the page nevertheless, in order not to run into an infinite loop.
					// FIXME: devise a better solution.
					if (currPageHeight == 0 && testHeight > pageHeight) {
						var svgHead : String = head.replace ('%HEIGHT%', testHeight.toFixed(2));
						var svg : String = svgHead + body + footer;
						output.info.numPages++;
						output.pages.push ({
							"fullSVG": svg,
							"fullPageHeight": testHeight,
							lines: [{
								"svgHead": svgHead,
								"svgBody": body,
								"svgFooter": footer,
								"height": testHeight
							}]
						});
					} else {

						// Ensure we have a "current page" to place staves on. 
						if (!currPage) {
							currPage = { fullSVG: '', lines : [] };
						}
						
						// (Case 2) The current staff system fits on the current page; there might be some
						// other staves on the page already; we save all info and wait for more.
						if (testHeight <= pageHeight) {
							currPageHeight = testHeight;
							currPage.fullPageHeight = currPageHeight;
							currPage.lines.push ({ 
								"svgHead" : head,
								"svgBody" : body,
								"svgFooter": footer,
								"height" : lineHeight
							});
						} else {
						
							// (Case 3) The current staff system won't fit on the current page; there is at least
							// one staff already on the page, so we can "seal" the page and move on.
							sealPageData();
							
							// Collect this staff on the next page
							svgReporter (lineHeight, head, body, footer);
						}						
					}
				}
				user.svgReporter = svgReporter; 
				tosvg ('', abcMarkup);
				
				// Pick up the last staff and seal the last page.
				sealPageData();
				return output;
			}
			
			/**
			 * Parses ABC code.
			 * 
			 * @param	in_fname
			 * 			File name
			 * 
			 * @param	file
			 * 			File content. Used for errors.
			 * 
			 * @param	bol (Optional)
			 * 			Begining of line.
			 * 
			 * @param	eof (Optional)
			 * 			End of file.
			 */
			private function tosvg (in_fname : String, file : String, bol : Number = NaN, eof : Number = NaN) : void {
				var	i; 
				var c; 
				var end;
				var select;
				var line0; 
				var line1;
				var last_info; 
				var opt; 
				var text; 
				var a : Array; 
				var b; 
				var s;
				var cfmt_sav; 
				var info_sav; 
				var char_tb_sav; 
				var glovar_sav; 
				var maps_sav;
				var mac_sav; 
				var maci_sav;
				var pscom;
				var txt_add : String = '\n';
				var proxy : Object = {
					eol : Number
				};
				
				// Initialize
				parse.file = file;
				parse.fname = in_fname;
				
				// Scan the file
				if (isNaN(bol)) {
					bol = 0;
				}
				if (isNaN (eof)) {
					eof = file.length;
				}
				for ( ; bol < eof; bol = parse.eol + 1) { 
					
					
					
					// Get a line
					proxy.eol = file.indexOf('\n', bol);
					if (proxy.eol < 0 || proxy.eol > eof) {
						proxy.eol = eof;
					}
					parse.eol = proxy.eol;
					
					// Remove the ending white spaces
					while (true) { 
						
						
						proxy.eol--;
						switch (file.charAt (proxy.eol)) {
							case ' ':
							case '\t':
							continue;
						}
						break;
					}
					proxy.eol++;
					
					// Empty line
					if (proxy.eol == bol) {
						if (parse.state == 1) {
							parse.istart = bol;
							syntax (1, "Empty line in tune header - ignored");
						} else if (parse.state >= 2) {
							end_tune (cfmt_sav, info_sav, char_tb_sav, glovar_sav, maps_sav, mac_sav, maci_sav);
							
							// Skip to next tune
							if (parse.select) {
								proxy.eol = file.indexOf('\nX:', parse.eol);
								if (proxy.eol < 0) {
									proxy.eol = eof;
								}
								parse.eol = proxy.eol;
							}
						}
						continue;
					}
					parse.istart = parse.bol = bol;
					parse.iend = proxy.eol;
					parse.line.index = 0;
					
					// Check if the line is a pseudo-comment or I:
					line0 = file.charAt(bol);
					line1 = file.charAt(bol + 1);
					if (line0 == '%') {
						
						// Comment
						if (parse.prefix.indexOf(line1) < 0) {
							continue;
						}
						
						// Change "%%abc xxxx" to "xxxx"
						if (file.charAt(bol + 2) == 'a'
							&& file.charAt(bol + 3) == 'b'
							&& file.charAt(bol + 4) == 'c'
							&& file.charAt(bol + 5) == ' ') {
							bol += 6;
							line0 = file.charAt(bol);
							line1 = file.charAt(bol + 1);
						} else {
							pscom = true;
						}
					} else if (line0 == 'I' && line1 == ':') {
						pscom = true;
					}
					
					// Pseudo-comments
					if (pscom) {
						pscom = false;
						
						// Skip %%/I:
						bol += 2;
						while (true) { 
							
							
							switch (file.charAt(bol)) {
								case ' ':
								case '\t':
									bol++;
									continue;
							}
							break;
						}
						text = file.slice (bol, proxy.eol);

						if (!text || text.charAt(0) == '%') {
							continue;
						}
						a = text.split (/\s+/, 2);
						if (!a[0]) {
							a.shift();
						}
						switch (a[0]) {
							case "abcm2ps":
							case "ss-pref":
								parse.prefix = a[1];
								continue
							case "abc-include":
								do_include(a[1]);
								continue;
						}
						
						// Beginxxx/endxxx
						if (a[0].slice(0, 5) == 'begin') {
							b = a[0].substr(5);
							end = '\n' + line0 + line1 + "end" + b;
							i = file.indexOf(end, proxy.eol)
							if (i < 0) {
								syntax(1, "No $1 after %%$2",
									end.slice(1), a[0]);
								parse.eol = eof
								continue
							}
							self.do_begin_end(b, a[1],
								file.slice(proxy.eol + 1, i).replace(
									new RegExp('^' + line0 + line1, 'gm'),
									''));
							parse.eol = file.indexOf('\n', i + 6)
							if (parse.eol < 0)
								parse.eol = eof
							continue
						}
						switch (a[0]) {
							case "select":
								if (parse.state != 0) {
									syntax(1, "%%select ignored")
									continue
								}
								select = uncomment(text.slice(7), false)
								if (select[0] == '"')
									select = select.slice(1, -1);
								if (!select) {
									delete parse.select
									continue
								}
								select = select.replace(/\(/g, '\\(');
								select = select.replace(/\)/g, '\\)');
								//				select = select.replace(/\|/g, '\\|');
								parse.select = new RegExp(select, 'm')
								continue
							case "tune":
								syntax(1, "%%tune not treated yet")
								continue
							case "voice":
								if (parse.state != 0) {
									syntax(1, "%%voice ignored")
									continue
								}
								select = uncomment(text.slice(6), false)
								
								/* if void %%voice, free all voice options */
								if (!select) {
									if (parse.cur_tune_opts)
										parse.cur_tune_opts.voice_opts = null
									else
										parse.voice_opts = null
									continue
								}
								
								if (select == "end")
									continue	/* end of previous %%voice */
								
								/* get the voice options */
								if (parse.cur_tune_opts) {
									if (!parse.cur_tune_opts.voice_opts)
										parse.cur_tune_opts.voice_opts = {}
									opt = parse.cur_tune_opts.voice_opts
								} else {
									if (!parse.voice_opts)
										parse.voice_opts = {}
									opt = parse.voice_opts
								}
								opt[select] = []
								while (true) { 

									
									bol = ++proxy.eol
									if (file[bol] != '%')
										break;
									proxy.eol = file.indexOf('\n', proxy.eol);
									if (file[bol + 1] != line1)
										continue;
									bol += 2;
									if (proxy.eol < 0)
										text = file.slice(bol)
									else
										text = file.slice(bol, proxy.eol);
									a = text.match(/\S+/)
									switch (a[0]) {
										default:
											opt[select].push(
												uncomment(text, true))
											continue
										case "score":
										case "staves":
										case "tune":
										case "voice":
											bol -= 2
											break
									}
									break
								}
								parse.eol = bol - 1
								continue
						}
						self.do_pscom(uncomment(text, true))
						continue
					}
					
					// music line (or free text)
					if (line1 != ':' || !/[A-Za-z+]/.test(line0)) {
						last_info = undefined;
						if (parse.state < 2)
							continue
						parse.line.buffer = uncomment(file.slice(bol, proxy.eol), true);
						parse_music_line()
						continue
					}
					
					// information fields
					bol += 2
					while (true) { 
						
						
						switch (file.charAt(bol)) {
							case ' ':
							case '\t':
								bol++
								continue
						}
						break
					}
					text = uncomment(file.slice(bol, proxy.eol), true)
					if (line0 == '+') {
						if (!last_info) {
							syntax(1, "+: without previous info field")
							continue
						}
						txt_add = ' ';		// concatenate
						line0 = last_info
					}
					
					switch (line0) {
						case 'X':			// start of tune
							if (parse.state != 0) {
								syntax(1, errs.ignored, line0)
								continue
							}
							if (parse.select
								&& !tune_selected (file, bol, eof, proxy)) {	// skip to the next tune
								proxy.eol = file.indexOf('\nX:', parse.eol)
								if (proxy.eol < 0)
									proxy.eol = eof;
								parse.eol = proxy.eol
								continue
							}
							
							cfmt_sav = clone(cfmt);
							cfmt.pos = clone(cfmt.pos);
							info_sav = clone(info, 1);
							char_tb_sav = clone(char_tb);
							glovar_sav = clone(glovar);
							maps_sav = clone(maps, 1);
							mac_sav = clone(mac);
							maci_sav = maci.concat();
							info.X = text;
							parse.state = 1			// tune header
							continue
						case 'T':
							switch (parse.state) {
								case 0:
									continue
								case 1:
									if (info.T == undefined)	// (keep empty T:)
										info.T = text
									else
										info.T += "\n" + text
									continue
							}
							s = new_block("title");
							s.text = text
							continue
						case 'K':
							switch (parse.state) {
								case 0:
									continue
								case 1:				// tune header
									info.K = text
									break
							}
							do_info(line0, text)
							continue
						case 'W':
							if (parse.state == 0
								|| cfmt.writefields.indexOf(line0) < 0)
								break
							if (info.W == undefined)
								info.W = text
							else
								info.W += txt_add + text
							break
						
						case 'm':
							if (parse.state >= 2) {
								syntax(1, errs.ignored, line0)
								continue
							}
							if ((!cfmt.sound || cfmt.sound != "play")
								&& cfmt.writefields.indexOf(line0) < 0)
								break
							a = text.match(/(.*?)[= ]+(.*)/)
							if (!a || !a[2]) {
								syntax(1, errs.bad_val, "m:")
								continue
							}
							mac[a[1]] = a[2];
							maci[a[1].charCodeAt(0)] = 1	// first letter
							break
						
						// info fields in tune body only
						case 's':
							if (parse.state != 3
								|| cfmt.writefields.indexOf(line0) < 0)
								break
							get_sym(text, txt_add == ' ')
							break
						case 'w':
							if (parse.state != 3
								|| cfmt.writefields.indexOf(line0) < 0)
								break
							get_lyrics(text, txt_add == ' ')
							if (text.slice(-1) == '\\') {	// old continuation
								txt_add = ' ';
								last_info = line0
								continue
							}
							break
						case '|':			// "|:" starts a music line
							if (parse.state < 2)
								continue
							parse.line.buffer = uncomment(file.slice(bol, proxy.eol), true);
							parse_music_line()
							continue
						default:
							if ("ABCDFGHOSZ".indexOf(line0) >= 0) {
								if (parse.state >= 2) {
									syntax (1, errs.ignored, line0);
									continue;
								}
								if (!info[line0]) {
									info[line0] = text;
								}
								else {
									info[line0] += txt_add + text
								}
								break;
							}
							
							// info field which may be embedded
							do_info (line0, text);
							continue;
					}
					txt_add = '\n';
					last_info = line0
				}
				if ($include) {
					return;
				}
				
				if (parse.state >= 2) {
					end_tune (cfmt_sav, info_sav, char_tb_sav, glovar_sav, maps_sav, mac_sav, maci_sav);
				}
				parse.state = 0
			}

			
			
			// ------------------------------------------
			
			
			// abc2svg - music.js - music generation
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			private var	gene,
			staff_tb,
			nstaff,			// current number of staves
			tsnext,			// next line when cut
			realwidth,		// real staff width while generating
			insert_meter,		// insert time signature (1) and indent 1st line (2)
			spf_last,		// spacing for last short line
			
			/* width of notes indexed by log2(note_length) */
			space_tb = Vector.<Number> ([
				7, 10, 14.15, 20, 28.3,
				40,			/* crotchet (whole note / 4) */
				56.6, 80, 100, 120
			]),
			smallest_duration
			
			/* -- decide whether to shift heads to other side of stem on chords -- */
			/* this routine is called only once per tune */
			
			// distance for no overlap - index: [prev acc][cur acc]
			//var dt_tb = [
			//	[5, 5, 5, 5],		/* dble sharp */
			//	[5, 6, 6, 6],		/* sharp */
			//	[5, 6, 5, 6],		/* natural */
			//	[5, 5, 5, 5]		/* flat / dble flat */
			//]
			
			// accidental x offset - index = note head type
			private var dx_tb : Vector.<Number> = Vector.<Number>([
				10,		// FULL
				10,		// EMPTY
				11,		// OVAL
				13,		// OVALBARS
				13		// SQUARE
			]);
			
			// head width  - index = note head type
			private var hw_tb : Vector.<Number> = Vector.<Number> ([
				4.5,		// FULL
				5,		// EMPTY
				6,		// OVAL
				7,		// OVALBARS
				8		// SQUARE
			])
			
			/* head width for voice overlap - index = note head type */
			private var w_note : Vector.<Number> = Vector.<Number> ([
				3.5,		// FULL
				3.7,		// EMPTY
				5,		// OVAL
				6,		// OVALBARS
				7		// SQUARE
			]);
			
			private function set_head_shift(s) : *  {
				var	i, i1, i2, d, ps, dx,
				dx_head = dx_tb[s.head],
					dir = s.stem,
					n = s.nhd
				
				if (n == 0)
					return			// single note
				
				/* set the head shifts */
				dx = dx_head * .78
				if (s.grace)
					dx *= .5
				if (dir >= 0) {
					i1 = 1;
					i2 = n + 1;
					ps = s.notes[0].pit
				} else {
					dx = -dx;
					i1 = n - 1;
					i2 = -1;
					ps = s.notes[n].pit
				}
				var	shift = false,
					dx_max = 0
				for (i = i1; i != i2; i += dir) { 
					d = s.notes[i].pit - ps;
					ps = s.notes[i].pit
					if (d == 0) {
						if (shift) {		/* unison on shifted note */
							var new_dx = s.notes[i].shhd =
								s.notes[i - dir].shhd + dx
							if (dx_max < new_dx)
								dx_max = new_dx
							continue
						}
						if (i + dir != i2	/* second after unison */
							//fixme: should handle many unisons after second
							&& ps + dir == s.notes[i + dir].pit) {
							s.notes[i].shhd = -dx
							if (dx_max < -dx)
								dx_max = -dx
							continue
						}
					}
					if (d < 0)
						d = -d
					if (d > 3 || (d >= 2 && s.head != C.SQUARE)) {
						shift = false
					} else {
						shift = !shift
						if (shift) {
							s.notes[i].shhd = dx
							if (dx_max < dx)
								dx_max = dx
						}
					}
				}
				s.xmx = dx_max				/* shift the dots */
			}
			
			// set the accidental shifts for a set of chords
			private function acc_shift(notes, dx_head) : *  {
				var	i, i1, dx, dx1, ps, p1, acc,
				n = notes.length;

				// set the shifts from the head shifts
				for (i = (n - 1); i >= 0; i--) { 	// (no shift on top)
					dx = notes[i].shhd;
					if (!dx || dx > 0) {
						continue;
					}
					dx = dx_head - dx;
					ps = notes[i].pit
					for (i1 = n; --i1 >= 0; ) { 
						if (!notes[i1].acc)
							continue
						p1 = notes[i1].pit
						if (p1 < ps - 3)
							break
						if (p1 > ps + 3)
							continue
						if (notes[i1].shac < dx)
							notes[i1].shac = dx
					}
				}
				
				// set the shifts from accidental shifts
				for (i = (n - 1); i >= 0; i--) { 		// from top to bottom
					acc = notes[i].acc
					if (!acc)
						continue
					dx = notes[i].shac
					if (!dx) {
						dx = notes[i].shhd
						if (dx < 0)
							dx = dx_head - dx
						else
							dx = dx_head
					}
					ps = notes[i].pit
					for (i1 = (n - 1); i1 > i; i1--) { 
						if (!notes[i1].acc)
							continue
						p1 = notes[i1].pit
						if (p1 >= ps + 4) {	// pitch far enough
							if (p1 > ps + 4	// if more than a fifth
								|| acc < 0	// if flat/dble flat
								|| notes[i1].acc < 0)
								continue
						}
						if (dx > notes[i1].shac - 6) {
							dx1 = notes[i1].shac + 7
							if (dx1 > dx)
								dx = dx1
						}
					}
					notes[i].shac = dx
				}
			}
			
			/* set the horizontal shift of accidentals */
			/* this routine is called only once per tune */
			private function set_acc_shft() : *  {
				var s, s2, st, i, acc, t, dx_head;
				
				// search the notes with accidentals at the same time
				s = tsfirst
				while (s) { 
					if (s.type != C.NOTE
						|| s.invis) {
						s = s.ts_next
						continue
					}
					st = s.st;
					t = s.time;
					acc = false
					for (s2 = s; s2; s2 = s2.ts_next) { 
						if (s2.time != t
							|| s2.type != C.NOTE
							|| s2.st != st)
							break
						if (acc)
							continue
						for (i = 0; i <= s2.nhd; i++) { 
							if (s2.notes[i].acc) {
								acc = true
								break
							}
						}
					}
					if (!acc) {
						s = s2
						continue
					}
					
					dx_head = dx_tb[s.head]
					//		if (s.dur >= C.BLEN * 2 && s.head == C.OVAL)
					//		if (s.dur >= C.BLEN * 2)
					//			dx_head = 15.8;
					
					// build a pseudo chord and shift the accidentals
					st = {
						notes: []
					}
					for ( ; s != s2; s = s.ts_next) { 
						st.notes = st.notes.concat(s.notes);
					}
					sort_pitch(st);
					acc_shift(st.notes, dx_head)
				}
			}
			
			// link a symbol before an other one
			private function lkvsym(s, next) : *  {	// voice linkage
				s.next = next;
				s.prev = next.prev
				if (s.prev)
					s.prev.next = s
				else
					s.p_v.sym = s;
				next.prev = s
			}
			private function lktsym(s, next) : *  {	// time linkage
				if (next) {
					s.ts_next = next;
					s.ts_prev = next.ts_prev
					if (s.ts_prev)
						s.ts_prev.ts_next = s;
					next.ts_prev = s
				} else {
					s.ts_next = s.ts_prev = null
				}
			}
			
			/* -- unlink a symbol -- */
			private function unlksym(s) : *  {
				if (s.next)
					s.next.prev = s.prev
				if (s.prev)
					s.prev.next = s.next
				else
					s.p_v.sym = s.next
				if (s.ts_next) {
					if (s.seqst && !s.ts_next.seqst) {
						s.ts_next.seqst = true;
						s.ts_next.shrink = s.shrink;
						s.ts_next.space = s.space
					}
					s.ts_next.ts_prev = s.ts_prev
				}
				if (s.ts_prev)
					s.ts_prev.ts_next = s.ts_next
				if (tsfirst == s)
					tsfirst = s.ts_next
				if (tsnext == s)
					tsnext = s.ts_next
			}
			
			/* -- insert a clef change (treble or bass) before a symbol -- */
			private function insert_clef(s, clef_type, clef_line) : *  {
				var	p_voice = s.p_v,
					new_s,
					st = s.st
				
				/* don't insert the clef between two bars */
				if (s.type == C.BAR && s.prev && s.prev.type == C.BAR)
					s = s.prev;
				
				/* create the symbol */
				p_voice.last_sym = s.prev
				if (!p_voice.last_sym)
					p_voice.sym = null;
				p_voice.time = s.time;
				new_s = sym_add(p_voice, C.CLEF);
				new_s.next = s;
				s.prev = new_s;
				
				new_s.clef_type = clef_type;
				new_s.clef_line = clef_line;
				new_s.st = st;
				new_s.clef_small = true
				delete new_s.second;
				new_s.notes = []
				new_s.notes[0] = {
					pit: s.notes[0].pit
				}
				new_s.nhd = 0;
				
				/* link in time */
				while (!s.seqst) { 
					s = s.ts_prev;
				}
				lktsym(new_s, s)
				if (new_s.ts_prev.type != C.CLEF)
					new_s.seqst = true
				return new_s
			}
			
			/* -- set the staff of the floating voices -- */
			/* this function is called only once per tune */
			private function set_float() : *  {
				var p_voice, st, staff_chg, v, s, s1, up, down
				
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					//		if (!p_voice.floating)
					//			continue
					staff_chg = false;
					st = p_voice.st
					for (s = p_voice.sym; s; s = s.next) { 
						if (!s.floating) {
							while (s && !s.floating) { 
								s = s.next;
							}
							if (!s)
								break
							staff_chg = false
						}
						if (!s.dur) {
							if (staff_chg)
								s.st++
							continue
						}
						if (s.notes[0].pit >= 19) {		/* F */
							staff_chg = false
							continue
						}
						if (s.notes[s.nhd].pit <= 12) {	/* F, */
							staff_chg = true
							s.st++
							continue
						}
						up = 127
						for (s1 = s.ts_prev; s1; s1 = s1.ts_prev) { 
							if (s1.st != st
								|| s1.v == s.v)
								break
							if (s1.type == C.NOTE)
								if (s1.notes[0].pit < up)
									up = s1.notes[0].pit
						}
						if (up == 127) {
							if (staff_chg)
								s.st++
							continue
						}
						if (s.notes[s.nhd].pit > up - 3) {
							staff_chg = false
							continue
						}
						down = -127
						for (s1 = s.ts_next; s1; s1 = s1.ts_next) { 
							if (s1.st != st + 1
								|| s1.v == s.v)
								break
							if (s1.type == C.NOTE)
								if (s1.notes[s1.nhd].pit > down)
									down = s1.notes[s1.nhd].pit
						}
						if (down == -127) {
							if (staff_chg)
								s.st++
							continue
						}
						if (s.notes[0].pit < down + 3) {
							staff_chg = true
							s.st++
							continue
						}
						up -= s.notes[s.nhd].pit
						down = s.notes[0].pit - down
						if (!staff_chg) {
							if (up < down + 3)
								continue
							staff_chg = true
						} else {
							if (up < down - 3) {
								staff_chg = false
								continue
							}
						}
						s.st++
					}
				}
			}
			
			/* -- set the x offset of the grace notes -- */
			private function set_graceoffs(s) : *  {
				var	next, m, dx, x,
				gspleft = cfmt.gracespace[0],
					gspinside = cfmt.gracespace[1],
					gspright = cfmt.gracespace[2],
					g = s.extra;
				
				if (s.prev && s.prev.type == C.BAR)
					gspleft -= 3;
				x = gspleft;
				
				g.beam_st = true
				for ( ; ; g = g.next) { 
					set_head_shift(g)
					acc_shift(g.notes, 7);
					dx = 0
					for (m = g.nhd; m >= 0; m--) { 
						if (g.notes[m].shac > dx)
							dx = g.notes[m].shac
					}
					x += dx;
					g.x = x
					
					if (g.nflags <= 0) {
						g.beam_st = true;
						g.beam_end = true
					}
					next = g.next
					if (!next) {
						g.beam_end = true
						break
					}
					if (next.nflags <= 0)
						g.beam_end = true
					if (g.beam_end) {
						next.beam_st = true;
						x += gspinside / 4
					}
					if (g.nflags <= 0)
						x += gspinside / 4
					if (g.y > next.y + 8)
						x -= 1.5
					x += gspinside
				}
				
				next = s.next
				if (next
					&& next.type == C.NOTE) {	/* if before a note */
					if (g.y >= 3 * (next.notes[next.nhd].pit - 18))
						gspright -= 1		// above, a bit closer
					else if (g.beam_st
						&& g.y < 3 * (next.notes[next.nhd].pit - 18) - 4)
						gspright += 2		// below with flag, a bit further
				}
				x += gspright;
				
				/* return the whole width */
				return x
			}
			
			/* -- compute the width needed by the guitar chords / annotations -- */
			private function gchord_width(s, wlnote, wlw) : *  {
				var	s2, gch, w, wl, ix,
				lspc = 0,
					rspc = 0,
					alspc = 0,
					arspc = 0
				
				for (ix = 0; ix < s.a_gch.length; ix++) { 
					gch = s.a_gch[ix]
					switch (gch.type) {
						default:		/* default = above */
							wl = -gch.x
							if (wl > lspc)
								lspc = wl;
							w = gch.w + 2 - wl
							if (w > rspc)
								rspc = w
							break
						case '<':		/* left */
							w = gch.w + wlnote
							if (w > alspc)
								alspc = w
							break
						case '>':		/* right */
							w = gch.w + s.wr
							if (w > arspc)
								arspc = w
							break
					}
				}
				
				/* adjust width for no clash */
				s2 = s.prev
				if (s2) {
					if (s2.a_gch) {
						for (s2 = s.ts_prev; ; s2 = s2.ts_prev) { 
							if (s2 == s.prev) {
								if (wlw < lspc)
									wlw = lspc
								break
							}
							if (s2.seqst)
								lspc -= s2.shrink
						}
					}
					if (alspc != 0)
						if (wlw < alspc)
							wlw = alspc
				}
				s2 = s.next
				if (s2) {
					if (s2.a_gch) {
						for (s2 = s.ts_next; ; s2 = s2.ts_next) { 
							if (s2 == s.next) {
								if (s.wr < rspc)
									s.wr = rspc
								break
							}
							if (s2.seqst)
								rspc -= 8
						}
					}
					if (arspc != 0)
						if (s.wr < arspc)
							s.wr = alspc
				}
				return wlw
			}
			
			/**
			 * Sets the width of a symbol.
			 * This routine sets the minimal left and right widths (`wl`, `wr`)
			 * so that successive symbols are still separated when no extra glue
			 * is put between them.
			 * (possible hook)
			 */
			private function set_width(s) : void {
				var	s2;
				var i;
				var m;
				var xx; 
				var w;
				var wlnote; 
				var wlw;
				var acc;
				var bar_type; 
				var meter;
				var last_acc;
				var n1;
				var n2;
				var esp; 
				var tmp;
				
				switch (s.type) {
					case C.NOTE:
					case C.REST:
						
						// Set the note widths
						s.wr = wlnote = hw_tb[s.head];
						
						// Room for shifted heads and accidental signs
						if (s.xmx > 0) {
							s.wr += s.xmx + 4;
						}
						for (s2 = s.prev; s2; s2 = s2.prev) { 
							if (w_tb[s2.type] != 0) {
								break;
							}
						}
						if (s2) {
							switch (s2.type) {
								case C.BAR:
								case C.CLEF:
								case C.KEY:
								case C.METER:
									wlnote += 3;
									break;
							}
						}
						for (m = 0; m <= s.nhd; m++) { 
							xx = s.notes[m].shhd;
							if (xx < 0) {
								if (wlnote < -xx + 5) {
									wlnote = -xx + 5;
								}
							}
							if (s.notes[m].acc) {
								tmp = s.notes[m].shac + (s.notes[m].micro ? 5.5 : 3.5);
								if (wlnote < tmp) {
									wlnote = tmp;
								}
							}
						}
						if (s2) {
							switch (s2.type) {
								case C.BAR:
								case C.CLEF:
								case C.KEY:
								case C.METER:
									wlnote -= 3;
									break;
							}
						}
						
						// Room for the decorations
						if (s.a_dd) {
							wlnote += deco_width(s);
						}
						
						// Space for flag if stem goes up on standalone note
						if (s.beam_st && s.beam_end && s.stem > 0 && s.nflags > 0) {
							if (s.wr < s.xmx + 9) {
								s.wr = s.xmx + 9;
							}
						}
						
						// leave room for dots and set their offset
						if (s.dots > 0) {
							
							// Don't recompute if this is a new music line
							if (s.wl == undefined) {
								switch (s.head) {
									case C.SQUARE:
										s.xmx += 4;
										break;
									case C.OVALBARS:
									case C.OVAL:
										s.xmx += 2;
										break;
									case C.EMPTY:
										s.xmx += 1;
										break;
								}
							}
							if (s.wr < s.xmx + 8) {
								s.wr = s.xmx + 8;
							}
							if (s.dots >= 2) {
								s.wr += 3.5 * (s.dots - 1);
							}
						}
						
						// For 2 notes tremolo, leave space for the small beam(s)
						if (s.trem2 && s.beam_end && wlnote < 20) {
							wlnote = 20;
						}
						wlw = wlnote;
						if (s2) {
							switch (s2.type) {
								
								// Extra space when up stem - down stem
								case C.NOTE:	
									if (s2.stem > 0 && s.stem < 0) {
										if (wlw < 7) {
											wlw = 7;
										}
									}
									
									// Make sure helper lines don't overlap
									if ((s.y > 27 && s2.y > 27) || (s.y < -3 && s2.y < -3)) {
										if (wlw < 6) {
											wlw = 6;
										}
									}
									
									// Make sure ties are wide enough
									if (s2.ti1) {
										if (wlw < 14) {
											wlw = 14;
										}
									}
									break;
								
								// Leave extra space at start of line
								case C.CLEF:
									if (s2.second || s2.clef_small) {
										break;
									}
									wlw += 8;
									break;
								case C.KEY:
									wlw += 4;
									break;
							}
						}
						
						// Leave room for guitar chords
						if (s.a_gch) {
							wlw = gchord_width(s, wlnote, wlw);
						}
						
						// Leave room for vocals under note. Related to `draw_lyrics()`
						if (s.a_ly) {
							wlw = ly_width(s, wlw);
						}
						
						// If preceeded by a grace note sequence, adjust
						if (s2 && s2.type == C.GRACE) {
							s.wl = wlnote - 4.5;
						}
						else {
							s.wl = wlw;
						}
						return;
					case C.SPACE:
						xx = s.width / 2;
						s.wr = xx;
						if (s.a_gch) {
							xx = gchord_width (s, xx, xx);
						}
						if (s.a_dd) {
							xx += deco_width(s);
						}
						s.wl = xx;
						return;
					case C.BAR:
						if (s.norepbra) {
							break;
						}
						bar_type = s.bar_type;
						switch (bar_type) {
							case "|":
								w = 7;
								break;
							default:
								w = 4 + 3 * bar_type.length;
								for (i = 0; i < bar_type.length; i++) { 
									switch (bar_type.charAt(i)) {
										case "[":
										case "]":
											w += 3;
											break;
										case ":":
											w += 2;
											break;
									}
								}
								break;
						}
						s.wl = w;
						if (s.next && s.next.type != C.METER) {
							s.wr = 7;
						}
						else {
							s.wr = 5;
						}
						
						// If preceeded by a grace note sequence, adjust
						for (s2 = s.prev; s2; s2 = s2.prev) { 
							if (w_tb[s2.type] != 0) {
								if (s2.type == C.GRACE) {
									s.wl -= 8;
								}
								break;
							}
						}
						
						if (s.a_dd) {
							s.wl += deco_width(s);
						}
						
						// Reserve room for the repeat numbers / chord indication
						if (s.text && s.text.length < 4 && s.next && s.next.a_gch) {
							set_font("repeat");
							s.wr += strwh(s.text)[0] + 2;
						}
						return;
					case C.CLEF:
						
						// There may be invisible clefs in empty staves
						if (s.invis) {
							
							// Cannot be 0
							s.wl = s.wr = 1;
							return;
						}
						s.wl = s.wr = s.clef_small ? 8 : 12;
						return;
					case C.KEY:
						s.wl = 3;
						esp = 4;
						if (!s.k_a_acc) {
							
							// New key signature
							n1 = s.k_sf;
							if (s.k_old_sf && (cfmt.cancelkey || n1 == 0)) {
								
								// Old key signature
								n2 = s.k_old_sf;
							}
							else {
								n2 = 0;
							}
							
							// If no natural
							if (n1 * n2 >= 0) {
								if (n1 < 0) {
									n1 = -n1;
								}
								if (n2 < 0) {
									n2 = -n2;
								}
								if (n2 > n1) {
									n1 = n2;
								}
							} else {
								n1 -= n2;
								if (n1 < 0) {
									n1 = -n1;
								}
								
								// See extra space in draw_keysig()
								esp += 3;
							}
						} else {
							n1 = n2 = s.k_a_acc.length;
							if (n2) {
								last_acc = s.k_a_acc[0].acc;
							}
							for (i = 1; i < n2; i++) { 
								acc = s.k_a_acc[i];
								if (acc.pit > s.k_a_acc[i - 1].pit + 6 || acc.pit < s.k_a_acc[i - 1].pit - 6) {
									
									// No clash
									n1--;
								}
								else if (acc.acc != last_acc) {
									esp += 3;
								}
								last_acc = acc.acc;
							}
						}
						s.wr = 5.5 * n1 + esp;
						return;
					case C.METER:
						wlw = 0;
						s.x_meter = [];
						for (i = 0; i < s.a_meter.length; i++) { 
							meter = s.a_meter[i];
							if (meter.top.charAt(0) == "C") {
								s.x_meter[i] = wlw + 6;
								wlw += 12;
							} else {
								w = 0;
								if (!meter.bot || meter.top.length > meter.bot.length) {
									meter = meter.top;
								}
								else {
									meter = meter.bot;
								}
						
								for (m = 0; m < meter.length; m++) { 
									switch (meter.charAt(m)) {
										case '(':
											wlw += 4;
											// no break here: fall thru;
										case ')':
										case '1':
											w += 4;
											break;
										default:
											w += 12;
											break;
									}
								}
								s.x_meter[i] = wlw + w / 2;
								wlw += w;
							}
						}
						s.wl = 0;
						s.wr = wlw + 6;
						return;
					case C.MREST:
						s.wl = 6;
						s.wr = 66;
						return;
					case C.GRACE:
						s.wl = set_graceoffs(s);
						s.wr = 0;
						if (s.a_ly) {
							ly_width(s, wlw);
						}
						return;
					case C.STBRK:
						s.wl = s.xmx;
						if (s.next && s.next.type == C.CLEF) {
							s.wr = 2;
							
							// "big" clef
							delete s.next.clef_small;
						} else {
							s.wr = 8;
						}
						return;
					case C.CUSTOS:
						s.wl = s.wr = 4;
						return;
						
					// These symbol types have no (accountable) width
					case C.BLOCK:
					case C.PART:
					case C.REMARK:
					case C.STAVES:
					case C.TEMPO:
						break;
					default:
						error (2, s, "set_width - Cannot set width for symbol $1", s.type);
						break;
				}
				s.wl = s.wr = 0;
			}
			
			/**
			 * Converts delta time to natural spacing
			 */
			private function time2space(s, len) : *  {
				var i, l, space
				
				if (smallest_duration >= C.BLEN / 2) {
					if (smallest_duration >= C.BLEN)
						len /= 4
					else
						len /= 2
				} else if (!s.next && len >= C.BLEN) {
					len /= 2
				}
				if (len >= C.BLEN / 4) {
					if (len < C.BLEN / 2)
						i = 5
					else if (len < C.BLEN)
						i = 6
					else if (len < C.BLEN * 2)
						i = 7
					else if (len < C.BLEN * 4)
						i = 8
					else
						i = 9
				} else {
					if (len >= C.BLEN / 8)
						i = 4
					else if (len >= C.BLEN / 16)
						i = 3
					else if (len >= C.BLEN / 32)
						i = 2
					else if (len >= C.BLEN / 64)
						i = 1
					else
						i = 0
				}
				l = len - ((C.BLEN / 16 / 8) << i)
				space = space_tb[i]
				if (l != 0) {
					if (l < 0) {
						space = space_tb[0] * len / (C.BLEN / 16 / 8)
					} else {
						if (i >= 9)
							i = 8
						space += (space_tb[i + 1] - space_tb[i]) * l / len
					}
				}
				return space
			}
			
			/* -- set the natural space -- */
			private function set_space(s) : *  {
				var	s2, space,
				prev_time = s.ts_prev.time,
					len = s.time - prev_time		/* time skip */
				
				if (len == 0) {
					switch (s.type) {
						case C.MREST:
							return s.wl
							///*fixme:do same thing at start of line*/
							//		case C.NOTE:
							//		case C.REST:
							//			if (s.ts_prev.type == C.BAR) {
							//				if (s.nflags < -2)
							//					return space_tb[0]
							//				return space_tb[2]
							//			}
							//			break
					}
					return 0
				}
				if (s.ts_prev.type == C.MREST)
					//		return s.ts_prev.wr + 16
					//				+ 3		// (bar wl=5 wr=8)
					return 71	// 66 (mrest.wl) + 5 (bar.wl)
				
				space = time2space(s, len)
				
				while (!s.dur) { 
					switch (s.type) {
						case C.BAR:
							// (hack to have quite the same note widths between measures)
							return space * .9 - 7
						case C.CLEF:
							return space - s.wl - s.wr
						case C.BLOCK:			// no space
						case C.PART:
						case C.REMARK:
						case C.STAVES:
						case C.TEMPO:
							s = s.ts_next
							if (!s)
								return space
							continue
					}
					break
				}
				
				/* reduce spacing within a beam */
				if (!s.beam_st)
					space *= .9			// ex fnnp
				
				/* decrease spacing when stem down followed by stem up */
				/*fixme:to be done later, after x computed in sym_glue*/
				if (s.type == C.NOTE && s.nflags >= -1
					&& s.stem > 0) {
					var stemdir = true
					
					for (s2 = s.ts_prev;
						s2 && s2.time == prev_time;
						s2 = s2.ts_prev) { 
						if (s2.type == C.NOTE
							&& (s2.nflags < -1 || s2.stem > 0)) {
							stemdir = false
							break
						}
					}
					if (stemdir) {
						for (s2 = s.ts_next;
							s2 && s2.time == s.time;
							s2 = s2.ts_next) { 
							if (s2.type == C.NOTE
								&& (s2.nflags < -1 || s2.stem < 0)) {
								stemdir = false
								break
							}
						}
						if (stemdir)
							space *= .9
					}
				}
				return space
			}
			
			// set a fixed spacing inside tuplets
			private function set_sp_tup(s, s_et) : *  {
				var	dt, s2,
				tim = s.time,
					endtime = s_et.time + s_et.dur,
					ttim = endtime - tim,
					space = time2space(s, ttim / s.tq0) * s.tq0 / ttim
				
				// start on the second note/rest
				do { 
					s = s.ts_next
				} while (!s.seqst);
				while (!s.dur) { 
					s = s.ts_next;
				}
				while (!s.seqst) { 
					s = s.ts_prev;
				}
				
				// stop outside the tuplet sequence
				// and add a measure bar when at end of tune
				do { 
					if (!s_et.ts_next) {
						s2 = add_end_bar(s_et);
						s_et = s2
					} else {
						s_et = s_et.ts_next
					}
				} while (!s_et.seqst);
				
				// check the minimum spacing
				s2 = s
				while (1) { 
					if (s2.dur
						&& s2.dur * space < s2.shrink)
						space = s2.shrink / s2.dur
					if (s2 == s_et)
						break
					s2 = s2.ts_next
				}
				
				// set the space values
				while (1) { 
					if (s.seqst) {
						dt = (s.time - tim) * space;
						tim = s.time
					}
					s.space = dt
					if (s == s_et)
						break
					s = s.ts_next
				}
			}
			
			// create an invisible bar for end of music lines
			private function add_end_bar(s) : *  {
				var	bar = {
					type: C.BAR,
						bar_type: "|",
						fname: s.fname,
						istart: s.istart,
						iend: s.iend,
						v: s.v,
						p_v: s.p_v,
						st: s.st,
						dur: 0,
						seqst: true,
						invis: true,
						time: s.time + s.dur,
						nhd: 0,
						notes: [{
							pit: s.notes[0].pit
						}],
						wl: 0,
						wr: 0,
						prev: s,
						ts_prev: s,
						shrink: s.wr + 3
				}
				s.next = s.ts_next = bar
				return bar
			}
			
			/**
			 * Sets the width and space of all symbols.
			 * This function is called once for the whole tune,
			 * then once per music line up to the first sequence.
			 */
			private function set_allsymwidth() : void {
				var	maxx;
				var new_val;
				var s_tupc;
				var s_tupn;
				var st;
				var s = tsfirst;
				var s2 = s;
				var xa = 0;
				var xl : Array = [];
				var wr : Array = [];
				var ntup = 0;
				
				// Loop through all symbols
				while (true) { 
					maxx = xa;
					do { 
						self.set_width(s);
						st = s.st;
						if (xl[st] == undefined) {
							xl[st] = 0;
						}
						if (wr[st] == undefined) {
							wr[st] = 0;
						}
						new_val = xl[st] + wr[st] + s.wl;
						if (new_val > maxx) {
							maxx = new_val;
						}
						s = s.ts_next;
					} while (s && !s.seqst);
					
					// Set the spaces of the time sequence
					s2.shrink = maxx - xa;
					
					// If not inside a tuplet sequence
					if (!ntup) {			
						s2.space = s2.ts_prev ? set_space(s2) : 0;
					}
					if (s2.shrink == 0 && s2.space == 0 && s2.type == C.CLEF) {
						
						// No space
						delete s2.seqst;
						s2.time = s2.ts_prev.time;
					}
					if (!s) {
						break;
					}
					
					// Update the minimum left space per staff
					for (st = 0; st < wr.length; st++) { 
						wr[st] = 0;
					}
					xa = maxx;
					do { 
						st = s2.st;
						xl[st] = xa;
						if (s2.wr > wr[st]) {
							wr[st] = s2.wr;
						}
						
						// Start of tuplet
						if (s2.tp0 && ++ntup == 1 && !s_tupc) {
							
							// Save the first tuplet's address
							s_tupc = s2;
						}
						
						// End of tuplet
						if (s2.te0) {
							ntup--;
						}
						s2 = s2.ts_next;
					} while (!s2.seqst);
				}
				
				// Adjust the spacing inside the tuplets
				s = s_tupc;
				if (!s) {
					return;
				}
				do { 
					
					// Start of tuplet
					s2 = s;
					ntup = 1;
					
					// Search the end of the tuplet sequence
					do { 
						s = s.ts_next;
						if (s.tp0) {
							ntup++;
						}
						if (s.te0) {
							ntup--;
						}
					} while (ntup != 0);
					set_sp_tup (s2, s);
					
					// Search next tuplet
					while (s && !s.tp0) { 
						s = s.ts_next;
					}
				} while (s);
			}
			
			/* change a symbol into a rest */
			private function to_rest(s) : *  {
				s.type = C.REST
				// just keep nl and seqst
				delete s.in_tuplet
				delete s.sl1
				delete s.sl2
				delete s.a_dd
				delete s.a_gch
				s.slur_start = s.slur_end = 0
				/*fixme: should set many parameters for set_width*/
				//	set_width(s)
			}
			
			/* -- set the repeat sequences / measures -- */
			private function set_repeat(s) : *  {	// first note
				var	s2, s3,  i, j, dur,
				n = s.repeat_n,
					k = s.repeat_k,
					st = s.st,
					v = s.v
				
				s.repeat_n = 0				// treated
				
				/* treat the sequence repeat */
				if (n < 0) {				/* number of notes / measures */
					n = -n;
					i = n				/* number of notes to repeat */
					for (s3 = s.prev; s3; s3 = s3.prev) { 
						if (!s3.dur) {
							if (s3.type == C.BAR) {
								error(1, s3, "Bar in repeat sequence")
								return
							}
							continue
						}
						if (--i <= 0)
							break
					}
					if (!s3) {
						error(1, s, errs.not_enough_n)
						return
					}
					dur = s.time - s3.time;
					
					i = k * n		/* whole number of notes/rests to repeat */
					for (s2 = s; s2; s2 = s2.next) { 
						if (!s2.dur) {
							if (s2.type == C.BAR) {
								error(1, s2, "Bar in repeat sequence")
								return
							}
							continue
						}
						if (--i <= 0)
							break
					}
					if (!s2
						|| !s2.next) {		/* should have some symbol */
						error(1, s, errs.not_enough_n)
						return
					}
					for (s2 = s.prev; s2 != s3; s2 = s2.prev) { 
						if (s2.type == C.NOTE) {
							s2.beam_end = true
							break
						}
					}
					for (j = k; --j >= 0; ) { 
						i = n			/* number of notes/rests */
						if (s.dur)
							i--;
						s2 = s.ts_next
						while (i > 0) { 
							if (s2.st == st) {
								unlksym(s2)
								if (s2.v == v
									&& s2.dur)
									i--
							}
							s2 = s2.ts_next
						}
						to_rest(s);
						s.dur = s.notes[0].dur = dur;
						s.rep_nb = -1;		// single repeat
						s.beam_st = true;
						self.set_width(s)
						if (s.seqst)
							s.space = set_space(s);
						s.head = C.SQUARE;
						for (s = s2; s; s = s.ts_next) { 
							if (s.st == st
								&& s.v == v
								&& s.dur)
								break
						}
					}
					return
				}
				
				/* check the measure repeat */
				i = n				/* number of measures to repeat */
				for (s2 = s.prev.prev ; s2; s2 = s2.prev) { 
					if (s2.type == C.BAR
						|| s2.time == tsfirst.time) {
						if (--i <= 0)
							break
					}
				}
				if (!s2) {
					error(1, s, errs.not_enough_m)
					return
				}
				
				dur = s.time - s2.time		/* repeat duration */
				
				if (n == 1)
					i = k			/* repeat number */
				else
					i = n			/* check only 2 measures */
				for (s2 = s; s2; s2 = s2.next) { 
					if (s2.type == C.BAR) {
						if (--i <= 0)
							break
					}
				}
				if (!s2) {
					error(1, s, errs.not_enough_m)
					return
				}
				
				/* if many 'repeat 2 measures'
				* insert a new %%repeat after the next bar */
				i = k				/* repeat number */
				if (n == 2 && i > 1) {
					s2 = s2.next
					if (!s2) {
						error(1, s, errs.not_enough_m)
						return
					}
					s2.repeat_n = n;
					s2.repeat_k = --i
				}
				
				/* replace */
				dur /= n
				if (n == 2) {			/* repeat 2 measures (once) */
					s3 = s
					for (s2 = s.ts_next; ; s2 = s2.ts_next) { 
						if (s2.st != st)
							continue
						if (s2.v == v
							&& s2.type == C.BAR)
							break
						unlksym(s2)
					}
					to_rest(s3);
					s3.dur = s3.notes[0].dur = dur;
					s3.invis = true
					if (s3.seqst)
						s3.space = set_space(s3);
					s2.bar_mrep = 2
					if (s2.seqst)
						s2.space = set_space(s2);
					s3 = s2.next;
					for (s2 = s3.ts_next; ; s2 = s2.ts_next) { 
						if (s2.st != st)
							continue
						if (s2.v == v
							&& s2.type == C.BAR)
							break
						unlksym(s2)
					}
					to_rest(s3);
					s3.dur = s3.notes[0].dur = dur;
					s3.invis = true;
					self.set_width(s3)
					if (s3.seqst)
						s3.space = set_space(s3)
					if (s2.seqst)
						s2.space = set_space(s2)
					return
				}
				
				/* repeat 1 measure */
				s3 = s
				for (j = k; --j >= 0; ) { 
					for (s2 = s3.ts_next; ; s2 = s2.ts_next) { 
						if (s2.st != st)
							continue
						if (s2.v == v
							&& s2.type == C.BAR)
							break
						unlksym(s2)
					}
					to_rest(s3);
					s3.dur = s3.notes[0].dur = dur;
					s3.beam_st = true
					if (s3.seqst)
						s3.space = set_space(s3)
					if (s2.seqst)
						s2.space = set_space(s2)
					if (k == 1) {
						s3.rep_nb = 1
						break
					}
					s3.rep_nb = k - j + 1;	// number to print above the repeat rest
					s3 = s2.next
				}
			}
			
			/* add a custos before the symbol of the next line */
			private function custos_add(s) : *  {
				var	p_voice, new_s, i,
				s2 = s
				
				while (1) { 
					if (s2.type == C.NOTE)
						break
					s2 = s2.next
					if (!s2)
						return
				}
				
				p_voice = s.p_v;
				p_voice.last_sym = s.prev;
				//	if (!p_voice.last_sym)
				//		p_voice.sym = null;
				p_voice.time = s.time;
				new_s = sym_add(p_voice, C.CUSTOS);
				new_s.next = s;
				s.prev = new_s;
				lktsym(new_s, s);
				
				new_s.seqst = true;
				new_s.shrink = s.shrink
				if (new_s.shrink < 8 + 4)
					new_s.shrink = 8 + 4;
				new_s.space = s2.space;
				new_s.wl = 0;
				new_s.wr = 4;
				
				new_s.nhd = s2.nhd;
				new_s.notes = []
				for (i = 0; i < s.notes.length; i++) { 
					new_s.notes[i] = {
						pit: s2.notes[i].pit,
							shhd: 0,
							dur: C.BLEN / 4
					}
				}
				new_s.stemless = true
			}
			
			/* -- define the beginning of a new music line -- */
			private function set_nl(s) : *  {
				var s2, p_voice, done
				
				// set the end of line marker and
				function set_eol(s)  :* {
					if (cfmt.custos && voice_tb.length == 1)
						custos_add(s)
					
					// set the nl flag if more music
					for (var s2 = s.ts_next; s2; s2 = s2.ts_next) { 
						if (s2.seqst) {
							s.nl = true
							break
						}
					}
				} // set_eol()
				
				// set the eol on the next symbol
				function set_eol_next(s) :*  {
					if (!s.next) {		// special case: the voice stops here
						set_eol(s)
						return s
					}
					for (s = s.ts_next; s; s = s.ts_next) { 
						if (s.seqst) {
							set_eol(s)
							break
						}
					}
					return s
				} // set_eol_next()
				
				/* if explicit EOLN, cut on the next symbol */
				if (s.eoln && !cfmt.keywarn && !cfmt.timewarn)
					return set_eol_next(s)
				
				/* if normal symbol, cut here */
				switch (s.type) {
					case C.CLEF:
					case C.BAR:
					case C.STAVES:
						break
					case C.KEY:
						if (cfmt.keywarn && !s.k_none)
							break
						return set_eol_next(s)
					case C.METER:
						if (cfmt.timewarn)
							break
						return set_eol_next(s)
					case C.GRACE:			/* don't cut on a grace note */
						s = s.next
						if (!s)
							return s
						/* fall thru */
					default:
						return set_eol_next(s)
				}
				
				/* go back to handle the staff breaks at end of line */
				for (; s; s = s.ts_prev) { 
					if (!s.seqst)
						continue
					switch (s.type) {
						case C.KEY:
						case C.CLEF:
						case C.METER:
							continue
					}
					break
				}
				done = 0
				for ( ; ; s = s.ts_next) { 
					if (!s)
						return s
					if (!s.seqst)
						continue
					if (done < 0)
						break
					switch (s.type) {
						case C.STAVES:
							if (s.ts_prev && s.ts_prev.type == C.BAR)
								break
							while (s.ts_next) { 
								if (w_tb[s.ts_next.type] != 0
									&& s.ts_next.type != C.CLEF)
									break
								s = s.ts_next
							}
							if (!s.ts_next || s.ts_next.type != C.BAR)
								continue
							s = s.ts_next
							// fall thru
						case C.BAR:
							if (done)
								break
							done = 1;
							continue
						case C.STBRK:
							if (!s.stbrk_forced)
								unlksym(s)	/* remove */
							else
								done = -1	// keep the next symbols on the next line
							continue
						case C.METER:
							if (!cfmt.timewarn)
								break
							continue
						case C.CLEF:
							if (done)
								break
							continue
						case C.KEY:
							if (!cfmt.keywarn || s.k_none)
								break
							continue
						default:
							if (!done || (s.prev && s.prev.type == C.GRACE))
								continue
							break
					}
					break
				}
				set_eol(s)
				return s
			}
			
			/* get the width of the starting clef and key signature */
			// return
			//	r[0] = width of clef and key signature
			//	r[1] = width of the meter
			private function get_ck_width() : *  {
				var	r0, r1,
				p_voice = voice_tb[0]
				
				self.set_width(p_voice.clef);
				self.set_width(p_voice.key);
				self.set_width(p_voice.meter)
				return [p_voice.clef.wl + p_voice.clef.wr +
					p_voice.key.wl + p_voice.key.wr,
					p_voice.meter.wl + p_voice.meter.wr]
			}
			
			// get the width of the symbols up to the next eoln or eof
			private function get_width(s, last) : *  {
				var	shrink, space,
				w = 0,
					sp_fac = (1 - cfmt.maxshrink)
				
				do { 
					if (s.seqst) {
						shrink = s.shrink
						if ((space = s.space) < shrink)
							w += shrink
						else
							w += shrink * cfmt.maxshrink
								+ space * sp_fac
						s.x = w
					}
					if (s == last)
						break
					s = s.ts_next
				} while (s);
				return w;
			}
			
			/* -- search where to cut the lines according to the staff width -- */
			private function set_lines(	s,		/* first symbol */
								last,		/* last symbol / null */
								lwidth,		/* w - (clef & key sig) */
								indent) :*  {	/* for start of tune */
				var	first, s2, s3, x, xmin, xmid, xmax, wwidth, shrink, space,
				nlines, cut_here;
				
				for ( ; last; last = last.ts_next) { 
					if (last.eoln)
						break
				}
				
				/* calculate the whole size of the piece of tune */
				wwidth = get_width(s, last) + indent
				
				/* loop on cutting the tune into music lines */
				while (1) { 
					nlines = Math.ceil(wwidth / lwidth)
					if (nlines <= 1) {
						if (last)
							last = set_nl(last)
						return last
					}
					
					s2 = first = s;
					xmin = s.x - s.shrink - indent;
					xmax = xmin + lwidth;
					xmid = xmin + wwidth / nlines;
					xmin += wwidth / nlines * cfmt.breaklimit;
					for (s = s.ts_next; s != last ; s = s.ts_next) { 
						if (!s.x)
							continue
						if (s.type == C.BAR)
							s2 = s
						if (s.x >= xmin)
							break
					}
					//fixme: can this occur?
					if (s == last) {
						if (last)
							last = set_nl(last)
						return last
					}
					
					/* try to cut on a measure bar */
					cut_here = false;
					s3 = null
					for ( ; s != last; s = s.ts_next) { 
						x = s.x
						if (!x)
							continue
						if (x > xmax)
							break
						if (s.type != C.BAR)
							continue
						if (x < xmid) {
							s3 = s		// keep the last bar
							continue
						}
						
						// cut on the bar closest to the middle
						if (!s3 || s.x < xmid) {
							s3 = s
							continue
						}
						if (s3 > xmid)
							break
						if (xmid - s3.x < s.x - xmid)
							break
						s3 = s
						break
					}
					
					/* if a bar, cut here */
					if (s3) {
						s = s3;
						cut_here = true
					}
					
					/* try to avoid to cut a beam or a tuplet */
					if (!cut_here) {
						var	beam = 0,
							bar_time = s2.time;
						
						xmax -= 8; // (left width of the inserted bar in set_allsymwidth)
						s = s2;			// restart from start or last bar
						s3 = null
						for ( ; s != last; s = s.ts_next) { 
							if (s.beam_st)
								beam++
							if (s.beam_end && beam > 0)
							beam--
								x = s.x
							if (!x)
								continue
							if (x + s.wr >= xmax)
								break
							if (beam || s.in_tuplet)
								continue
							//fixme: this depends on the meter
							if ((s.time - bar_time) % (C.BLEN / 4) == 0) {
								s3 = s
								continue
							}
							if (!s3 || s.x < xmid) {
								s3 = s
								continue
							}
							if (s3 > xmid)
								break
							if (xmid - s3.x < s.x - xmid)
								break
							s3 = s
							break
						}
						if (s3) {
							s = s3;
							cut_here = true
						}
					}
					
					// cut anyhere
					if (!cut_here) {
						s3 = s = s2
						for ( ; s != last; s = s.ts_next) { 
							x = s.x
							if (!x)
								continue
							if (s.x < xmid) {
								s3 = s
								continue
							}
							if (s3 > xmid)
								break
							if (xmid - s3.x < s.x - xmid)
								break
							s3 = s
							break
						}
						s = s3
					}
					
					if (s.nl) {		/* already set here - advance */
						error(0, s,
							"Line split problem - adjust maxshrink and/or breaklimit");
						nlines = 2
						for (s = s.ts_next; s != last; s = s.ts_next) { 
							if (!s.x)
								continue
							if (--nlines <= 0)
								break
						}
					}
					s = set_nl(s)
					if (!s
						|| (last && s.time >= last.time))
						break
					wwidth -= s.x - first.x;
					indent = 0
				}
				return s
			}
			
			/* Cut the tune into music lines */
			private function cut_tune (lwidth : Number, indent : Number) : void {
				var s2; 
				var s3; 
				var i; 
				var xmin;
				var s : Object = tsfirst;
				
				// Take care of the voice subnames
				if (indent != 0) {
					i = set_indent();
					lwidth -= i;
					indent -= i;
				}
				
				// Adjust the line width according to the starting clef
				// and key signature. 
				// FIXME: may change in the tune
				i = get_ck_width();
				lwidth -= i[0];
				indent += i[1];
				
				if (cfmt.custos && voice_tb.length == 1) {
					lwidth -= 12;
				}
				
				// If asked, count the measures and set the EOLNs
				if (cfmt.barsperstaff) {
					i = cfmt.barsperstaff;
					for (s2 = s; s2; s2 = s2.ts_next) { 
						if (s2.type != C.BAR || !s2.bar_num || --i > 0) {
							continue;
						}
						s2.eoln = true;
						i = cfmt.barsperstaff;
					}
				}
				
				// Cut at explicit end of line, checking the line width
				xmin = indent;
				s2 = s;
				while ((s = s.ts_next)) {
					if (!s.seqst && !s.eoln) {
						continue;
					}
					xmin += s.shrink;
					
					// Overflow
					if (xmin > lwidth) {
						s2 = set_lines(s2, s, lwidth, indent);
					} else {
						if (!s.eoln) {
							continue;
						}
						delete s.eoln;
						
						// If eoln on a note or a rest, check for a smaller
						// duration in an other voice.
						if (s.dur) {
							for (s3 = s.ts_next; s3; s3 = s3.ts_next) { 
								if (s3.seqst || s3.dur < s.dur) {
									break;
								}
							}
							if (s3 && !s3.seqst) {
								s2 = set_lines(s2, s, lwidth, indent);
							}
							else {
								s2 = set_nl(s);
							}
						} else {
							s2 = set_nl(s);
						}
					}
					if (!s2) {
						break;
					}
					
					// (S2 may be tsfirst - no ts_prev - when only one
					//  embedded info in the first line after the first K:)
					if (!s2.ts_prev) {
						delete s2.nl;
						continue;
					}
					xmin = s2.shrink;
					
					// Don't miss an eoln
					s = s2.ts_prev;
					indent = 0
				}
			}
			
			/* -- set the y values of some symbols -- */
			private function set_yval(s) : *  {
				//fixme: staff_tb is not yet defined
				//	var top = staff_tb[s.st].topbar
				//	var bot = staff_tb[s.st].botbar
				switch (s.type) {
					case C.CLEF:
						if (s.second
							|| s.invis) {
							//			s.ymx = s.ymn = (top + bot) / 2
							s.ymx = s.ymn = 12
							break
						}
						s.y = (s.clef_line - 1) * 6
						switch (s.clef_type) {
							default:			/* treble / perc */
								s.ymx = s.y + 28
								s.ymn = s.y - 14
								break
							case "c":
								s.ymx = s.y + 13
								s.ymn = s.y - 11
								break
							case "b":
								s.ymx = s.y + 7
								s.ymn = s.y - 12
								break
						}
						if (s.clef_small) {
							s.ymx -= 2;
							s.ymn += 2
						}
						if (s.ymx < 26)
							s.ymx = 26
						if (s.ymn > -1)
							s.ymn = -1
						//		s.y += s.clef_line * 6
						//		if (s.y > 0)
						//			s.ymx += s.y
						//		else if (s.y < 0)
						//			s.ymn += s.y
						if (s.clef_octave) {
							if (s.clef_octave > 0)
								s.ymx += 12
							else
								s.ymn -= 12
						}
						break
					case C.KEY:
						if (s.k_sf > 2)
							s.ymx = 24 + 10
						else if (s.k_sf > 0)
							s.ymx = 24 + 6
						else
							s.ymx = 24 + 2;
						s.ymn = -2
						break
					default:
						//		s.ymx = top;
						s.ymx = 24;
						s.ymn = 0
						break
				}
			}
			
			// set the clefs (treble or bass) in a 'auto clef' sequence
			// return the starting clef type
			private function set_auto_clef(st, s_start, clef_type_start) : *  {
				var s, min, max, time, s2, s3;
				
				/* get the max and min pitches in the sequence */
				max = 12;					/* "F," */
				min = 20					/* "G" */
				for (s = s_start; s; s = s.ts_next) { 
					if (s.type == C.STAVES && s != s_start)
						break
					if (s.st != st)
						continue
					if (s.type != C.NOTE) {
						if (s.type == C.CLEF) {
							if (s.clef_type != 'a')
								break
							unlksym(s)
						}
						continue
					}
					if (s.notes[0].pit < min)
						min = s.notes[0].pit
					else if (s.notes[s.nhd].pit > max)
						max = s.notes[s.nhd].pit
				}
				
				if (min >= 19					/* upper than 'F' */
					|| (min >= 13 && clef_type_start != 'b'))	/* or 'G,' */
					return 't'
				if (max <= 13					/* lower than 'G,' */
					|| (max <= 19 && clef_type_start != 't'))	/* or 'F' */
					return 'b'
				
				/* set clef changes */
				if (clef_type_start == 'a') {
					if ((max + min) / 2 >= 16)
						clef_type_start = 't'
					else
						clef_type_start = 'b'
				}
				var	clef_type = clef_type_start,
					s_last = s,
					s_last_chg = null
				for (s = s_start; s != s_last; s = s.ts_next) { 
					if (s.type == C.STAVES && s != s_start)
						break
					if (s.st != st || s.type != C.NOTE)
						continue
					
					/* check if a clef change may occur */
					time = s.time
					if (clef_type == 't') {
						if (s.notes[0].pit > 12		/* F, */
							|| s.notes[s.nhd].pit > 20) {	/* G */
							if (s.notes[0].pit > 20)
								s_last_chg = s
							continue
						}
						s2 = s.ts_prev
						if (s2
							&& s2.time == time
							&& s2.st == st
							&& s2.type == C.NOTE
							&& s2.notes[0].pit >= 19)	/* F */
							continue
						s2 = s.ts_next
						if (s2
							&& s2.st == st
							&& s2.time == time
							&& s2.type == C.NOTE
							&& s2.notes[0].pit >= 19)	/* F */
							continue
					} else {
						if (s.notes[0].pit < 12		/* F, */
							|| s.notes[s.nhd].pit < 20) {	/* G */
							if (s.notes[s.nhd].pit < 12)
								s_last_chg = s
							continue
						}
						s2 = s.ts_prev
						if (s2
							&& s2.time == time
							&& s2.st == st
							&& s2.type == C.NOTE
							&& s2.notes[0].pit <= 13)	/* G, */
							continue
						s2 = s.ts_next
						if (s2
							&& s2.st == st
							&& s2.time == time
							&& s2.type == C.NOTE
							&& s2.notes[0].pit <= 13)	/* G, */
							continue
					}
					
					/* if first change, change the starting clef */
					if (!s_last_chg) {
						clef_type = clef_type_start =
							clef_type == 't' ? 'b' : 't';
						s_last_chg = s
						continue
					}
					
					/* go backwards and search where to insert a clef change */
					s3 = s
					for (s2 = s.ts_prev; s2 != s_last_chg; s2 = s2.ts_prev) { 
						if (s2.st != st)
							continue
						if (s2.type == C.BAR
							&& s2.v == s.v) {
							s3 = s2
							break
						}
						if (s2.type != C.NOTE)
							continue
						
						/* have a 2nd choice on beam start */
						if (s2.beam_st
							&& !s2.p_v.second)
							s3 = s2
					}
					
					/* no change possible if no insert point */
					if (s3.time == s_last_chg.time) {
						s_last_chg = s
						continue
					}
					s_last_chg = s;
					
					/* insert a clef change */
					clef_type = clef_type == 't' ? 'b' : 't';
					s2 = insert_clef(s3, clef_type, clef_type == "t" ? 2 : 4);
					s2.clef_auto = true
					//		s3.prev.st = st
				}
				return clef_type_start
			}
			
			/* set the clefs */
			/* this function is called once at start of tune generation */
			/*
			* global variables:
			*	- staff_tb[st].clef = clefs at start of line (here, start of tune)
			*				(created here, updated on clef draw)
			*	- voice_tb[v].clef = clefs at end of generation
			*				(created on voice creation, updated here)
			*/
			private function set_clefs() : *  {
				var	s, s2, st, v, p_voice, g, new_type, new_line, p_staff, pit,
				staff_clef = new Array(nstaff),	// st -> { clef, autoclef }
					sy = cur_sy,
					mid = []
				
				// create the staff table
				staff_tb = new Array(nstaff)
				for (st = 0; st <= nstaff; st++) { 
					staff_clef[st] = {
						autoclef: true
					}
					staff_tb[st] = {
						output: "",
						sc_out: ""
					}
				}
				
				// set the starting clefs of the staves
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					if (sy.voices[v].range < 0)
						continue
					st = sy.voices[v].st
					if (!sy.voices[v].second) {		// main voices
						if (p_voice.staffnonote != undefined)
							sy.staves[st].staffnonote = p_voice.staffnonote
						if (p_voice.staffscale)
							sy.staves[st].staffscale = p_voice.staffscale
						if (sy.voices[v].sep)
							sy.staves[st].sep = sy.voices[v].sep
						if (sy.voices[v].maxsep)
							sy.staves[st].maxsep = sy.voices[v].maxsep;
					}
					if (!sy.voices[v].second
						&& !p_voice.clef.clef_auto)
						staff_clef[st].autoclef = false
				}
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					if (sy.voices[v].range < 0
						|| sy.voices[v].second)		// main voices
						continue
					st = sy.voices[v].st;
					s = p_voice.clef
					if (staff_clef[st].autoclef) {
						s.clef_type = set_auto_clef(st,
							tsfirst,
							s.clef_type);
						s.clef_line = s.clef_type == 't' ? 2 : 4
					}
					staff_clef[st].clef = staff_tb[st].clef = s
				}
				for (st = 0; st <= sy.nstaff; st++) { 
					mid[st] = (sy.staves[st].stafflines.length - 1) * 3;
				}
				
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.repeat_n) {
						set_repeat(s);
					}
					
					switch (s.type) {
						case C.STAVES:
							sy = s.sy
							for (st = 0; st <= nstaff; st++) { 
								staff_clef[st].autoclef = true;
							}
							for (v = 0; v < voice_tb.length; v++) { 
								if (sy.voices[v].range < 0)
									continue
								p_voice = voice_tb[v];
								st = sy.voices[v].st
								if (!sy.voices[v].second) {
									if (p_voice.staffnonote != undefined)
										sy.staves[st].staffnonote = p_voice.staffnonote
									if (p_voice.staffscale)
										sy.staves[st].staffscale = p_voice.staffscale
									if (sy.voices[v].sep)
										sy.staves[st].sep = sy.voices[v].sep
									if (sy.voices[v].maxsep)
										sy.staves[st].maxsep = sy.voices[v].maxsep
								}
								s2 = p_voice.clef
								if (!s2.clef_auto)
									staff_clef[st].autoclef = false
							}
							for (st = 0; st <= sy.nstaff; st++) { 
								mid[st] = (sy.staves[st].stafflines.length - 1) * 3;
							}
							for (v = 0; v < voice_tb.length; v++) { 
								if (sy.voices[v].range < 0
									|| sy.voices[v].second)	// main voices
									continue
								p_voice = voice_tb[v];
								st = sy.voices[v].st;
								s2 = p_voice.clef
								if (s2.clef_auto) {
									//fixme: the staff may have other voices with explicit clefs...
									//					if (!staff_clef[st].autoclef)
									//						???
									new_type = set_auto_clef(st, s,
										staff_clef[st].clef ?
										staff_clef[st].clef.clef_type :
										'a');
									new_line = new_type == 't' ? 2 : 4
								} else {
									new_type = s2.clef_type;
									new_line = s2.clef_line
								}
								if (!staff_clef[st].clef) {	// new staff
									if (s2.clef_auto) {
										if (s2.type != 'a')
											p_voice.clef =
												clone(p_voice.clef);
										p_voice.clef.clef_type = new_type;
										p_voice.clef.clef_line = new_line
									}
									staff_tb[st].clef =
										staff_clef[st].clef = p_voice.clef
									continue
								}
								// old staff
								if (new_type == staff_clef[st].clef.clef_type
									&& new_line == staff_clef[st].clef.clef_line)
									continue
								g = s.ts_next
								while (g && (g.v != v || g.st != st)) {
									g = g.ts_next;
								}
								if (!g)				// ??
									continue
								if (g.type != C.CLEF) {
									g = insert_clef(g, new_type, new_line)
									if (s2.clef_auto)
										g.clef_auto = true
								}
								staff_clef[st].clef = p_voice.clef = g
							}
							continue
						default:
							s.mid = mid[s.st]
							continue
						case C.CLEF:
							break
					}
					
					if (s.clef_type == 'a') {
						s.clef_type = set_auto_clef(s.st,
							s.ts_next,
							staff_clef[s.st].clef.clef_type);
						s.clef_line = s.clef_type == 't' ? 2 : 4
					}
					
					p_voice = s.p_v;
					p_voice.clef = s
					if (s.second) {
						/*fixme:%%staves:can this happen?*/
						//			if (!s.prev)
						//				break
						unlksym(s)
						continue
					}
					st = s.st
					// may have been inserted on %%staves
					//		if (s.clef_auto) {
					//			unlksym(s)
					//			continue
					//		}
					
					if (staff_clef[st].clef) {
						if (s.clef_type == staff_clef[st].clef.clef_type
							&& s.clef_line == staff_clef[st].clef.clef_line) {
							//				unlksym(s)
							continue
						}
					} else {
						
						// the voice moved to a new staff with a forced clef
						staff_tb[st].clef = s
					}
					staff_clef[st].clef = s
				}
				
				/* set a pitch to the symbols of voices with no note */
				sy = cur_sy
				for (v = 0; v < voice_tb.length; v++) { 
					if (sy.voices[v].range < 0)
						continue
					s2 = voice_tb[v].sym
					if (!s2 || s2.notes[0].pit != 127)
						continue
					st = sy.voices[v].st
					switch (staff_tb[st].clef.clef_type) {
						default:
							pit = 22		/* 'B' */
							break
						case "c":
							pit = 16		/* 'C' */
							break
						case "b":
							pit = 10		/* 'D,' */
							break
					}
					for (s = s2; s; s = s.next) { 
						s.notes[0].pit = pit;
					}
				}
			}
			
			/* set the pitch of the notes according to the clefs
			* and set the vertical offset of the symbols */
			/* this function is called at start of tune generation and
			* then, once per music line up to the old sequence */
			
			private var delta_tb = {
				t: 0 - 2 * 2,
					c: 6 - 3 * 2,
					b: 12 - 4 * 2,
					p: 0 - 3 * 2
			}
			
			/* upper and lower space needed by rests */
			private var rest_sp = [
				[18, 18],
				[12, 18],
				[12, 12],
				[0, 12],
				[6, 8],
				[10, 10],			/* crotchet */
				[6, 4],
				[10, 0],
				[10, 4],
				[10, 10]
			]
			
			// (possible hook)
			private function set_pitch(last_s) : *  {
				var	s, s2, g, st, delta, m, pitch, note,
				dur = C.BLEN,
					staff_delta = new Array(nstaff),
					sy = cur_sy
				
				// set the starting clefs of the staves
				for (st = 0; st <= nstaff; st++) { 
					s = staff_tb[st].clef;
					staff_delta[st] = delta_tb[s.clef_type] + s.clef_line * 2
					if (s.clefpit)
						staff_delta[st] += s.clefpit
					if (cfmt.sound) {
						if (s.clef_octave && !s.clef_oct_transp)
							staff_delta[st] += s.clef_octave
					} else {
						if (s.clef_oct_transp)
							staff_delta[st] -= s.clef_octave
					}
				}
				
				for (s = tsfirst; s != last_s; s = s.ts_next) { 
					st = s.st
					switch (s.type) {
						case C.CLEF:
							staff_delta[st] = delta_tb[s.clef_type] +
							s.clef_line * 2
							if (s.clefpit)
								staff_delta[st] += s.clefpit
							if (cfmt.sound) {
								if (s.clef_octave && !s.clef_oct_transp)
									staff_delta[st] += s.clef_octave
							} else {
								if (s.clef_oct_transp)
									staff_delta[st] -= s.clef_octave
							}
							set_yval(s)
							break
						case C.GRACE:
							for (g = s.extra; g; g = g.next) { 
								delta = staff_delta[g.st]
								if (delta != 0
									&& !s.p_v.key.k_drum) {
									for (m = 0; m <= g.nhd; m++) { 
										note = g.notes[m];
										note.pit += delta
									}
								}
								g.ymn = 3 * (g.notes[0].pit - 18) - 2;
								g.ymx = 3 * (g.notes[g.nhd].pit - 18) + 2
							}
							set_yval(s)
							break
						case C.KEY:
							s.k_y_clef = staff_delta[st] /* keep the y delta */
							/* fall thru */
						default:
							set_yval(s)
							break
						case C.MREST:
							if (s.invis)
								break
							s.y = 12;
							s.ymx = 24 + 15;
							s.ymn = -2
							break
						case C.REST:
							if (voice_tb.length == 1) {
								s.y = 12;		/* rest single voice */
								//				s.ymx = 12 + 8;
								//				s.ymn = 12 - 8
								s.ymx = 24;
								s.ymn = 0
								break
							}
							// fall thru
						case C.NOTE:
							delta = staff_delta[st]
							if (delta != 0
								&& !s.p_v.key.k_drum) {
								for (m = s.nhd; m >= 0; m--) { 
									s.notes[m].opit = s.notes[m].pit;
									s.notes[m].pit += delta
								}
							}
							if (s.type == C.NOTE) {
								s.ymx = 3 * (s.notes[s.nhd].pit - 18) + 4;
								s.ymn = 3 * (s.notes[0].pit - 18) - 4;
							} else {
								s.y = (((s.notes[0].pit - 18) / 2) | 0) * 6;
								s.ymx = s.y + rest_sp[5 - s.nflags][0];
								s.ymn = s.y - rest_sp[5 - s.nflags][1]
							}
							if (s.dur < dur)
								dur = s.dur
							break
					}
				}
				if (!last_s)
					smallest_duration = dur
			}
			
			/**
			 * Set the stem direction in multi-voice environment.
			 * This function is called only once per tune
			 * (possible hook)
			 */
			private function set_stem_dir() : void {
				var	t : Object;
				var u : Object;
				var i : int;
				var st : int;
				var rvoice : int;
				var v : int;
				
				// Voice -> staff 1 & 2
				var v_st : Object;
				var st_v : Array; 
				
				// Staff -> (v, ymx, ymn)*
				var vobj : Object;
				
				// Array of `v_st` Objects
				var v_st_tb : Array;
				
				// Array of `st_v` Objects
				var st_v_tb : Array = [];
				var s : Object = tsfirst;
				var sy : Object = cur_sy;
				var nst : int = sy.nstaff;
				
				while (s) { 
					for (st = 0; st <= nst; st++) { 
						st_v_tb[st] = [];
					}
					v_st_tb = [];
					
					// Get the max/min offsets in the delta time
					// FIXME: the stem height is not calculated yet
					for (u = s; u; u = u.ts_next) { 
						if (u.type == C.BAR) {
							break;
						}
						if (u.type == C.STAVES) {
							if (u != s) {
								break;
							}
							sy = s.sy;
							for (st = nst; st <= sy.nstaff; st++) { 
								st_v_tb[st] = [];
							}
							nst = sy.nstaff;
							continue;
						}
						if ((u.type != C.NOTE && u.type != C.REST) || u.invis) {
							continue;
						}
						st = u.st;
						if (st > nst) {
							var msg : String = "*** fatal set_stem_dir(): bad staff number " + st + " max " + nst;
							error (2, null, msg);
							throw new Error (msg);
						}
						v = u.v;
						v_st = v_st_tb[v];
						if (!v_st) {
							v_st = {
								st1: -1,
								st2: -1
							};
							v_st_tb[v] = v_st;
						}
						if (v_st.st1 < 0) {
							v_st.st1 = st;
						} else if (v_st.st1 != st) {
							if (st > v_st.st1) {
								if (st > v_st.st2) {
									v_st.st2 = st;
								}
							} else {
								if (v_st.st1 > v_st.st2) {
									v_st.st2 = v_st.st1;
								}
								v_st.st1 = st;
							}
						}
						st_v = st_v_tb[st];
						rvoice = sy.voices[v].range;
						for (i = st_v.length; --i >= 0; ) { 
							vobj = st_v[i];
							if (vobj.v == rvoice) {
								break;
							}
						}
						if (i < 0) {
							vobj = {
								v: rvoice,
								ymx: 0,
								ymn: 24
							}
							for (i = 0; i < st_v.length; i++) { 
								if (rvoice < st_v[i].v) {
									st_v.splice(i, 0, vobj);
									break;
								}
							}
							if (i == st_v.length) {
								st_v.push (vobj);
							}
						}
						if (u.type != C.NOTE) {
							continue;
						}
						if (u.ymx > vobj.ymx) {
							vobj.ymx = u.ymx;
						}
						if (u.ymn < vobj.ymn) {
							vobj.ymn = u.ymn;
						}
						if (u.xstem) {
							if (u.ts_prev.st != st - 1 || u.ts_prev.type != C.NOTE) {
								error (1, s, "Bad !xstem!");
								u.xstem = false;
								// FIXME: nflags KO (???)
							} else {
								u.ts_prev.multi = 1;
								u.multi = 1;
								u.stemless = true;
							}
						}
					}
					for ( ; s != u; s = s.ts_next) { 
						if (s.multi) {
							continue;
						}
						switch (s.type) {
							default:
								continue;
							case C.REST:
								
								// Handle %%voicecombine 0
								if ((s.combine != undefined && s.combine < 0)
									|| !s.ts_next || s.ts_next.type != C.REST
									|| s.ts_next.st != s.st
									|| s.time != s.ts_next.time
									|| s.dur != s.ts_next.dur
									|| s.invis) {
									break;
								}
								unlksym (s.ts_next);
								break;
							case C.NOTE:
							case C.GRACE:
								break;
						}
						st = s.st;
						v = s.v;
						v_st = v_st_tb[v];
						st_v = st_v_tb[st];
						if (v_st && v_st.st2 >= 0) {
							if (st == v_st.st1) {
								s.multi = -1;
							}
							else if (st == v_st.st2) {
								s.multi = 1;
							}
							continue;
						}
						
						// Voice alone on the staff
						if (st_v.length <= 1) {
							
							// FIXME: could be done in `set_var()`
							if (s.floating) {
								s.multi = st == voice_tb[v].st ? -1 : 1;
							}
							continue;
						}
						rvoice = sy.voices[v].range;
						for (i = st_v.length; --i >= 0; ) { 
							if (st_v[i].v == rvoice) {
								break;
							}
						}
						
						// Voice ignored
						if (i < 0) {
							continue;
						}
						
						// Last voice
						if (i == st_v.length - 1) {
							s.multi = -1;	
						}
						
						// First voice(s)
						else {
							s.multi = 1;
							
							// If 3 voices and enough vertical space set stems down for the middle voice
							if (i != 0 && i + 2 == st_v.length) {
								if (st_v[i].ymn - cfmt.stemheight > st_v[i + 1].ymx) {
									s.multi = -1;
								}
								
								// Special case for unison
								t = s.ts_next;
								if (s.ts_prev
									&& s.ts_prev.time == s.time
									&& s.ts_prev.st == s.st
									&& s.notes[s.nhd].pit == s.ts_prev.notes[0].pit
									&& s.beam_st
									&& s.beam_end
									&& (!t
										|| t.st != s.st
										|| t.time != s.time)) {
									s.multi = -1;
								}
							}
						}
					}
					while (s && s.type == C.BAR) { 
						s = s.ts_next;
					}
				}
			}
			
			/* -- adjust the offset of the rests when many voices -- */
			/* this function is called only once per tune */
			private function set_rest_offset() : *  {
				var	s, s2, v, end_time, not_alone, v_s, y, ymax, ymin,
				shift, dots, dx,
				v_s_tb = [],
					sy = cur_sy
				
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.invis)
						continue
					if (s.type == C.STAVES)
						sy = s.sy
					if (!s.dur)
						continue
					v_s = v_s_tb[s.v]
					if (!v_s) {
						v_s = {}
						v_s_tb[s.v] = v_s
					}
					v_s.s = s;
					v_s.st = s.st;
					v_s.end_time = s.time + s.dur
					if (s.type != C.REST)
						continue
					
					/* check if clash with previous symbols */
					ymin = -127;
					ymax = 127;
					not_alone = dots = false
					for (v = 0; v <= v_s_tb.length; v++) { 
						v_s = v_s_tb[v]
						if (!v_s || !v_s.s
							|| v_s.st != s.st
							|| v == s.v)
							continue
						if (v_s.end_time <= s.time)
							continue
						not_alone = true;
						s2 = v_s.s
						if (sy.voices[v].range < sy.voices[s.v].range) {
							if (s2.time == s.time) {
								if (s2.ymn < ymax) {
									ymax = s2.ymn
									if (s2.dots)
										dots = true
								}
							} else {
								if (s2.y < ymax)
									ymax = s2.y
							}
						} else {
							if (s2.time == s.time) {
								if (s2.ymx > ymin) {
									ymin = s2.ymx
									if (s2.dots)
										dots = true
								}
							} else {
								if (s2.y > ymin)
									ymin = s2.y
							}
						}
					}
					
					/* check if clash with next symbols */
					end_time = s.time + s.dur
					for (s2 = s.ts_next; s2; s2 = s2.ts_next) { 
						if (s2.time >= end_time)
							break
						if (s2.st != s.st
							//			 || (s2.type != C.NOTE && s2.type != C.REST)
							|| !s2.dur
							|| s2.invis)
							continue
						not_alone = true
						if (sy.voices[s2.v].range < sy.voices[s.v].range) {
							if (s2.time == s.time) {
								if (s2.ymn < ymax) {
									ymax = s2.ymn
									if (s2.dots)
										dots = true
								}
							} else {
								if (s2.y < ymax)
									ymax = s2.y
							}
						} else {
							if (s2.time == s.time) {
								if (s2.ymx > ymin) {
									ymin = s2.ymx
									if (s2.dots)
										dots = true
								}
							} else {
								if (s2.y > ymin)
									ymin = s2.y
							}
						}
					}
					if (!not_alone) {
						s.y = 12;
						s.ymx = 24;
						s.ymn = 0
						continue
					}
					if (ymax == 127 && s.y < 12) {
						shift = 12 - s.y
						s.y += shift;
						s.ymx += shift;
						s.ymn += shift
					}
					if (ymin == -127 && s.y > 12) {
						shift = s.y - 12
						s.y -= shift;
						s.ymx -= shift;
						s.ymn -= shift
					}
					shift = ymax - s.ymx
					if (shift < 0) {
						shift = Math.ceil(-shift / 6) * 6
						if (s.ymn - shift >= ymin) {
							s.y -= shift;
							s.ymx -= shift;
							s.ymn -= shift
							continue
						}
						dx = dots ? 15 : 10;
						s.notes[0].shhd = dx;
						s.xmx = dx
						continue
					}
					shift = ymin - s.ymn
					if (shift > 0) {
						shift = Math.ceil(shift / 6) * 6
						if (s.ymx + shift <= ymax) {
							s.y += shift;
							s.ymx += shift;
							s.ymn += shift
							continue
						}
						dx = dots ? 15 : 10;
						s.notes[0].shhd = dx;
						s.xmx = dx
						continue
					}
				}
			}
			
			/* -- create a starting symbol -- */
			private function new_sym(type, p_voice,
							 last_s) : *  {	/* symbol at same time */
				var s = {
					type: type,
					fname: last_s.fname,
						//		istart: last_s.istart,
						//		iend: last_s.iend,
						v: p_voice.v,
						p_v: p_voice,
						st: p_voice.st,
						time: last_s.time,
						next: p_voice.last_sym.next
				}
				if (s.next)
					s.next.prev = s;
				p_voice.last_sym.next = s;
				s.prev = p_voice.last_sym;
				p_voice.last_sym = s;
				
				lktsym(s, last_s)
				if (s.ts_prev.type != type)
					s.seqst = true
				if (last_s.type == type && s.v != last_s.v) {
					delete last_s.seqst;
					last_s.shrink = 0
				}
				return s
			}
			
			/* -- init the symbols at start of a music line -- */
			private function init_music_line() : *  {
				var	p_voice, s, s2, s3, last_s, v, st, shr, shrmx,
				nv = voice_tb.length
				
				/* initialize the voices */
				for (v = 0; v < nv; v++) { 
					if (cur_sy.voices[v].range < 0)
						continue
					p_voice = voice_tb[v];
					p_voice.second = cur_sy.voices[v].second;
					p_voice.last_sym = p_voice.sym;
					
					/* move the voice to a printed staff */
					st = cur_sy.voices[v].st
					while (st < nstaff && !cur_sy.st_print[st]) { 
						st++;
					}
					p_voice.st = st
				}
				
				/* add a clef at start of the main voices */
				last_s = tsfirst
				while (last_s.type == C.CLEF) { 		/* move the starting clefs */
					v = last_s.v
					if (cur_sy.voices[v].range >= 0
						&& !cur_sy.voices[v].second) {
						delete last_s.clef_small;	/* normal clef */
						p_voice = last_s.p_v;
						p_voice.last_sym = p_voice.sym = last_s
					}
					last_s = last_s.ts_next
				}
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v]
					if (p_voice.sym && p_voice.sym.type == C.CLEF)
						continue
					if (cur_sy.voices[v].range < 0
						|| (cur_sy.voices[v].second
							&& !p_voice.bar_start))	// needed for correct linkage
						continue
					st = cur_sy.voices[v].st
					if (!staff_tb[st]
						|| !staff_tb[st].clef)
						continue
					s = clone(staff_tb[st].clef);
					s.v = v;
					s.p_v = p_voice;
					s.st = st;
					s.time = tsfirst.time;
					s.prev = null;
					s.next = p_voice.sym
					if (s.next)
						s.next.prev = s;
					p_voice.sym = s;
					p_voice.last_sym = s;
					s.ts_next = last_s;
					if (last_s)
						s.ts_prev = last_s.ts_prev
					else
						s.ts_prev = null
					if (!s.ts_prev) {
						tsfirst = s;
						s.seqst = true
					} else {
						s.ts_prev.ts_next = s
						delete s.seqst
					}
					if (last_s) {
						last_s.ts_prev = s
						if (last_s.type == C.CLEF)
							delete last_s.seqst
					}
					delete s.clef_small;
					s.second = cur_sy.voices[v].second
					// (fixme: needed for sample5 X:3 Fugue & staffnonote.xhtml)
					if (!cur_sy.st_print[st])
						s.invis = true
				}
				
				/* add keysig */
				for (v = 0; v < nv; v++) { 
					if (cur_sy.voices[v].range < 0
						|| cur_sy.voices[v].second
						|| !cur_sy.st_print[cur_sy.voices[v].st])
						continue
					p_voice = voice_tb[v]
					if (last_s && last_s.v == v && last_s.type == C.KEY) {
						p_voice.last_sym = last_s;
						last_s.k_old_sf = last_s.k_sf;	// no key cancel
						last_s = last_s.ts_next
						continue
					}
					s2 = p_voice.key
					if (s2.k_sf || s2.k_a_acc) {
						s = new_sym(C.KEY, p_voice, last_s);
						s.k_sf = s2.k_sf;
						s.k_old_sf = s2.k_sf;	// no key cancel
						s.k_none = s2.k_none;
						s.k_a_acc = s2.k_a_acc;
						s.istart = s2.istart;
						s.iend = s2.iend
						if (s2.k_bagpipe) {
							s.k_bagpipe = s2.k_bagpipe
							if (s.k_bagpipe == 'p')
								s.k_old_sf = 3	/* "A" -> "D" => G natural */
						}
					}
				}
				
				/* add time signature (meter) if needed */
				if (insert_meter & 1) {
					for (v = 0; v < nv; v++) { 
						p_voice = voice_tb[v];
						s2 = p_voice.meter
						if (cur_sy.voices[v].range < 0
							|| cur_sy.voices[v].second
							|| !cur_sy.st_print[cur_sy.voices[v].st]
							|| s2.a_meter.length == 0)
							continue
						if (last_s && last_s.v == v && last_s.type == C.METER) {
							p_voice.last_sym = last_s;
							last_s = last_s.ts_next
							continue
						}
						s = new_sym(C.METER, p_voice, last_s);
						s.istart = s2.istart;
						s.iend = s2.iend;
						s.wmeasure = s2.wmeasure;
						s.a_meter = s2.a_meter
					}
					insert_meter &= ~1		// no meter any more
				}
				
				/* add bar if needed (for repeat bracket) */
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v];
					s2 = p_voice.bar_start;
					p_voice.bar_start = null
					
					// if bar already, keep it in sequence
					if (last_s && last_s.v == v && last_s.type == C.BAR) {
						p_voice.last_sym = last_s;
						last_s = last_s.ts_next
						continue
					}
					
					if (!s2)
						continue
					if (cur_sy.voices[v].range < 0
						|| !cur_sy.st_print[cur_sy.voices[v].st])
						continue
					
					s2.next = p_voice.last_sym.next
					if (s2.next)
						s2.next.prev = s2;
					p_voice.last_sym.next = s2;
					s2.prev = p_voice.last_sym;
					p_voice.last_sym = s2;
					lktsym(s2, last_s);
					s2.time = tsfirst.time
					if (s2.ts_prev.type != s2.type)
						s2.seqst = true;
					if (last_s && last_s.type == s2.type && s2.v != last_s.v) {
						delete last_s.seqst;
						//			last_s.shrink = 0
					}
				}
				
				/* if initialization of a new music line, compute the spacing,
				* including the first (old) sequence */
				self.set_pitch(last_s)
				for (s = last_s; s; s = s.ts_next) { 
					if (s.seqst) {
						for (s = s.ts_next; s; s = s.ts_next) { 
							if (s.seqst) {
								break;
							}
						}
						break;
					}
				}
				
				// set the spacing of the added symbols
				while (last_s) { 
					if (last_s.seqst) {
						do { 
							last_s = last_s.ts_next
						} while (last_s && !last_s.seqst);
						break
					}
					last_s = last_s.ts_next
				}
				
				s = tsfirst
				while (1) { 
					s2 = s;
					shrmx = 0
					do { 
						self.set_width(s);
						shr = s.wl
						for (s3 = s.prev; s3; s3 = s3.prev) { 
							if (w_tb[s3.type] != 0) {
								shr += s3.wr
								break
							}
						}
						if (shr > shrmx)
							shrmx = shr;
						s = s.ts_next
					} while (s != last_s && !s.seqst);
					s2.shrink = shrmx;
					s2.space = 0
					if (s == last_s)
						break
				}
			}
			
			/* -- set a pitch in all symbols and the start/stop of the beams -- */
			private function set_words(p_voice) : *  {
				var	s, s2, nflags, lastnote,
				start_flag = true,
					pitch = 127			/* no note */
				
				for (s = p_voice.sym; s; s = s.next) { 
					if (s.type == C.NOTE) {
						pitch = s.notes[0].pit
						break
					}
				}
				for (s = p_voice.sym; s; s = s.next) { 
					switch (s.type) {
						case C.MREST:
							start_flag = true
							break
						case C.BAR:
							s.bar_type = bar_cnv(s.bar_type)
							if (!s.beam_on)
								start_flag = true
							if (!s.next && s.prev
								//			 && s.prev.type == C.NOTE
								//			 && s.prev.dur >= C.BLEN * 2)
								&& s.prev.head == C.OVALBARS)
								s.prev.head = C.SQUARE
							break
						case C.NOTE:
						case C.REST:
							if (s.trem2)
								break
							nflags = s.nflags
							
							if (s.ntrem)
								nflags += s.ntrem
							if (s.type == C.REST && s.beam_end) {
								s.beam_end = false;
								start_flag = true
							}
							if (start_flag
								|| nflags <= 0) {
								if (lastnote) {
									lastnote.beam_end = true;
									lastnote = null
								}
								if (nflags <= 0) {
									s.beam_st = true;
									s.beam_end = true
								} else if (s.type == C.NOTE) {
									s.beam_st = true;
									start_flag = false
								}
							}
							if (s.beam_end)
								start_flag = true
							if (s.type == C.NOTE)
								lastnote = s
							break
					}
					if (s.type == C.NOTE) {
						if (s.nhd != 0) {
							sort_pitch (s);
						}
						pitch = s.notes[0].pit
						//			if (s.prev
						//			 && s.prev.type != C.NOTE) {
						//				s.prev.notes[0].pit = (s.prev.notes[0].pit
						//						    + pitch) / 2
						for (s2 = s.prev; s2; s2 = s2.prev) { 
							if (s2.type != C.REST)
								break
							s2.notes[0].pit = pitch
						}
					} else {
						if (!s.notes) {
							s.notes = []
							s.notes[0] = {}
							s.nhd = 0
						}
						s.notes[0].pit = pitch
					}
				}
				if (lastnote)
					lastnote.beam_end = true
			}
			
			/* -- set the end of the repeat sequences -- */
			private function set_rb(p_voice) : *  {
				var	s2, mx, n,
				s = p_voice.sym
				
				while (s) { 
					if (s.type != C.BAR || !s.rbstart || s.norepbra) {
						s = s.next
						continue
					}
					
					mx = cfmt.rbmax
					
					/* if 1st repeat sequence, compute the bracket length */
					if (s.text && s.text[0] == '1') {
						n = 0;
						s2 = null
						for (s = s.next; s; s = s.next) { 
							if (s.type != C.BAR)
								continue
							n++
							if (s.rbstop) {
								if (n <= cfmt.rbmax) {
									mx = n;
									s2 = null
								}
								break
							}
							if (n == cfmt.rbmin)
								s2 = s
						}
						if (s2) {
							s2.rbstop = 1;
							mx = cfmt.rbmin
						}
					}
					while (s) { 
						
						/* check repbra shifts (:| | |2 in 2nd staves) */
						if (s.rbstart != 2) {
							s = s.next
							if (!s)
								break
							if (s.rbstart != 2) {
								s = s.next
								if (!s)
									break
								if (s.rbstart != 2)
									break
							}
						}
						n = 0;
						s2 = null
						for (s = s.next; s; s = s.next) { 
							if (s.type != C.BAR)
								continue
							n++
							if (s.rbstop)
							break
							if (!s.next)
								s.rbstop = 2	// right repeat with end
							else if (n == mx)
								s.rbstop = 1	// right repeat without end
						}
					}
				}
			}
			
			
			private var delpit : Array = [0, -7, -14, 0];
			
			/**
			 * Initialize the generator
			 * This function is called only once per tune.
			 */
			private function set_global() : void {
				var p_voice : Object;
				var st : int; 
				var v : int; 
				var nv : int; 
				var sy : Object;
				
				// Get the max number of staves
				sy = cur_sy;
				st = sy.nstaff;
				while (true) { 
					sy = sy.next;
					if (!sy) {
						break;
					}
					if (sy.nstaff > st) {
						st = sy.nstaff;
					}
				}
				nstaff = st;
				
				// Set the pitches, the words (beams) and the repeat brackets
				nv = voice_tb.length;
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v];
					set_words (p_voice);
					set_rb (p_voice);
				}
				
				// Set the staff of the floating voices
				set_float ();
				
				// Set the clefs and adjust the pitches of all symbol
				set_clefs ();
				self.set_pitch (null);
			}
			
			/**
			 * Returns the left indentation of the staves.
			 * Among others, this is based on voice name length
			 */
			private function set_indent (first = null) : *  {
				var	st : int; 
				var v : int; 
				var strSize : Array;
				var w : Number; 
				var maxw : Number = 0;
				var p_voice : Object; 
				var p : String; 
				var i : int; 
				var j : int; 
				var font : Object;
				var nv  : int = voice_tb.length;
				
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v];
					if (cur_sy.voices[v].range < 0) {
						continue;
					}
					// Ciacob ??? This value is never used
					st = cur_sy.voices[v].st;
					p = ((first || p_voice.new_name) && p_voice.nm)? p_voice.nm : p_voice.snm;
					if (!p) {
						continue;
					}
					if (p.indexOf(CommonStrings.BROKEN_VERTICAL_BAR) != -1) {
						p = p.split (CommonStrings.BROKEN_VERTICAL_BAR).pop();
					}
					if (!font) {
						font = get_font("voice");
						set_font(font);
					}
					i = 0;
					while (true) { 
						j = p.indexOf("\\n", i);
						if (j < 0) {
							strSize = strwh(p.slice(i));
						}
						else {
							strSize = strwh(p.slice(i, j));
						}
						w = strSize[0] as Number;
						if (w > maxw) {
							maxw = w;
						}
						if (j < 0) {
							break;
						}
						i = j + 1;
					}
				}
				if (font) {
					maxw += 4 * cwid(' ') * font.swfac;
				}
				
				// (width of left bar)
				w = .5;
				for (st = 0; st <= cur_sy.nstaff; st++) { 
					if (cur_sy.staves[st].flags & (OPEN_BRACE2 | OPEN_BRACKET2)) {
						w = 12;
						break;
					}
					if (cur_sy.staves[st].flags & (OPEN_BRACE | OPEN_BRACKET)) {
						w = 6;
					}
				}
				maxw += w;
				
				// if %%indent
				if (first) {
					maxw += cfmt.indent;
				}
				return maxw;
			}
			
			/**
			 * Decides on beams and stem directions.
			 * This routine is called only once per tune.
			 */
			private function set_beams (sym) : void {
				var	s : Object; 
				var g : Object; 
				var beam : Boolean; 
				var s_opp : Object; 
				var n : Number; 
				var m : int; 
				var mid_p : Number; 
				var pu : Number; 
				var pd : Number;
				var laststem : int = -1;
				
				for (s = sym; s; s = s.next) { 
					if (s.type != C.NOTE) {
						if (s.type != C.GRACE) {
							continue;
						}
						g = s.extra;
						
						// Opposite gstem direction
						if (g.stem == 2) {
							s_opp = s;
							continue;
						}
						if (!s.stem && (s.stem = s.multi) == 0) {
							s.stem = 1;
						}
						for (; g; g = g.next) { 
							g.stem = s.stem;
							g.multi = s.multi;
						}
						continue;
					}
					
					// If not explicitly set and alone on the staff
					if (!s.stem && (s.stem = s.multi) == 0) {
						mid_p = s.mid / 3 + 18;
						
						// Notes in a beam have the same stem direction
						if (beam) {
							s.stem = laststem;
						} 
						
						// Beam start
						else if (s.beam_st && !s.beam_end) {
							beam = true;
							pu = s.notes[s.nhd].pit;
							pd = s.notes[0].pit;
							for (g = s.next; g; g = g.next) { 
								if (g.type != C.NOTE) {
									continue;
								}
								if (g.stem || g.multi) {
									s.stem = g.stem || g.multi;
									break;
								}
								if (g.notes[g.nhd].pit > pu) {
									pu = g.notes[g.nhd].pit;
								}
								if (g.notes[0].pit < pd) {
									pd = g.notes[0].pit;
								}
								if (g.beam_end) {
									break;
								}
							}
							if (g.beam_end) {
								if ((pu + pd) / 2 < mid_p) {
									s.stem = 1;
								} else if ((pu + pd) / 2 > mid_p) {
									s.stem = -1;
								} else {
									
									// FIXME: equal: check all notes of the beam
									if (cfmt.bstemdown) {
										s.stem = -1;
									}
								}
							}
							if (!s.stem) {
								s.stem = laststem;
							}
						}
						
						// No beam
						else {
							n = (s.notes[s.nhd].pit + s.notes[0].pit) / 2;
							if (n == mid_p) {
								n = 0;
								for (m = 0; m <= s.nhd; m++) { 
									n += s.notes[m].pit;
								}
								n /= (s.nhd + 1);
							}
							if (n < mid_p) {
								s.stem = 1;
							}
							else if (n > mid_p) {
								s.stem = -1;
							}
							else if (cfmt.bstemdown) {
								s.stem = -1;
							}
							else {
								s.stem = laststem;
							}
						}
					} 
					
					// Stem set by set_stem_dir
					else {
						if (s.beam_st && !s.beam_end) {
							beam = true;
						}
					}
					if (s.beam_end) {
						beam = false;
					}
					laststem = s.stem;
					
					// Opposite gstem direction
					if (s_opp) {
						for (g = s_opp.extra; g; g = g.next) { 
							g.stem = -laststem;
						}
						s_opp.stem = -laststem;
						s_opp = null;
					}
				}
			}
			
			// check if there may be one head for unison when voice overlap
			private function same_head(s1, s2) : *  {
				var i1, i2, l1, l2, head, i11, i12, i21, i22, sh1, sh2
				
				if (s1.shiftunison && s1.shiftunison >= 3)
					return false
				if ((l1 = s1.dur) >= C.BLEN)
					return false
				if ((l2 = s2.dur) >= C.BLEN)
					return false
				if (s1.stemless && s2.stemless)
					return false
				if (s1.dots != s2.dots) {
					if ((s1.shiftunison && (s1.shiftunison & 1))
						|| s1.dots * s2.dots != 0)
						return false
				}
				if (s1.stem * s2.stem > 0)
					return false
				
				/* check if a common unison */
				i1 = i2 = 0
				if (s1.notes[0].pit > s2.notes[0].pit) {
					//fixme:dots
					if (s1.stem < 0)
						return false
					while (s2.notes[i2].pit != s1.notes[0].pit) { 
						if (++i2 > s2.nhd)
							return false
					}
				} else if (s1.notes[0].pit < s2.notes[0].pit) {
					//fixme:dots
					if (s2.stem < 0)
						return false
					while (s2.notes[0].pit != s1.notes[i1].pit) { 
						if (++i1 > s1.nhd)
							return false
					}
				}
				if (s2.notes[i2].acc != s1.notes[i1].acc)
					return false;
				i11 = i1;
				i21 = i2;
				sh1 = s1.notes[i1].shhd;
				sh2 = s2.notes[i2].shhd
				do { 
					//fixme:dots
					i1++;
					i2++
					if (i1 > s1.nhd) {
						//fixme:dots
						//			if (s1.notes[0].pit < s2.notes[0].pit)
						//				return false
						break
					}
					if (i2 > s2.nhd) {
						//fixme:dots
						//			if (s1.notes[0].pit > s2.notes[0].pit)
						//				return false
						break
					}
					if (s2.notes[i2].acc != s1.notes[i1].acc)
						return false
					if (sh1 < s1.notes[i1].shhd)
						sh1 = s1.notes[i1].shhd
					if (sh2 < s2.notes[i2].shhd)
						sh2 = s2.notes[i2].shhd
				} while (s2.notes[i2].pit == s1.notes[i1].pit);
				//fixme:dots
				if (i1 <= s1.nhd) {
					if (i2 <= s2.nhd)
						return false
					if (s2.stem > 0)
						return false
				} else if (i2 <= s2.nhd) {
					if (s1.stem > 0)
						return false
				}
				i12 = i1;
				i22 = i2;
				
				head = 0
				if (l1 != l2) {
					if (l1 < l2) {
						l1 = l2;
						l2 = s1.dur
					}
					if (l1 < C.BLEN / 2) {
						if (s2.dots > 0)
							head = 2
						else if (s1.dots > 0)
							head = 1
					} else if (l2 < C.BLEN / 4) {	/* (l1 >= C.BLEN / 2) */
						//			if ((s1.shiftunison && s1.shiftunison == 2)
						//			 || s1.dots != s2.dots)
						if (s1.shiftunison && (s1.shiftunison & 2))
							return false
						head = s2.dur >= C.BLEN / 2 ? 2 : 1
					} else {
						return false
					}
				}
				if (head == 0)
					head = s1.p_v.scale < s2.p_v.scale ? 2 : 1
				if (head == 1) {
					for (i2 = i21; i2 < i22; i2++) { 
						s2.notes[i2].invis = true
						delete s2.notes[i2].acc
					}
					for (i2 = 0; i2 <= s2.nhd; i2++) { 
						s2.notes[i2].shhd += sh1;
					}
				} else {
					for (i1 = i11; i1 < i12; i1++) { 
						s1.notes[i1].invis = true
						delete s1.notes[i1].acc
					}
					for (i1 = 0; i1 <= s1.nhd; i1++) { 
						s1.notes[i1].shhd += sh2;
					}
				}
				return true
			}
			
			/* handle unison with different accidentals */
			private function unison_acc(s1, s2, i1, i2) : *  {
				var m, d
				
				if (!s2.notes[i2].acc) {
					d = w_note[s2.head] * 2 + s2.xmx + s1.notes[i1].shac + 2
					if (s1.notes[i1].micro)
						d += 2
					if (s2.dots)
						d += 6
					for (m = 0; m <= s1.nhd; m++) { 
						s1.notes[m].shhd += d;
						s1.notes[m].shac -= d
					}
					s1.xmx += d
				} else {
					d = w_note[s1.head] * 2 + s1.xmx + s2.notes[i2].shac + 2
					if (s2.notes[i2].micro)
						d += 2
					if (s1.dots)
						d += 6
					for (m = 0; m <= s2.nhd; m++) { 
						s2.notes[m].shhd += d;
						s2.notes[m].shac -= d
					}
					s2.xmx += d
				}
			}
			
			private var MAXPIT = 48 * 2
			
			/* set the left space of a note/chord */
			private function set_left(s) : *  {
				var	m, i, j, shift,
				w_base = w_note[s.head],
					w = w_base,
					left = []
				
				for (i = 0; i < MAXPIT; i++) { 
					left.push(-100);
				}
				
				/* stem */
				if (s.nflags > -2) {
					if (s.stem > 0) {
						w = -w;
						i = s.notes[0].pit * 2;
						j = (Math.ceil((s.ymx - 2) / 3) + 18) * 2
					} else {
						i = (Math.ceil((s.ymn + 2) / 3) + 18) * 2;
						j = s.notes[s.nhd].pit * 2
					}
					if (i < 0)
						i = 0
					if (j >= MAXPIT)
						j = MAXPIT - 1
					while (i <= j) { 
						left[i++] = w;
					}
				}
				
				/* notes */
				shift = s.notes[s.stem > 0 ? 0 : s.nhd].shhd;	/* previous shift */
				for (m = 0; m <= s.nhd; m++) { 
					w = -s.notes[m].shhd + w_base + shift;
					i = s.notes[m].pit * 2
					if (i < 0)
						i = 0
					else if (i >= MAXPIT - 1)
						i = MAXPIT - 2
					if (w > left[i])
						left[i] = w
					if (s.head != C.SQUARE)
						w -= 1
					if (w > left[i - 1])
						left[i - 1] = w
					if (w > left[i + 1])
						left[i + 1] = w
				}
				
				return left
			}
			
			/* set the right space of a note/chord */
			private function set_right(s) : *  {
				var	m, i, j, k, shift,
				w_base = w_note[s.head],
					w = w_base,
					flags = s.nflags > 0 && s.beam_st && s.beam_end,
					right = []
				
				for (i = 0; i < MAXPIT; i++) { 
					right.push(-100);
				}
				
				/* stem and flags */
				if (s.nflags > -2) {
					if (s.stem < 0) {
						w = -w;
						i = (Math.ceil((s.ymn + 2) / 3) + 18) * 2;
						j = s.notes[s.nhd].pit * 2;
						k = i + 4
					} else {
						i = s.notes[0].pit * 2;
						j = (Math.ceil((s.ymx - 2) / 3) + 18) * 2
					}
					if (i < 0)
						i = 0
					if (j > MAXPIT)
						j = MAXPIT
					while (i < j) { 
						right[i++] = w;
					}
				}
				
				if (flags) {
					if (s.stem > 0) {
						if (s.xmx == 0)
							i = s.notes[s.nhd].pit * 2
						else
							i = s.notes[0].pit * 2;
						i += 4
						if (i < 0)
							i = 0
						for (; i < MAXPIT && i <= j - 4; i++) { 
							right[i] = 11;
						}
					} else {
						i = k
						if (i < 0)
							i = 0
						for (; i < MAXPIT && i <= s.notes[0].pit * 2 - 4; i++) { 
							right[i] = 3.5;
						}
					}
				}
				
				/* notes */
				shift = s.notes[s.stem > 0 ? 0 : s.nhd].shhd	/* previous shift */
				for (m = 0; m <= s.nhd; m++) { 
					w = s.notes[m].shhd + w_base - shift;
					i = s.notes[m].pit * 2
					if (i < 0)
						i = 0
					else if (i >= MAXPIT - 1)
						i = MAXPIT - 2
					if (w > right[i])
						right[i] = w
					if (s.head != C.SQUARE)
						w -= 1
					if (w > right[i - 1])
						right[i - 1] = w
					if (w > right[i + 1])
						right[i + 1] = w
				}
				
				return right
			}
			
			/* -- shift the notes horizontally when voices overlap -- */
			/* this routine is called only once per tune */
			private function set_overlap() : *  {
				var	s, s1, s2, s3, i, i1, i2, m, sd, t, dp,
				d, d2, dr, dr2, dx,
				left1, right1, left2, right2, right3, pl, pr
				
				// invert the voices
				function v_invert() :*  {
					s1 = s2;
					s2 = s;
					d = d2;
					pl = left1;
					pr = right1;
					dr2 = dr
				}
				
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.type != C.NOTE
						|| s.invis)
						continue
					
					/* treat the stem on two staves with different directions */
					if (s.xstem
						&& s.ts_prev.stem < 0) {
						for (m = 0; m <= s.nhd; m++) { 
							s.notes[m].shhd -= 7;		// stem_xoff
							s.notes[m].shac += 16
						}
					}
					
					/* search the next note at the same time on the same staff */
					s2 = s
					while (1) { 
						s2 = s2.ts_next
						if (!s2)
							break
						if (s2.time != s.time) {
							s2 = null
							break
						}
						if (s2.type == C.NOTE
							&& !s2.invis
							&& s2.st == s.st)
							break
					}
					if (!s2)
						continue
					s1 = s
					
					/* set the dot vertical offset */
					if (cur_sy.voices[s1.v].range < cur_sy.voices[s2.v].range)
						s2.dot_low = true
					else
						s1.dot_low = true
					
					/* no shift if no overlap */
					if (s1.ymn > s2.ymx
						|| s1.ymx < s2.ymn)
						continue
					
					if (same_head(s1, s2))
						continue
					
					/* compute the minimum space for 's1 s2' and 's2 s1' */
					right1 = set_right(s1);
					left2 = set_left(s2);
					
					s3 = s1.ts_prev
					if (s3 && s3.time == s1.time
						&& s3.st == s1.st && s3.type == C.NOTE && !s3.invis) {
						right3 = set_right(s3)
						for (i = 0; i < MAXPIT; i++) { 
							if (right3[i] > right1[i])
								right1[i] = right3[i]
						}
					} else {
						s3 = null
					}
					d = -10
					for (i = 0; i < MAXPIT; i++) { 
						if (left2[i] + right1[i] > d)
							d = left2[i] + right1[i]
					}
					if (d < -3) {			// no clash if no dots clash
						if (!s1.dots || !s2.dots
							|| !s2.dot_low
							|| s1.stem > 0 || s2.stem < 0
							|| s1.notes[s1.nhd].pit + 2 != s2.notes[0].pit
							|| (s2.notes[0].pit & 1))
							continue
					}
					
					right2 = set_right(s2);
					left1 = set_left(s1)
					if (s3) {
						right3 = set_left(s3)
						for (i = 0; i < MAXPIT; i++) { 
							if (right3[i] > left1[i])
								left1[i] = right3[i]
						}
					}
					d2 = dr = dr2 = -100
					for (i = 0; i < MAXPIT; i++) { 
						if (left1[i] + right2[i] > d2)
							d2 = left1[i] + right2[i]
						if (right2[i] > dr2)
							dr2 = right2[i]
						if (right1[i] > dr)
							dr = right1[i]
					}
					
					/* check for unison with different accidentals
					* and clash of dots */
					t = 0;
					i1 = s1.nhd;
					i2 = s2.nhd
					while (1) { 
						dp = s1.notes[i1].pit - s2.notes[i2].pit
						switch (dp) {
							case 0:
								if (s1.notes[i1].acc != s2.notes[i2].acc) {
									t = -1
									break
								}
								if (s2.notes[i2].acc)
									s2.notes[i2].acc = 0
								if (s1.dots && s2.dots
									&& (s1.notes[i1].pit & 1))
									t = 1
								break
							case -1:
								//fixme:dots++
								//				if (s1.dots && s2.dots)
								//					t = 1
								//++--
								if (s1.dots && s2.dots) {
									if (s1.notes[i1].pit & 1) {
										s1.dot_low = false;
										s2.dot_low = false
									} else {
										s1.dot_low = true;
										s2.dot_low = true
									}
								}
								//fixme:dots--
								break
							case -2:
								if (s1.dots && s2.dots
									&& !(s1.notes[i1].pit & 1)) {
									//fixme:dots++
									//					t = 1
									//++--
									s1.dot_low = false;
									s2.dot_low = false
									//fixme:dots--
									break
								}
								break
						}
						if (t < 0)
							break
						if (dp >= 0) {
							if (--i1 < 0)
								break
						}
						if (dp <= 0) {
							if (--i2 < 0)
								break
						}
					}
					
					if (t < 0) {	/* unison and different accidentals */
						unison_acc(s1, s2, i1, i2)
						continue
					}
					
					sd = 0;
					if (s1.dots) {
						if (s2.dots) {
							if (!t)			/* if no dot clash */
								sd = 1		/* align the dots */
							//fixme:dots
						}
					} else if (s2.dots) {
						if (d2 + dr < d + dr2)
							sd = 1		/* align the dots */
						//fixme:dots
					}
					pl = left2;
					pr = right2
					if (!s3 && d2 + dr < d + dr2)
						v_invert()
					d += 3
					if (d < 0)
						d = 0;			// (not return!)
					
					/* handle the previous shift */
					m = s1.stem >= 0 ? 0 : s1.nhd;
					d += s1.notes[m].shhd;
					m = s2.stem >= 0 ? 0 : s2.nhd;
					d -= s2.notes[m].shhd
					
					/*
					* room for the dots
					* - if the dots of v1 don't shift, adjust the shift of v2
					* - otherwise, align the dots and shift them if clash
					*/
					if (s1.dots) {
						dx = 7.7 + s1.xmx +		// x 1st dot
							3.5 * s1.dots - 3.5 +	// x last dot
							3;			// some space
						if (!sd) {
							d2 = -100;
							for (i1 = 0; i1 <= s1.nhd; i1++) { 
								i = s1.notes[i1].pit
								if (!(i & 1)) {
									if (!s1.dot_low)
										i++
									else
									i--
								}
								i *= 2
								if (i < 1)
									i = 1
								else if (i >= MAXPIT - 1)
									i = MAXPIT - 2
								if (pl[i] > d2)
									d2 = pl[i]
								if (pl[i - 1] + 1 > d2)
									d2 = pl[i - 1] + 1
								if (pl[i + 1] + 1 > d2)
									d2 = pl[i + 1] + 1
							}
							if (dx + d2 + 2 > d)
								d = dx + d2 + 2
						} else {
							if (dx < d + dr2 + s2.xmx) {
								d2 = 0
								for (i1 = 0; i1 <= s1.nhd; i1++) { 
									i = s1.notes[i1].pit
									if (!(i & 1)) {
										if (!s1.dot_low)
											i++
										else
										i--
									}
									i *= 2
									if (i < 1)
										i = 1
									else if (i >= MAXPIT - 1)
										i = MAXPIT - 2
									if (pr[i] > d2)
										d2 = pr[i]
									if (pr[i - 1] + 1 > d2)
										d2 = pr[i - 1] = 1
									if (pr[i + 1] + 1 > d2)
										d2 = pr[i + 1] + 1
								}
								if (d2 > 4.5
									&& 7.7 + s1.xmx + 2 < d + d2 + s2.xmx)
									s2.xmx = d2 + 3 - 7.7
							}
						}
					}
					
					for (m = s2.nhd; m >= 0; m--) { 
						s2.notes[m].shhd += d
						//			if (s2.notes[m].acc
						//			 && s2.notes[m].pit < s1.notes[0].pit - 4)
						//				s2.notes[m].shac -= d
					}
					s2.xmx += d
					if (sd)
						s1.xmx = s2.xmx		// align the dots
				}
			}
			
			/* -- set the stem height -- */
			/* this routine is called only once per tune */
			// (possible hook)
			private function set_stems() : *  {
				var s, s2, g, slen, scale,ymn, ymx, nflags, ymin, ymax
				
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.type != C.NOTE) {
						if (s.type != C.GRACE)
							continue
						ymin = ymax = s.mid
						for (g = s.extra; g; g = g.next) { 
							slen = GSTEM
							if (g.nflags > 1)
								slen += 1.2 * (g.nflags - 1);
							ymn = 3 * (g.notes[0].pit - 18);
							ymx = 3 * (g.notes[g.nhd].pit - 18)
							if (s.stem >= 0) {
								g.y = ymn;
								g.ys = ymx + slen;
								ymx = Math.round(g.ys)
							} else {
								g.y = ymx;
								g.ys = ymn - slen;
								ymn = Math.round(g.ys)
							}
							ymx += 2;
							ymn -= 2
							if (ymn < ymin)
								ymin = ymn
							else if (ymx > ymax)
								ymax = ymx;
							g.ymx = ymx;
							g.ymn = ymn
						}
						s.ymx = ymax;
						s.ymn = ymin
						continue
					}
					
					/* shift notes in chords (need stem direction to do this) */
					set_head_shift(s);
					
					/* if start or end of beam, adjust the number of flags
					* with the other end */
					nflags = s.nflags
					if (s.beam_st && !s.beam_end) {
						if (s.feathered_beam)
							nflags = ++s.nflags
						for (s2 = s.next; /*s2*/; s2 = s2.next) { 
							if (s2.type == C.NOTE) {
								if (s.feathered_beam)
									s2.nflags++
								if (s2.beam_end)
									break
							}
						}
						/*			if (s2) */
						if (s2.nflags > nflags)
							nflags = s2.nflags
					} else if (!s.beam_st && s.beam_end) {
						//fixme: keep the start of beam ?
						for (s2 = s.prev; /*s2*/; s2 = s2.prev) { 
							if (s2.beam_st)
								break
						}
						/*			if (s2) */
						if (s2.nflags > nflags)
							nflags = s2.nflags
					}
					
					/* set height of stem end */
					slen = cfmt.stemheight
					switch (nflags) {
						case 2: slen += 2; break
						case 3:	slen += 5; break
						case 4:	slen += 10; break
						case 5:	slen += 16; break
					}
					if ((scale = s.p_v.scale) != 1)
						slen *= (scale + 1) * .5;
					ymn = 3 * (s.notes[0].pit - 18)
					if (s.nhd > 0) {
						slen -= 2;
						ymx = 3 * (s.notes[s.nhd].pit - 18)
					} else {
						ymx = ymn
					}
					if (s.ntrem)
						slen += 2 * s.ntrem		/* tremolo */
					if (s.stemless) {
						if (s.stem >= 0) {
							s.y = ymn;
							s.ys = ymx
						} else {
							s.ys = ymn;
							s.y = ymx
						}
						if (nflags == -4)		/* if longa */
							ymn -= 6;
						s.ymx = ymx + 4;
						s.ymn = ymn - 4
					} else if (s.stem >= 0) {
						if (nflags >= 2)
							slen -= 1
						if (s.notes[s.nhd].pit > 26
							&& (nflags <= 0
								|| !s.beam_st
								|| !s.beam_end)) {
							slen -= 2
							if (s.notes[s.nhd].pit > 28)
								slen -= 2
						}
						s.y = ymn
						if (s.notes[0].ti1)
							ymn -= 3;
						s.ymn = ymn - 4;
						s.ys = ymx + slen
						if (s.ys < s.mid)
							s.ys = s.mid;
						s.ymx = (s.ys + 2.5) | 0
					} else {			/* stem down */
						if (s.notes[0].pit < 18
							&& (nflags <= 0
								|| !s.beam_st || !s.beam_end)) {
							slen -= 2
							if (s.notes[0].pit < 16)
								slen -= 2
						}
						s.ys = ymn - slen
						if (s.ys > s.mid)
							s.ys = s.mid;
						s.ymn = (s.ys - 2.5) | 0;
						s.y = ymx
						/*fixme:the tie may be lower*/
						if (s.notes[s.nhd].ti1)
							ymx += 3;
						s.ymx = ymx + 4
					}
				}
			}
			
			/* -- split up unsuitable bars at end of staff -- */
			// return true if the bar type has changed
			private function check_bar(s) : *  {
				var	bar_type, i, b1, b2,
				p_voice = s.p_v
				
				/* search the last bar */
				while (s.type == C.CLEF || s.type == C.KEY || s.type == C.METER) { 
					if (s.type == C.METER
						&& s.time > p_voice.sym.time)	/* if not empty voice */
						insert_meter |= 1;	/* meter in the next line */
					s = s.prev
					if (!s)
						return
				}
				if (s.type != C.BAR)
					return
				
				if (s.text != undefined) {		// if repeat bar
					p_voice.bar_start = clone(s);
					p_voice.bar_start.bar_type = ""
					delete s.text
					delete s.a_gch
					//		return
				}
				bar_type = s.bar_type
				if (bar_type == ":")
					return
				if (bar_type.slice(-1) != ':')		// if not left repeat bar
					return
				
				if (!p_voice.bar_start)
					p_voice.bar_start = clone(s)
				if (bar_type[0] != ':') {		// 'xx:' (not ':xx:')
					if (bar_type == "||:") {
						p_voice.bar_start.bar_type = "[|:";
						s.bar_type = "||"
						return true
					}
					p_voice.bar_start.bar_type = bar_type
					if (s.prev && s.prev.type == C.BAR)
						unlksym(s)
					else
						s.bar_type = "|"
					return
				}
				if (bar_type == "||:") {
					p_voice.bar_start.bar_type = "[|:";
					s.bar_type = "||"
					return true
				}
				
				// ':xx:' -> ':x|]' and '[|x:'
				i = 0
				while (bar_type[i] == ':') { 
					i++;
				}
				if (i < bar_type.length) {
					s.bar_type = bar_type.slice(0, i) + '|]';
					i = bar_type.length - 1
					while (bar_type[i] == ':') { 
						i--;
					}
					p_voice.bar_start.bar_type = '[|' + bar_type.slice(i + 1)
				} else {
					i = (bar_type.length / 2) |0;			// '::::' !
					s.bar_type = bar_type.slice(0, i) + '|]';
					p_voice.bar_start.bar_type = '[|' + bar_type.slice(i)
				}
				return true
			}
			
			/* -- move the symbols of an empty staff to the next one -- */
			private function sym_staff_move(st) : *  {
				for (var s = tsfirst; s; s = s.ts_next) { 
					if (s.nl)
						break
					if (s.st == st
						&& s.type != C.CLEF) {
						s.st++;
						s.invis = true
					}
				}
			}
			
			// generate a block symbol
			private var blocks : Array = []		// array of delayed block symbols
			
			private function block_gen(s) : *  {
				switch (s.subtype) {
					case "leftmargin":
					case "rightmargin":
					case "pagescale":
					case "pagewidth":
					case "scale":
					case "staffwidth":
						svg_flush();
						self.set_format(s.subtype, s.param)
						break
					case "ml":
						svg_flush();
						user.img_out(s.text)
						break
					case "newpage":
						blk_flush();
						block.newpage = true;
						blk_out()
						break
					case "sep":
						set_page();
						vskip(s.sk1);
						output += '<path class="stroke" d="M';
						out_sxsy(s.x, ' ', 0);
						output += 'h' + s.l.toFixed(2) + '"/>\n';
						vskip(s.sk2);
						break
					case "text":
						write_text(s.text, s.opt)
						break
					case "title":
						write_title(s.text, true)
						break
					case "vskip":
						vskip(s.sk);
						//		blk_out()
						break
					default:
						error(2, s, 'Block $1 not treated', s.subtype)
						break
				}
			}
			
			/* -- define the start and end of a piece of tune -- */
			/* tsnext becomes the beginning of the next line */
			private function set_piece() : *  {
				var	s, last, p_voice, st, v, nst, nv, tmp,
				non_empty = [],
					non_empty_gl = [],
					sy = cur_sy
				
				function reset_staff(st) :*  {
					var	p_staff = staff_tb[st],
						sy_staff = sy.staves[st]
					
					if (!p_staff)
						p_staff = staff_tb[st] = {}
					p_staff.y = 0;			// staff system not computed yet
					p_staff.stafflines = sy_staff.stafflines;
					p_staff.staffscale = sy_staff.staffscale;
					p_staff.ann_top = p_staff.ann_bot = 0
				} // reset_staff()
				
				// adjust the empty flag of brace systems
				function set_brace() :*  {
					var	st, i, empty_fl,
					n = sy.staves.length
					
					// if a system brace has empty and non empty staves, keep all staves
					for (st = 0; st < n; st++) { 
						if (!(sy.staves[st].flags & (OPEN_BRACE | OPEN_BRACE2)))
							continue
						empty_fl = 0;
						i = st
						while (st < n) { 
							empty_fl |= non_empty[st] ? 1 : 2
							if (sy.staves[st].flags & (CLOSE_BRACE | CLOSE_BRACE2))
								break
							st++
						}
						if (empty_fl == 3) {	// if both empty and not empty staves
							while (i <= st) { 
								non_empty[i] = true;
								non_empty_gl[i++] = true
							}
						}
					}
				} // set_brace()
				
				// set the top and bottom of the staves
				function set_top_bot() :*  {
					var st, p_staff, i, l, hole
					
					for (st = 0; st <= nstaff; st++) { 
						p_staff = staff_tb[st]
						if (!non_empty_gl[st]) {
							p_staff.botbar = p_staff.topbar = 0
							continue
						}
						l = p_staff.stafflines.length;
						p_staff.topbar = 6 * (l - 1)
						
						for (i = 0; i < l - 1; i++)
							if (p_staff.stafflines.charAt(i) != '.') {
								break;
							}
						p_staff.botline = p_staff.botbar = i * 6
						if (i >= l - 2) {		// 0, 1 or 2 lines
							if (p_staff.stafflines.charAt(i) != '.') {
								p_staff.botbar -= 6;
								p_staff.topbar += 6
							} else {		// no line: big bar
								p_staff.botbar -= 12;
								p_staff.topbar += 12
							}
						}
					}
				} // set_top_bot()
				
				/* reset the staves */
				nstaff = nst = sy.nstaff
				for (st = 0; st <= nst; st++) { 
					reset_staff(st);
				}
				
				/*
				* search the next end of line,
				* and mark the empty staves
				*/
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.nl) {
						//fixme: not useful
						//			// delay the next block symbols
						//			while (s && s.type == C.BLOCK) {
						//				blocks.push(s);
						//				unlksym(s);
						//				s = s.ts_next
						//			}
						break
					}
					if (!s.ts_next)
						last = s		// keep the last symbol
					switch (s.type) {
						case C.STAVES:
							set_brace();
							sy.st_print = non_empty;
							sy = s.sy;
							nst = sy.nstaff
							if (nstaff < nst) {
								for (st = nstaff + 1; st <= nst; st++) { 
									reset_staff(st);
								}
								nstaff = nst
							}
							non_empty = []
							continue
							
							// the block symbols will be treated after music line generation
						case C.BLOCK:
							blocks.push(s);
							unlksym(s)
							if (last)
								last = s.ts_prev
							continue
					}
					st = s.st
					if (non_empty[st])
						continue
					switch (s.type) {
						case C.CLEF:
							if (st > nstaff) {	// if clef warning/change for new staff
								staff_tb[st].clef = s;
								unlksym(s)
							}
							break
						case C.BAR:
							if (!sy.staves[st].staffnonote	// default = 1
								|| sy.staves[st].staffnonote <= 1)
								break
							// fall thru
						case C.GRACE:
							non_empty_gl[st] = non_empty[st] = true
							break
						case C.NOTE:
						case C.REST:
						case C.SPACE:
						case C.MREST:
							if (sy.staves[st].staffnonote > 1) {
								non_empty_gl[st] = non_empty[st] = true
							} else if (!s.invis) {
								if (sy.staves[st].staffnonote != 0
									|| s.type == C.NOTE)
									non_empty_gl[st] = non_empty[st] = true
							}
							break
					}
				}
				tsnext = s;
				
				/* set the last empty staves */
				set_brace()
				//	for (st = 0; st <= nstaff; st++)
				//		sy.st_print[st] = non_empty[st];
				sy.st_print = non_empty;
				
				/* define the offsets of the measure bars */
				set_top_bot()
				
				/* move the symbols of the empty staves to the next staff */
				//fixme: could be optimized (use a old->new staff array)
				for (st = 0; st < nstaff; st++) { 
					if (!non_empty_gl[st])
						sym_staff_move(st)
				}
				
				/* let the last empty staff have a full height */
				if (!non_empty_gl[nstaff])
					staff_tb[nstaff].topbar = 0;
				
				/* initialize the music line */
				init_music_line();
				
				// keep the array of the staves to be printed
				gene.st_print = non_empty_gl;
				
				// if not the end of the tune, set the end of the music line
				if (tsnext) {
					s = tsnext;
					delete s.nl;
					last = s.ts_prev;
					last.ts_next = null;
					
					// and the end of the voices
					nv = voice_tb.length
					for (v = 0; v < nv; v++) { 
						p_voice = voice_tb[v]
						if (p_voice.sym
							&& p_voice.sym.time <= tsnext.time) {
							for (s = tsnext.ts_prev; s; s = s.ts_prev) { 
								if (s.v == v) {
									p_voice.s_next = s.next;
									s.next = null;
									if (check_bar(s)) {
										tmp = s.wl;
										self.set_width(s);
										s.shrink += s.wl - tmp
									}
									break
								}
							}
							if (s)
								continue
						}
						p_voice.s_next = p_voice.sym;
						p_voice.sym = null
					}
				}
				
				// if the last symbol is not a bar, add an invisible bar
				if (last.type != C.BAR) {
					s = add_end_bar(last);
					s.space = set_space(s)
					if (s.space < s.shrink
						&& last.type != C.KEY)
						s.space = s.shrink
				}
			}
			
			/* -- position the symbols along the staff -- */
			// (possible hook)
			private function set_sym_glue(width) : *  {
				var	s, g, ll,
				some_grace,
				spf,			// spacing factor
				xmin = 0,		// sigma shrink = minimum spacing
					xx = 0,			// sigma natural spacing
					x = 0,			// sigma expandable elements
					xs = 0,			// sigma unexpandable elements with no space
					xse = 0			// sigma unexpandable elements with space
				
				/* calculate the whole space of the symbols */
				for (s = tsfirst; s; s = s.ts_next) { 
					if (s.type == C.GRACE && !some_grace)
						some_grace = s
					if (s.seqst) {
						xmin += s.shrink
						if (s.space) {
							if (s.space < s.shrink) {
								xse += s.shrink;
								xx += s.shrink
							} else {
								xx += s.space
							}
						} else {
							xs += s.shrink
						}
					}
				}
				
				// can occur when bar alone in a staff system
				if (xx == 0) {
					realwidth = 0
					return
				}
				
				// last line?
				ll = !tsnext ||			// yes
					tsnext.type == C.BLOCK	// no, but followed by %%command
					|| blocks.length	//	(abcm2ps compatibility)
				
				// strong shrink
				if (xmin >= width
					|| xx == xse) {		// no space
					if (xmin > width)
						error(1, s, "Line too much shrunk $1 $2 $3",
							xmin.toFixed(2),
							xx.toFixed(2),
							width.toFixed(2));
					x = 0
					for (s = tsfirst; s; s = s.ts_next) { 
						if (s.seqst)
							x += s.shrink;
						s.x = x
					}
					//		realwidth = width
					spf_last = 0
				} else if ((ll && xx + xs > width * (1 - cfmt.stretchlast))
					|| (!ll && (xx + xs > width || cfmt.stretchstaff))) {
					for (var cnt = 4; --cnt >= 0; ) { 
						spf = (width - xs - xse) / (xx - xse);
						xx = 0;
						xse = 0;
						x = 0
						for (s = tsfirst; s; s = s.ts_next) { 
							if (s.seqst) {
								if (s.space) {
									if (s.space * spf <= s.shrink) {
										xse += s.shrink;
										xx += s.shrink;
										x += s.shrink
									} else {
										xx += s.space;
										x += s.space * spf
									}
								} else {
									x += s.shrink
								}
							}
							s.x = x
						}
						if (Math.abs(x - width) < 0.1)
							break
					}
					spf_last = spf
				} else {			// shorter line
					spf = (width - xs - xse) / xx
					if (spf_last < spf)
						spf = spf_last
					for (s = tsfirst; s; s = s.ts_next) { 
						if (s.seqst)
							x += s.space * spf <= s.shrink ?
								s.shrink : s.space * spf
						s.x = x
					}
				}
				realwidth = x
				
				/* set the x offsets of the grace notes */
				for (s = some_grace; s; s = s.ts_next) { 
					if (s.type != C.GRACE)
						continue
					if (s.gr_shift)
						x = s.prev.x + s.prev.wr
					else
						x = s.x - s.wl
					for (g = s.extra; g; g = g.next) { 
						g.x += x;
					}
				}
				
				// shift the x offset of the invisible bars at start of staff
				for (s = tsfirst; s; s = s.ts_next) { 
					switch (s.type) {
						case C.CLEF:
						case C.KEY:
						case C.METER:
						case C.PART:
							continue
						case C.BAR:
							if (!s.bar_type && !s.text) {	// if not repeat
								s.x = tsfirst.x - tsfirst.wl
								if (s.prev && s.prev.type == C.PART)
									s.prev.x = s.x + 10
							}
							continue
					}
					break
				}
			}
			
			// set the starting symbols of the voices for the new music line
			private function set_sym_line() : *  {
				var	p_voice, s, v,
				nv = voice_tb.length
				
				// set the first symbol of each voice
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v];
					s = p_voice.s_next;		// (set in set_piece)
					p_voice.sym = s
					if (s)
						s.prev = null
				}
			}
			
			/**
			 *  Set the left offset the images.
			 */
			private function set_posx () : void {
				posx = img.lm / cfmt.scale;
			}
			
			/**
			 * Initializes the process of generating a new music line
			 * and outputing the inter-staff blocks (if any).
			 */
			private function gen_init() : void {
				var	s : Object = tsfirst;
				var tim : Number = s.time;
				
				for ( ; s; s = s.ts_next) { 
					if (s.time != tim) {
						set_page();
						return;
					}
					switch (s.type) {
						case C.NOTE:
						case C.REST:
						case C.MREST:
							set_page();
							return;
						default:
							continue;
						case C.STAVES:
							cur_sy = s.sy;
							break;
						case C.BLOCK:
							block_gen(s);
							break;
					}
					unlksym (s);
					if (s.p_v.s_next == s) {
						s.p_v.s_next = s.next;
					}
				}
				
				// No more notes
				tsfirst = null;
			}
			
			/**
			 * Generates the music (possible hook).
			 */
			private function output_music() : void {				
				var v : int;
				var lwidth : Number; 
				var indent : Number; 
				var line_height : Number;
				
				gen_init();
				if (!tsfirst) {
					return;
				}
				set_global();
				
				// If many voices, set the stems direction
				if (voice_tb.length > 1) {
					self.set_stem_dir();
				}
				
				// Decide on beams
				for (v = 0; v < voice_tb.length; v++) { 
					set_beams (voice_tb[v].sym);
				}
				
				// Set the stem lengths
				self.set_stems();
				
				// If many voices, set the vertical offset of rests.
				// Shift the notes on voice overlap
				if (voice_tb.length > 1) {	
					set_rest_offset();
					set_overlap();
				}
				
				// Set the horizontal offset of accidentals
				set_acc_shft();
				
				// Set the width of all symbols
				set_allsymwidth();
				indent = set_indent (true);
				
				// If single line, adjust the page width
				if (cfmt.singleline) {
					v = get_ck_width();
					lwidth = indent + v[0] + v[1] + get_width(tsfirst, null);
					img.width = lwidth * cfmt.scale + img.lm + img.rm + 2;
				} else {
					
					// Else, split the tune into music lines
					lwidth = get_lwidth();
					cut_tune (lwidth, indent);
				}

				// Last spacing factor
				spf_last = 1.2;
				
				// loop per music line
				while (true) { 
					set_piece();
					self.set_sym_glue(lwidth - indent);
					if (realwidth != 0) {
						if (indent != 0) {
							posx += indent;
						}
						
						// Delayed output
						draw_sym_near();
						line_height = set_staff();
						delayed_update();
						draw_systems(indent);
						draw_all_sym();
						vskip(line_height)
						if (indent != 0) {
							posx -= indent;
							
							// No more indentation
							insert_meter &= ~2;
						}
						while (blocks.length != 0) { 
							block_gen(blocks.shift());
						}
					}
					
					tsfirst = tsnext;
					svg_flush();
					if (!tsnext) {
						break;
					}
					
					// Next line
					gen_init();
					if (!tsfirst) {
						break;
					}
					tsfirst.ts_prev = null;
					set_sym_line();
					
					// The image size may have changed
					lwidth = get_lwidth();
					indent = set_indent();
				}
			}
			
			/* -- reset the generator -- */
			private function reset_gen() : *  {
				insert_meter = cfmt.writefields.indexOf('M') >= 0 ?
					3 :	/* insert meter and indent */
					2	/* indent only */
			}
			
			
			// --------------------------------------
			
			// abc2svg - parse.js - ABC parse
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			private var	a_gch : Array;		// array of parsed guitar chords
			private var a_dcn : Array;		// array of parsed decoration names
			private var multicol : Object;	// multi column object
			private var maps : Object = {};	// maps object - hashcode = map name
			//	-> object - hashcode = note
			//	[0] array of heads
			//	[1] print
			//	[2] color
			private var	qplet_tb : Vector.<int> = Vector.<int> ([ 0, 1, 3, 2, 3, 0, 2, 0, 3, 0 ]);
			private var ntb : String = "CDEFGABcdefgab";
			
			
			// set the source references of a symbol
			private function set_ref(s) : *  {
				s.fname = parse.fname;
				s.istart = parse.istart;
				s.iend = parse.iend
			}
			
			// -- %% pseudo-comment
			
			// clef definition (%%clef, K: and V:)
			private function new_clef(clef_def) : *  {
				var	s = {
					type: C.CLEF,
						clef_line: 2,
						clef_type: "t",
						v: curvoice.v,
						p_v: curvoice,
						time: curvoice.time,
						dur: 0
				},
					i = 1
				
				set_ref(s)
				
				switch (clef_def.charAt(0)) {
					case '"':
						i = clef_def.indexOf('"', 1);
						s.clef_name = clef_def.slice(1, i);
						i++
						break
					case 'a':
						if (clef_def.charAt(1) == 'u') {	// auto
							s.clef_type = "a";
							s.clef_auto = true;
							i = 4
							break
						}
						i = 4				// alto
					case 'C':
						s.clef_type = "c";
						s.clef_line = 3
						break
					case 'b':				// bass
						i = 4
					case 'F':
						s.clef_type = "b";
						s.clef_line = 4
						break
					case 'n':				// none
						i = 4
						s.invis = true
						break
					case 't':
						if (clef_def.charAt(1) == 'e') {	// tenor
							s.clef_type = "c";
							s.clef_line = 4
							break
						}
						i = 6
					case 'G':
						//		s.clef_type = "t"		// treble
						break
					case 'p':
						i = 4
					case 'P':				// perc
						s.clef_type = "p";
						s.clef_line = 3;
						curvoice.key.k_sf = 0;		// no accidental
						curvoice.ckey.k_drum = true	// no transpose
						break
					default:
						syntax(1, "Unknown clef '$1'", clef_def)
						return //undefined
				}
				if (clef_def.charAt(i) >= '1' && clef_def.charAt(i) <= '9') {
					s.clef_line = Number(clef_def.charAt(i));
					i++
				}
				if (clef_def.charAt(i + 1) != '8')
					return s
				switch (clef_def.charAt(i)) {			// octave
					case '^':
						s.clef_oct_transp = true
					case '+':
						s.clef_octave = 7
						break
					case '_':
						s.clef_oct_transp = true
					case '-':
						s.clef_octave = -7
						break
				}
				return s
			}
			
			private var note_pit : Vector.<int> = Vector.<int> ([0, 2, 4, 5, 7, 9, 11]);
			
			// get a transposition value
			private function get_transp(param,
								type = null) : *  {		// undefined or "instr"
				var	i, val, tmp, note,
				pit = []
				
				if (param[0] == '0')
					return 0
				if ("123456789-+".indexOf(param[0]) >= 0) {	// by semi-tone
					val = parseInt(param) * 3
					if (isNaN(val) || val < -108 || val > 108) {
						//fixme: no source reference...
						syntax(1, "Bad transpose value")
						return
					}
					switch (param.slice(-1)) {
						default:
							return val
						case '#':
							val++
							break
						case 'b':
							val += 2
							break
					}
					if (val > 0)
						return val
					return val - 3
				}
				
				// by music interval
				if (type == "instr") {	// convert instrument= into score= or sound=
					tmp = param.indexOf('/')
					if (!cfmt.sound) {
						if (tmp < 0)
							return 0	// written pitch
						param = param.replace('/', '')
					} else {
						if (tmp < 0)
							param = 'c' + param
						else
							param = param.replace(/.*\//, 'c')
					}
				}
				
				tmp = new scanBuf();
				tmp.buffer = param
				for (i = 0; i < 2; i++) { 
					note = parse_acc_pit(tmp)
					if (!note) {
						syntax(1, "Bad transpose value")
						return
					}
					note.pit += 124;	// 126 - 2 for value > 0 and 'C' % 7 == 0
					val = ((note.pit / 7) | 0) * 12 + note_pit[note.pit % 7]
					if (note.acc && note.acc != 3)		// if not natural
						val += note.acc;
					pit[i] = val
				}
				if (cfmt.sound)
					pit[0] = 252;			// 'c'
				
				val = (pit[1] - pit[0]) * 3
				if (note) {
					switch (note.acc) {
						default:
							return val
						case 2:
						case 1:
							val++
							break
						case -1:
						case -2:
							val += 2
							break
					}
				}
				if (val > 0)
					return val
				return val - 3
			}
			
			// set the linebreak character
			private function set_linebreak(param) : *  {
				var i, item
				
				for (i = 0; i < 128; i++) { 
					if (char_tb[i] == "\n")
						char_tb[i] = nil	// remove old definition
				}
				param = param.split(/\s+/)
				for (i = 0; i < param.length; i++) { 
					item = param[i]
					switch (item) {
						case '!':
						case '$':
						case '*':
						case ';':
						case '?':
						case '@':
							break
						case "<none>":
							continue
						case "<EOL>":
							item = '\n'
							break
						default:
							syntax(1, "Bad value '$1' in %%linebreak - ignored",
								item)
							continue
					}
					char_tb[item.charCodeAt(0)] = '\n'
				}
			}
			
			// set a new user character (U: or %%user)
			private function set_user(parm) : *  {
				var	k, c, v,
				a = parm.match(/(.*?)[= ]*([!"].*[!"])/)
				
				if (!a) {
					syntax(1, 'Lack of starting ! or " in U: / %%user')
					return
				}
				c = a[1];
				v = a[2]
				if (v.slice(-1) != v[0]) {
					syntax(1, "Lack of ending $1 in U:/%%user", v[0])
					return
				}
				if (c[0] == '\\') {
					if (c[1] == 't')
						c = '\t'
					else if (!c[1])
						c = ' '
				}
				
				k = c.charCodeAt(0)
				if (k >= 128) {
					syntax(1, errs.not_ascii)
					return
				}
				switch (char_tb[k][0]) {
					case '0':			// nil
					case 'd':
					case 'i':
					case ' ':
						break
					case '"':
					case '!':
						if (char_tb[k].length > 1)
							break
						// fall thru
					default:
						syntax(1, "Bad user character '$1'", c)
						return
				}
				switch (v) {
					case "!beambreak!":
						v = " "
						break
					case "!ignore!":
						v = "i"
						break
					case "!nil!":
					case "!none!":
						v = "d"
						break
				}
				char_tb[k] = v
			}
			
			// get a stafflines value
			private function get_st_lines(param) : *  {
				var n, val
				
				if (!param)
					return
				if (/^[\]\[|.-]+$/.test(param))
					return param.replace(/\]/g, '[')
				
				n = parseInt(param)
				switch (n) {
					case 0: return "..."
					case 1: return "..|"
					case 2: return ".||"
					case 3: return ".|||"
				}
				if (isNaN(n) || n < 0 || n > 16)
					return //undefined
				val = '|'
				while (--n > 0) { 
					val += '|';
				}
				return val
			}
			
			// create a block symbol in the tune body
			private function new_block(subtype) : *  {
				var	s = {
					type: C.BLOCK,
						subtype: subtype,
						dur: 0
				}
				
				if (parse.state == 2)
					goto_tune()
				var voice_s = curvoice;
				curvoice = voice_tb[par_sy.top_voice]
				sym_link(s);
				curvoice = voice_s
				return s
			}
			
			// set the voice parameters
			// (possible hook)
			private function set_vp(a) : *  {
				var	s, item, pos, val, clefpit
				
				while (1) { 
					item = a.shift()
					if (!item)
						break
					if (item.charAt(item.length - 1) == '='
						&& a.length == 0) {
						syntax(1, errs.bad_val, item)
						break
					}
					switch (item) {
						case "clef=":
							s = a.shift()		// keep last clef
							break
						case "clefpitch=":
							item = a.shift()		// (<note><octave>)
							if (item) {
								val = ntb.indexOf(item[0])
								if (val >= 0) {
									switch (item[1]) {
										case "'":
											val += 7
											break
										case ',':
											val -= 7
											if (item[2] == ',')
												val -= 7
											break
									}
									clefpit = 4 - val	// 4 = 'G'
									break
								}
							}
							syntax(1, errs.bad_val, item)
							break
						case "octave=":
						case "uscale=":			// %%microscale
							val = parseInt(a.shift())
							if (isNaN(val))
								syntax(1, errs.bad_val, item)
							else
								curvoice[item.slice(0, -1)] = val
							break
						case "cue=":
							curvoice.scale = a.shift() == 'on' ? .7 : 1
							break
						case "instrument=":
							curvoice.transp = get_transp(a.shift(), 'instr')
							break
						case "map=":			// %%voicemap
							curvoice.map = a.shift()
							break
						case "name=":
						case "nm=":
							curvoice.nm = a.shift()
							if (curvoice.nm.charAt(0) == '"')
								curvoice.nm = curvoice.nm.slice(1, -1);
							curvoice.new_name = true
							break
						case "stem=":
						case "pos=":
							if (item == "pos=")
								item = a.shift().split(' ')
							else
								item = ["stm", a.shift()];
							val = posval[item[1]]
							if (val == undefined) {
								syntax(1, errs.bad_val, item[0])
								break
							}
							if (!pos)
								pos = {}
							pos[item[0]] = val
							break
						case "scale=":			// %%voicescale
							val = parseFloat(a.shift())
							if (isNaN(val) || val < .6 || val > 1.5)
								syntax(1, errs.bad_val, "%%voicescale")
							else
								curvoice.scale = val
							break
						case "score=":
							if (cfmt.sound)
								break
							item = a.shift()
							if (item.indexOf('/') < 0)
								item += '/c';
							curvoice.transp = get_transp(item)
							break
						case "shift=":
							curvoice.shift = get_transp(a.shift())
							break
						case "sound=":
						case "transpose=":		// (abcMIDI compatibility)
							if (!cfmt.sound)
								break
							curvoice.transp = get_transp(a.shift())
							break
						case "subname=":
						case "sname=":
						case "snm=":
							curvoice.snm = a.shift()
							if (curvoice.snm.charAt(0) == '"')
								curvoice.snm = curvoice.snm.slice(1, -1);
							break
						case "stafflines=":
							val = get_st_lines(a.shift())
							if (val == undefined)
								syntax(1, "Bad %%stafflines value")
							else if (curvoice.st != undefined)
								par_sy.staves[curvoice.st].stafflines = val
							else
								curvoice.stafflines = val
							break
						case "staffnonote=":
							val = parseInt(a.shift())
							if (isNaN(val))
								syntax(1, "Bad %%staffnonote value")
							else
								curvoice.staffnonote = val
							break
						case "staffscale=":
							val = parseFloat(a.shift())
							if (isNaN(val) || val < .3 || val > 2)
								syntax(1, "Bad %%staffscale value")
							else
								curvoice.staffscale = val
							break
						default:
							switch (item.slice(0, 4)) {
								case "treb":
								case "bass":
								case "alto":
								case "teno":
								case "perc":
									s = item
									break
								default:
									if ("GFC".indexOf(item.charAt(0)) >= 0)
										s = item
									else if (item.slice(-1) == '=')
										a.shift()
									break
							}
							break
					}
				}
				if (pos) {
					curvoice.pos = clone(curvoice.pos)
					for (item in pos) { 
						if (pos.hasOwnProperty(item)) {
							curvoice.pos[item] = pos[item];
						}
					}
				}
				
				if (s) {
					s = new_clef(s)
					if (s) {
						if (clefpit)
							s.clefpit = clefpit
						get_clef(s)
					}
				}
			} // set_vp()
			
			// set the K: / V: parameters
			private function set_kv_parm(a) : *  {	// array of items
				if (!curvoice.init) {	// add the global parameters if not done yet
					curvoice.init = true
					if (info.V) {
						if (info.V['*'])
							a = info.V['*'].concat(a)
						if (info.V[curvoice.id])
							a = info.V[curvoice.id].concat(a)
					}
				}
				if (a.length != 0)
					self.set_vp(a)
			} // set_kv_parm()
			
			// memorize the K:/V: parameters
			private function memo_kv_parm(vid,	// voice ID (V:) / '*' (K:/V:*)
								  a) :*  {	// array of items
				if (a.length == 0)
					return
				if (!info.V)
					info.V = {}
				if (info.V[vid])
					Array.prototype.push.apply(info.V[vid], a)
				else
					info.V[vid] = a
			}
			
			// K: key signature
			// return the key and the voice/clef parameters
			private function new_key(param) : *  {
				var	i, clef, key_end, c, tmp,
				mode = 0,
					s = {
						type: C.KEY,
							k_delta: 0,
							dur:0
					}
				
				set_ref(s);
				
				// tonic
				i = 1
				switch (param.charAt(0)) {
					case 'A': s.k_sf = 3; break
					case 'B': s.k_sf = 5; break
					case 'C': s.k_sf = 0; break
					case 'D': s.k_sf = 2; break
					case 'E': s.k_sf = 4; break
					case 'F': s.k_sf = -1; break
					case 'G': s.k_sf = 1; break
					case 'H':				// bagpipe
						switch (param[1]) {
							case 'P':
							case 'p':
								s.k_bagpipe = param[1];
								s.k_sf = param[1] == 'P' ? 0 : 2;
								i++
								break
							default:
								syntax(1, "Unknown bagpipe-like key")
								break
						}
						break
					case 'P':
						syntax(1, "K:P is deprecated");
						s.k_drum = true;
						key_end = true
						break
					case 'n':				// none
						if (param.indexOf("none") == 0) {
							s.k_sf = 0;
							s.k_none = true;
							i = 4
						}
						// fall thru
					default:
						key_end = true
						break
				}
				
				if (!key_end) {
					switch (param.charAt(i)) {
						case '#': s.k_sf += 7; i++; break
						case 'b': s.k_sf -= 7; i++; break
					}
					param = Strings.trim(param.slice(i));
					switch (param.slice(0, 3).toLowerCase()) {
						default:
							if (param.charAt(0) != 'm'
								|| (param[1] != ' ' && param[1] != '\t'
									&& param[1] != '\n')) {
								key_end = true
								break
							}
							// fall thru ('m')
						case "aeo":
						case "m":
						case "min": s.k_sf -= 3;
							mode = 5
							break
						case "dor": s.k_sf -= 2;
							mode = 1
							break
						case "ion":
						case "maj": break
						case "loc": s.k_sf -= 5;
							mode = 6
							break
						case "lyd": s.k_sf += 1;
							mode = 3
							break
						case "mix": s.k_sf -= 1;
							mode = 4
							break
						case "phr": s.k_sf -= 4;
							mode = 2
							break
					}
					if (!key_end)
						param = param.replace(/\w+\s*/, '')
					
					// [exp] accidentals
					if (param.indexOf("exp ") == 0) {
						param = param.replace(/\w+\s*/, '')
						if (!param)
							syntax(1, "No accidental after 'exp'");
						s.k_exp = true
					}
					c = param.charAt(0);
					if (c == '^' || c == '_' || c == '=') {
						s.k_a_acc = [];
						tmp = new scanBuf();
						tmp.buffer = param
						do { 
							var note = parse_acc_pit(tmp)
							if (!note)
								return [s, null]
							s.k_a_acc.push(note);
							c = param[tmp.index]
							while (c == ' ') { 
								c = param[++tmp.index];
							}
						} while (c == '^' || c == '_' || c == '=');
						param = param.slice(tmp.index)
					} else if (s.k_exp && param.indexOf("none") == 0) {
						s.k_sf = 0;
						param = param.replace(/\w+\s*/, '')
					}
				}
				
				s.k_delta = cgd2cde[(s.k_sf + 7) % 7];
				s.k_mode = mode
				
				return [s, info_split(param, 0)]
			}
			
			// M: meter
			private function new_meter(text) : *  {
				var	s = {
					type: C.METER,
						dur: 0,
						a_meter: []
				},
					meter = {},
					val, v,
					m1 = 0, m2,
					i = 0, j,
					wmeasure,
					p = text,
					in_parenth;
				
				set_ref(s)
				
				if (p.indexOf("none") == 0) {
					i = 4;				/* no meter */
					wmeasure = 1;	// simplify measure numbering and C.MREST conversion
				} else {
					wmeasure = 0
					while (i < text.length) { 
						if (p.charAt(i) == '=')
							break
						switch (p.charAt(i)) {
							case 'C':
								meter.top = p.charAt(i++);
								if (p.charAt(i) == '|')
									meter.top += p.charAt(i++);
								m1 = 4;
								m2 = 4
								break
							case 'c':
							case 'o':
								m1 = p[i] == 'c' ? 4 : 3;
								m2 = 4;
								meter.top = p[i++]
								if (p[i] == '.')
									meter.top += p[i++]
								break
							case '(':
								if (p[i + 1] == '(') {	/* "M:5/4 ((2+3)/4)" */
									in_parenth = true;
									meter.top = p[i++];
									s.a_meter.push(meter);
									meter = {}
								}
								j = i + 1
								while (j < text.length) { 
									if (p[j] == ')' || p[j] == '/')
										break
									j++
								}
								if (p[j] == ')' && p[j + 1] == '/') {	/* "M:5/4 (2+3)/4" */
									i++		/* remove the parenthesis */
									continue
								}			/* "M:5 (2+3)" */
								/* fall thru */
							case ')':
								in_parenth = p[i] == '(';
								meter.top = p[i++];
								s.a_meter.push(meter);
								meter = {}
								continue
							default:
								if (p.charAt(i) <= '0' || p.charAt(i) > '9') {
									syntax(1, "Bad char '$1' in M:", p.charAt(i));
									return;
								}
								m2 = 2;			/* default when no bottom value */
								meter.top = p.charAt(i++);
								for (;;) { 
									while (p.charAt(i) >= '0' && p.charAt(i) <= '9') {
										meter.top += p.charAt(i++);
									}
									if (p.charAt(i) == ')') {
										if (p.charAt(i + 1) != '/')
											break;
										i++;
									}
									if (p.charAt(i) == '/') {
										i++;
										if (p.charAt(i) <= '0' || p.charAt(i) > '9') {
											syntax(1, "Bad char '$1' in M:", p.charAt(i));
											return;
										}
										meter.bot = p.charAt(i++);
										while (p.charAt(i) >= '0' && p.charAt(i) <= '9') {
											meter.bot += p.charAt(i++);
										}
										break;
									}
									if (p.charAt(i) != ' ' && p.charAt(i) != '+')
										break;
									if (i >= text.length
										|| p.charAt(i + 1) == '(')	/* "M:5 (2/4+3/4)" */
										break
									meter.top += p.charAt(i++);
								}
								m1 = parseInt(meter.top);
								break
						}
						if (!in_parenth) {
							if (meter.bot)
								m2 = parseInt(meter.bot);
							wmeasure += m1 * C.BLEN / m2
						}
						s.a_meter.push(meter);
						meter = {}
						while (p.charAt(i) == ' ') {
							i++;
						}
						if (p.charAt(i) == '+') {
							meter.top = p.charAt(i++);
							s.a_meter.push(meter);
							meter = {};
						}
					}
				}
				if (p.charAt(i) == '=') {
					val = p.substring(++i).match(/^(\d+)\/(\d+)$/)
					if (!val) {
						syntax(1, "Bad duration '$1' in M:", p.substring(i))
						return
					}
					wmeasure = C.BLEN * val[1] / val[2]
				}
				s.wmeasure = wmeasure
				
				if (parse.state != 3) {
					info.M = text;
					glovar.meter = s
					if (parse.state >= 1) {
						
						/* in the tune header, change the unit note length */
						if (!glovar.ulen) {
							if (wmeasure <= 1
								|| wmeasure >= C.BLEN * 3 / 4)
								glovar.ulen = C.BLEN / 8
							else
								glovar.ulen = C.BLEN / 16
						}
						for (v = 0; v < voice_tb.length; v++) { 
							voice_tb[v].meter = s;
							voice_tb[v].wmeasure = wmeasure
						}
					}
				} else {
					curvoice.wmeasure = wmeasure
					if (is_voice_sig()) {
						curvoice.meter = s;
						reset_gen()
					} else {
						sym_link(s)
					}
				}
			}
			
			/* Q: tempo */
			private function new_tempo(text) : *  {
				var	i = 0, j, c, nd, tmp,
					s = {
						type: C.TEMPO,
							dur: 0
					}
				
				set_ref(s)
				
				if (cfmt.writefields.indexOf('Q') < 0)
					s.del = true			// don't display
				
				/* string before */
				if (text.charAt(0) == '"') {
					i = text.indexOf('"', 1)
					if (i < 0) {
						syntax(1, "Unterminated string in Q:")
						return
					}
					s.tempo_str1 = text.slice(1, i);
					i++
					while (text[i] == ' ') { 
						i++;
					}
				}
				
				/* beat */
				tmp = new scanBuf();
				tmp.buffer = text;
				tmp.index = i
				while (1) { 
					//		c = tmp.char()
					c = text.charAt (tmp.index);
					if (c == undefined || c <= '0' || c > '9')
						break
					nd = parse_dur(tmp)
					if (!s.tempo_notes)
						s.tempo_notes = []
					s.tempo_notes.push(C.BLEN * nd[0] / nd[1])
					while (1) { 
						//			c = tmp.char()
						c = text.charAt(tmp.index);
						if (c != ' ') {
							break;
						}
						tmp.index++
					}
				}
				
				/* tempo value */
				if (c == '=') {
					c = text[++tmp.index]
					while (c == ' ') { 
						c = text[++tmp.index];
					}
					i = tmp.index
					if (c == 'c' && text[i + 1] == 'a'
						&& text[i + 2] == '.' && text[i + 3] == ' ') {
						s.tempo_ca = 'ca. ';
						tmp.index += 4;
						//			c = text[tmp.index]
					}
					if (text[tmp.index + 1] != '/') {
						s.tempo = tmp.get_int()
					} else {
						nd = parse_dur(tmp);
						s.new_beat = C.BLEN * nd[0] / nd[1]
					}
					c = text[tmp.index]
					while (c == ' ') { 
						c = text[++tmp.index];
					}
				}
				
				/* string after */
				if (c == '"') {
					tmp.index++;
					i = text.indexOf('"', tmp.index + 1)
					if (i < 0) {
						syntax(1, "Unterminated string in Q:")
						return
					}
					s.tempo_str2 = text.slice(tmp.index, i)
				}
				
				if (parse.state != 3) {
					if (parse.state == 1) {			// tune header
						info.Q = text;
						glovar.tempo = s
						return
					}
					goto_tune()
				}
				if (curvoice.v == par_sy.top_voice) {	/* tempo only for first voice */
					sym_link(s)
					if (glovar.tempo && curvoice.time == 0)
						glovar.tempo.del = true
				}
			}
			
			// treat the information fields which may embedded
			private function do_info(info_type, text) : *  {
				var s, d1, d2, a, vid
				
				switch (info_type) {
					
					// info fields in any state
					case 'I':
						self.do_pscom(text)
						break
					case 'L':
						//fixme: ??
						if (parse.state == 2)
							goto_tune();
						a = text.match(/^1\/(\d+)(=(\d+)\/(\d+))?$/)
						if (a) {
							d1 = Number(a[1])
							if (!d1 || (d1 & (d1 - 1)) != 0)
								break
							d1 = C.BLEN / d1
							if (a[2]) {
								d2 = Number(a[4])
								if (!d2 || (d2 & (d2 - 1)) != 0) {
									d2 = 0
									break
								}
								d2 = Number(a[3]) / d2 * C.BLEN
							} else {
								d2 = d1
							}
						} else if (text == "auto") {
							d1 = d2 = -1
						}
						if (!d2) {
							syntax(1, "Bad L: value")
							break
						}
						if (parse.state < 2) {
							glovar.ulen = d1
						} else {
							curvoice.ulen = d1;
							curvoice.dur_fact = d2 / d1
						}
						break
					case 'M':
						new_meter(text)
						break
					case 'U':
						set_user(text)
						break
					
					// fields in tune header or tune body
					case 'P':
						if (parse.state == 0)
							break
						if (parse.state == 1) {
							info.P = text
							break
						}
						if (parse.state == 2)
							goto_tune()
						if (cfmt.writefields.indexOf(info_type) < 0)
							break
						s = {
						type: C.PART,
							text: text,
							dur: 0
					}
						
						/*
						* If not in the main voice, then,
						* if the voices are synchronized and no P: yet in the main voice,
						* the misplaced P: goes into the main voice.
						*/
						var p_voice = voice_tb[par_sy.top_voice]
						if (curvoice.v != p_voice.v) {
							if (curvoice.time != p_voice.time)
								break
							if (p_voice.last_sym && p_voice.last_sym.type == C.PART)
								break		// already a P:
							var voice_sav = curvoice;
							curvoice = p_voice;
							sym_link(s);
							curvoice = voice_sav
						} else {
							sym_link(s)
						}
						break
					case 'Q':
						if (parse.state == 0)
							break
						new_tempo(text)
						break
					case 'V':
						get_voice(text)
						break
					
					// key signature at end of tune header on in tune body
					case 'K':
						if (parse.state == 0)
							break
						get_key(text)
						break
					
					// info in any state
					case 'N':
					case 'R':
						if (!info[info_type])
							info[info_type] = text
						else
							info[info_type] += '\n' + text
						break
					case 'r':
						if (!user.keep_remark
							|| parse.state != 3)
							break
						s = {
						type: C.REMARK,
							text: text,
							dur: 0
					}
						sym_link(s)
						break
					default:
						syntax(0, "'$1:' line ignored", info_type)
						break
				}
			}
			
			// music line parsing functions
			
			/* -- adjust the duration and time of symbols in a measure when L:auto -- */
			private function adjust_dur(s) : *  {
				var s2, time, auto_time, i, res;
				
				/* search the start of the measure */
				s2 = curvoice.last_sym
				if (!s2)
					return;
				
				/* the bar time is correct if there are multi-rests */
				if (s2.type == C.MREST
					|| s2.type == C.BAR)			/* in second voice */
					return
				while (s2.type != C.BAR && s2.prev) { 
					s2 = s2.prev;
				}
				time = s2.time;
				auto_time = curvoice.time - time
				
				/* remove the invisible rest at start of tune */
				if (time == 0) {
					while (s2 && !s2.dur) { 
						s2 = s2.next;
					}
					if (s2 && s2.type == C.REST
						&& s2.invis) {
						time += s2.dur * curvoice.wmeasure / auto_time
						if (s2.prev)
							s2.prev.next = s2.next
						else
							curvoice.sym = s2.next
						if (s2.next)
							s2.next.prev = s2.prev;
						s2 = s2.next
					}
				}
				if (curvoice.wmeasure == auto_time)
					return				/* already good duration */
				
				for ( ; s2; s2 = s2.next) { 
					s2.time = time
					if (!s2.dur || s2.grace)
						continue
					s2.dur = s2.dur * curvoice.wmeasure / auto_time;
					s2.dur_orig = s2.dur_orig * curvoice.wmeasure / auto_time;
					time += s2.dur
					if (s2.type != C.NOTE && s2.type != C.REST)
						continue
					for (i = 0; i <= s2.nhd; i++) { 
						s2.notes[i].dur = s2.notes[i].dur * curvoice.wmeasure / auto_time;
					}
					res = identify_note(s2, s2.dur_orig);
					s2.head = res[0];
					s2.dots = res[1];
					s2.nflags = res[2]
					if (s2.nflags <= -2)
						s2.stemless = true
					else
						delete s2.stemless
				}
				curvoice.time = s.time = time
			}
			
			/* -- parse a bar -- */
			private function new_bar() : *  {
				var	s2, c, bar_type,
				line = parse.line,
					s = {
						type: C.BAR,
							fname: parse.fname,
							istart: parse.bol + line.index,
							dur: 0,
							multi: 0		// needed for decorations
					}
				
				if (vover && vover.bar)			// end of voice overlay
					get_vover('|')
				if (glovar.new_nbar) {			// %%setbarnb
					s.bar_num = glovar.new_nbar;
					glovar.new_nbar = 0
				}
				bar_type = line.char()
				while (1) { 
					c = line.next_char()
					switch (c) {
						case '|':
						case '[':
						case ']':
						case ':':
							bar_type += c
							continue
					}
					break
				}
				if (bar_type.charAt(0) == ':') {
					if (bar_type.length == 1) {	// ":" alone
						bar_type = '|';
						s.bar_dotted = true
					} else {
						s.rbstop = 2		// right repeat with end
					}
				}
				
				// set the guitar chord and the decorations
				if (a_gch)
					self.gch_build(s)
				if (a_dcn) {
					deco_cnv(a_dcn, s);
					a_dcn = null
				}
				
				/* if the last element is '[', it may start
				* a chord or an embedded header */
				switch (bar_type.slice(-1)) {
					case '[':
						if (/[0-9" ]/.test(c))		// "
							break
						bar_type = bar_type.slice(0, -1);
						line.index--;
						c = '['
						break
					case ':':				// left repeat
						s.rbstop = 2			// with bracket end
						break
				}
				
				// check if repeat bar
				if (c > '0' && c <= '9') {
					if (bar_type.slice(-1) == '[')
						bar_type = bar_type.slice(0, -1);
					s.text = c
					while (1) { 
						c = line.next_char()
						if ("0123456789,.-".indexOf(c) < 0)
							break
						s.text += c
					}
					s.rbstop = 2;
					s.rbstart = 2
				} else if (c == '"' && bar_type.slice(-1) == '[') {
					bar_type = bar_type.slice(0, -1);
					s.text = ""
					while (1) { 
						c = line.next_char()
						if (!c) {
							syntax(1, "No end of repeat string")
							return
						}
						if (c == '"') {
							line.index++
							break
						}
						if (c == '\\') {
							s.text += c;
							c = line.next_char()
						}
						s.text += c
					}
					s.text = cnv_escape(s.text);
					s.rbstop = 2;
					s.rbstart = 2
				}
				
				// ']' as the first character indicates a repeat bar stop
				if (bar_type.charAt(0) == ']') {
					s.rbstop = 2			// with end
					if (bar_type.length != 1)
						bar_type = bar_type.slice(1)
					else
						s.invis = true
				}
				
				s.iend = parse.bol + line.index
				
				if (s.rbstart
					&& curvoice.norepbra
					&& !curvoice.second)
					s.norepbra = true
				
				if (curvoice.ulen < 0)			// L:auto
					adjust_dur(s);
				
				s2 = curvoice.last_sym
				if (s2 && s2.type == C.SPACE) {
					s2.time--		// keep the space at the right place
				} else if (s2 && s2.type == C.BAR) {
					//fixme: why these next lines?
					//		&& !s2.a_gch && !s2.a_dd
					//		&& !s.a_gch && !s.a_dd) {
					
					/* remove the invisible repeat bars when no shift is needed */
					if (bar_type == "["
						&& !s2.text
						&& (curvoice.st == 0
							|| (par_sy.staves[curvoice.st - 1].flags & STOP_BAR)
							|| s.norepbra)) {
						if (s.text)
							s2.text = s.text
						if (s.a_gch)
							s2.a_gch = s.a_gch
						if (s.norepbra)
							s2.norepbra = s.norepbra
						if (s.rbstart)
							s2.rbstart = s.rbstart
						if (s.rbstop)
							s2.rbstop = s.rbstop
						//--fixme: pb when on next line and empty staff above
						return
					}
					
					/* merge back-to-back repeat bars */
					if (bar_type == "|:") {
						if (s2.bar_type == ":|") {
							s2.bar_type = "::";
							s2.rbstop = 2
							return
						}
						if (s2.bar_type == "||") {
							s2.bar_type = "||:";
							s2.rbstop = 2
							return
						}
					}
				}
				
				/* set some flags */
				switch (bar_type) {
					case "[":
						s.rbstop = 2
					case "[]":
					case "[|]":
						s.invis = true;
						bar_type = "[]"
						break
					case ":|:":
					case ":||:":
						bar_type = "::"
						break
					case "||":
						if (!cfmt.rbdbstop)
							break
					case "[|":
					case "|]":
						s.rbstop = 2
						break
				}
				s.bar_type = bar_type
				if (!curvoice.lyric_restart)
					curvoice.lyric_restart = s
				if (!curvoice.sym_restart)
					curvoice.sym_restart = s
				
				/* the bar must appear before a key signature */
				if (s2 && s2.type == C.KEY
					&& (!s2.prev || s2.prev.type != C.BAR)) {
					curvoice.last_sym = s2.prev
					if (!s2.prev)
						curvoice.sym = s2.prev;	// null
					sym_link(s);
					s.next = s2;
					s2.prev = s;
					curvoice.last_sym = s2
				} else {
					sym_link(s)
				}
				s.st = curvoice.st			/* original staff */
				
				/* if repeat bar and shift, add a repeat bar */
				if (s.rbstart
					&& !curvoice.norepbra
					&& curvoice.st > 0
					&& !(par_sy.staves[curvoice.st - 1].flags & STOP_BAR)) {
					s2 = {
						type: C.BAR,
							fname: s.fname,
							istart: s.istart,
							iend: s.iend,
							bar_type: "[",
							multi: 0,
							invis: true,
							text: s.text,
							rbstart: 2
					}
					sym_link(s2);
					s2.st = curvoice.st
					delete s.text;
					s.rbstart = 0
				}
			}
			
			// parse %%staves / %%score
			// return an array of [vid, flags] / null
			private function parse_staves(p) : *  {
				var	v, vid,
				a_vf = [],
					err = false,
					flags = 0,
					brace = 0,
					bracket = 0,
					parenth = 0,
					flags_st = 0,
					i = 0
				
				/* parse the voices */
				while (i < p.length) { 
					switch (p.charAt(i)) {
						case ' ':
						case '\t':
							break
						case '[':
							if (parenth || brace + bracket >= 2) {
								syntax(1, errs.misplaced, '[');
								err = true
								break
							}
							flags |= brace + bracket == 0 ? OPEN_BRACKET : OPEN_BRACKET2;
							bracket++;
							flags_st <<= 8;
							flags_st |= OPEN_BRACKET
							break
						case '{':
							if (parenth || brace || bracket >= 2) {
								syntax(1, errs.misplaced, '{');
								err = true
								break
							}
							flags |= !bracket ? OPEN_BRACE : OPEN_BRACE2;
							brace++;
							flags_st <<= 8;
							flags_st |= OPEN_BRACE
							break
						case '(':
							if (parenth) {
								syntax(1, errs.misplaced, '(');
								err = true
								break
							}
							flags |= OPEN_PARENTH;
							parenth++;
							flags_st <<= 8;
							flags_st |= OPEN_PARENTH
							break
						case '*':
							if (brace && !parenth && !(flags & (OPEN_BRACE | OPEN_BRACE2)))
								flags |= FL_VOICE
							break
						case '+':
							flags |= MASTER_VOICE
							break
						default:
							if (!/\w/.test(p.charAt(i))) {
								syntax(1, "Bad voice ID in %%staves");
								err = true
								break
							}
							
							/* get / create the voice in the voice table */
							vid = ""
							while (i < p.length) { 
								if (" \t()[]{}|*".indexOf(p.charAt(i)) >= 0)
									break
								vid += p.charAt(i++);
							}
							for ( ; i < p.length; i++) { 
								switch (p.charAt(i)) {
									case ' ':
									case '\t':
										continue
									case ']':
										if (!(flags_st & OPEN_BRACKET)) {
											syntax(1, errs.misplaced, ']');
											err = true
											break
										}
										bracket--;
										flags |= brace + bracket == 0 ?
										CLOSE_BRACKET :
										CLOSE_BRACKET2;
										flags_st >>= 8
										continue
									case '}':
										if (!(flags_st & OPEN_BRACE)) {
											syntax(1, errs.misplaced, '}');
											err = true
											break
										}
										brace--;
										flags |= !bracket ?
										CLOSE_BRACE :
										CLOSE_BRACE2;
										flags &= ~FL_VOICE;
										flags_st >>= 8
										continue
									case ')':
										if (!(flags_st & OPEN_PARENTH)) {
											syntax(1, errs.misplaced, ')');
											err = true
											break
										}
										parenth--;
										flags |= CLOSE_PARENTH;
										flags_st >>= 8
										continue
									case '|':
										flags |= STOP_BAR
										continue
								}
								break
							}
							a_vf.push([vid, flags]);
							flags = 0
							continue
					}
					i++
				}
				if (flags_st != 0) {
					syntax(1, "'}', ')' or ']' missing in %%staves");
					err = true
				}
				if (err || a_vf.length == 0)
					return //null
				return a_vf
			}
			
			// split an info string
			private function info_split(text, ...etc) : *  {
				if (!text)
					return []
				var	a = text.match(/(".+?"|.+?)(\s+|=|$)/g)
				if (!a) {
					syntax(1, "Unterminated string")
					return []
				}
				for (var i = 0; i < a.length; i++) { 
					a[i] = Strings.trim(a[i]);
				}
				return a;
			}
			
			/* -- get head type, dots, flags of note/rest for a duration -- */
			private function identify_note(s, dur) : *  {
				var head, dots, flags
				
				if (dur % 12 != 0)
					syntax(1, "Invalid note duration $1", dur);
				dur /= 12			/* see C.BLEN for values */
				if (dur == 0)
					syntax(1, "Note too short")
				for (flags = 5; dur != 0; dur >>= 1, flags--) { 
					if (dur & 1)
						break
				}
				dur >>= 1
				switch (dur) {
					case 0: dots = 0; break
					case 1: dots = 1; break
					case 3: dots = 2; break
					//	case 7: dots = 3; break
					default:
						dots = 3
						break
				}
				flags -= dots
				//--fixme: is 'head' useful?
				if (flags >= 0) {
					head = C.FULL
				} else switch (flags) {
					default:
						syntax(1, "Note too long");
						flags = -4
						/* fall thru */
					case -4:
						head = C.SQUARE
						break
					case -3:
						head = cfmt.squarebreve ? C.SQUARE : C.OVALBARS
						break
					case -2:
						head = C.OVAL
						break
					case -1:
						head = C.EMPTY
						break
				}
				return [head, dots, flags]
			}
			
			// parse a duration and return [numerator, denominator]
			// 'line' is not always 'parse.line'
			private var reg_dur = /(\d*)(\/*)(\d*)/g		/* (stop comment) */
			
			private function parse_dur(line) : *  {
				var res, num, den;
				
				reg_dur.lastIndex = line.index;
				res = reg_dur.exec(line.buffer)
				if (!res[0])
					return [1, 1];
				num = res[1] || 1;
				den = res[3] || 1
				if (!res[3])
					den *= 1 << res[2].length;
				line.index = reg_dur.lastIndex
				return [num, den]
			}
			
			// parse the note accidental and pitch
			private function parse_acc_pit(line) : *  {
				var	note, acc, micro_n, micro_d, pit, nd,
				c = line.char()
				
				// optional accidental
				switch (c) {
					case '^':
						c = line.next_char()
						if (c == '^') {
							acc = 2;
							c = line.next_char()
						} else {
							acc = 1
						}
						break
					case '=':
						acc = 3;
						c = line.next_char()
						break
					case '_':
						c = line.next_char()
						if (c == '_') {
							acc = -2;
							c = line.next_char()
						} else {
							acc = -1
						}
						break
				}
				
				/* look for microtone value */
				if (acc && acc != 3 && (c >= '1' && c <= '9')
					|| c == '/') {				// compatibility
					nd = parse_dur(line);
					micro_n = nd[0];
					micro_d = nd[1]
					if (micro_d == 1)
						micro_d = curvoice ? curvoice.uscale : 1
					else
						micro_d *= 2;	// 1/2 tone fraction -> tone fraction
					c = line.char()
				}
				
				/* get the pitch */
				pit = ntb.indexOf(c) + 16;
				c = line.next_char()
				if (pit < 16) {
					syntax(1, "'$1' is not a note", line.buffer[line.index - 1])
					return //undefined
				}
				
				// octave
				while (c == "'") { 
					pit += 7;
					c = line.next_char()
				}
				while (c == ',') { 
					pit -= 7;
					c = line.next_char()
				}
				note = {
					pit: pit,
					shhd: 0,
					shac: 0,
					ti1: 0
				}
				if (acc) {
					note.acc = acc
					if (micro_n) {
						note.micro_n = micro_n;
						note.micro_d = micro_d
					}
				}
				return note
			}
			
			// convert a note pitch to ABC text
			private function note2abc(note) : *  {
				var	i,
				abc = 'abcdefg'[(note.pit + 77) % 7]
				
				//fixme: treat microtone
				if (note.acc)
					abc = ['__', '_', '', '^', '^^', '='][note.acc + 2] + abc
				for (i = note.pit; i >= 30; i -= 7)	{ // down to 'c'
					abc += "'";
				}
				for (i = note.pit; i < 23; i += 7)	{ // up to 'C'
					abc += ",";
				}
				return abc
			}
			
			/* set the mapping of a note */
			private function set_map(note) : *  {
				var	map = maps[curvoice.map],	// never null
					nn = note2abc(note)
				
				if (!map[nn]) {
					nn = 'octave,' + nn.replace(/[',]/g, '')	// octave '
					if (!map[nn]) {
						nn = 'key,' +			// 'key,'
							'abcdefg'[(note.pit + 77 -
								curvoice.ckey.k_delta) % 7]
						if (!map[nn]) {
							nn = 'all'		// 'all'
							if (!map[nn])
								return
						}
					}
				}
				note.map = map[nn]
				if (note.map[1]) {
					note.pit = note.map[1].pit;		// print/play
					note.acc = note.map[1].acc
				}
			}
			
			/* -- parse note or rest with pitch and length -- */
			// 'line' is not always 'parse.line'
			private function parse_basic_note(line, ulen) : *  {
				var	nd,
				note = parse_acc_pit(line)
				
				if (!note)
					return //null
				
				// duration
				if (line.char() == '0') {		// compatibility
					parse.stemless = true;
					line.index++
				}
				nd = parse_dur(line);
				note.dur = ulen * nd[0] / nd[1]
				return note
			}
			
			private function parse_vpos() : *  {
				var	c,
				line = parse.line,
					ti1 = 0
				
				if (line.buffer.charAt(line.index - 1) == '.' && !a_dcn)
					ti1 = C.SL_DOTTED
				switch (line.next_char()) {
					case "'":
						line.index++
						return ti1 + C.SL_ABOVE
					case ",":
						line.index++
						return ti1 + C.SL_BELOW
				}
				return ti1 + C.SL_AUTO
			}
			
			private var	cde2fcg : Vector.<int> = Vector.<int> ([0, 2, 4, -1, 1, 3, 5]);
			private var cgd2cde : Vector.<int> = Vector.<int> ([0, 4, 1, 5, 2, 6, 3]);
			private var acc2 : Vector.<int> = Vector.<int> ([-2, -1, 3, 1, 2]);
			
			/* transpose a note / chord */
			private function note_transp(s) : *  {
				var	i, j, n, d, a, acc, i1, i3, i4, note,
				m = s.nhd,
					sf_old = curvoice.okey.k_sf,
					i2 = curvoice.ckey.k_sf - sf_old,
					dp = cgd2cde[(i2 + 4 * 7) % 7],
					t = curvoice.vtransp
				
				if (t < 0 && dp != 0)
					dp -= 7;
				dp += ((t / 3 / 12) | 0) * 7
				for (i = 0; i <= m; i++) { 
					note = s.notes[i];
					
					// pitch
					n = note.pit;
					note.pit += dp;
					
					// accidental
					i1 = cde2fcg[(n + 5 + 16 * 7) % 7];	/* fcgdaeb */
					a = note.acc
					if (!a) {
						if (!curvoice.okey.a_acc) {
							if (sf_old > 0) {
								if (i1 < sf_old - 1)
									a = 1	// sharp
							} else if (sf_old < 0) {
								if (i1 >= sf_old + 6)
									a = -1	// flat
							}
						} else {
							for (j = 0; j < curvoice.okey.a_acc.length; j++) { 
								acc = curvoice.okey.a_acc[j]
								if ((n + 16 * 7 - acc.pit) % 7 == 0) {
									a = acc.acc
									break
								}
							}
						}
					}
					i3 = i1 + i2
					if (a && a != 3)				// ! natural
						i3 += a * 7;
					
					i1 = ((((i3 + 1 + 21) / 7) | 0) + 2 - 3 + 32 * 5) % 5;
					a = acc2[i1]
					if (note.acc) {
						;
					} else if (curvoice.ckey.k_none) {
						if (a == 3		// natural
							|| acc_same_pitch(note.pit))
							continue
					} else if (curvoice.ckey.a_acc) {	/* acc list */
						i4 = cgd2cde[(i3 + 16 * 7) % 7]
						for (j = 0; j < curvoice.ckey.a_acc.length; j++) { 
							if ((i4 + 16 * 7 - curvoice.ckey.a_acc[j].pits) % 7
								== 0)
								break
						}
						if (j < curvoice.ckey.a_acc.length)
							continue
					} else {
						continue
					}
					i1 = note.acc;
					d = note.micro_d
					if (d				/* microtone */
						&& i1 != a) {			/* different accidental type */
						n = note.micro_n
						//fixme: double sharps/flats ?*/
						//fixme: does not work in all cases (tied notes, previous accidental)
						switch (a) {
							case 3:			// natural
								if (n > d / 2) {
									n -= d / 2;
									note.micro_n = n;
									a = i1
								} else {
									a = -i1
								}
								break
							case 2:			// double sharp
								if (n > d / 2) {
									note.pit += 1;
									n -= d / 2
								} else {
									n += d / 2
								}
								a = i1;
								note.micro_n = n
								break
							case -2:		// double flat
								if (n >= d / 2) {
									note.pit -= 1;
									n -= d / 2
								} else {
									n += d / 2
								}
								a = i1;
								note.micro_n = n
								break
						}
					}
					note.acc = a
				}
			}
			
			/* sort the notes of the chord by pitch (lowest first) */
			private function sort_pitch(s) : *  {
				s.notes = s.notes.sort(function(n1, n2) :* {
					return n1.pit - n2.pit
				})
			}
			// (possible hook)
			private function new_note(grace, tp_fact) : *  {
				var	note, s, in_chord, c, dcn, type,
				i, n, s2, nd, res, num, dur,
				sl1 = 0,
					line = parse.line,
					a_dcn_sav = a_dcn;	// save parsed decoration names
				
				a_dcn = null;
				parse.stemless = false;
				s = {
					type: C.NOTE,
						fname: parse.fname,
						stem: 0,
						multi: 0,
						nhd: 0,
						xmx: 0
				}
				s.istart = parse.bol + line.index
				
				if (curvoice.color)
					s.color = curvoice.color
				
				if (grace) {
					s.grace = true
				} else {
					if (a_gch)
						self.gch_build(s)
					if (parse.repeat_n) {
						s.repeat_n = parse.repeat_n;
						s.repeat_k = parse.repeat_k;
						parse.repeat_n = 0
					}
				}
				c = line.char()
				switch (c) {
					case 'X':
						s.invis = true
					case 'Z':
						s.type = C.MREST;
						c = line.next_char()
						s.nmes = (c > '0' && c <= '9') ? line.get_int() : 1;
						s.dur = curvoice.wmeasure * s.nmes
						
						// ignore if in second voice
						if (curvoice.second) {
							curvoice.time += s.dur
							return //null
						}
						break
					case 'y':
						s.type = C.SPACE;
						s.invis = true;
						s.dur = 0;
						c = line.next_char()
						if (c >= '0' && c <= '9')
							s.width = line.get_int()
						else
							s.width = 10
						break
					case 'x':
						s.invis = true
					case 'z':
						s.type = C.REST;
						line.index++;
						nd = parse_dur(line);
						s.dur_orig = ((curvoice.ulen < 0) ?
							15120 :	// 2*2*2*2*3*3*3*5*7
							curvoice.ulen) * nd[0] / nd[1];
						s.dur = s.dur_orig * curvoice.dur_fact;
						s.notes = [{
							pit: 18,
							dur: s.dur_orig
						}]
						break
					case '[':			// chord
						in_chord = true;
						c = line.next_char()
						// fall thru
					default:			// accidental, chord, note
						if (curvoice.uscale)
							s.uscale = curvoice.uscale;
						s.notes = []
						
						// loop on the chord
						while (1) { 
							
							// when in chord, get the slurs and decorations
							if (in_chord) {
								while (1) { 
									if (!c)
										break
									i = c.charCodeAt(0);
									if (i >= 128) {
										syntax(1, errs.not_ascii)
										return //null
									}
									type = char_tb[i]
									switch (type.charAt(0)) {
										case '(':
											sl1 <<= 4;
											sl1 += parse_vpos();
											c = line.char()
											continue
										case '!':
											if (!a_dcn)
												a_dcn = []
											if (type.length > 1) {
												a_dcn.push(type.slice(1, -1))
											} else {
												dcn = ""
												while (1) { 
													c = line.next_char()
													if (!c) {
														syntax(1, "No end of decoration")
														return //null
													}
													if (c == '!')
														break
													dcn += c
												}
												a_dcn.push(dcn)
											}
											c = line.next_char()
											continue
									}
									break
								}
							}
							note = parse_basic_note(line,
								s.grace ? C.BLEN / 4 :
								curvoice.ulen < 0 ?
								15120 :	// 2*2*2*2*3*3*3*5*7
								curvoice.ulen)
							if (!note)
								return //null
							
							// transpose
							if (curvoice.octave)
								note.pit += curvoice.octave * 7
							if (curvoice.ottava)
								note.pit += curvoice.ottava
							if (sl1) {
								note.sl1 = sl1
								if (s.sl1)
									s.sl1++
								else
									s.sl1 = 1;
								sl1 = 0
							}
							if (a_dcn) {
								note.a_dcn = a_dcn;
								a_dcn = null
							}
							s.notes.push(note)
							if (!in_chord)
								break
							
							// in chord: get the ending slurs and the ties
							c = line.char()
							while (1) { 
								switch (c) {
									case ')':
										if (note.sl2)
											note.sl2++
										else
											note.sl2 = 1
										if (s.sl2)
											s.sl2++
										else
											s.sl2 = 1;
										c = line.next_char()
										continue
									case '-':
										note.ti1 = parse_vpos();
										s.ti1 = true;
										c = line.char()
										continue
									case '.':
										c = line.next_char()
										if (c != '-') {
											syntax(1, "Misplaced dot")
											break
										}
										continue
								}
								break
							}
							if (c == ']') {
								line.index++;
								
								// adjust the chord duration
								nd = parse_dur(line);
								s.nhd = s.notes.length - 1
								for (i = 0; i <= s.nhd ; i++) { 
									note = s.notes[i];
									note.dur = note.dur * nd[0] / nd[1]
								}
								break
							}
						}
						
						// the duration of the chord is the duration of the 1st note
						s.dur_orig = s.notes[0].dur;
						s.dur = s.notes[0].dur * curvoice.dur_fact
				}
				if (s.grace && s.type != C.NOTE) {
					syntax(1, "Not a note in grace note sequence")
					return //null
				}
				
				if (s.notes) {				// if note or rest
					if (!s.grace) {
						switch (curvoice.pos.stm) {
							case C.SL_ABOVE: s.stem = 1; break
							case C.SL_BELOW: s.stem = -1; break
							case C.SL_HIDDEN: s.stemless = true; break
						}
						
						// adjust the symbol duration
						s.dur *= tp_fact;
						num = curvoice.brk_rhythm
						if (num) {
							curvoice.brk_rhythm = 0;
							s2 = curvoice.last_note
							if (num > 0) {
								n = num * 2 - 1;
								s.dur = s.dur * n / num;
								s.dur_orig = s.dur_orig * n / num
								for (i = 0; i <= s.nhd; i++) { 
									s.notes[i].dur = s.notes[i].dur * n / num;
								}
								s2.dur /= num;
								s2.dur_orig /= num
								for (i = 0; i <= s2.nhd; i++) { 
									s2.notes[i].dur /= num;
								}
							} else {
								num = -num;
								n = num * 2 - 1;
								s.dur /= num;
								s.dur_orig /= num
								for (i = 0; i <= s.nhd; i++) { 
									s.notes[i].dur /= num;
								}
								s2.dur = s2.dur * n / num;
								s2.dur_orig = s2.dur_orig * n / num
								for (i = 0; i <= s2.nhd; i++) { 
									s2.notes[i].dur = s2.notes[i].dur * n / num;
								}
							}
							curvoice.time = s2.time + s2.dur;
							res = identify_note(s2, s2.dur_orig);
							s2.head = res[0];
							s2.dots = res[1];
							s2.nflags = res[2]
							if (s2.nflags <= -2)
								s2.stemless = true
							else
								delete s2.stemless
							
							// adjust the time of the grace notes, bars...
							for (s2 = s2.next; s2; s2 = s2.next) { 
								s2.time = curvoice.time;
							}
						}
					} else {		/* grace note - adjust its duration */
						var div = curvoice.ckey.k_bagpipe ? 8 : 4
						
						for (i = 0; i <= s.nhd; i++) { 
							s.notes[i].dur /= div;
						}
						s.dur /= div;
						s.dur_orig /= div
						if (grace.stem)
							s.stem = grace.stem
					}
					
					// set the symbol parameters
					if (s.type == C.NOTE) {
						res = identify_note(s, s.dur_orig);
						s.head = res[0];
						s.dots = res[1];
						s.nflags = res[2]
						if (s.nflags <= -2)
							s.stemless = true
					} else {					// rest
						
						/* change the figure of whole measure rests */
						//--fixme: does not work in sample.abc because broken rhythm on measure bar
						dur = s.dur_orig
						if (dur == curvoice.wmeasure) {
							if (dur < C.BLEN * 2)
								dur = C.BLEN
							else if (dur < C.BLEN * 4)
								dur = C.BLEN * 2
							else
								dur = C.BLEN * 4
						}
						res = identify_note(s, dur);
						s.head = res[0];
						s.dots = res[1];
						s.nflags = res[2]
					}
					curvoice.last_note = s
				}
				
				sym_link(s)
				
				if (s.type == C.NOTE) {
					if (curvoice.vtransp)
						note_transp(s)
					if (curvoice.map
						&& maps[curvoice.map]) {
						for (i = 0; i <= s.nhd; i++) { 
							set_map(s.notes[i]);
						}
					}
				}
				
				if (cfmt.shiftunison)
					s.shiftunison = cfmt.shiftunison
				if (!grace) {
					if (!curvoice.lyric_restart)
						curvoice.lyric_restart = s
					if (!curvoice.sym_restart)
						curvoice.sym_restart = s
				}
				
				if (a_dcn_sav)
					deco_cnv(a_dcn_sav, s, s.prev)
				if (parse.stemless)
					s.stemless = true
				s.iend = parse.bol + line.index
				return s
			}
			
			// characters in the music line (ASCII only)
			private var nil = ["0"]
			private var char_tb = [
				nil, nil, nil, nil,		/* 00 - .. */
				nil, nil, nil, nil,
				nil, " ", "\n", nil,		/* . \t \n . */
				nil, nil, nil, nil,
				nil, nil, nil, nil,
				nil, nil, nil, nil,
				nil, nil, nil, nil,
				nil, nil, nil, nil,		/* .. - 1f */
				" ", "!", '"', "i",		/* (sp) ! " # */
				"\n", nil, "&", nil,		/* $ % & ' */
				"(", ")", "i", nil,		/* ( ) * + */
				nil, "-", "!dot!", nil,		/* , - . / */
				nil, nil, nil, nil, 		/* 0 1 2 3 */
				nil, nil, nil, nil, 		/* 4 5 6 7 */
				nil, nil, "|", "i",		/* 8 9 : ; */
				"<", "n", "<", "i",		/* < = > ? */
				"i", "n", "n", "n",		/* @ A B C */
				"n", "n", "n", "n", 		/* D E F G */
				"!fermata!", "d", "d", "d",	/* H I J K */
				"!emphasis!", "!lowermordent!",
				"d", "!coda!",		/* L M N O */
				"!uppermordent!", "d",
				"d", "!segno!",		/* P Q R S */
				"!trill!", "d", "d", "d",	/* T U V W */
				"n", "d", "n", "[",		/* X Y Z [ */
				"\\","|", "n", "n",		/* \ ] ^ _ */
				"i", "n", "n", "n",	 	/* ` a b c */
				"n", "n", "n", "n",	 	/* d e f g */
				"d", "d", "d", "d",		/* h i j k */
				"d", "d", "d", "d",		/* l m n o */
				"d", "d", "d", "d",		/* p q r s */
				"d", "!upbow!",
				"!downbow!", "d",	/* t u v w */
				"n", "n", "n", "{",		/* x y z { */
				"|", "}", "!gmark!", nil,	/* | } ~ (del) */
			]
			
			private function parse_music_line() : *  {
				var	grace, last_note_sav, a_dcn_sav, no_eol, s,
				tp_a = [], tp,
					tpn = -1,
					tp_fact = 1,
					slur_start = 0,
					line = parse.line
				
				// check if a transposing macro matches a source sequence
				// if yes return the base note
				function check_mac(m) :*  {
					var	i, j, b
					
					for (i = 1, j = line.index + 1; i < m.length; i++, j++) { 
						if (m[i] == line.buffer[j])
							continue
						if (m[i] != 'n')		// search the base note
							return //null
						b = ntb.indexOf(line.buffer[j])
						if (b < 0)
							return //null
						while (line.buffer[j + 1] == "'") { 
							b += 7;
							j++
						}
						while (line.buffer[j + 1] == ',') { 
							b -= 7;
							j++
						}
					}
					line.index = j
					return b
				}
				
				// expand a transposing macro
				function expand(m, b)  :* {
					var	i, c, d,
					r = "",				// result
						n = m.length
					
					for (i = 0; i < n; i++) { 
						c = m[i]
						if (c >= 'h' && c <= 'z') {
							d = b + c.charCodeAt(0) - 'n'.charCodeAt(0)
							c = ""
							while (d < 0) { 
								d += 7;
								c += ','
							}
							while (d > 14) { 
								d -= 7;
								c += "'"
							}
							r += ntb[d] + c
						} else {
							r += c
						}
					}
					return r
				} // expand()
				
				// parse a macro
				function parse_mac(m, b) :*  {
					var	seq,
					line_sav = line,
						istart_sav = parse.istart;
					
					parse.line = line = new scanBuf();
					parse.istart += line_sav.index;
					line.buffer = b ? expand(m, b) : m;
					parse_seq(true);
					parse.line = line = line_sav;
					parse.istart = istart_sav
				}
				
				// parse a music sequence
				function parse_seq(in_mac = false) :*  {
					var	c, idx, type, k, s, dcn, i, n, text
					
					while (1) { 
						c = line.char()
						if (!c)
							break
						
						// special case for '.' (dot)
						if (c == '.') {
							switch (line.buffer[line.index + 1]) {
								case '(':
								case '-':
								case '|':
									c = line.next_char()
									break
							}
						}
						
						idx = c.charCodeAt(0);
						if (idx >= 128) {
							syntax(1, errs.not_ascii);
							line.index++
							break
						}
						
						// check if start of a macro
						if (!in_mac && maci[idx]) {
							n = 0
							for (k in mac) { 
								if (!mac.hasOwnProperty(k)
									|| k[0] != c)
									continue
								if (k.indexOf('n') < 0) {
									if (line.buffer.indexOf(k, line.index)
										!= line.index)
										continue
									line.index += k.length
								} else {
									n = check_mac(k)
									if (!n)
										continue
								}
								parse_mac(mac[k], n);
								n = 1
								break
							}
							if (n)
								continue
						}
						
						type = char_tb[idx]
						switch (type.charAt(0)) {
							case ' ':			// beam break
								s = curvoice.last_note
								if (s) {
									s.beam_end = true
									if (grace)
										grace.gr_shift = true
								}
								break
							case '\n':			// line break
								if (cfmt.barsperstaff)
									break
								if (par_sy.voices[curvoice.v].range == 0
									&& curvoice.last_sym)
									curvoice.last_sym.eoln = true
								break
							case '&':			// voice overlay
								if (grace) {
									syntax(1, errs.bad_char, c)
									break
								}
								c = line.next_char()
								if (c == ')') {
									get_vover(')')
									break
								}
								get_vover('&')
								continue
							case '(':			// slur start - tuplet - vover
								c = line.next_char()
								if (c > '0' && c <= '9') {	// tuplet
									var	pplet = line.get_int();
									var qplet = qplet_tb[pplet];
									var rplet = pplet;
									var c = line.char();
									
									if (c == ':') {
										c = line.next_char()
										if (c > '0' && c <= '9') {
											qplet = line.get_int();
											c = line.char()
										}
										if (c == ':') {
											c = line.next_char()
											if (c > '0' && c <= '9') {
												rplet = line.get_int();
												c = line.char()
											} else {
												syntax(1, "Invalid 'r' in tuplet")
												continue
											}
										}
									}
									if (qplet == 0 || qplet == undefined)
										qplet = (curvoice.wmeasure % 9) == 0 ?
											3 : 2;
									tp = tp_a[++tpn]
									if (!tp)
										tp_a[tpn] = tp = {}
									tp.p = pplet;
									tp.q = qplet;
									tp.r = rplet;
									tp.f = cfmt.tuplets;
									tp.fact	= tp_fact * qplet / pplet;
									tp_fact = tp.fact
									continue
								}
								if (c == '&') {		// voice overlay start
									if (grace) {
										syntax(1, errs.bad_char, c)
										break
									}
									get_vover('(')
									break
								}
								slur_start <<= 4;
								line.index--;
								slur_start += parse_vpos()
								continue
							case ')':			// slur end
								if (curvoice.ignore)
									break
								s = curvoice.last_sym
								if (s) {
									switch (s.type) {
										case C.NOTE:
										case C.REST:
										case C.SPACE:
											break
										default:
											s = null
											break
									}
								}
								if (!s) {
									syntax(1, errs.bad_char, c)
									break
								}
								if (s.slur_end)
									s.slur_end++
								else
									s.slur_end = 1
								break
							case '!':			// start of decoration
								if (!a_dcn)
									a_dcn = []
								if (type.length > 1) {	// decoration letter
									dcn = type.slice(1, -1)
								} else {
									dcn = "";
									i = line.index		// in case no deco end
									while (1) { 
										c = line.next_char()
										if (!c)
											break
										if (c == '!')
											break
										dcn += c
									}
									if (!c) {
										line.index = i;
										syntax(1, "No end of decoration")
										break
									}
								}
								if (ottava[dcn])
									set_ottava(dcn)
								a_dcn.push(dcn)
								break
							case '"':
								parse_gchord(type)
								break
							case '-':
								var tie_pos = 0
								
								if (!curvoice.last_note
									|| curvoice.last_note.type != C.NOTE) {
									syntax(1, "No note before '-'")
									break
								}
								tie_pos = parse_vpos();
								s = curvoice.last_note
								for (i = 0; i <= s.nhd; i++) { 
									if (!s.notes[i].ti1)
										s.notes[i].ti1 = tie_pos
									else if (s.nhd == 0)
										syntax(1, "Too many ties")
								}
								s.ti1 = true
								if (grace)
									grace.ti1 = true
								continue
							case '[':
								var c_next = line.buffer.charAt(line.index + 1);
								
								if ('|[]: "'.indexOf(c_next) >= 0
									|| (c_next >= '1' && c_next <= '9')) {
									if (grace) {
										syntax(1, errs.bar_grace)
										break
									}
									new_bar()
									continue
								}
								if (line.buffer.charAt(line.index + 2) == ':') {
									i = line.buffer.indexOf(']', line.index + 1)
									if (i < 0) {
										syntax(1, "Lack of ']'")
										break
									}
									text = Strings.trim(line.buffer.slice(line.index + 3, i));
									
									parse.istart = parse.bol + line.index;
									parse.iend = parse.bol + ++i;
									line.index = 0;
									do_info(c_next, text);
									line.index = i
									continue
								}
								// fall thru ('[' is start of chord)
							case 'n':				// note/rest
								s = self.new_note(grace, tp_fact)
								if (!s)
									continue
								if (s.type == C.NOTE) {
									if (slur_start) {
										s.slur_start = slur_start;
										slur_start = 0
									}
								}
								if (grace) {
									//fixme: tuplets in grace notes?
									if (tpn >= 0)
										s.in_tuplet = true
									continue
								}
								
								// set the tuplet values
								if (tpn >= 0 && s.notes) {
									s.in_tuplet = true
									//fixme: only one nesting level
									if (tpn > 0) {
										if (tp_a[0].p) {
											s.tp0 = tp_a[0].p;
											s.tq0 = tp_a[0].q;
											s.tf = tp_a[0].f;
											tp_a[0].p = 0
										}
										tp_a[0].r--
										if (tp.p) {
											s.tp1 = tp.p;
											s.tq1 = tp.q;
											s.tf = tp.f;
											tp.p = 0
										}
									} else if (tp.p) {
										s.tp0 = tp.p;
										s.tq0 = tp.q;
										s.tf = tp.f;	// %%tuplets
										tp.p = 0
									}
									tp.r--
									if (tp.r == 0) {
										if (tpn-- == 0) {
											s.te0 = true;
											tp_fact = 1;
											curvoice.time = Math.round(curvoice.time);
											s.dur = curvoice.time - s.time
										} else {
											s.te1 = true;
											tp = tp_a[0]
											if (tp.r == 0) {
												tpn--;
												s.te0 = true;
												tp_fact = 1;
												curvoice.time = Math.round(curvoice.time);
												s.dur = curvoice.time - s.time
											} else {
												tp_fact = tp.fact
											}
										}
									}
								}
								continue
							case '<':				/* '<' and '>' */
								if (!curvoice.last_note) {
									syntax(1, "No note before '<'")
									break
								}
								if (grace) {
									syntax(1, "Cannot have a broken rhythm in grace notes")
									break
								}
								n = c == '<' ? 1 : -1
								while (c == '<' || c == '>') { 
									n *= 2;
									c = line.next_char()
								}
								curvoice.brk_rhythm = n
								continue
							case 'i':				// ignore
								break
							case '{':
								if (grace) {
									syntax(1, "'{' in grace note")
									break
								}
								last_note_sav = curvoice.last_note;
								curvoice.last_note = null;
								a_dcn_sav = a_dcn;
								a_dcn = undefined;
								grace = {
								type: C.GRACE,
									fname: parse.fname,
									istart: parse.bol + line.index,
									dur: 0,
									multi: 0
							}
								switch (curvoice.pos.gst) {
									case C.SL_ABOVE: grace.stem = 1; break
									case C.SL_BELOW: grace.stem = -1; break
									case C.SL_HIDDEN: grace.stem = 2; break	/* opposite */
								}
								sym_link(grace);
								c = line.next_char()
								if (c == '/') {
									grace.sappo = true	// acciaccatura
									break
								}
								continue
							case '|':
								if (grace) {
									syntax(1, errs.bar_grace)
									break
								}
								c = line.buffer.charAt(line.index - 1);
								new_bar()
								if (c == '.')
									curvoice.last_sym.bar_dotted = true
								continue
							case '}':
								s = curvoice.last_note
								if (!grace || !s) {
									syntax(1, errs.bad_char, c)
									break
								}
								if (a_dcn)
									syntax(1, "Decoration ignored");
								s.gr_end = true;
								grace.extra = grace.next;
								grace.extra.prev = null;
								grace.next = null;
								curvoice.last_sym = grace;
								grace = null
								if (!s.prev			// if one grace note
									&& !curvoice.ckey.k_bagpipe) {
									for (i = 0; i <= s.nhd; i++) { 
										s.notes[i].dur *= 2;
									}
									s.dur *= 2;
									s.dur_orig *= 2
									var res = identify_note(s, s.dur_orig);
									s.head = res[0];
									s.dots = res[1];
									s.nflags = res[2]
								}
								curvoice.last_note = last_note_sav;
								a_dcn = a_dcn_sav
								break
							case "\\":
								c = line.buffer.charAt(line.index + 1);
								if (!c) {
									no_eol = true
									break
								}
								// fall thru
							default:
								syntax(1, errs.bad_char, c)
								break
						}
						line.index++
					}
				} // parse_seq()
				
				if (parse.state != 3) {		// if not in tune body
					if (parse.state != 2)
						return
					goto_tune()
				}
				
				parse_seq()
				
				if (tpn >= 0) {
					syntax(1, "No end of tuplet")
					for (s = curvoice.last_note; s; s = s.prev) { 
						if (s.tp1)
							s.tp1 = 0
						if (s.tp0) {
							s.tp0 = 0
							break
						}
					}
				}
				if (grace) {
					syntax(1, "No end of grace note sequence");
					curvoice.last_sym = grace.prev;
					curvoice.last_note = last_note_sav
					if (grace.prev)
						grace.prev.next = null
				}
				if (cfmt.breakoneoln && curvoice.last_note)
					curvoice.last_note.beam_end = true
				if (no_eol || cfmt.barsperstaff)
					return
				if (char_tb['\n'.charCodeAt(0)] == '\n'
					&& par_sy.voices[curvoice.v].range == 0
					&& curvoice.last_sym)
					curvoice.last_sym.eoln = true
				//--fixme: cfmt.alignbars
			}
			
			// ---------------------------------------
			
			
			// abc2svg - subs.js - text output
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			/* width of characters according to the encoding */
			/* these are the widths for Times-Roman, extracted from the 'a2ps' package */
			
			private var cw_tb : Vector.<Number> = Vector.<Number> ([
				.000,.000,.000,.000,.000,.000,.000,.000,	// 00
				.000,.000,.000,.000,.000,.000,.000,.000,
				.000,.000,.000,.000,.000,.000,.000,.000,	// 10
				.000,.000,.000,.000,.000,.000,.000,.000,
				.250,.333,.408,.500,.500,.833,.778,.333,	// 20
				.333,.333,.500,.564,.250,.564,.250,.278,
				.500,.500,.500,.500,.500,.500,.500,.500,	// 30
				.500,.500,.278,.278,.564,.564,.564,.444,
				.921,.722,.667,.667,.722,.611,.556,.722,	// 40
				.722,.333,.389,.722,.611,.889,.722,.722,
				.556,.722,.667,.556,.611,.722,.722,.944,	// 50
				.722,.722,.611,.333,.278,.333,.469,.500,
				.333,.444,.500,.444,.500,.444,.333,.500,	// 60
				.500,.278,.278,.500,.278,.778,.500,.500,
				.500,.500,.333,.389,.278,.500,.500,.722,	// 70
				.500,.500,.444,.480,.200,.480,.541,.500
			]);
			
			/* -- return the character width -- */
			private function cwid(c) : *  {
				var i = c.charCodeAt(0)		// utf-16
				
				if (i >= 0x80) {		// if not ASCII
					if (i >= 0x300 && i < 0x370)
						return 0;	// combining diacritical mark
					i = 0x61		// 'a'
				}
				return cw_tb[i]
			}
			
			/**
			 * Estimates the width and height of a string.
			 */
			private function strwh (str : String) : Array {
				var	font : Object = gene.curfont;
				var swfac : Number = font.swfac;
				var h : Number = font.size;
				var w : Number = 0;
				var i : int;
				var j : int; 
				var c : String;
				var n : int = str.length;
				
				for (i = 0; i < n; i++) { 
					c = str.charAt(i);
					switch (c) {
						case '$':
							c = str[i + 1];
							if (c == '0') {
								font = gene.deffont;
							} else if (c >= '1' && c <= '9') {
								font = get_font("u" + c);
							} else {
								c = '$';
								break;
							}
							i++;
							swfac = font.swfac;
							if (font.size > h) {
								h = font.size;
							}
							continue;
						case '&':
							j = str.indexOf(';', i);
							if (j > 0 && j - i < 10) {
								i = j;
								
								// XML character reference
								c = 'a';
							}
							break;
					}
					w += cwid(c) * swfac;
				}
				gene.curfont = font;
				return [w, h];
			}
			
			// set the default and current font
			private function set_font(xxx) : *  {
				if (typeof xxx == "string")
					xxx = get_font(xxx);
				gene.curfont = gene.deffont = xxx
			}
			
			// output a string handling the font changes
			private function out_str(str) : *  {
				var	n_font,
				o_font = gene.curfont,
					c_font = o_font;
				
				output += str.replace(/<|>|&.*?;|&|  |\$./g, function(c) :* {
					switch (c.charAt(0)) {
						case '<': return "&lt;"
						case '>': return "&gt;"
						case '&':
							if (c == '&')
								return "&amp;"
							return c;
						case ' ':
							return '  '		// space + nbspace
						case '$':
							if (c.charAt(1) == '0') {
								n_font = gene.deffont;
								use_font(n_font)
							} else if (c.charAt(1) >= '1' && c.charAt(1) <= '9')
								n_font = get_font("u" + c.charAt(1))
							else
								return c;
							c = '';
							if (n_font == c_font)
								return c;
							if (c_font != o_font)
								c = "</tspan>";
							c_font = n_font
							if (c_font == o_font)
								return c;
							return c + '<tspan class="' +
							font_class(n_font) + '">'
					}
				})
				if (c_font != o_font) {
					output += "</tspan>";
					gene.curfont = c_font	// keep current font for next paragraph
				}
			}
			
			/**
			 * Outputs a string, also handling font changes.
			 * 
			 * @param	x - The horizontal point of the text anchor.
			 * 
			 * @param	y - The vertical point of the text anchor.
			 * 
			 * @param	str - The string to output in the resulting SVG document.
			 * 
			 * @param	action
			 * 			Optional. How to align the text. Accepted values are:
			 * 			- "c": center the text;
			 * 			- "j": justify the text using the char limit provided by the `line_w` parameter;
			 * 			- "r": right align the text.
			 * 			By default `action` is `null`, which left aligns the text.
			 * 
			 * @param	line_w
			 * 			Optional. The number of chars to wrap the text to if `action` was "j".
			 * 
			 * @param	id
			 * 			Optional. A string to set as the "id" attribute on the resulting SVG text element.
			 * 			
			 */
			private function xy_str (x : Number, y : Number, str : String, action : String = null,
									 line_w : Number = NaN, id : String = null, cssClass : String = null) : void {
				var	wh : Array = strwh (str);
				var w : Number = wh[0] as Number;
				var	h : Number = wh[1] as Number;
				var hotspotX : Number = sx(x-2);
				
				// A bit upper for the descent
				y += h * .2;
				id = (id || '');
				output += '<text class="' + font_class (gene.curfont) + '" id="' + id + '" x="';
				out_sxsy (x, '" y="', y + 1);
				switch (action) {
					case 'c':
						output += '" text-anchor="middle">';
						hotspotX -= w * .5; 
						break;
					case 'j':
						if (line_w) {
							output += '" textLength="' + line_w.toFixed(2) + '">';
						}
						break;
					case 'r':
						output += '" text-anchor="end">';
						hotspotX -= w;
						break;
					default:
						output += '">';
						break;
				}
				out_str (str);
				output += "</text>\n";
				if (id) {
					addHotspot (cssClass || "annot", hotspotX, sy(y + h + 2), w + 4, h + 3, id);
				}
			}
			
			/**
			 * Outputs a string in a box.
			 */
			private function xy_str_b (x : Number, y : Number, str : String, action : String = null,
									   line_w : Number = NaN, id : String = null, cssClass : String = null) : void {
				var	wh : Array = strwh (str);
				var w : Number = wh[0] as Number;
				var	h : Number = wh[1] as Number;
				output += '<rect class="stroke" x="';
				out_sxsy(x - 2, '" y="', y + h + 4);
				output += '" width="' + (w + 4).toFixed(2) +
					'" height="' + (h + 3).toFixed(2) +
					'"/>\n';
				xy_str (x, y + 1, str, null, line_w, id);
				if (id) {
					addHotspot (cssClass || "annot", sx(x-2), sy(y + h + 2), w + 4, h + 3, id);
				}
			}
			
			/**
			 * Moves trailing "The" to front, sets to uppercase letters or adds xref
			 */
			private function trim_title (title : String, is_subtitle : Boolean) : String {
				var i : int;
				if (cfmt.titletrim) {
					i = title.lastIndexOf (", ");
					if (i < 0 || title.charAt(i + 2) < 'A' || title.charAt(i + 2) > 'Z') {
						i = 0;
					} 
					
					// Compatibility
					else if (cfmt.titletrim == true) {	
						if (i < title.length - 7 || title.indexOf(' ', i + 3) >= 0) {
							i = 0;
						}
					} else {
						if (i < title.length - cfmt.titletrim - 2) {
							i = 0;
						}
					}
				}
				if (!is_subtitle && cfmt.writefields.indexOf('X') >= 0) {
					title = info.X + '.  ' + title;
				}
				if (i) {
					title = Strings.trim (title.slice(i + 2)) + ' ' + title.slice(0, i);
				}
				if (cfmt.titlecaps) {
					return title.toUpperCase();
				}
				return title;
			}
			
			// return the width of the music line
			private function get_lwidth() : *  {
				return (img.width - img.lm - img.rm
					- 2)	// for bar thickness at eol
				/ cfmt.scale
			}
			
			/**
			 * Outputs the title of the piece.
			 */ 
			private function write_title (title : String, is_subtitle : Boolean) : void {
				var h : Number;
				var nameSegments : Array;
				var projId : String;
				
				// If the title is encoded with an ID, separate them and
				// tag the resulting SVG text element with the ID
				if (title.indexOf('¦') != -1) {
					nameSegments = title.split ('¦');
					projId = nameSegments[0] as String;
					title = nameSegments.pop() as String;
				}
				
				if (!title) {
					return;
				}
				set_page();
				title = trim_title (title, is_subtitle);
				if (is_subtitle) {
					set_font("subtitle");
					h = cfmt.subtitlespace;
				} else {
					set_font("title");
					h = cfmt.titlespace;
				}
				vskip (strwh(title)[1] + h);
				if (cfmt.titleleft) {
					xy_str (0, 0, title, null, NaN, projId);
				}
				else {
					xy_str (get_lwidth() / 2, 0, title, "c", NaN, projId);
				}
				pageY = sy(h);
			}
			
			/**
			 * Outputs a header in format '111 (222)'
			 */
			private function put_inf2r (x : Number, y : Number, str1 : String, str2 : String, action : String) : void {
				if (!str1) {
					if (!str2) {
						return;
					}
					str1 = str2;
					str2 = null;
				}
				
				// If this header field is encoded with an ID, separate them and
				// tag the resulting SVG text element with the ID
				var nameSegments : Array;
				var fieldId : String;
				if (str1.indexOf('¦') != -1) {
					nameSegments = str1.split ('¦');
					fieldId = nameSegments[0] as String;
					str1 = nameSegments.pop() as String;
				}
				if (!str2) {
					xy_str (x, y, str1, action, NaN, fieldId);
				}
				else {
					xy_str (x, y, str1 + ' (' + str2 + ')', action, NaN, fieldId);
				}
			}
			
			// let vertical room for a text line
			private function str_skip(str) : *  {
				vskip(strwh(str)[1] * cfmt.lineskipfac)
			}
			
			/* -- write a text block (%%begintext / %%text / %%center) -- */
			private var write_text = function(text, action) :* {
				if (action == 's')
					return				// skip
				set_font("text");
				set_page();
				var	strlw = get_lwidth(),
					sz = gene.curfont.size,
					lineskip = sz * cfmt.lineskipfac,
					parskip = sz * cfmt.parskipfac,
					p_start = block.started ? function() :* {} : blk_out,
					p_flush = block.started ? svg_flush : blk_flush,
					i, j, x, words, w, k, ww, str;
				
				p_start()
				switch (action) {
					default:
						//	case 'c':
						//	case 'r':
						switch (action) {
							case 'c': x = strlw / 2; break
							case 'r': x = strlw; break
							default: x = 0; break
						}
						j = 0
						while (1) { 
							i = text.indexOf('\n', j)
							if (i < 0) {
								str = text.slice(j);
								str_skip(str);
								xy_str(x, 0, str, action)
								break
							}
							if (i == j) {			// new paragraph
								vskip(parskip);
								p_flush();
								use_font(gene.curfont)
								while (text[i + 1] == '\n') { 
									vskip(lineskip);
									i++
								}
								if (i == text.length)
									break
								p_start()
							} else {
								str = text.slice(j, i);
								str_skip(str);
								xy_str(x, 0, str, action)
							}
							j = i + 1
						}
						vskip(parskip);
						p_flush()
						break
					case 'f':
					case 'j':
						j = 0
						while (1) { 
							i = text.indexOf('\n\n', j)
							if (i < 0)
								words = text.slice(j)
							else
								words = text.slice(j, i);
							words = words.split(/\s+/);
							w = k = 0
							for (j = 0; j < words.length; j++) { 
								ww = strwh(words[j] + ' ')[0];
								w += ww
								if (w >= strlw) {
									str = words.slice(k, j).join(' ');
									str_skip(str);
									xy_str(0, 0, str, action, strlw);
									k = j;
									w = ww
								}
							}
							if (w != 0) {
								str = words.slice(k).join(' ');
								str_skip(str);
								xy_str(0, 0, str)
							}
							vskip(parskip);
							p_flush()
							if (i < 0)
								break
							while (text[i + 2] == '\n') { 
								vskip(lineskip);
								i++
							}
							if (i == text.length)
								break
							p_start();
							use_font(gene.curfont);
							j = i + 2
						}
						break
				}
			}
			
			/* -- output the words after tune -- */
			private function put_words(words) : *  {
				var p, i, j, n, nw, i2, i_end, have_text;
				
				// output a line of words after tune
				function put_wline(p, x, right) :*  {
					var i = 0, j, k
					
					if (p[i] == '$' && p[i +  1] >= '0' && p[i + 1] <= '9')
						i += 2;
					k = 0;
					j = i
					if ((p[i] >= '0' && p[i] <= '9') || p[i + 1] == '.') {
						while (i < p.length) { 
							i++
							if (p[i] == ' '
								|| p[i - 1] == ':'
								|| p[i - 1] == '.')
							break
						}
						k = i
						while (p[i] == ' ') { 
							i++;
						}
					}
					
					if (k != 0)
						xy_str(x, 0, p.slice(j, k), 'r')
					if (i < p.length)
						xy_str(x + 5, 0, p.slice(i), 'l')
					return i >= p.length && k == 0
				} // put_wline()
				
				blk_out();
				set_font("words")
				
				/* see if we may have 2 columns */
				var	middle = get_lwidth() / 2,
					max2col = (middle - 45.) / (cwid('a') * gene.curfont.swfac);
				n = 0;
				words = words.split('\n');
				nw = words.length
				for (i = 0; i < nw; i++) { 
					p = words[i]
					/*fixme:utf8*/
					if (p.length > max2col) {
						n = 0
						break
					}
					if (!p) {
						if (have_text) {
							n++;
							have_text = false
						}
					} else {
						have_text = true
					}
				}
				if (n > 0) {
					i = n = ((n + 1) / 2) | 0;
					have_text = false
					for (i_end = 0; i_end < nw; i_end++) { 
						p = words[i_end];
						j = 0
						while (p[j] == ' ') { 
							j++;
						}
						if (j == p.length) {
							if (have_text && --i <= 0)
								break
							have_text = false
						} else {
							have_text = true
						}
					}
					i2 = i_end + 1
				} else {
					i2 = i_end = nw
				}
				
				/* output the text */
				vskip(cfmt.wordsspace)
				
				for (i = 0; i < i_end || i2 < nw; i++) { 
					//fixme:should also permit page break on stanza start
					if (i < i_end && words[i].length == 0) {
						blk_out();
						use_font(gene.curfont)
					}
					vskip(cfmt.lineskipfac * gene.curfont.size)
					if (i < i_end)
						put_wline(words[i], 45., 0)
					if (i2 < nw) {
						if (put_wline(words[i2], 20. + middle, 1)) {
							if (--n == 0) {
								if (i < i_end) {
									n++
								} else if (i2 < words.length - 1) {
									
									/* center the last words */
									/*fixme: should compute the width average.. */
									middle *= .6
								}
							}
						}
						i2++
					}
				}
			}
			
			/* -- output history -- */
			private function put_history() : *  {
				var	i, j, c, str, font, h, w, head,
				names = cfmt.infoname.split("\n"),
					n = names.length
				
				for (i = 0; i < n; i++) { 
					c = (names[i] as String).charAt(0);
					if (cfmt.writefields.indexOf(c) < 0)
						continue
					str = info[c]
					if (!str)
						continue
					if (!font) {
						font = true;
						set_font("history");
						vskip(cfmt.textspace);
						h = gene.curfont.size * cfmt.lineskipfac
					}
					head = names[i].slice(2)
					if (head[0] == '"')
						head = head.slice(1, -1);
					vskip(h);
					xy_str(0, 0, head);
					w = strwh(head)[0];
					str = str.split('\n');
					xy_str(w, 0, str[0])
					for (j = 1; j < str.length; j++) { 
						vskip(h);
						xy_str(w, 0, str[j])
					}
					vskip(h * .3);
					blk_out();
					use_font(gene.curfont)
				}
			}
			
			/* -- write heading with format -- */
			private var info_font_init = {
				A: "info",
				C: "composer",
				O: "composer",
				P: "parts",
				Q: "tempo",
				R: "info",
				T: "title",
				X: "title"
			}
			private function write_headform(lwidth) : *  {
				var	c, font, font_name, align, x, y, sz,
				info_val = {},
					info_font = clone(info_font_init),
					info_sz = {
						A: cfmt.infospace,
							C: cfmt.composerspace,
							O: cfmt.composerspace,
							R: cfmt.infospace
					},
					info_nb = {}
				
				// compress the format
				var	fmt = "",
					p = cfmt.titleformat,
					j = 0,
					i = 0
				
				while (1) { 
					while (p[i] == ' ') { 
						i++;
					}
					if (i >= p.length)
					break
					c = p[i++]
					if (c < 'A' || c > 'Z') {
						if (c == '+') {
							if (fmt.length == 0
								|| fmt.slice(-1) == '+')
								continue
							fmt = fmt.slice(0, -1) + '+'
						} else if (c == ',') {
							if (fmt.slice(-1) == '+')
								fmt = fmt.slice(0, -1) + 'l'
							fmt += '\n'
						}
						continue
					}
					if (!info_val[c]) {
						if (!info[c])
							continue
						info_val[c] = info[c].split('\n');
						info_nb[c] = 1
					} else {
						info_nb[c]++
					}
					fmt += c
					switch (p[i]) {
						case '-':
							fmt += 'l'
							i++
							break
						case '0':
							fmt += 'c'
							i++
							break
						case '1':
							fmt += 'r'
							i++
							break
						default:
							fmt += 'c'
							break
					}
				}
				if (fmt.slice(-1) == '+')
					fmt = fmt.slice(0, -1) + 'l';
				fmt += '\n'
				
				// loop on the blocks
				var	ya = {
					l: cfmt.titlespace,
						c: cfmt.titlespace,
						r: cfmt.titlespace
				},
					xa = {
						l: 0,
						c: lwidth * .5,
							r: lwidth
					},
					yb = {},
					str;
				p = fmt;
				i = 0
				while (1) { 
					
					// get the y offset of the top text
					yb.l = yb.c = yb.r = y = 0;
					j = i
					while (1) { 
						c = p[j++]
						if (c == '\n')
							break
						align = p[j++]
						if (align == '+')
							align = p[j + 1]
						else if (yb[align] != 0)
							continue
						str = info_val[c]
						if (!str)
							continue
						font_name = info_font[c]
						if (!font_name)
							font_name = "history";
						font = get_font(font_name);
						sz = font.size * 1.1
						if (info_sz[c])
							sz += info_sz[c]
						if (y < sz)
							y = sz;
						yb[align] = sz
					}
					ya.l += y - yb.l;
					ya.c += y - yb.c;
					ya.r += y - yb.r
					while (1) { 
						c = p[i++]
						if (c == '\n')
							break
						align = p[i++]
						if (info_val[c].length == 0)
							continue
						str = info_val[c].shift()
						if (align == '+') {
							info_nb[c]--;
							c = p[i++];
							align = p[i++]
							if (info_val[c].length > 0) {
								if (str)
									str += ' ' + info_val[c].shift()
								else
									str = ' ' + info_val[c].shift()
							}
						}
						font_name = info_font[c]
						if (!font_name)
							font_name = "history";
						font = get_font(font_name);
						sz = font.size * 1.1
						if (info_sz[c])
							sz += info_sz[c];
						set_font(font);
						x = xa[align];
						y = ya[align] + sz
						
						if (c == 'Q') {			/* special case for tempo */
							if (!glovar.tempo.del) {
								if (align != 'l') {
									var w = tempo_width(glovar.tempo)
									
									if (align == 'c')
										w *= .5;
									x -= w
								}
								write_tempo(glovar.tempo, x, -y)
							}
						} else if (str) {
							xy_str(x, -y, str, align)
						}
						
						if (c == 'T') {
							font_name = info_font.T = "subtitle";
							info_sz.T = cfmt.subtitlespace
						}
						if (info_nb[c] <= 1) {
							if (c == 'T') {
								font = get_font(font_name);
								sz = font.size * 1.1
								if (info_sz[c])
									sz += info_sz[c];
								set_font(font)
							}
							while (info_val[c].length > 0) { 
								y += sz;
								str = info_val[c].shift();
								xy_str(x, -y, str, align)
							}
						}
						info_nb[c]--;
						ya[align] = y
					}
					if (ya.c > ya.l)
						ya.l = ya.c
					if (ya.r > ya.l)
						ya.l = ya.r
					if (i >= fmt.length)
						break
					ya.c = ya.r = ya.l
				}
				vskip(ya.l)
			}
			
			/* -- output the tune heading -- */
			private function write_heading() : *  {
				var	i, j, area, composer, origin, rhythm, down1, down2,
				lwidth = get_lwidth()
				
				blk_out();
				vskip(cfmt.topspace)
				
				if (cfmt.titleformat) {
					write_headform(lwidth);
					vskip(cfmt.musicspace)
					return
				}
				
				/* titles */
				if (info.T
					&& cfmt.writefields.indexOf('T') >= 0) {
					i = 0
					while (1) { 
						j = info.T.indexOf("\n", i)
						if (j < 0) {
							write_title(info.T.substring(i), i != 0)
							break
						}
						write_title(info.T.slice(i, j), i != 0);
						i = j + 1
					}
				}
				
				/* rhythm, composer, origin */
				set_font("composer");
				//	down1 = cfmt.composerspace + gene.curfont.size
				down1 = down2 = 0
				if (parse.ckey.k_bagpipe
					&& !cfmt.infoline
					&& cfmt.writefields.indexOf('R') >= 0)
					rhythm = info.R
				if (rhythm) {
					xy_str(0, -cfmt.composerspace, rhythm);
					down1 = cfmt.composerspace
				}
				area = info.A
				if (cfmt.writefields.indexOf('C') >= 0)
					composer = info.C
				if (cfmt.writefields.indexOf('O') >= 0)
					origin = info.O
				if (composer || origin || cfmt.infoline) {
					var xcomp, align;
					
					vskip(cfmt.composerspace)
					if (cfmt.aligncomposer < 0) {
						xcomp = 0;
						align = ' '
					} else if (cfmt.aligncomposer == 0) {
						xcomp = lwidth * .5;
						align = 'c'
					} else {
						xcomp = lwidth;
						align = 'r'
					}
					down2 = down1
					if (composer || origin) {
						if (cfmt.aligncomposer >= 0
							&& down1 != down2)
							vskip(down1 - down2);
						i = 0
						while (1) { 
							vskip(gene.curfont.size)
							if (composer)
								j = composer.indexOf("\n", i)
							else
								j = -1
							if (j < 0) {
								put_inf2r(xcomp, 0,
									composer ? composer.substring(i) : null,
									origin,
									align)
								break
							}
							xy_str(xcomp, 0, composer.slice(i, j), align);
							down1 += gene.curfont.size;
							i = j + 1
						}
						if (down2 > down1)
							vskip(down2 - down1)
					}
					
					rhythm = rhythm ? null : info.R
					if ((rhythm || area) && cfmt.infoline) {
						
						/* if only one of rhythm or area then do not use ()'s
						* otherwise output 'rhythm (area)' */
						set_font("info");
						vskip(gene.curfont.size + cfmt.infospace);
						put_inf2r(lwidth, 0, rhythm, area, 'r');
						down1 += gene.curfont.size + cfmt.infospace
					}
					//		down2 = 0
				} else {
					down2 = cfmt.composerspace
				}
				
				/* parts */
				if (info.P
					&& cfmt.writefields.indexOf('P') >= 0) {
					set_font("parts");
					down1 = cfmt.partsspace + gene.curfont.size - down1
					if (down1 > 0)
						down2 += down1
					if (down2 > .01)
						vskip(down2);
					xy_str(0, 0, info.P);
					down2 = 0
				}
				vskip(down2 + cfmt.musicspace)
			}
			
			// ----------------------------
			
			// abc2svg - svg.js - svg functions
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			// Output buffer
			private var output : String = "";
			
			private var style : String = '\n';
			
			private var font_style : String = '';
			
			// Default x offset of the images
			private var posx : Number = cfmt.leftmargin / cfmt.scale;
			
			// Y offset in the block
			private var posy : Number = 0;
			
			// Image width, left and right margins
			private var img : Object = {
				width: cfmt.pagewidth,
					lm: cfmt.leftmargin,	
					rm: cfmt.rightmargin
			};
			private var defined_glyph : Object = {};
			private var defs : String = '';
			
			// Unreferenced defs as <filter>
			private var fulldefs : String = '';
			
			// Staff/voice graphic parameters
			// Color: undefined
			private var stv_g : Object = {
				scale: 1,
				dy: 0,
				st: -1,
				v: 0,
				g: 0
			};
		
			// Started & newpage
			private var block : Object = {};
			
			// glyphs in music font
			private var tgls : Object = {
				brace: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue000", def:'#brace'},
				hl: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue022", def:'#hl'},
				hl1: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue023", def:'#hl1'},
				hl2: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue023", def:'#hl2'},
				ghl: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue024", def:'#ghl'},
				lphr: { hsX : 0, hsY: 0, x:0, y:24, c:"\ue030", def:'#lphr'},
				mphr: { hsX : 0, hsY: 0, x:0, y:24, c:"\ue038", def:'#mphr'},
				sphr: { hsX : 0, hsY: 0, x:0, y:27, c:"\ue039", def:'#sphr'},
				rdots: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue043", def:'#rdots'},	// repeat dots
				dsgn: { hsX : 0, hsY: 0, x:0, y:-4, c:"\ue045"},	// D.S.
				dcap: { hsX : 0, hsY: 0, x:0, y:-4, c:"\ue046"},	// D.C.
				sgno: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue047", def:'#sgno'},	// segno
				coda: { hsX : 0, hsY: 0, x:0, y:-6, c:"\ue048", def:'#coda'},
				tclef: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue050", def:'#tclef'},
				cclef: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue05c", def:'#cclef'},
				bclef: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue062", def:'#bclef'},
				pclef: { hsX : 0, hsY: 0, x:-6, y:0, c:"\ue069", def:'#pclef'},
				spclef: { hsX : 0, hsY: 0, x:-6, y:0, c:"\ue069"},
				stclef: { hsX : 0, hsY: 0, x:-8, y:0, c:"\ue07a", def:'#stclef'},
				scclef: { hsX : 0, hsY: 0, x:-8, y:0, c:"\ue07b", def:'#scclef'},
				sbclef: { hsX : 0, hsY: 0, x:-7, y:0, c:"\ue07c", def:'#sbclef'},
				oct: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue07d", def:'#oct'}, // 8 for clefs
				meter0: { hsX : 0, hsY: 0, c:"\ue080", def:'#meter0', defW:90},
				meter1: { hsX : 0, hsY: 0, c:"\ue081", def:'#meter1', defW:60},
				meter2: { hsX : 0, hsY: 0, c:"\ue082", def:'#meter2', defW:80},
				meter3: { hsX : 0, hsY: 0, c:"\ue083", def:'#meter3', defW:80},
				meter4: { hsX : 0, hsY: 0, c:"\ue084", def:'#meter4', defW:80},
				meter5: { hsX : 0, hsY: 0, c:"\ue085", def:'#meter5', defW:80},
				meter6: { hsX : 0, hsY: 0, c:"\ue086", def:'#meter6', defW:77},
				meter7: { hsX : 0, hsY: 0, c:"\ue087", def:'#meter7', defW:80},
				meter8: { hsX : 0, hsY: 0, c:"\ue088", def:'#meter8', defW:80},
				meter9: { hsX : 0, hsY: 0, c:"\ue089", def:'#meter9', defW:80},
				"meter+": { hsX : 0, hsY: 0, c:"\ue08c"},
				"meter(": { hsX : 0, hsY: 0, c:"\ue094"},
				"meter)": { hsX : 0, hsY: 0, c:"\ue095"},
				csig: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue08a", def:'#csig'},		// common time
				ctsig: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue08b", def:'#ctsig'},	// cut time
				HDD: { hsX : 0, hsY: 0, x:-7, y:0, c:"\ue0a0", def:'#HDD'},
				breve: { hsX : 0, hsY: 0, x:-6, y:0, c:"\ue0a1", def:'#breve'},
				HD: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue0a2", def:'#HD'},
				Hd: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue0a3", def:'#Hd'},
				hd: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue0a4", def:'#hd'},
				ghd: { hsX : 0, hsY: 0, x:2, y:0, c:"\ue0a4", sc:.66, def:'#ghd'},	// grace note head
				pshhd: { hsX : 0, hsY: 0, x:-3.7, y:0, c:"\ue0a9", def:'#pshhd'},
				pfthd: { hsX : 0, hsY: 0, x:-3.7, y:0, c:"\ue0b3", def:'#pfthd'},
				x: { hsX : 0, hsY: 0, x:-3.7, y:0, c:"\ue0a9"},		// 'x' note head
				"circle-x": { hsX : 0, hsY: 0, x:-3.7, y:0, c:"\ue0b3"}, // 'circle-x' note head
				srep: { hsX : 0, hsY: 0, x:-5, y:0, c:"\ue101", def:'#srep'},
				diamond: { hsX : 0, hsY: 0, x:-4, y:0, c:"\ue1b9"},
				triangle: { hsX : 0, hsY: 0, x:-4, y:0, c:"\ue1bb"},
				dot: { hsX : 0, hsY: 0, x:-1.5, y:1, c:"\ue1e7", def:'#dot'},
				"acc-1": { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue260", def:'#ft0'},	// flat
				acc3: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue261", def:'#nt0'},	// natural
				acc1: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue262", def:'#sh0'},	// sharp
				acc2: { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue263", def:'#dsh0'},	// double sharp
				"acc-2": { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue264", def:'#dft0'},	// double flat
				"acc-1_1_4": { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue280"},	// quarter-tone flat
				"acc-1_3_4": { hsX : 0, hsY: 0, x:-4, y:0, c:"\ue281"},	// three-quarter-tones flat
				acc1_1_4: { hsX : 0, hsY: 0, x:-2, y:0, c:"\ue282"},	// quarter-tone sharp
				acc1_3_4: { hsX : 0, hsY: 0, x:-4, y:0, c:"\ue283"},	// three-quarter-tones sharp
				accent: { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue4a0", def:'#accent'},
				stc: { hsX : 0, hsY: 0, x:-1, y:-2, c:"\ue4a2", def:'#stc'},	// staccato
				emb: { hsX : 0, hsY: 0, x:-4, y:-2, c:"\ue4a4", def:'#emb'},
				wedge: { hsX : 0, hsY: 0, x:-1, y:0, c:"\ue4a8", def:'#wedge'},
				marcato: { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue4ac", def:'#marcato'},
				hld: { hsX : 0, hsY: 0, x:-7, y:0, c:"\ue4c0", def:'#hld'},		// fermata
				brth: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue4ce"},
				r00: { hsX : 0, hsY: 0, x:-1.5, y:0, w:12, h:6, c:"\ue4e1", def:'#r00'},
				r0: { hsX : 0, hsY: 0, x:-1.5, y:0, w:12, h:6, c:"\ue4e2", def:'#r0'},
				r1: { hsX : -1, hsY: -5, x:0, y:0.55, w:14, h:10, c:"\ue4e3", def:'#r1'},
				r2: { hsX : -1, hsY: -1.5, x:0, y:-0.55, w:14, h:10, c:"\ue4e4", def:'#r2'},
				r4: { hsX : 0, hsY: 0, x:0, y:0, w:12, h:18, c:"\ue4e5", def:'#r4'},
				r8: { hsX : 0, hsY: 0, x:0, y:0, w:12, h:16, c:"\ue4e6", def:'#r8'},
				r16: { hsX : -1, hsY: 3, x:0, y:0, w:12, h:22, c:"\ue4e7", def:'#r16'},
				r32: { hsX : -0.5, hsY: 0, x:0, y:0, w:12, h:28, c:"\ue4e8", def:'#r32'},
				r64: { hsX : -1.1, hsY: 3, x:0, y:0, w:11, h:32, c:"\ue4e9", def:'#r64'},
				r128: { hsX : 0, hsY: 0, x:0, y:0, w:26, h:30, c:"\ue4ea", def:'#r128'},
				mrest: { hsX : 0, hsY: 0, x:-10, y:0, c:"\ue4ee", def:'#mrest'},
				mrep: { hsX : 0, hsY: 0, x:-6, y:0, c:"\ue500", def:'#mrep'},
				mrep2: { hsX : 0, hsY: 0, x:-9, y:0, c:"\ue501", def:'#mrep2'},
				p: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue520"},
				f: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue522"},
				pppp: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue529"},
				ppp: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue52a"},
				pp: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue52b"},
				mp: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue52c"},
				mf: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue52d"},
				ff: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue52f"},
				fff: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue530"},
				ffff: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue531"},
				sfz: { hsX : 0, hsY: 0, x:-4, y:-6, c:"\ue539", def:'#sfz'},
				trl: { hsX : 0, hsY: 0, x:-4, y:-4, c:"\ue566", def:'#trl'},	// trill
				turn: { hsX : 0, hsY: 0, x:-5, y:-4, c:"\ue567", def:'#turn'},
				turnx: { hsX : 0, hsY: 0, x:-5, y:-4, c:"\ue569", def:'#turnx'},
				umrd: { hsX : 0, hsY: 0, x:-7, y:-2, c:"\ue56c", def:'#umrd'},
				lmrd: { hsX : 0, hsY: 0, x:-7, y:-2, c:"\ue56d", def:'#lmrd'},
				dplus: { hsX : 0, hsY: 0, x:-4, y:10, c:"\ue582", def:'#dplus'},	// plus
				sld: { hsX : 0, hsY: 0, x:-8, y:12, c:"\ue5d4", def:'#sld'},	// slide
				grm: { hsX : 0, hsY: 0, x:-2, y:0, c:"\ue5e2", def:'#grm'},		// grace mark
				dnb: { hsX : 0, hsY: 0, x:-4, y:0, c:"\ue610", def:'#dnb'},		// down bow
				upb: { hsX : 0, hsY: 0, x:-3, y:0, c:"\ue612", def:'#upb'},		// up bow
				opend: { hsX : 0, hsY: 0, x:-2, y:0, c:"\ue614", def:'#opend'},	// harmonic
				roll: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue618"},
				thumb: { hsX : 0, hsY: 0, x:0, y:0, c:"\ue624", def:'#thumb'},
				snap: { hsX : 0, hsY: 0, x:-2, y:0, c:"\ue630", def:'#snap'},
				ped: { hsX : 0, hsY: 0, x:-10, y:0, c:"\ue650", def:'#ped'},
				pedoff: { hsX : 0, hsY: 0, x:-5, y:0, c:"\ue655", def:'#pedoff'},
				pMsig: { hsX : 0, hsY: 0, x:-6, y:-12, c:"\ue910", def:'#pMsig'},	// M:o.
				pmsig: { hsX : 0, hsY: 0, x:-6, y:-12, c:"\ue911", def:'#pmsig'},	// M:o
				iMsig: { hsX : 0, hsY: 0, x:-6, y:-12, c:"\ue914", def:'#iMsig'},	// M:c.
				imsig: { hsX : 0, hsY: 0, x:-6, y:-12, c:"\ue915", def:'#imsig'},	// M:c
				longa: { hsX : 0, hsY: 0, x:-6, y:0, c:"\ue95c", def:'#longa'},
				custos: { hsX : 0, hsY: 0, x:-4, y:3, c:"\uea02", def:'#custos'},
				ltr: { hsX : 0, hsY: 0, x:2, y:6, c:"\ueaa4", def:'#ltr'}		// long trill element
			}
			
			// glyphs to put in <defs>
			private var glyphs : Object = {
			}
			
			// Mark a glyph as used and add it in <defs>
			private function def_use (gl : String) : void {
				var	i, j, g;
				
				if (defined_glyph[gl]) {
					return;
				}
				defined_glyph[gl] = true;
				g = glyphs[gl];
				if (!g) {
					error (1, null, "Unknown glyph: '$1'", gl)
					return;	// fixme: the xlink is already set!
				}
				j = 0;
				while (true) { 
					i = g.indexOf ('xlink:href="#', j);
					if (i < 0) {
						break;
					}
					i += 13;
					j = g.indexOf ('"', i);
					def_use (g.slice (i, j));
				}
				defs += '\n' + g;
			}
			
			// add user defs from %%beginsvg
			private function defs_add(text) : *  {
				var	i, j, gl, tag, $is,
				ie = 0
				
				// remove XML comments
				text = text.replace(/<!--.*?-->/g, '')
				
				while (1) { 
					$is = text.indexOf('<', ie);
					if ($is < 0)
						break
					i = text.indexOf('id="', $is)
						if (i < 0)
							break
						i += 4;
					j = text.indexOf('"', i);
					if (j < 0)
						break
					gl = text.slice(i, j);
					ie = text.indexOf('>', j);
					if (ie < 0)
						break
					if (text[ie - 1] == '/') {
						ie++
					} else {
						i = text.indexOf(' ', $is);
						if (i < 0)
							break
						tag = text.slice($is + 1, i);
						ie = text.indexOf('</' + tag + '>', ie)
						if (ie < 0)
							break
						ie += 3 + tag.length
					}
					if (text.substr($is, 7) == '<filter')
						fulldefs += '\n' + text.slice($is, ie)
							else
								glyphs[gl] = text.slice($is, ie)
				}
			}
			
			// output the stop/start of a graphic sequence
			private function set_g() : *  {
				
				// close the previous sequence
				if (stv_g.started) {
					stv_g.started = false;
					output += "</g>\n"
				}
				
				// check if new sequence needed
				if (stv_g.scale == 1 && !stv_g.color)
					return
				
				// open the new sequence
				output += '<g '
				if (stv_g.scale != 1) {
					if (stv_g.st >= 0)
						output += staff_tb[stv_g.st].scale_str
					else
						output += voice_tb[stv_g.v].scale_str
				}
				if (stv_g.color) {
					if (stv_g.scale != 1)
						output += ' ';
					output += 'style="color:' + stv_g.color + '"'
				}
				output += ">\n";
				stv_g.started = true
			}
			
			/* set the color */
			private function set_color(color) : *  {
				if (color == stv_g.color)
					return undefined	// same color
				var	old_color = stv_g.color;
				stv_g.color = color;
				set_g()
				return old_color
			}
			
			/* -- set the staff scale (only) -- */
			private function set_sscale(st) : *  {
				var	new_scale, dy
				
				if (st != stv_g.st && stv_g.scale != 1)
					stv_g.scale = 0;
				new_scale = st >= 0 ? staff_tb[st].staffscale : 1
				if (st >= 0 && new_scale != 1)
					dy = staff_tb[st].y
				else
					dy = posy
				if (new_scale == stv_g.scale && dy == stv_g.dy)
					return
				stv_g.scale = new_scale;
				stv_g.dy = dy;
				stv_g.st = st;
				set_g()
			}
			
			/* -- set the voice or staff scale -- */
			private function set_scale(s) : *  {
				var	new_scale = s.p_v.scale
				
				if (new_scale == 1) {
					set_sscale(s.st)
					return
				}
				/*fixme: KO when both staff and voice are scaled */
				if (new_scale == stv_g.scale && stv_g.dy == posy)
					return
				stv_g.scale = new_scale;
				stv_g.dy = posy;
				stv_g.st = -1;
				stv_g.v = s.v;
				set_g()
			}
			
			// -- set the staff output buffer and scale when delayed output
			private function set_dscale(st, no_scale = false) : *  {
				if (output) {
					if (stv_g.st < 0) {
						staff_tb[0].output += output
					} else if (stv_g.scale == 1) {
						staff_tb[stv_g.st].output += output
					} else {
						staff_tb[stv_g.st].sc_out += output
					}
					output = ""
				}
				if (st < 0)
					stv_g.scale = 1
				else
					stv_g.scale = no_scale ? 1 : staff_tb[st].staffscale;
				stv_g.st = st;
				stv_g.dy = 0
			}
			
			/**
			 * Updates the y offsets of delayed output
			 */
			private function delayed_update() : void  {
				var st : int; 
				for (st = 0; st <= nstaff; st++) { 
					if (staff_tb[st].sc_out) {
						output += '<g class="delayed-output-1" transform="translate(0,' +
							(posy - staff_tb[st].y).toFixed(2) +
							') scale(' +
							staff_tb[st].staffscale.toFixed(2) +
							')">\n' +
							staff_tb[st].sc_out +
							'</g>\n';
						staff_tb[st].sc_out = "";
					}
					if (!staff_tb[st].output) {
						continue;
					}

					// FIXME: this calculation failed on very large staff systems (e.g., orchestra). Trial & error value used instead.
					// (-staff_tb[st].y).toFixed(2) +
					output += '<g class="delayed-output-2" transform="translate(0,45.00)">\n' +
						staff_tb[st].output +
						'</g>\n';
					staff_tb[st].output = "";
				}
			}
			
			// 1:1 correspondence to the symbol types
			private var anno_type : Array = [
				'bar',
				'clef',
				'custos',
				'',
				'grace',
				'key',
				'meter',
				'Zrest',
				'note',
				'part',
				'rest',
				'yspace',
				'staves',
				'Break',
				'tempo',
				'',
				'block',
				'remark'
			];
			
			/**
			 * Outputs the annotations
			 */
			private function anno_out (s : Object, t : *, f : Function) : void {
				if (s.istart == undefined) {
					return;
				}
				var	type : int = s.type;
				if (s.grace) {
					type = C.GRACE;
				}
				var annotationHeight : Number = s.ymx - s.ymn + 4;
				var wl : Number = s.wl || 2;
				var wr : Number = s.wr || 2;

				var annotationClass : String = (t || anno_type[type]);
				var annotationX : Number = (s.x - wl - 2);
				var annotationY : Number = (staff_tb[s.st].y + s.ymn + annotationHeight - 2);
				var annotationWidth : Number = (wl + wr + 4);
				var annotationID : String = s.notes? s.notes[0]? s.notes[0].ids? s.notes[0].ids[0] : null : null : null; 
				
				if (annotationID) {
					f (annotationClass, s.istart, s.iend, annotationX, annotationY, annotationWidth, annotationHeight, annotationID);
				}
			}
			
			/**
			 * Produces a clickable hotspot in the generated SVG
			 */
			private function addHotspot (annotationClass : String, annotationX : Number, annotationY : Number,
										 annotationWidth : Number, annotationHeight : Number, annotationID : String) : void {
				
				output += '\n<rect class="hotspot ' + annotationClass + '" id="' + annotationID + '" x="' + annotationX.toFixed(2) + 
					'" y="' + annotationY.toFixed(2) + '" rx="1" width="' + annotationWidth.toFixed(2) + 
					'" height="' + annotationHeight.toFixed(2) + '" />\n';
			}
			
			private function a_start(s, t : * = undefined) : void {
				anno_out (s, t, user.anno_start);
			}
			
			private function a_stop(s, t : * = undefined) : void {
				anno_out (s, t, user.anno_stop);
			}
			
			private function empty_function (...args) : void {};
			private var	anno_start : *;
			private var anno_stop : *;
			
			// output a string with x, y, a and b
			// In the string,
			//	X and Y are replaced by scaled x and y
			//	A and B are replaced by a and b as string
			//	F and G are replaced by a and b as float
			private function out_XYAB(str, x, y, a=NaN, b=NaN) : void {
				x = sx(x);
				y = sy(y);
				output += str.replace(/X|Y|A|B|F|G/g, function(c, ...args) : String {
					switch (c) {
						case 'X': return x.toFixed(2)
						case 'Y': return y.toFixed(2)
						case 'A': return a
						case 'B': return b
						case 'F': return a.toFixed(2)
							//		case 'G':
						default: return b.toFixed(2)
					}
				});
			}
			
			// open / close containers
			private function g_open(x, y, rot, sx = NaN, sy = NaN) : *  {
				out_XYAB('<g class="generic-container" transform="translate(X,Y', x, y);
				if (rot)
					output += ') rotate(' + rot.toFixed(2)
				if (sx) {
					if (sy)
						output += ') scale(' + sx.toFixed(2) +
							', ' + sy.toFixed(2)
					else
						output += ') scale(' + sx.toFixed(2)
				}
				output += ')">\n';
				stv_g.g++
			}
			private function g_close() : *  {
				stv_g.g--;
				output += '</g>\n'
			}
			
			// external SVG string
			private var out_svg = function(str) :*  { output += str }
			
			// Converts given `x` to score coordinates
			internal function sx (x : Number) : Number  {
				if (stv_g.g) {
					return x;
				}
				return ((x + posx) / stv_g.scale);
			}

			// Converts given `y` to score coordinates
			internal function sy (y : Number) : Number  {
				if (stv_g.g) {
					return -y;
				}
				if (stv_g.scale == 1) {
					return (posy - y);
				}
				
				// voice scale
				if (stv_g.st < 0) {
					return ((posy - y) / stv_g.scale);
				}
				
				// staff scale
				return (stv_g.dy - y);
			}

			private var sh = function(h) :*  {
				if (stv_g.st < 0)
					return h / stv_g.scale
				return h
			}
			// for absolute X,Y coordinates
			private var ax = function(x) :*  { return x + posx }
			private var ay = function(y) :*  {
				if (stv_g.st < 0)
					return posy - y
				return posy + (stv_g.dy - y) * stv_g.scale - stv_g.dy
			}
			private var ah = function(h) :* {
				if (stv_g.st < 0)
					return h
				return h * stv_g.scale
			}
			// output scaled (x + <sep> + y)
			private function out_sxsy(x, sep, y) : void  {
				x = sx(x);
				y = sy(y);
				output += x.toFixed(2) + sep + y.toFixed(2)
			}

			
			// define the start of a path
			private function xypath(x, y, fill = false) : *  {
				out_XYAB('<path class="A" d="mX Y ', x, y, fill ? "fill" : "stroke")
			}

			
			/**
			 * Outputs a glyph
			 */
			private function xygl (x : Number, y : Number, gl : String, noteIds : Array = null, noteheadIndex : int = -1) : void {
				var idsList : String = noteIds? noteIds.join('-') : '';
				if (noteheadIndex >= 0) {
					if (idsList) {
						idsList = [idsList, noteheadIndex].join ('_');
					} else {
						idsList = noteheadIndex.toString();
					}
				}
				var tgl : Object = tgls[gl];
				if (tgl && !glyphs[gl]) {
					x += tgl.x * stv_g.scale;
					y -= tgl.y;
					if (tgl.sc) {
						out_XYAB ('<text id="' + idsList + '" transform="translate(X,Y) scale(F)">B</text>\n',
							x, y, tgl.sc, tgl.c);
					}
					else {
						if ('def' in tgl) {
							out_XYAB('<use x="X" y="Y" xlink:href="A" id="' + idsList + '" class="' + idsList + '" />', x, y, tgl.def);
						} else {
							out_XYAB('<text x="X" y="Y" id="' + idsList + '">A</text>\n', x, y, tgl.c);
						}
					}
					return;
				}
				if (!glyphs[gl]) {
					error (1, null, 'no definition of $1', gl);
					return;
				}
				def_use (gl);
				out_XYAB('<use x="X" y="Y" xlink:href="#A"/>\n', x, y, gl)
			}
			
			// - specific functions -
			// gua gda (acciaccatura)
			private function out_acciac(x, y, dx, dy, up) : *  {
				if (up) {
					x -= 1;
					y += 4
				} else {
					x -= 5;
					y -= 4
				}
				out_XYAB('<path class="stroke" d="mX YlF G"/>\n',
					x, y, dx, -dy)
			}
			
			/**
			 * Generates SVG code for displaying a normal/dotted measure bar.
			 * If an Array of IDs is provided, they are used to tag the resulting path element.  
			 */
			private function out_bar (x : Number, y : Number, h : Number, dotted : Boolean, ids : Array = null): void {
				var idsList : String = ids? ids.join ('-') : '';
				output += '<path class="stroke" stroke-width="1" id="' + idsList + '" ' +
					(dotted ? 'stroke-dasharray="5,5" ' : '') +
					'd="m' + (x + posx).toFixed(2) +
					' ' + (posy - y).toFixed(2) + 'v' + (-h).toFixed(2) +
					'"/>\n'
			}
			
			// tuplet value - the staves are not defined
			private function out_bnum(x, y, str) : void {
				out_XYAB('<text class="tuplet-number" x="X" y="Y" text-anchor="middle">A</text>\n',
					x, y, str.toString());
			}
			
			// Outputs a staff system brace
			private function out_brace (x : Number, y : Number, h : Number) : void {
				x += posx - 10;
				y = posy - y - 3;

				// Note: `94` is roughly the height of the original SVG path
				h /= 94;
				output += '<g transform="translate(' + x.toFixed(2) + ',' + y.toFixed(2) + ') scale(0.65,' + h.toFixed(2) +
					')"><use xlink:href="#brace"/></g>\n';
			}
			
			// Outputs a staff system bracket
			private function out_bracket (x : Number, y : Number, h : Number) : void {
				x += posx - 5;
				y = posy - y - 3;
				h += 2;
				var bracketSVG : String = '<path class="fill" d="m' + x.toFixed(2) + ' ' + y.toFixed(2) +
						' c10.5 1 12 -4.5 12 -3.5c0 1 -3.5 5.5 -8.5 5.5 v' + h.toFixed(2) +
						' c5 0 8.5 4.5 8.5 5.5c0 1 -1.5 -4.5 -12 -3.5"/>\n';
				output += bracketSVG;
			}

			// Outputs a secondary staff system bracket, e.g., the type of bracket used to group
			// Violin 1 with Violin 2 in a strings quartet.
			private function out_line_bracket (x : Number, y : Number, h : Number) : void {
				x += posx - 3.5;
				y = posy - y - 2.5;
				h += 2;
				var bracketSVG : String = '<path d="m'+ x.toFixed(2) + ' ' + y.toFixed(2) + ' h8v1h-7v' + h.toFixed(2) + ' h7v1h-8"/>';
				output += bracketSVG;
			}

			// hyphen
			private function out_hyph(x, y, w) : *  {
				var	n, a_y,
				d = 25 + ((w / 20) | 0) * 3
				
				if (w > 15.)
					n = ((w - 15) / d) | 0
				else
					n = 0;
				x += (w - d * n - 5) / 2;
				
				// Set the line a bit upper
				out_XYAB('<path class="stroke" stroke-width="1.2" stroke-dasharray="5,A" d="mX YhB"/>\n',
					x, y + 6,
					Math.round((d - 5) / stv_g.scale), d * n + 5);
			}
			
			/**
			 * Draws a stem (and flags, if needed).
			 * FIXME: h is already scaled - change that?
			 * Optional fixme: dx KO with half note or longa
			 */
			private function out_stem (x : Number, y : Number, h : Number, grace : Boolean = false, 
									   nflags = NaN, straight : Boolean = false, ids : Array = null) : void {
				var idsList : String = ids? ids.join ('-') : '';
				
				var	dx : Number = grace ? GSTEM_XOFF : 3.5;
				var slen : Number = -h;
				
				// Down
				if (h < 0) {
					dx = -dx;
				}
				x += dx * stv_g.scale;
				if (stv_g.st < 0) {
					slen /= stv_g.scale;
				}
				
				// Stem
				out_XYAB ('<path class="stroke" d="mX YvF" id="' + idsList + '"/>\n', x, y, slen);
				if (!nflags) {
					return;
				}
				
				output += '<path class="fill" id="' + idsList + '" d="';
				y += h;
					
				// Up
				if (h > 0) {
					if (!straight) {
						if (!grace) {
							if (nflags == 1) {
								out_XYAB ('MX Yc0.6 5.6 9.6 9 5.6 18.4 1.6 -6 -1.3 -11.6 -5.6 -12.8 ', x, y);
							} else {
								while (--nflags >= 0) { 
									out_XYAB('MX Yc0.9 3.7 9.1 6.4 6 12.4 1 -5.4 -4.2 -8.4 -6 -8.4 ', x, y);
									y -= 5.4;
								}
							}
						}
						
						// Grace
						else {
							if (nflags == 1) {
								out_XYAB('MX Yc0.6 3.4 5.6 3.8 3 10 1.2 -4.4 -1.4 -7 -3 -7 ', x, y);
							} else {
								while (--nflags >= 0) { 
									out_XYAB('MX Yc1 3.2 5.6 2.8 3.2 8 1.4 -4.8 -2.4 -5.4 -3.2 -5.2 ', x, y);
									y -= 3.5;
								}
							}
						}
					}
					
					// Straight
					else {
						if (!grace) {
							
							// FIXME: check endpoints
							y += 1;
							while (--nflags >= 0) { 
								out_XYAB('MX Yl7 3.2 0 3.2 -7 -3.2z ',
									x, y);
								y -= 5.4
							}
						}
						
						// Grace
						else {
							while (--nflags >= 0) { 
								out_XYAB('MX Yl3 1.5 0 2 -3 -1.5z ',
									x, y);
								y -= 3
							}
						}
					}
				}
				
				// Down
				else { 
					if (!straight) {
						if (!grace) {
							if (nflags == 1) {
								out_XYAB('MX Yc0.6 -5.6 9.6 -9 5.6 -18.4 1.6 6 -1.3 11.6 -5.6 12.8 ', x, y);
							} else {
								while (--nflags >= 0) { 
									out_XYAB('MX Yc0.9 -3.7 9.1 -6.4 6 -12.4 1 5.4 -4.2 8.4 -6 8.4 ', x, y);
									y += 5.4;
								}
							}
						}
						
						// Grace
						else {
							if (nflags == 1) {
								out_XYAB('MX Yc0.6 -3.4 5.6 -3.8 3 -10 1.2 4.4 -1.4 7 -3 7 ', x, y);
							} else {
								while (--nflags >= 0) { 
									out_XYAB('MX Yc1 -3.2 5.6 -2.8 3.2 -8 1.4 4.8 -2.4 5.4 -3.2 5.2 ', x, y);
									y += 3.5;
								}
							}
						}
					}
					
					// Straight
					else {
						if (!grace) {
							// FIXME: check endpoints
							y += 1;
							while (--nflags >= 0) { 
								out_XYAB ('MX Yl7 -3.2 0 -3.2 -7 3.2z ', x, y);
								y += 5.4;
							}
						}
					}
				}
				output += '"/>\n';
			}
			
			
			/**
			 * Produces an SVG element that draws a thick measure bar.
			 * If an Array of IDs is given, they will be used to tag the resulting SVG path element.
			 */
			private function out_thbar (x : Number, y : Number, h : Number, ids : Array = null) : void {
				x += posx + 1.5;
				y = posy - y;
				var idsList : String = ids? ids.join ('-') : '';
				output += '<path class="stroke" stroke-width="3" id="' + idsList + '" ' +
					'd="m' + x.toFixed(2) + ' ' + y.toFixed(2) +
					'v' + (-h).toFixed(2) + '"/>\n';
			}
			
			// tremolo
			private function out_trem (x, y, ntrem) : void {
				out_XYAB('<path class="fill" d="mX Y ', x - 4.5, y);
				while (true) { 
					output += 'l9 -3v3l-9 3z';
					if (--ntrem <= 0) {
						break;
					}
					output += 'm0 5.4';
				}
				output += '"/>\n';
			}
			
			// tuplet bracket - the staves are not defined
			private function out_tubr(x, y, dx, dy, up) : *  {
				var	h = up ? -3 : 3;
				
				y += h;
				dx /= stv_g.scale;
				output += '<path class="stroke" d="m';
				out_sxsy(x, ' ', y);
				output += 'v' + h.toFixed(2) +
					'l' + dx.toFixed(2) + ' ' + (-dy).toFixed(2) +
					'v' + (-h).toFixed(2) + '"/>\n'
			}
			
			/**
			 * Draws a tuplet bracket with a number in its center
			 */
			internal function out_tubrn (x : int, y : int, dx : int, dy : int, up : Boolean, str : String) : void  {
				var	sw : int = str.length * 10;
				
				const Y_OFFSET : int = 4;
				y += up? -Y_OFFSET : Y_OFFSET;
				
				const HOOK_SIZE : int = 8;
				var h : int = up? -HOOK_SIZE : HOOK_SIZE;
				dx /= stv_g.scale;
				if (!up) {
					y += HOOK_SIZE;
				}
					
				const BRACKET_THICKNESS : int = 4;
				const GUTTER_THICKNESS : int = BRACKET_THICKNESS * 0.5;
				const GUTTER_COLOR : String = (cfmt.bgcolor || '#ffffff');

				var yOffset : int = Math.floor ((BRACKET_THICKNESS + GUTTER_THICKNESS) * 0.5);
				var bracketLeft : int = sx(x) || 0;
				var paddedBracketLeft : int = bracketLeft + BRACKET_THICKNESS || 0;
				var bracketRight : int = (bracketLeft + dx) || 0;
				var paddedBracketRight : int = bracketRight - BRACKET_THICKNESS || 0;
				var bracketHoleRight : int = (bracketRight - (bracketRight - bracketLeft - sw) * 0.5) || 0;
				var bracketHoleLeft : int = bracketHoleRight - sw || 0;
				var holeSize : int = (bracketHoleRight - bracketHoleLeft) || 0;
				var hookLevel : int = sy (up? y + yOffset : y - yOffset) || 0;
				var bracketLevel : int = hookLevel + h || 0;
				var paddedBracketLevel : int = up? bracketLevel + BRACKET_THICKNESS : bracketLevel - BRACKET_THICKNESS;
				var holeBackgroundLevel : int = (up? bracketLevel + BRACKET_THICKNESS * 0.5 - holeSize * 0.5: bracketLevel - BRACKET_THICKNESS * 0.5 - holeSize * 0.5) || 0;
				var numberX : int = (bracketHoleLeft + holeSize * 0.65) || 0;
				var numberY : int = (holeBackgroundLevel + holeSize * 0.8) || 0;
				
				// Draw the outline (some reserved "white" space around the bracket);
				output += '<polygon fill="'+ GUTTER_COLOR +'" points="'+
					bracketLeft + ',' + bracketLevel + ' ' +
					bracketRight + ',' + bracketLevel + ' ' +
					bracketRight + ',' + hookLevel + ' ' +
					paddedBracketRight + ',' + hookLevel + ' ' +
					paddedBracketRight + ',' + paddedBracketLevel + ' ' +
					paddedBracketLeft + ',' + paddedBracketLevel + ' ' +
					paddedBracketLeft + ',' + hookLevel + ' ' +
					bracketLeft + ',' + hookLevel + ' ' +
					'"/>\n';
				
				// Draw the bracket (some reserved "white" space around the bracket);
				output += '<path class="stroke tuplet-bracket" d="M' + 
					(bracketLeft + GUTTER_THICKNESS) + ',' + (up? hookLevel - GUTTER_THICKNESS : hookLevel + GUTTER_THICKNESS) + ' V' +
					(up? bracketLevel + GUTTER_THICKNESS : bracketLevel - GUTTER_THICKNESS) + ' H' +
					(bracketRight - GUTTER_THICKNESS) + ' V' +
					(up? hookLevel - GUTTER_THICKNESS : hookLevel + GUTTER_THICKNESS) + '"/>'
				
				// Draw number background
				output += '<rect fill="'+ GUTTER_COLOR +'" x="' + 
					bracketHoleLeft +'" y="' +
					holeBackgroundLevel + '" width="'+
					holeSize + '" height="'+ 
					holeSize + '" rx="' +
					int (holeSize * 0.5) +
					'" />\n';
				
				// Draw number
				output += '<text class="tuplet-number" x="'+ 
					numberX +'" y="' +
					numberY +'" text-anchor="middle">'+ 
					str +' </text>\n';
			}
			
			
			// underscore line
			private function out_wln(x, y, w) : *  {
				out_XYAB('<path class="stroke" stroke-width="0.8" d="mX YhF"/>\n',
					x, y + 3, w)
			}
			
			// decorations with string
			private var deco_str_style = {
				crdc:	{
					dx: 0,
					dy: 5,
					style: 'font:italic 14px serif_embedded'
				},
				dacs:	{
					dx: 0,
					dy: 3,
					style: 'font:16px serif_embedded',
					anchor: ' text-anchor="middle"'
				},
				fng:	{
					dx: 0,
					dy: 1,
					style: 'font-family:Bookman; font-size:8px',
					anchor: ' text-anchor="middle"'
				},
				pf:	{
					dx: 0,
					dy: 5,
					style: 'font:italic bold 16px serif_embedded'
				},
				'@':	{
					dx: 0,
					dy: 5,
					style: 'font: 12px sans_embedded'
				}
			}
			
			private function out_deco_str(x, y, name, str) : *  {
				var	a, f,
				a_deco = deco_str_style[name]
				
				if (!a_deco) {
					xygl(x, y, name)
					return
				}
				x += a_deco.dx;
				y += a_deco.dy;
				if (!a_deco.def) {
					style += "\n." + name + " {" + a_deco.style + "}";
					a_deco.def = true
				}
				out_XYAB('<text x="X" y="Y" class="A"B>', x, y,
					name, a_deco.anchor || "");
				set_font("annotation");
				out_str(str);
				output += '</text>\n'
			}
			
			private function out_arp(x, y, val) : *  {
				g_open(x, y, 270);
				x = 0;
				val = Math.ceil(val / 6)
				while (--val >= 0) { 
					xygl(x, 6, "ltr");
					x += 6
				}
				g_close()
			}
			private function out_cresc(x, y, val, defl) : *  {
				x += val;
				val = -val;
				out_XYAB('<path class="stroke" d="mX YlA ', x, y + 5, val)
				if (defl.nost)
					output += '-2.2m0 -3.6l' + (-val).toFixed(2) + ' -2.2"/>\n'
				else
					output += '-4l' + (-val).toFixed(2) + ' -4"/>\n'
				
			}
			private function out_dim(x, y, val, defl) : *  {
				out_XYAB('<path class="stroke" d="mX YlA ', x, y + 5, val)
				if (defl.noen)
					output += '-2.2m0 -3.6l' + (-val).toFixed(2) + ' -2.2"/>\n'
				else
					output += '-4l' + (-val).toFixed(2) + ' -4"/>\n'
			}
			private function out_ltr(x, y, val) : *  {
				y += 4;
				val = Math.ceil(val / 6)
				while (--val >= 0) { 
					xygl(x, y, "ltr");
					x += 6
				}
			}
			private function out_8va(x, y, val, defl) : *  {
				if (!defl.nost) {
					out_XYAB('<text x="X" y="Y" style="font:italic bold 12px serif_embedded">8<tspan dy="-4" style="font-size:10px">va</tspan></text>\n',
						x - 8, y);
					x += 12;
					val -= 12
				} else {
					val -= 5
				}
				y += 6;
				out_XYAB('<path class="stroke" stroke-dasharray="6,6" d="mX YhA"/>\n',
					x, y, val)
				if (!defl.noen)
					out_XYAB('<path class="stroke" d="mX Yv6"/>\n', x + val, y)
			}
			private function out_8vb(x, y, val, defl) : *  {
				if (!defl.nost) {
					out_XYAB('<text x="X" y="Y" \
						style="font:italic bold 12px serif_embedded">8\
						<tspan dy="-4" style="font-size:10px">vb</tspan></text>\n',
						x - 8, y);
					x += 4;
					val -= 4
				} else {
					val -= 5
				}
				//	y -= 2;
				out_XYAB('<path class="stroke" stroke-dasharray="6,6" d="mX YhA"/>\n',
					x, y, val)
				if (!defl.noen)
					out_XYAB('<path class="stroke" d="mX Yv-6"/>\n', x + val, y)
			}
			private function out_15ma(x, y, val, defl) : *  {
				if (!defl.nost) {
					out_XYAB('<text x="X" y="Y" \
						style="font:italic bold 12px serif_embedded">15\
						<tspan dy="-4" style="font-size:10px">ma</tspan></text>\n',
						x - 10, y);
					x += 20;
					val -= 20
				} else {
					val -= 5
				}
				y += 6;
				out_XYAB('<path class="stroke" stroke-dasharray="6,6" d="mX YhA"/>\n',
					x, y, val)
				if (!defl.noen)
					out_XYAB('<path class="stroke" d="mX Yv6"/>\n', x + val, y)
			}
			private function out_15mb(x, y, val, defl) : *  {
				if (!defl.nost) {
					out_XYAB('<text x="X" y="Y" \
						style="font:italic bold 12px serif_embedded">15\
						<tspan dy="-4" style="font-size:10px">mb</tspan></text>\n',
						x - 10, y);
					x += 7;
					val -= 7
				} else {
					val -= 5
				}
				//	y -= 2;
				out_XYAB('<path class="stroke" stroke-dasharray="6,6" d="mX YhA"/>\n',
					x, y, val)
				if (!defl.noen)
					out_XYAB('<path class="stroke" d="mX Yv-6"/>\n', x + val, y)
			}
			private var deco_val_tb = {
				arp:	out_arp,
				cresc:	out_cresc,
				dim:	out_dim,
				ltr:	out_ltr,
				"8va":	out_8va,
				"8vb":	out_8vb,
				"15ma":	out_15ma,
				"15mb": out_15mb
			}
			
			private function out_deco_val(x, y, name, val, defl) : *  {
				if (deco_val_tb[name])
					deco_val_tb[name](x, y, val, defl)
				else
					error(1, null, "No function for decoration '$1'", name)
			}
			
			private function out_glisq(x2, y2, de) : *  {
				var	de1 = de.start,
					x1 = de1.x,
					y1 = de1.y + staff_tb[de1.st].y,
					ar = Math.atan2(y1 - y2, x2 - x1),
					a = ar / Math.PI * 180,
					len = (x2 - x1) / Math.cos(ar);
				
				g_open(x1, y1, a);
				x1 = de1.s.dots ? 13 + de1.s.xmx : 8;
				len = (len - x1 - 6) / 6 | 0
				if (len < 1)
					len = 1
				while (--len >= 0) { 
					xygl(x1, 0, "ltr");
					x1 += 6
				}
				g_close()
			}
			
			private function out_gliss(x2, y2, de) : *  {
				var	de1 = de.start,
					x1 = de1.x,
					y1 = de1.y + staff_tb[de1.st].y,
					ar = -Math.atan2(y2 - y1, x2 - x1),
					a = ar / Math.PI * 180,
					len = (x2 - x1) / Math.cos(ar);
				
				g_open(x1, y1, a);
				x1 = de1.s.dots ? 13 + de1.s.xmx : 8;
				len -= x1 + 8;
				xypath(x1, 0);
				output += 'l' + len.toFixed(2) + ' 0" stroke-width="1"/>\n';
				g_close()
			}
			
			private var deco_l_tb = {
				glisq: out_glisq,
				gliss: out_gliss
			}
			
			private function out_deco_long(x, y, de) : *  {
				var	name = de.dd.glyph
				
				if (deco_l_tb[name])
					deco_l_tb[name](x, y, de)
				else
					error(1, null, "No function for decoration '$1'", name)
			}
			
			// update the vertical offset
			private function vskip(h) : *  {
				posy += h
			}
			
			/**
			 * Creates the SVG code for one block (music line/staff system).
			 */
			private function svg_flush() : void {
				if (multicol || !output || posy == 0) {
					return;
				}
				var	head : String = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" color="black" class="music" stroke-width=".7"';
				var g : String = '';
				if (cfmt.bgcolor) {
					head += ' style="background-color: ' + cfmt.bgcolor + '"';
				}
				posy *= cfmt.scale;
				if (user.imagesize) {
					head += ' ' + user.imagesize + ' viewBox="0 0 ' + img.width.toFixed(0) + ' %HEIGHT%">\n';
				} else {
					head += ' width="' + img.width.toFixed(0) + 'px" height="%HEIGHT%px">\n';
				}
				if (style || font_style) {
					var hStyle : Object = user.hotspotStyle || {};
					var hStroke : String = (hStyle.stroke as String) || '#3983fa';
					var hFill : String = (hStyle.fill as String) || '#6abffc';
					var hFillOpacity : Number = (hStyle.fillOpacity as Number) || 0.4;		
					var hStrokeOpacity : Number = (hStyle.strokeOpacity as Number) || 1;
					style += '\n.hotspot { stroke: ' + hStroke +'; fill: ' + hFill + '; fill-opacity: ' + hFillOpacity + 
						'; stroke-opacity: ' + hStrokeOpacity + '; }';
					style += '\n.tuplet-number { font-family: sans; font-size: 9 }';
					style += '\n.ghost-rest { fill-opacity: 0.3; stroke-opacity: 0.3; }';
					style += '\n.fill {fill: ' + (cfmt.fgcolor || 'currentColor') + '}';
					style += '\n.stroke {stroke: ' + (cfmt.fgcolor || 'currentColor') + '; fill: none}';
					style += '\n.music text, .music tspan {fill: ' + (cfmt.fgcolor || 'currentColor') + '}';

					head += '<style type="text/css">' + style + font_style + '\n</style>\n';
				}
				defs += fulldefs;
				head += '<defs>\n'+ SVG_DEF_BODY + '\n</defs>\n';
				
				// If a `%%pagescale` different than `1` is given, do a global scale.
				// The class `g` is used to mark the container as global.
				if (cfmt.scale != 1) {
					head += '<g class="g" transform="scale(' + cfmt.scale.toFixed(2) + ')">\n';
					g = '</g>\n';
				}
				if (user.img_out) {
					user.img_out (head + output + g + '\n</svg>');
				}
				if (user.svgReporter) {
					user.svgReporter (posy, head, output, g + '\n</svg>');
				}
				output = '';
				font_style = '';
				defined_glyph = {};
				defined_font = {};
				defs = '';
				posy = 0;
			}
			
			// Outputs a part of a block of images
			private function blk_out() : void  {
				if (multicol || !user.img_out) {
					return;
				}
				blk_flush();
				if (user.page_format && !block.started) {
					block.started = true;
					if (block.newpage) {
						block.newpage = false;
						user.img_out('<div class="nobrk newpage">');
					} else {
						user.img_out('<div class="nobrk">');
					}
				}
			}
			
			// output the end of a block (or tune)
			private function blk_flush() : *  {
				if (!user.img_out) {
					return;
				}
				svg_flush()
				if (block.started) {
					block.started = false;
					user.img_out('</div>')
				}
			}
			
			
			// ---------------------------------
			
			// abc2svg - tune.js - tune generation
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			private var	par_sy;		// current staff system for parse
			private var cur_sy;		// current staff system for generation
			private var voice_tb : Array;
			private var curvoice;
			private var staves_found;
			private var vover;		// voice overlay
			private var tsfirst;
			
			/* apply the %%voice options of the current voice */
			private function voice_filter() : *  {
				var opt, sel, i
				
				for (opt in parse.voice_opts) { 
					if (!parse.voice_opts.hasOwnProperty(opt))
						continue
					sel = new RegExp(opt)
					if (sel.test(curvoice.id)
						|| sel.test(curvoice.nm)) {
						for (i in parse.voice_opts[opt]) { 
							if (parse.voice_opts[opt].hasOwnProperty(i)) {
								self.do_pscom(parse.voice_opts[opt][i]);
							}
						}
					}
				}
			}
			
			/* -- link a ABC symbol into the current voice -- */
			private function sym_link(s) : *  {
				if (!s.fname)
					set_ref(s)
				if (!curvoice.ignore) {
					parse.last_sym = s;
					s.prev = curvoice.last_sym
					if (curvoice.last_sym)
						curvoice.last_sym.next = s
					else
						curvoice.sym = s;
					curvoice.last_sym = s
				}
				s.v = curvoice.v;
				s.p_v = curvoice;
				s.st = curvoice.cst;
				s.time = curvoice.time
				if (s.dur && !s.grace)
					curvoice.time += s.dur;
				s.pos = curvoice.pos
				if (curvoice.second)
					s.second = true
				if (curvoice.floating)
					s.floating = true
			}
			
			/* -- add a new symbol in a voice -- */
			private function sym_add(p_voice, type) : *  {
				var	s = {
					type:type,
					dur:0
				},
					s2,
					p_voice2 = curvoice;
				
				curvoice = p_voice;
				sym_link(s);
				curvoice = p_voice2;
				s2 = s.prev
				if (!s2)
					s2 = s.next
				if (s2) {
					s.fname = s2.fname;
					s.istart = s2.istart;
					s.iend = s2.iend
				}
				return s
			}
			
			/* -- expand a multi-rest into single rests and measure bars -- */
			private function mrest_expand(s) : *  {
				var	p_voice, s2, next,
				nb = s.nmes,
					dur = s.dur / nb
				
				/* change the multi-rest (type bar) to a single rest */
				var a_dd = s.a_dd;
				s.type = C.REST;
				s.dur = dur;
				s.head = C.FULL;
				s.nflags = -2;
				
				/* add the bar(s) and rest(s) */
				next = s.next;
				p_voice = s.p_v;
				p_voice.last_sym = s;
				p_voice.time = s.time + dur;
				p_voice.cst = s.st;
				s2 = s
				while (--nb > 0) { 
					s2 = sym_add(p_voice, C.BAR);
					s2.bar_type = "|";
					s2 = sym_add(p_voice, C.REST);
					if (s.invis)
						s2.invis = true;
					s2.dur = dur;
					s2.head = C.FULL;
					s2.nflags = -2;
					p_voice.time += dur
				}
				s2.next = next
				if (next)
					next.prev = s2;
				
				/* copy the mrest decorations to the last rest */
				s2.a_dd = a_dd
			}
			
			/* -- sort all symbols by time and vertical sequence -- */
			// weight of the symbols !! depends on the symbol type !!
			private var w_tb : Vector.<uint> = Vector.<uint> ([
				2,	// bar
				1,	// clef
				8,	// custos
				0,	// (free)
				3,	// grace
				5,	// key
				6,	// meter
				9,	// mrest
				9,	// note
				0,	// part
				9,	// rest
				3,	// space
				0,	// staves
				7,	// stbrk
				0,	// tempo
				0,	// (free)
				0,	// block
				0	// remark
			]);
			
			private function sort_all() : *  {
				var	s, s2, p_voice, v, time, w, wmin, ir, multi,
				prev, nb, ir2, v2, sy,
				nv = voice_tb.length,
					vtb = [],
					vn = [],			/* voice indexed by range */
					mrest_time = -1
				
				for (v = 0; v < nv; v++) { 
					vtb.push(voice_tb[v].sym);
				}
				
				/* initialize the voice order */
				var	fl = 1,				// start a new time sequence
					new_sy = cur_sy
				
				while (1) { 
					if (new_sy && fl) {
						sy = new_sy;
						new_sy = null;
						multi = -1;
						vn = []
						for (v = 0; v < nv; v++) { 
							if (!sy.voices[v]) {
								sy.voices[v] = {
									range: -1
								}
								continue
							}
							ir = sy.voices[v].range
							if (ir < 0)
								continue
							vn[ir] = v;
							multi++
						}
					}
					
					/* search the min time and symbol weight */
					wmin = time = 1000000				/* big int */
					for (ir = 0; ir < nv; ir++) { 
						v = vn[ir]
						if (v == undefined)
							break
						s = vtb[v]
						if (!s || s.time > time)
							continue
						w = w_tb[s.type]
						if (s.time < time) {
							time = s.time;
							wmin = w
						} else if (w < wmin) {
							wmin = w
						}
						if (s.type == C.MREST) {
							if (s.nmes == 1)
								mrest_expand(s)
							else if (multi > 0)
								mrest_time = time
						}
					}
					
					if (wmin > 127)
						break			// done
					
					/* if some multi-rest and many voices, expand */
					if (time == mrest_time) {
						nb = 0
						for (ir = 0; ir < nv; ir++) { 
							v = vn[ir]
							if (v == undefined)
								break
							s = vtb[v]
							if (!s || s.time != time
								|| w_tb[s.type] != wmin)
								continue
							if (s.type != C.MREST) {
								mrest_time = -1 /* some note or rest */
								break
							}
							if (nb == 0) {
								nb = s.nmes
							} else if (nb != s.nmes) {
								mrest_time = -1	/* different duration */
								break
							}
						}
						if (mrest_time < 0) {
							for (ir = 0; ir < nv; ir++) { 
								v = vn[ir]
								if (v == undefined)
									break
								s = vtb[v]
								if (s && s.type == C.MREST)
									mrest_expand(s)
							}
						}
					}
					
					/* link the vertical sequence */
					for (ir = 0; ir < nv; ir++) { 
						v = vn[ir]
						if (v == undefined)
							break
						s = vtb[v]
						if (!s || s.time != time
							|| w_tb[s.type] != wmin)
							continue
						if (s.type == C.STAVES) {
							new_sy = s.sy;
							
							// set all voices of previous and next staff systems
							// as reachable
							for (ir2 = 0; ir2 < nv; ir2++) { 
								if (vn[ir2] == undefined)
									break
							}
							for (v2 = 0; v2 < nv; v2++) { 
								if (!new_sy.voices[v2])
									continue
								ir = new_sy.voices[v2].range
								if (ir < 0
									|| sy.voices[v2].range >= 0)
									continue
								vn[ir2++] = v2
							}
						}
						if (fl) {
							fl = 0;
							s.seqst = true
						}
						s.ts_prev = prev
						if (prev)
							prev.ts_next = s
						else
							tsfirst = s;
						prev = s
						
						vtb[v] = s.next
					}
					fl = wmin		/* start a new sequence if some width */
				}
			}
			
			// adjust some voice elements
			private function voice_adj() : *  {
				var p_voice, s, s2, v
				
				// set the duration of the notes under a feathered beam
				function set_feathered_beam(s1)  :* {
					var	s, s2, t, b, i, a,
					d = s1.dur,
						n = 1
					
					/* search the end of the beam */
					for (s = s1; s; s = s.next) { 
						if (s.beam_end || !s.next)
							break
						n++
					}
					if (n <= 1) {
						delete s1.feathered_beam
						return
					}
					s2 = s;
					b = d / 2;		/* smallest note duration */
					a = d / (n - 1);	/* delta duration */
					t = s1.time
					if (s1.feathered_beam > 0) {	/* !beam-accel! */
						for (s = s1, i = n - 1;
							s != s2;
							s = s.next, i--) { 
							d = ((a * i) | 0) + b;
							s.dur = d;
							s.time = t;
							t += d
						}
					} else {				/* !beam-rall! */
						for (s = s1, i = 0;
							s != s2;
							s = s.next, i++) { 
							d = ((a * i) | 0) + b;
							s.dur = d;
							s.time = t;
							t += d
						}
					}
					s.dur = s.time + s.dur - t;
					s.time = t
				} // end set_feathered_beam()
				
				/* if Q: from tune header, put it at start of the music */
				s = glovar.tempo
				if (s && staves_found <= 0) {	// && !s.del) {		- play problem
					v = par_sy.top_voice;
					p_voice = voice_tb[v];
					if (p_voice.sym && p_voice.sym.type != C.TEMPO) {
						s = clone(s);
						s.v = v;
						s.p_v = p_voice;
						s.st = p_voice.st;
						s.time = 0;
						s.next = p_voice.sym
						if (s.next)
							s.next.prev = s;
						p_voice.sym = s
					}
				}
				
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					if (p_voice.ignore)
						p_voice.ignore = false
					for (s = p_voice.sym; s; s = s.next) { 
						if (s.time >= staves_found)
							break
					}
					for ( ; s; s = s.next) { 
						switch (s.type) {
							case C.GRACE:
								// with w_tb[C.BAR] = 2,
								// the grace notes go after the bar;
								// if before a bar, change the grace time
								if (s.next && s.next.type == C.BAR)
									s.time--
								
								if (!cfmt.graceword)
									continue
								for (s2 = s.next; s2; s2 = s2.next) { 
									switch (s2.type) {
										case C.SPACE:
											continue
										case C.NOTE:
											if (!s2.a_ly)
												break
											s.a_ly = s2.a_ly;
											s2.a_ly = null
											break
									}
									break
								}
								continue
						}
						
						if (s.feathered_beam)
							set_feathered_beam(s)
					}
				}
			}
			
			/* -- duplicate the voices as required -- */
			private function dupl_voice() : *  {
				var	p_voice, p_voice2, s, s2, g, g2, v, i,
				nv = voice_tb.length
				
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v];
					p_voice2 = p_voice.clone
					if (!p_voice2)
						continue
					p_voice.clone = null
					for (s = p_voice.sym; s; s = s.next) { 
						//fixme: there may be other symbols before the %%staves at this same time
						if (s.time >= staves_found)
							break
					}
					p_voice2.clef = clone(p_voice.clef);
					curvoice = p_voice2
					for ( ; s; s = s.next) { 
						if (s.type == C.STAVES)
							continue
						s2 = clone(s)
						if (s.notes) {
							s2.notes = []
							for (i = 0; i <= s.nhd; i++) { 
								s2.notes.push(clone(s.notes[i]));
							}
						}
						sym_link(s2)
						//			s2.time = s.time
						if (p_voice2.second)
							s2.second = true
						else
							delete s2.second
						if (p_voice2.floating)
							s2.floating = true
						else
							delete s2.floating
						delete s2.a_ly;
						g = s2.extra
						if (!g)
							continue
						g2 = clone(g);
						s2.extra = g2;
						s2 = g2;
						s2.v = p_voice2.v;
						s2.p_v = p_voice2;
						s2.st = p_voice2.st
						for (g = g.next; g; g = g.next) { 
							g2 = clone(g)
							if (g.notes) {
								g2.notes = []
								for (i = 0; i <= g.nhd; i++) { 
									g2.notes.push(clone(g.notes[i]));
								}
							}
							s2.next = g2;
							g2.prev = s2;
							s2 = g2;
							s2.v = p_voice2.v;
							s2.p_v = p_voice2;
							s2.st = p_voice2.st
						}
					}
				}
			}
			
			/* -- create a new staff system -- */
			private function new_syst(init = false) : *  {
				var	st, v,
				sy_new = {
					voices: [],
					staves: [],
					top_voice: 0
				}
				
				if (init) {				/* first staff system */
					cur_sy = par_sy = sy_new
					return
				}
				
				// update the previous system
				for (v = 0; v < voice_tb.length; v++) { 
					st = par_sy.voices[v].st
					var	sy_staff = par_sy.staves[st],
						p_voice = voice_tb[v]
					if (p_voice.staffnonote != undefined)
						sy_staff.staffnonote = p_voice.staffnonote
					if (p_voice.staffscale)
						sy_staff.staffscale = p_voice.staffscale;
					sy_new.voices[v] = clone(par_sy.voices[v]);
					sy_new.voices[v].range = -1;
					delete sy_new.voices[v].second
				}
				for (st = 0; st < par_sy.staves.length; st++) { 
					sy_new.staves[st] = clone(par_sy.staves[st]);
					sy_new.staves[st].flags = 0
				}
				par_sy.next = sy_new;
				par_sy = sy_new
			}
			
			/* -- set the bar numbers -- */
			// (possible hook)
			private function set_bar_num() : *  {
				var	s, s2, tim, bar_time, bar_num, rep_dtime,
				v = cur_sy.top_voice,
					wmeasure = voice_tb[v].meter.wmeasure,
					bar_rep = gene.nbar
				
				/* don't count a bar at start of line */
				for (s = tsfirst; ; s = s.ts_next) { 
					if (!s)
						return
					switch (s.type) {
						case C.METER:
							wmeasure = s.wmeasure
						case C.CLEF:
						case C.KEY:
						case C.STBRK:
							continue
						case C.BAR:
							if (s.bar_num) {
								gene.nbar = s.bar_num	/* (%%setbarnb) */
								break
							}
							if (s.text			// if repeat bar
								&& !cfmt.contbarnb) {
								if (s.text[0] == '1') {
									bar_rep = gene.nbar
								} else {
									gene.nbar = bar_rep; /* restart bar numbering */
									s.bar_num = gene.nbar
								}
							}
							break
					}
					break
				}
				
				// at start of tune, check for an anacrusis
				bar_time = s.time + wmeasure
				if (s.time == 0) {
					for (s2 = s.ts_next; s2; s2 = s2.ts_next) { 
						if (s2.type == C.BAR && s2.time) {
							if (s2.time < bar_time) {	// if anacrusis
								s = s2;
								bar_time = s.time + wmeasure
							}
							break
						}
					}
				}
				
				// set the measure number on the top bars
				bar_num = gene.nbar
				
				for ( ; s; s = s.ts_next) { 
					switch (s.type) {
						case C.METER:
							wmeasure = s.wmeasure
							if (s.time < bar_time)
								bar_time = s.time + wmeasure
							break
						case C.MREST:
							bar_num += s.nmes - 1
							while (s.ts_next && s.ts_next.type != C.BAR) { 
								s = s.ts_next;
							}
							break
						case C.BAR:
							if (s.bar_num)
								bar_num = s.bar_num	// (%%setbarnb)
							if (s.time < bar_time) {	// incomplete measure
								if (s.text && s.text[0] == '1') {
									bar_rep = bar_num;
									rep_dtime = bar_time - s.time
								}
								break
							}
							
							/* check if any repeat bar at this time */
							tim = s.time;
							s2 = s
							do { 
								if (s2.dur)
									break
								if (s2.type == C.BAR && s2.text)	// if repeat bar
									break
								s2 = s2.next
							} while (s2 && s2.time == tim);
							bar_num++
							if (s2 && s2.type == C.BAR && s2.text) {
							if (s2.text[0] == '1') {
								rep_dtime = 0;
								bar_rep = bar_num
							} else {			// restart bar numbering
								if (!cfmt.contbarnb)
									bar_num = bar_rep
								if (rep_dtime) {	// [1 inside measure
									if (cfmt.contbarnb)
										bar_num--;
									bar_time = tim + rep_dtime
									break
								}
							}
						}
							s.bar_num = bar_num;
							bar_time = tim + wmeasure
							
							// skip the bars of the other voices
							while (s.ts_next && !s.ts_next.seqst) { 
								s = s.ts_next;
							}
							break
					}
				}
				if (cfmt.measurenb < 0)		/* if no display of measure bar */
					gene.nbar = bar_num	/* update in case of more music to come */
			}
			
			// note mapping
			// %%map map_name note [print [note_head]] [param]*
			private function get_map(text) : *  {
				if (!text)
					return
				
				var	i, note, notes, map, tmp, ns,
				a = info_split(text, 2)
				
				if (a.length < 3) {
					syntax(1, "Not enough parameters in %%map")
					return
				}
				ns = a[1]
				if (ns.indexOf("octave,") == 0
					|| ns.indexOf("key,") == 0) {		// remove the octave part
					ns = ns.replace(/[,']+$/m, '').toLowerCase(); //'
					if (ns[0] == 'k')		// remove the accidental part
						ns = ns.replace(/[_=^]+/, '')
				} else if (ns[0] == '*' || ns.indexOf("all") == 0) {
					ns = 'all'
				} else {				// exact pitch, rebuild the note
					tmp = new scanBuf();
					tmp.buffer = a[1];
					note = parse_acc_pit(tmp)
					if (!note) {
						syntax(1, "Bad note in %%map")
						return
					}
					ns = note2abc(note)
				}
				
				notes = maps[a[0]]
				if (!notes)
					maps[a[0]] = notes = {}
				map = notes[ns]
				if (!map)
					notes[ns] = map = []
				
				/* try the optional 'print' and 'heads' parameters */
				if (!a[2])
					return
				i = 2
				if (a[2].indexOf('=') < 0) {
					if (a[2][0] != '*') {
						tmp = new scanBuf();		// print
						tmp.buffer = a[2];
						map[1] = parse_acc_pit(tmp)
					}
					if (!a[3])
						return
					i++
					if (a[3].indexOf('=') < 0) {
						map[0] = a[3].split(',');
						i++
					}
				}
				
				for (; i < a.length; i++) { 
					switch (a[i]) {
						case "heads=":
							map[0] = a[++i].split(',')
							break
						case "print=":
							if (cfmt.sound == "play")
								break
							tmp = new scanBuf();
							tmp.buffer = a[++i];
							map[1] = parse_acc_pit(tmp)
							break
						//		case "transpose=":
						//			switch (a[++i][0]) {
						//			case "n":
						//				map[2] = false
						//				break
						//			case "y":
						//				map[2] = true
						//				break
						//			}
						//			break
						case "color=":
							map[2] = a[++i]
							break
					}
				}
			}
			
			// set the transposition in the previous or starting key
			private function set_transp() : *  {
				var	s, transp, vtransp
				
				if (curvoice.ckey.k_bagpipe || curvoice.ckey.k_drum)
					return
				
				if (cfmt.transp && curvoice.transp)	// if %%transpose and score=
					syntax(0, "Mix of old and new transposition syntaxes");
				
				transp = (cfmt.transp || 0) +		// %%transpose
					(curvoice.transp || 0) +	// score= / sound=
					(curvoice.shift || 0);		// shift=
				vtransp = curvoice.vtransp || 0
				if (transp == vtransp)
					return
				
				curvoice.vtransp = transp;
				
				s = curvoice.last_sym
				if (!s) {				// no symbol yet
					curvoice.key = clone(curvoice.okey);
					key_transp(curvoice.key);
					curvoice.ckey = clone(curvoice.key)
					if (curvoice.key.k_none)
						curvoice.key.k_sf = 0
					return
				}
				
				// set the transposition in the previous K:
				while (1) { 
					if (s.type == C.KEY)
						break
					if (!s.prev) {
						s = curvoice.key
						break
					}
					s = s.prev
				}
				key_transp(s);
				curvoice.ckey = clone(s)
				if (curvoice.key.k_none)
					s.k_sf = 0
			}
			
			private function set_ottava(dcn) : *  {
				if (cfmt.sound)
					return
				switch (dcn) {
					case "15ma(":
						curvoice.ottava = -14
						break
					case "8va(":
						curvoice.ottava = -7
						break
					case "8vb(":
						curvoice.ottava = 7
						break
					case "15mb(":
						curvoice.ottava = 14
						break
					case "15ma)":
					case "8va)":
					case "8vb)":
					case "15mb)":
						curvoice.ottava = 0
						break
				}
			}
			
			/* -- process a pseudo-comment (%% or I:) -- */
			// (possible hook)
			private function do_pscom(text) : *  {
				var	h1, val, s, cmd, param, n, k, b,
				lock = false
				
				if (text.slice(-5) == ' lock') {
					lock = true;
					text = text.slice(0, -5).trim()
				}
				cmd = text.match(/(\w|-)+/)
				if (!cmd)
					return
				cmd = cmd[0];
				param = Strings.trim (text.replace(cmd, ''));
				switch (cmd) {
					case "center":
						if (parse.state >= 2) {
							s = new_block("text");
							s.text = cnv_escape(param);
							s.opt = 'c'
							return
						}
						write_text(cnv_escape(param), 'c')
						return
					case "clef":
						if (parse.state >= 2) {
							if (parse.state == 2)
								goto_tune();
							s = new_clef(param)
							if (s)
								get_clef(s)
						}
						return
					case "deco":
						deco_add(param)
						return
					case "linebreak":
						set_linebreak(param)
						return
					case "map":
						get_map(param)
						return
					case "maxsysstaffsep":
						if (parse.state == 3) {
							par_sy.voices[curvoice.v].maxsep = get_unit(param)
							return
						}
						break
					case "multicol":
						generate()
						switch (param) {
							case "start":
								blk_out();
								multicol = {
								posy: posy,
								maxy: posy,
								lmarg: cfmt.leftmargin,
									rmarg: cfmt.rightmargin,
									state: parse.state
							}
								break
							case "new":
								if (!multicol) {
									syntax(1, "%%multicol new without start")
									break
								}
								if (posy > multicol.maxy)
									multicol.maxy = posy;
								cfmt.leftmargin = multicol.lmarg;
								cfmt.rightmargin = multicol.rmarg;
								img.chg = true;
								set_page();
								posy = multicol.posy
								break
							case "end":
								if (!multicol) {
									syntax(1, "%%multicol end without start")
									break
								}
								if (posy < multicol.maxy)
									posy = multicol.maxy;
								cfmt.leftmargin = multicol.lmarg;
								cfmt.rightmargin = multicol.rmarg;
								multicol = undefined;
								blk_flush();
								img.chg = true;
								set_page()
								break
							default:
								syntax(1, "Unknown keyword '$1' in %%multicol", param)
								break
						}
						return;
					case "ottava":
						if (parse.state != 3) {
							if (parse.state != 2)
								return
							goto_tune()
						}
						n = parseInt(param)
						if (isNaN(n) || n < -2 || n > 2) {
							syntax(1, errs.bad_val, "%%ottava")
							return
						}
						switch (curvoice.ottava) {
							case 14: b = "15mb)"; break
							case 7: b = "8vb)"; break
							case -7: b = "8va)"; break
							case -14: b = "15ma)"; break
						}
						if (b) {
							if (!a_dcn)
								a_dcn = []
							a_dcn.push(b);
							set_ottava(b)
						}
						switch (n) {
							case -2: b = "15mb("; break
							case -1: b = "8vb("; break
							case 0: return
							case 1: b = "8va("; break
							case 2: b = "15ma("; break
						}
						if (!a_dcn)
							a_dcn = []
						a_dcn.push(b);
						set_ottava(b)
						return
					case "repbra":
						if (parse.state >= 2) {
							if (parse.state == 2)
								goto_tune();
							curvoice.norepbra = !get_bool(param)
						}
						return
					case "repeat":
						if (parse.state != 3)
							return
						if (!curvoice.last_sym) {
							syntax(1, "%%repeat cannot start a tune")
							return
						}
						if (!param.length) {
							n = 1;
							k = 1
						} else {
							b = param.split(/\s+/);
							
							n = parseInt(b[0]);
							k = parseInt(b[1])
							if (isNaN(n) || n < 1
								|| (curvoice.last_sym.type == C.BAR
									&& n > 2)) {
								syntax(1, "Incorrect 1st value in %%repeat")
								return
							}
							if (isNaN(k)) {
								k = 1
							} else {
								if (k < 1) {
									syntax(1, "Incorrect 2nd value in %%repeat")
									return
								}
							}
						}
						parse.repeat_n = curvoice.last_sym.type == C.BAR ? n : -n;
						parse.repeat_k = k
						return
					case "sep":
						var	h2, len, values, lwidth;
						
						set_page();
						lwidth = img.width - img.lm - img.rm;
						h1 = h2 = len = 0
						if (param) {
							values = param.split(/\s+/);
							h1 = get_unit(values[0])
							if (values[1]) {
								h2 = get_unit(values[1])
								if (values[2])
									len = get_unit(values[2])
							}
						}
						if (h1 < 1)
							h1 = 14
						if (h2 < 1)
							h2 = h1
						if (len < 1)
							len = 90
						if (parse.state >= 2) {
							s = new_block(cmd);
							s.x = (lwidth - len) / 2 / cfmt.scale;
							s.l = len / cfmt.scale;
							s.sk1 = h1;
							s.sk2 = h2
							return
						}
						blk_out();
						vskip(h1);
						output += '<path class="stroke" d="M';
						out_sxsy((lwidth - len) / 2 / cfmt.scale, ' ', 0);
						output += 'h' + (len / cfmt.scale).toFixed(2) + '"/>\n';
						vskip(h2);
						blk_flush()
						return
					case "setbarnb":
						val = parseInt(param)
						if (isNaN(val))
							syntax(1, "Bad %%setbarnb value")
						else if (parse.state >= 2)
							glovar.new_nbar = val
						else
							cfmt.measurefirst = val
						return
					case "staff":
						if (parse.state != 3) {
							if (parse.state != 2)
								return
							goto_tune()
						}
						val = parseInt(param)
						if (isNaN(val)) {
							syntax(1, "Bad %%staff value '$1'", param)
							return
						}
						var st
						if (param[0] == '+' || param[0] == '-')
							st = curvoice.cst + val
						else
							st = val - 1
						if (st < 0 || st > nstaff) {
							syntax(1, "Bad %%staff number $1 (cur $2, max $3)",
								st, curvoice.cst, nstaff)
							return
						}
						delete curvoice.floating;
						curvoice.cst = st
						return
					case "staffbreak":
						if (parse.state != 3) {
							if (parse.state != 2)
								return
							goto_tune()
						}
						s = {
						type: C.STBRK,
							dur:0
					}
						if (param[0] >= '0' && param[0] <= '9') {
							s.xmx = get_unit(param)
							if (param.slice(-1) == 'f')
								s.stbrk_forced = true
						} else {
							s.xmx = 14
							if (param[0] == 'f')
								s.stbrk_forced = true
						}
						sym_link(s)
						return
					case "stafflines":
					case "staffscale":
					case "staffnonote":
						self.set_v_param(cmd, param)
						return
					case "staves":
					case "score":
						if (parse.state == 0)
							return
						get_staves(cmd, param)
						return
					case "sysstaffsep":
						//--fixme: may be global
						if (parse.state == 3) {
							par_sy.voices[curvoice.v].sep = get_unit(param)
							return
						}
						break
					case "text":
						if (parse.state >= 2) {
							s = new_block(cmd);
							s.text = cnv_escape(param);
							s.opt = cfmt.textoption
							return
						}
						write_text(cnv_escape(param), cfmt.textoption)
						return
					case "transpose":		// (abcm2ps compatibility)
						if (cfmt.sound)
							return
						switch (parse.state) {
							case 0:
								cfmt.transp = 0
								// fall thru
							case 1:
							case 2:
								cfmt.transp = (cfmt.transp || 0) + get_transp(param)
								return
								//		case 2:
								//			goto_tune()
								//			break
						}
						for (s = curvoice.last_sym; s; s = s.prev) { 
							switch (s.type) {
								case C.NOTE:		// insert a key
									s = clone(curvoice.okey);
									s.k_old_sf = curvoice.ckey.k_sf;
									sym_link(s)
									break
								case C.KEY:
									break
								default:
									continue
							}
							break
						}
						do_info('V', curvoice.id + ' shift=' + param)
						return
					case "tune":
						//fixme: to do
						return
					case "user":
						set_user(param)
						return
					case "voicecolor":
						if (parse.state != 3) {
							if (parse.state != 2)
								return
							goto_tune()
						}
						curvoice.color = param
						return
					case "vskip":
						val = get_unit(param)
						if (val < 0) {
							syntax(1, "%%vskip cannot be negative")
							return
						}
						if (parse.state >= 2) {
							s = new_block(cmd);
							s.sk = val
							return
						}
						vskip(val);
						return;
					case "pageheight":
						var factor : Number = Strings.endsWith (param, 'cm')? CM : Strings.endsWith (param, 'in')? IN : 1;
						pageHeight = parseFloat(param) * factor;
						break;
					case "newpage":
					case "leftmargin":
					case "rightmargin":
					case "pagescale":
					case "pagewidth":
					case "printmargin":
					case "scale":
					case "staffwidth":
						if (parse.state == 3) {			// tune body
							s = new_block(cmd);
							s.param = param
							return
						}
						if (cmd == "newpage") {
							blk_flush();
							block.newpage = true;
							return
						}
						break
				}
				self.set_format(cmd, param, lock)
			}
			
			// treat the %%beginxxx / %%endxxx sequences
			// (posible hook)
			private function do_begin_end(type,
								  opt,
								  text) : *  {
				var i, j, action, s
				
				switch (type) {
					case "ml":
						if (parse.state >= 2) {
							s = new_block(type);
							s.text = text
						} else {
							svg_flush();
							if (user.img_out) {
								user.img_out(text);
							}
						}
						break
					case "svg":
						j = 0
						while (1) { 
							i = text.indexOf('<style type="text/css">\n', j)
							if (i < 0)
								break
							j = text.indexOf('</style>', i)
							if (j < 0) {
								syntax(1, "No </style> in %%beginsvg sequence")
								break
							}
							style += text.slice(i + 23, j).replace(/\s+$/, '')
						}
						j = 0
						while (1) { 
							i = text.indexOf('<defs>\n', j)
							if (i < 0)
								break
							j = text.indexOf('</defs>', i)
							if (j < 0) {
								syntax(1, "No </defs> in %%beginsvg sequence")
								break
							}
							defs_add(text.slice(i + 6, j))
						}
						break
					case "text":
						action = get_textopt(opt);
						if (!action)
							action = cfmt.textoption
						if (parse.state >= 2) {
							s = new_block(type);
							s.text = cnv_escape(text);
							s.opt = action
							break
						}
						write_text(cnv_escape(text), action)
						break
				}
			}
			
			/* -- generate a piece of tune -- */
			private function generate() : void {
				var v; 
				var p_voice;
				
				if (vover) {
					syntax (1, "No end of voice overlay");
					get_vover (vover.bar ? '|' : ')');
				}
				
				if (voice_tb.length == 0) {
					return;
				}
				
				voice_adj();
				dupl_voice();
				
				// Define the time / vertical sequences				
				sort_all();
				if (!tsfirst) {
					return;
				}
				
				self.set_bar_num();
				
				// No more symbol
				if (!tsfirst) {
					return;
				}
				
				// Give the parser result to the application
				if (user.get_abcmodel) {
					user.get_abcmodel (tsfirst, voice_tb, anno_type, info);
				}
				
				// If SVG generation					
				self.output_music();

				
				// Reset the parser
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					p_voice.time = 0;
					p_voice.sym = p_voice.last_sym = null;
					p_voice.st = cur_sy.voices[v].st;
					p_voice.second = cur_sy.voices[v].second;

					delete p_voice.have_ly;
					p_voice.hy_st = 0;
					delete p_voice.bar_start;
					delete p_voice.slur_st;
					delete p_voice.s_tie;
					delete p_voice.s_rtie;
				}
				
				// For compress/dup the voices
				staves_found = 0;
			}
			
			// Transpose a key
			// FIXME: transpose of the accidental list is not done
			private function key_transp(s_key) : *  {
				var	t = (curvoice.vtransp / 3) | 0,
					sf = (t & ~1) + (t & 1) * 7 + s_key.k_sf
				
				switch ((curvoice.vtransp + 210) % 3) {
					case 1:
						sf = (sf + 4 + 12 * 4) % 12 - 4	/* more sharps */
						break
					case 2:
						sf = (sf + 7 + 12 * 4) % 12 - 7	/* more flats */
						break
					default:
						sf = (sf + 5 + 12 * 4) % 12 - 5	/* Db, F# or B */
						break
				}
				s_key.k_sf = sf;
				s_key.k_delta = cgd2cde[(sf + 7) % 7]
			}
			
			/* -- set the accidentals when K: with modified accidentals -- */
			private function set_k_acc(s) : *  {
				var i, j, n, nacc, p_acc,
				accs = [],
					pits = [],
					m_n = [],
					m_d = []
				
				if (s.k_sf > 0) {
					for (nacc = 0; nacc < s.k_sf; nacc++) { 
						accs[nacc] = 1;			// sharp
						pits[nacc] = [26, 23, 27, 24, 21, 25, 22][nacc]
					}
				} else {
					for (nacc = 0; nacc < -s.k_sf; nacc++) { 
						accs[nacc] = -1;		// flat
						pits[nacc] = [22, 25, 21, 24, 20, 23, 26][nacc]
					}
				}
				n = s.k_a_acc.length
				for (i = 0; i < n; i++) { 
					p_acc = s.k_a_acc[i]
					for (j = 0; j < nacc; j++) { 
						if (pits[j] == p_acc.pit) {
							accs[j] = p_acc.acc
							if (p_acc.micro_n) {
								m_n[j] = p_acc.micro_n;
								m_d[j] = p_acc.micro_d
							}
							break
						}
					}
					if (j == nacc) {
						accs[j] = p_acc.acc;
						pits[j] = p_acc.pit
						if (p_acc.micro_n) {
							m_n[j] = p_acc.micro_n;
							m_d[j] = p_acc.micro_d
						}
						nacc++
					}
				}
				for (i = 0; i < nacc; i++) { 
					p_acc = s.k_a_acc[i]
					if (!p_acc)
						p_acc = s.k_a_acc[i] = {}
					p_acc.acc = accs[i];
					p_acc.pit = pits[i]
					if (m_n[i]) {
						p_acc.micro_n = m_n[i];
						p_acc.micro_d = m_d[i]
					} else {
						delete p_acc.micro_n
						delete p_acc.micro_d
					}
				}
			}
			
			/*
			* for transpose purpose, check if a pitch is already in the measure or
			* if it is tied from a previous note, and return the associated accidental
			*/
			private function acc_same_pitch(pitch) : *  {
				var	i, time,
				s = curvoice.last_sym.prev
				
				if (!s)
					return //undefined;
				
				time = s.time
				
				for (; s; s = s.prev) { 
					switch (s.type) {
						case C.BAR:
							if (s.time < time)
								return //undefined // no same pitch
							while (1) { 
								s = s.prev
								if (!s)
									return //undefined
								if (s.type == C.NOTE) {
									if (s.time + s.dur == time)
										break
									return //undefined
								}
								if (s.time < time)
									return //undefined
							}
							for (i = 0; i <= s.nhd; i++) { 
								if (s.notes[i].pit == pitch
									&& s.notes[i].ti1)
									return s.notes[i].acc
							}
							return //undefined
						case C.NOTE:
							for (i = 0; i <= s.nhd; i++) { 
								if (s.notes[i].pit == pitch)
									return s.notes[i].acc
							}
							break
					}
				}
				return //undefined
			}
			
			/* -- get staves definition (%%staves / %%score) -- */
			private function get_staves(cmd, parm) : *  {
				var	s, p_voice, p_voice2, i, flags, v, vid,
				st, range,
				a_vf = parse_staves(parm) // array of [vid, flags]
				
				if (!a_vf)
					return
				
				if (voice_tb.length != 0) {
					voice_adj();
					dupl_voice()
				}
				
				/* create a new staff system */
				var	maxtime = 0,
					no_sym = true
				
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					if (p_voice.time > maxtime)
						maxtime = p_voice.time
					if (p_voice.sym)
						no_sym = false
				}
				if (no_sym				/* if first %%staves */
					|| (maxtime == 0 && staves_found < 0)) {
					for (v = 0; v < par_sy.voices.length; v++) { 
						par_sy.voices[v].range = -1;
					}
				} else {
					
					/*
					* create a new staff system and
					* link the 'staves' symbol in a voice which is seen from
					* the previous system - see sort_all
					*/
					for (v = 0; v < par_sy.voices.length; v++) { 
						if (par_sy.voices[v].range >= 0) {
							curvoice = voice_tb[v]
							break
						}
					}
					curvoice.time = maxtime;
					s = {
						type: C.STAVES,
							dur: 0
					}
					
					sym_link(s);		// link the staves in this voice
					par_sy.nstaff = nstaff;
					new_syst();
					s.sy = par_sy
				}
				
				staves_found = maxtime
				
				/* initialize the (old) voices */
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					delete p_voice.second
					delete p_voice.ignore
					delete p_voice.floating
				}
				range = 0
				for (i = 0; i < a_vf.length; i++) { 
					vid = a_vf[i][0];
					p_voice = new_voice(vid);
					p_voice.time = maxtime;
					v = p_voice.v
					if (i == 0)
						par_sy.top_voice = p_voice.v
					
					// if the voice is already here, clone it
					if (par_sy.voices[v].range >= 0) {
						p_voice2 = clone(p_voice);
						par_sy.voices[voice_tb.length] = clone(par_sy.voices[v]);
						v = voice_tb.length;
						p_voice2.v = v;
						p_voice2.sym = p_voice2.last_sym = null;
						p_voice2.time = maxtime;
						voice_tb.push(p_voice2)
						delete p_voice2.clone
						while (p_voice.clone) { 
							p_voice = p_voice.clone;
						}
						p_voice.clone = p_voice2;
						p_voice = p_voice2
					}
					a_vf[i][0] = p_voice;
					par_sy.voices[v].range = range++
				}
				
				/* change the behavior from %%staves to %%score */
				if (cmd.charAt(1) == 't') {				/* if %%staves */
					for (i = 0; i < a_vf.length; i++) { 
						flags = a_vf[i][1]
						if (!(flags & (OPEN_BRACE | OPEN_BRACE2)))
							continue
						if ((flags & (OPEN_BRACE | CLOSE_BRACE))
							== (OPEN_BRACE | CLOSE_BRACE)
							|| (flags & (OPEN_BRACE2 | CLOSE_BRACE2))
							== (OPEN_BRACE2 | CLOSE_BRACE2))
							continue
						if (a_vf[i + 1][1] != 0)
							continue
						if ((flags & OPEN_PARENTH)
							|| (a_vf[i + 2][1] & OPEN_PARENTH))
							continue
						
						/* {a b c} -> {a *b c} */
						if (a_vf[i + 2][1] & (CLOSE_BRACE | CLOSE_BRACE2)) {
							a_vf[i + 1][1] |= FL_VOICE
							
							/* {a b c d} -> {(a b) (c d)} */
						} else if (a_vf[i + 2][1] == 0
							&& (a_vf[i + 3][1]
								& (CLOSE_BRACE | CLOSE_BRACE2))) {
							a_vf[i][1] |= OPEN_PARENTH;
							a_vf[i + 1][1] |= CLOSE_PARENTH;
							a_vf[i + 2][1] |= OPEN_PARENTH;
							a_vf[i + 3][1] |= CLOSE_PARENTH
						}
					}
				}
				
				/* set the staff system */
				st = -1
				for (i = 0; i < a_vf.length; i++) { 
					flags = a_vf[i][1]
					if ((flags & (OPEN_PARENTH | CLOSE_PARENTH))
						== (OPEN_PARENTH | CLOSE_PARENTH)) {
						flags &= ~(OPEN_PARENTH | CLOSE_PARENTH);
						a_vf[i][1] = flags
					}
					p_voice = a_vf[i][0]
					if (flags & FL_VOICE) {
						p_voice.floating = true;
						p_voice.second = true
					} else {
						st++;
						if (!par_sy.staves[st]) {
							par_sy.staves[st] = {
								stafflines: '|||||',
								staffscale: 1
							}
						}
						par_sy.staves[st].flags = 0
					}
					v = p_voice.v;
					p_voice.st = p_voice.cst =
						par_sy.voices[v].st = st;
					par_sy.staves[st].flags |= flags
					if (flags & OPEN_PARENTH) {
						p_voice2 = p_voice
						while (i < a_vf.length - 1) { 
							p_voice = a_vf[++i][0];
							v = p_voice.v
							if (a_vf[i][1] & MASTER_VOICE) {
								p_voice2.second = true
								p_voice2 = p_voice
							} else {
								p_voice.second = true;
							}
							p_voice.st = p_voice.cst
								= par_sy.voices[v].st
								= st
							if (a_vf[i][1] & CLOSE_PARENTH)
								break
						}
						par_sy.staves[st].flags |= a_vf[i][1]
					}
				}
				if (st < 0)
					st = 0
				par_sy.nstaff = nstaff = st
				
				/* change the behaviour of '|' in %%score */
				if (cmd.charAt(1) == 'c') {				/* if %%score */
					for (st = 0; st < nstaff; st++) { 
						par_sy.staves[st].flags ^= STOP_BAR;
					}
				}
				
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v]
					if (par_sy.voices[v].range < 0) {
						p_voice.ignore = true
						continue
					}
					par_sy.voices[v].second = p_voice.second;
					st = p_voice.st
					if (st > 0 && !p_voice.norepbra
						&& !(par_sy.staves[st - 1].flags & STOP_BAR))
						p_voice.norepbra = true
				}
				
				curvoice = parse.state >= 2 ? voice_tb[par_sy.top_voice] : null
			}
			
			/* -- get a voice overlay -- */
			private function get_vover(type) : *  {
				var	p_voice2, p_voice3, range, s, time, v, v2, v3,
				line = parse.line
				
				// get a voice or create a clone of the current voice
				function clone_voice(id) :*  {
					var v, p_voice
					
					for (v = 0; v < voice_tb.length; v++) { 
						p_voice = voice_tb[v]
						if (p_voice.id == id)
							return p_voice		// found
					}
					p_voice = clone(curvoice);
					p_voice.v = voice_tb.length;
					p_voice.id = id;
					p_voice.sym = p_voice.last_sym = null;
					
					delete p_voice.nm
					delete p_voice.snm
					delete p_voice.new_name
					delete p_voice.lyric_restart
					delete p_voice.lyric_cont
					delete p_voice.ly_a_h;
					delete p_voice.sym_restart
					delete p_voice.sym_cont
					delete p_voice.have_ly
					
					voice_tb.push(p_voice)
					return p_voice
				} // clone_voice()
				
				/* treat the end of overlay */
				if (curvoice.ignore)
					return
				if (type == '|'
					|| type == ')')  {
					if (!curvoice.last_note) {
						syntax(1, errs.nonote_vo)
						return
					}
					curvoice.last_note.beam_end = true
					if (!vover) {
						syntax(1, "Erroneous end of voice overlay")
						return
					}
					if (curvoice.time != vover.p_voice.time) {
						syntax(1, "Wrong duration in voice overlay");
						if (curvoice.time > vover.p_voice.time)
							vover.p_voice.time = curvoice.time
					}
					curvoice = vover.p_voice;
					vover = null
					return
				}
				
				/* treat the full overlay start */
				if (type == '(') {
					if (vover) {
						syntax(1, "Voice overlay already started")
						return
					}
					vover = {
						p_voice: curvoice,
						time: curvoice.time
					}
					return
				}
				
				/* (here is treated a new overlay - '&') */
				/* create the extra voice if not done yet */
				if (!curvoice.last_note) {
					syntax(1, errs.nonote_vo)
					return
				}
				curvoice.last_note.beam_end = true;
				p_voice2 = curvoice.voice_down
				if (!p_voice2) {
					p_voice2 = clone_voice(curvoice.id + 'o');
					curvoice.voice_down = p_voice2;
					p_voice2.time = 0;
					p_voice2.second = true;
					v2 = p_voice2.v;
					par_sy.voices[v2] = {
						st: curvoice.st,
							second: true
					}
					var f_clone = curvoice.clone != undefined ? 1 : 0;
					range = par_sy.voices[curvoice.v].range
					for (v = 0; v < par_sy.voices.length; v++) { 
						if (par_sy.voices[v].range > range)
							par_sy.voices[v].range += f_clone + 1
					}
					par_sy.voices[v2].range = range + 1
					if (f_clone) {
						p_voice3 = clone_voice(p_voice2.id + 'c');
						p_voice3.second = true;
						v3 = p_voice3.v;
						par_sy.voices[v3] = {
							second: true,
							range: range + 2
						}
						p_voice2.clone = p_voice3
					}
				}
				p_voice2.ulen = curvoice.ulen
				p_voice2.dur_fact = curvoice.dur_fact
				if (curvoice.uscale)
					p_voice2.uscale = curvoice.uscale
				
				if (!vover) {				/* first '&' in a measure */
					vover = {
						bar: true,
						p_voice: curvoice
					}
					time = p_voice2.time
					for (s = curvoice.last_sym; /*s*/; s = s.prev) { 
						if (s.type == C.BAR
							|| s.time <= time)	/* (if start of tune) */
							break
					}
					vover.time = s.time
				} else {
					if (curvoice != vover.p_voice
						&& curvoice.time != vover.p_voice.time) {
						syntax(1, "Wrong duration in voice overlay")
						if (curvoice.time > vover.p_voice.time)
							vover.p_voice.time = curvoice.time
					}
				}
				p_voice2.time = vover.time;
				curvoice = p_voice2
			}
			
			// check if a clef, key or time signature may go at start of the current voice
			private function is_voice_sig() : *  {
				var s
				
				if (!curvoice.sym)
					return true	// new voice (may appear in the middle of a tune)
				if (curvoice.time != 0)
					return false
				for (s = curvoice.last_sym; s; s = s.prev) { 
					if (w_tb[s.type] != 0) {
						return false;
					}
				}
				return true
			}
			
			// treat a clef found in the tune body
			private function get_clef(s) : *  {
				var	s2, s3
				
				if (is_voice_sig()) {
					curvoice.clef = s
					return
				}
				
				// clef change
				/* the clef must appear before a key signature or a bar */
				for (s2 = curvoice.last_sym;
					s2 && s2.prev && s2.time == curvoice.time;
					s2 = s2.prev) { 
					if (w_tb[s2.type] != 0)
						break
				}
				if (s2 && s2.prev
					&& s2.time == curvoice.time		// if no time skip
					&& ((s2.type == C.KEY && !s2.k_none) || s2.type == C.BAR)) {
					for (s3 = s2; s3.prev; s3 = s3.prev) { 
						switch (s3.prev.type) {
							case C.KEY:
							case C.BAR:
								continue
						}
						break
					}
					s2 = curvoice.last_sym;
					curvoice.last_sym = s3.prev;
					sym_link(s);
					s.next = s3;
					s3.prev = s;
					curvoice.last_sym = s2
				} else {
					sym_link(s)
				}
				s.clef_small = true
			}
			
			// treat K: (kp = key signature + parameters)
			private function get_key(parm) : *  {
				var	v, p_voice, s, transp,
				//		[s_key, a] = new_key(parm)	// KO with nodejs
				a = new_key(parm),
					s_key = a[0];
				
				a = a[1]
				if (s_key.k_sf
					&& !s_key.k_exp
					&& s_key.k_a_acc)
					set_k_acc(s_key)
				
				switch (parse.state) {
					case 1:				// in tune header (first K:)
						if (s_key.k_sf == undefined && !s_key.k_a_acc) { // empty K:
							s_key.k_sf = 0;
							s_key.k_none = true
						}
						for (v = 0; v < voice_tb.length; v++) { 
							p_voice = voice_tb[v];
							p_voice.key = clone(s_key);
							p_voice.okey = clone(s_key);
							p_voice.ckey = clone(s_key)
						}
						parse.ckey = s_key
						if (a.length != 0)
							memo_kv_parm('*', a)
						if (!glovar.ulen)
							glovar.ulen = C.BLEN / 8;
						parse.state = 2;		// in tune header after K:
						
						set_page();
						write_heading();
						reset_gen();
						gene.nbar = cfmt.measurefirst	// measure numbering
						return
					case 2:					// K: at start of tune body
						goto_tune(true)
						break
				}
				if (a.length != 0)
					set_kv_parm(a);
				
				if (!curvoice.ckey.k_bagpipe && !curvoice.ckey.k_drum)
					transp = (cfmt.transp || 0) +
						(curvoice.transp || 0) +
						(curvoice.shift || 0)
				
				if (s_key.k_sf == undefined) {
					if (!s_key.k_a_acc
						&& !transp)
						return
					s_key.k_sf = curvoice.okey.k_sf
				}
				
				curvoice.okey = clone(s_key)
				if (transp) {
					curvoice.vtransp = transp;
					key_transp(s_key)
				}
				
				s_key.k_old_sf = curvoice.ckey.k_sf;	// memorize the key changes
				
				curvoice.ckey = s_key
				
				if (is_voice_sig()) {
					curvoice.key = clone(s_key)
					if (s_key.k_none)
						curvoice.key.k_sf = 0
					return
				}
				
				/* the key signature must appear before a time signature */
				s = curvoice.last_sym
				if (s && s.type == C.METER) {
					curvoice.last_sym = s.prev
					if (!curvoice.last_sym)
						curvoice.sym = null;
					sym_link(s_key);
					s_key.next = s;
					s.prev = s_key;
					curvoice.last_sym = s
				} else {
					sym_link(s_key)
				}
			}
			
			// get / create a new voice
			private function new_voice(id) : *  {
				var	p_voice, v, p_v_sav,
				n = voice_tb.length
				
				// if first explicit voice and no music, replace the default V:1
				if (n == 1
					&& voice_tb[0]['default']) {
						delete voice_tb[0]['default']
							if (voice_tb[0].time == 0) {
								p_voice = voice_tb[0];
								p_voice.id = id
								if (cfmt.transp	// != undefined
									&& parse.state >= 2) {
									p_v_sav = curvoice;
									curvoice = p_voice;
									set_transp();
									curvoice = p_v_sav
								}
								return p_voice		// default voice
							}
					}
						for (v = 0; v < n; v++) { 
							p_voice = voice_tb[v]
							if (p_voice.id == id)
								return p_voice		// old voice
						}
						
						p_voice = {
						v: v,
						id: id,
						time: 0,
						'new': true,
						pos: {
							dyn: 0,
							gch: 0,
							gst: 0,
							orn: 0,
							stm: 0,
							voc: 0,
							vol: 0
						},
						scale: 1,
						//		st: 0,
						//		cst: 0,
						ulen: glovar.ulen,
						dur_fact: 1,
						key: clone(parse.ckey),	// key at start of tune (parse) / line (gene)
						ckey: clone(parse.ckey),	// current key (parse)
						okey: clone(parse.ckey),	// key without transposition (parse)
						meter: clone(glovar.meter),
						wmeasure: glovar.meter.wmeasure,
						clef: {
							type: C.CLEF,
							clef_auto: true,
							clef_type: "a",		// auto
							time: 0
						},
						hy_st: 0
					}
						
					voice_tb.push(p_voice);
					par_sy.voices[v] = {
						range: -1
					}
				return p_voice
			}
			
			// this function is called at program start and on end of tune
			private function init_tune() : *  {
				nstaff = -1;
				voice_tb = [];
				curvoice = null;
				new_syst(true);
				staves_found = -1;
				gene = {}
				a_de = []			// remove old decorations
				od = {}				// no ottava decorations anymore
			}
			
			// treat V: with many voices
			private function do_cloning(vs) : *  {
				var	i, eol,
				file = parse.file,
					start = parse.eol + 1,		// next line after V:
					bol = start
				
				// search the end of the music to be cloned
				while (1) { 
					eol = file.indexOf('\n', bol)
					if (eol < 0) {
						eol = 0
						break
					}
					
					// stop on comment, or information field
					if (/%.*|\n.*|.:.|\[.:/.test(file.slice(eol + 1, eol + 4)))
						break
					bol = eol + 1
				}
				
				// insert the music sequence in each voice
				$include++;
				tosvg(parse.fname, file, start, eol)	// first voice
				for (i = 0; i < vs.length; i++) { 
					get_voice(vs[i]);
					tosvg(parse.fname, file, start, eol)
				}
				$include--
			}
			
			// treat a 'V:' info
			private function get_voice(parm) : *  {
				var	v, transp, vtransp, vs,
				a = info_split(parm, 1),
					vid = a.shift();
				
				if (!vid)
					return				// empty V:
				
				if (vid.indexOf(',') > 0) {		// if many voices
					vs = vid.split(',');
					vid = vs.shift()
				}
				
				if (parse.state < 2) {
					if (a.length != 0)
						memo_kv_parm(vid, a)
					if (vid != '*' && parse.state == 1)
						new_voice(vid)
					return
				}
				
				if (vid == '*') {
					syntax(1, "Cannot have V:* in tune body")
					return
				}
				curvoice = new_voice(vid);
				set_kv_parm(a)
				if (parse.state == 2)			// if first voice
					goto_tune();
				set_transp();
				
				v = curvoice.v
				if (curvoice['new']) {			// if new voice
					delete curvoice['new']
					if (staves_found < 0) {		// if no %%score/%%staves
						curvoice.st = curvoice.cst = ++nstaff;
						par_sy.nstaff = nstaff;
						par_sy.voices[v].st = nstaff;
						par_sy.voices[v].range = v;
						par_sy.staves[nstaff] = {
							stafflines: "|||||",
							staffscale: 1
						}
					}
					
					if (par_sy.voices[v].range < 0) {
						//			if (cfmt.alignbars)
						//				syntax(1, "V: does not work with %%alignbars")
						if (staves_found >= 0)
							curvoice.ignore = true
					}
				}
				
				if (curvoice.stafflines && curvoice.st != undefined) {
					par_sy.staves[curvoice.st].stafflines = curvoice.stafflines;
					curvoice.stafflines = ''
				}
				
				if (!curvoice.filtered
					&& !curvoice.ignore
					&& parse.voice_opts) {
					curvoice.filtered = true;
					voice_filter()
				}
				
				if (vs)
					do_cloning(vs)
			}
			
			// change state from 'tune header after K:' to 'in tune body'
			// curvoice is defined when called from get_voice()
			private function goto_tune(is_K = false) : *  {
				var	v, p_voice,
				s = {
					type: C.STAVES,
						dur: 0,
						sy: par_sy
				}
				
				parse.state = 3;			// in tune body
				
				// if no voice yet, create the default voice
				if (voice_tb.length == 0) {
					curvoice = new_voice("1");
					curvoice.clef.istart = curvoice.key.istart;
					curvoice.clef.iend = curvoice.key.iend;
					//		nstaff = 0;
					curvoice['default'] = true
				} else if (!curvoice) {
					curvoice = voice_tb[staves_found < 0 ? 0 : par_sy.top_voice]
				}
				
				if (!curvoice.init && !is_K) {
					set_kv_parm([]);
					set_transp()
				}
				
				// update some voice parameters
				for (v = 0; v < voice_tb.length; v++) { 
					p_voice = voice_tb[v];
					p_voice.ulen = glovar.ulen
					if (p_voice.ckey.k_bagpipe
						&& !p_voice.pos.stm) {
						p_voice.pos = clone(p_voice.pos);
						p_voice.pos.stm = C.SL_BELOW
					}
				}
				
				// initialize the voices when no %%staves/score
				if (staves_found < 0) {
					nstaff = voice_tb.length - 1
					for (v = 0; v <= nstaff; v++) { 
						p_voice = voice_tb[v];
						delete p_voice['new'];		// old voice
						p_voice.st = p_voice.cst =
							par_sy.voices[v].st =
							par_sy.voices[v].range = v;
						par_sy.staves[v] = {
							stafflines: '|||||',
							staffscale: 1
						}
					}
					par_sy.nstaff = nstaff
				}
				
				// link the first %%score in the top voice
				p_voice = curvoice;
				curvoice = voice_tb[par_sy.top_voice];
				sym_link(s)
				if (staves_found < 0)
					s['default'] = true;
						curvoice = p_voice
			}
			
			
			// ------------------------------------------
			
			// abc2svg - lyrics.js - lyrics
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			// parse a symbol line (s:)
			private function get_sym(p, cont) : *  {
				var s, c, i, j, d
				
				if (curvoice.ignore)
					return
				
				// get the starting symbol of the lyrics
				if (cont) {					// +:
					s = curvoice.sym_cont
					if (!s) {
						syntax(1, "+: symbol line without music")
						return
					}
				} else {
					if (curvoice.sym_restart) {		// new music
						curvoice.sym_start = s = curvoice.sym_restart;
						curvoice.sym_restart = null
					} else {
						s = curvoice.sym_start
					}
					if (!s)
						s = curvoice.sym
					if (!s) {
						syntax(1, "s: without music")
						return
					}
				}
				
				/* scan the symbol line */
				i = 0
				while (1) { 
					while (p[i] == ' ' || p[i] == '\t') { 
						i++;
					}
					c = p[i]
					if (!c)
						break
					switch (c) {
						case '|':
							while (s && s.type != C.BAR) { 
								s = s.next;
							}
							if (!s) {
								syntax(1, "Not enough measure bars for symbol line")
								return
							}
							s = s.next;
							i++
							continue
						case '!':
						case '"':
							j = ++i
							i = p.indexOf(c, j)
							if (i < 0) {
								syntax(1, c == '!' ?
									"No end of decoration" :
									"No end of guitar chord");
								i = p.length
								continue
							}
							d = p.slice(j - 1, i + 1)
							break
						case '*':
							break
						default:
							d = c.charCodeAt(0)
							if (d < 128) {
								d = char_tb[d]
								if (d.length > 1
									&& (d[0] == '!' || d[0] == '"')) {
									c = d[0]
									break
								}
							}
							syntax(1, errs.bad_char, c)
							break
					}
					
					/* store the element in the next note */
					while (s && (s.type != C.NOTE || s.grace)) {
						s = s.next;
					}
					if (!s) {
						syntax(1, "Too many elements in symbol line")
						return
					}
					switch (c) {
						default:
							//		case '*':
							break
						case '!':
							deco_cnv([d.slice(1, -1)], s, s.prev)
							break
						case '"':
							a_gch = s.a_gch;
							parse_gchord(d)
							if (a_gch)
								self.gch_build(s)
							break
					}
					s = s.next;
					i++
				}
				curvoice.lyric_cont = s
			}
			
			/* -- parse a lyric (vocal) line (w:) -- */
			private function get_lyrics(text, cont) : *  {
				var s, word, p, i, j, ly
				
				if (curvoice.ignore)
					return
				if (curvoice.pos.voc != C.SL_HIDDEN)
					curvoice.have_ly = true
				
				// get the starting symbol of the lyrics
				if (cont) {					// +:
					s = curvoice.lyric_cont
					if (!s) {
						syntax(1, "+: lyric without music")
						return
					}
				} else {
					set_font("vocal")
					if (curvoice.lyric_restart) {		// new music
						curvoice.lyric_start = s = curvoice.lyric_restart;
						curvoice.lyric_restart = null;
						curvoice.lyric_line = 0
					} else {
						curvoice.lyric_line++;
						s = curvoice.lyric_start
					}
					if (!s)
						s = curvoice.sym
					if (!s) {
						syntax(1, "w: without music")
						return
					}
				}
				
				/* scan the lyric line */
				p = text;
				i = 0
				while (1) { 
					while (p[i] == ' ' || p[i] == '\t') { 
						i++;
					}
					if (!p[i])
					break
					j = parse.istart + i + 2	// start index
					switch (p[i]) {
						case '|':
							while (s && s.type != C.BAR) { 
								s = s.next;
							}
							if (!s) {
								syntax(1, "Not enough measure bars for lyric line")
								return
							}
							s = s.next;
							i++
							continue
						case '-':
							word = "-\n"
							break
						case '_':
							word = "_\n"
							break
						case '*':
							word = ""
							break
						default:
							if (p[i] == '\\'
								&& i == p.length - 1) {
								curvoice.lyric_cont = s
								return
							}
							word = "";
							while (1) { 
								if (!p[i])
									break
								switch (p[i]) {
									case '_':
									case '*':
									case '|':
										i--
										case ' ':
										case '\t':
										break
									case '~':
									word += ' ';
									i++
									continue
									case '-':
									word += "\n"
									break
									case '\\':
									word += p[++i];
									i++
									continue
									default:
									word += p[i++]
									continue
								}
								break
							}
							break
					}
					
					/* store the word in the next note */
					while (s && (s.type != C.NOTE || s.grace)) {
						s = s.next;
					}
					if (!s) {
						syntax(1, "Too many words in lyric line")
						return
					}
					if (word
						&& s.pos.voc != C.SL_HIDDEN) {
						if (word.match(/^\$\d/)) {
							if (word[1] == '0')
								set_font("vocal")
							else
								set_font("u" + word[1]);
							word = word.slice(2)
						}
						ly = {
							t: word,
							font: gene.curfont,
								w: strwh(word)[0],
								istart: j,
								iend: j + word.length
						}
						if (!s.a_ly)
							s.a_ly = []
						s.a_ly[curvoice.lyric_line] = ly
					}
					s = s.next;
					i++
				}
				curvoice.lyric_cont = s
			}
			
			// -- set the width needed by the lyrics --
			// (called once per tune)
			private function ly_width(s, wlw) : *  {
				var	ly, sz, swfac, align, xx, w, i, j, k, shift, p,
				a_ly = s.a_ly;
				
				align = 0
				for (i = 0; i < a_ly.length; i++) { 
					ly = a_ly[i]
					if (!ly)
						continue
					p = ly.t;
					if (p == "-\n" || p == "_\n") {
						ly.shift = 0
						continue
					}
					w = ly.w;
					swfac = ly.font.swfac;
					xx = w + 2 * cwid(' ') * swfac
					if (s.type == C.GRACE) {			// %%graceword
						shift = s.wl
					} else if ((p[0] >= '0' && p[0] <= '9' && p.length > 2)
						|| p[1] == ':'
						|| p[0] == '(' || p[0] == ')') {
						if (p[0] == '(') {
							sz = cwid('(') * swfac
						} else {
							j = p.indexOf(' ');
							set_font(ly.font)
							if (j > 0)
								sz = strwh(p.slice(0, j))[0]
							else
								sz = w
						}
						shift = (w - sz + 2 * cwid(' ') * swfac) * .4
						if (shift > 20)
							shift = 20;
						shift += sz
						if (ly.t[0] >= '0' && ly.t[0] <= '9') {
							if (shift > align)
								align = shift
						}
					} else {
						shift = xx * .4
						if (shift > 20)
							shift = 20
					}
					ly.shift = shift
					if (wlw < shift)
						wlw = shift;
					//		if (p[p.length - 1] == "\n")		// if "xx-"
					//			xx -= cwid(' ') * swfac
					xx -= shift;
					shift = 2 * cwid(' ') * swfac
					for (k = s.next; k; k = k.next) { 
						switch (k.type) {
							case C.NOTE:
							case C.REST:
								if (!k.a_ly || !k.a_ly[i]
									|| k.a_ly[i].w == 0)
									xx -= 9
								else if (k.a_ly[i].t == "-\n"
									|| k.a_ly[i].t == "_\n")
									xx -= shift
								else
									break
								if (xx <= 0)
									break
								continue
							case C.CLEF:
							case C.METER:
							case C.KEY:
								xx -= 10
								continue
							default:
								xx -= 5
								break
						}
						break
					}
					if (xx > s.wr)
						s.wr = xx
				}
				if (align > 0) {
					for (i = 0; i < a_ly.length; i++) { 
						ly = a_ly[i]
						if (ly && ly.t[0] >= '0' && ly.t[0] <= '9')
							ly.shift = align
					}
				}
				return wlw
			}
			
			/* -- draw the lyrics under (or above) notes -- */
			/* (the staves are not yet defined) */
			/* !! this routine is tied to ly_width() !! */
			private function draw_lyric_line(p_voice, j, y) : *  {
				var	p, lastx, w, s, s2, ly, lyl,
				hyflag, lflag, x0, font, shift
				
				if (p_voice.hy_st & (1 << j)) {
					hyflag = true;
					p_voice.hy_st &= ~(1 << j)
				}
				for (s = p_voice.sym; /*s*/; s = s.next) { 
					if (s.type != C.CLEF && s.type != C.KEY && s.type != C.METER) {
						break;
					}
				}
				lastx = s.prev ? s.prev.x : tsfirst.x;
				x0 = 0
				for ( ; s; s = s.next) { 
					if (s.a_ly)
						ly = s.a_ly[j]
					else
						ly = null
					if (!ly) {
						switch (s.type) {
							case C.REST:
							case C.MREST:
								if (lflag) {
									out_wln(lastx + 3, y, x0 - lastx);
									lflag = false;
									lastx = s.x + s.wr
								}
						}
						continue
					}
					if (ly.font != gene.curfont)		/* font change */
						gene.curfont = font = ly.font;
					p = ly.t;
					w = ly.w;
					shift = ly.shift
					if (hyflag) {
						if (p == "_\n") {		/* '_' */
							p = "-\n"
						} else if (p != "-\n") {	/* not '-' */
							out_hyph(lastx, y, s.x - shift - lastx);
							hyflag = false;
							lastx = s.x + s.wr
						}
					}
					if (lflag
						&& p != "_\n") {		/* not '_' */
						out_wln(lastx + 3, y, x0 - lastx + 3);
						lflag = false;
						lastx = s.x + s.wr
					}
					if (p == "-\n"			/* '-' */
						|| p == "_\n") {		/* '_' */
						if (x0 == 0 && lastx > s.x - 18)
							lastx = s.x - 18
						if (p[0] == '-')
							hyflag = true
						else
							lflag = true;
						x0 = s.x - shift
						continue
					}
					x0 = s.x - shift;
					if (p.slice(-1) == '\n') {
						p = p.slice(0, -1);	/* '-' at end */
						hyflag = true
					}
					if (user.anno_start || user.anno_stop) {
						s2 = {
							st: s.st,
								istart: ly.istart,
								iend: ly.iend,
								x: x0,
								y: y,
								ymn: y,
								ymx: y + gene.curfont.size,
								wl: 0,
								wr: w
						}
						anno_start(s2, 'lyrics')
					}
					xy_str(x0, y, p);
					anno_stop(s2, 'lyrics')
					lastx = x0 + w
				}
				if (hyflag) {
					hyflag = false;
					x0 = realwidth - 10
					if (x0 < lastx + 10)
						x0 = lastx + 10;
					out_hyph(lastx, y, x0 - lastx)
					if (cfmt.hyphencont)
						p_voice.hy_st |= (1 << j)
				}
				
				/* see if any underscore in the next line */
				for (p_voice.s_next ; s; s = s.next) { 
					if (s.type == C.NOTE) {
						if (!s.a_ly)
							break
						ly = s.a_ly[j]
						if (ly && ly.t == "_\n") {
							lflag = true;
							x0 = realwidth - 15
							if (x0 < lastx + 12)
								x0 = lastx + 12
						}
						break
					}
				}
				if (lflag) {
					out_wln(lastx + 3, y, x0 - lastx + 3);
					lflag = false
				}
			}
			
			private function draw_lyrics(p_voice, nly, a_h, y,
								 incr) : *  {	/* 1: below, -1: above */
				var	j, top,
				sc = staff_tb[p_voice.st].staffscale;
				
				set_font("vocal")
				if (incr > 0) {				/* under the staff */
					if (y > -cfmt.vocalspace)
						y = -cfmt.vocalspace;
					y *= sc
					for (j = 0; j < nly; j++) { 
						y -= a_h[j] * 1.1;
						draw_lyric_line(p_voice, j, y)
					}
					return (y - a_h[j - 1] / 6) / sc
				}
				
				/* above the staff */
				top = staff_tb[p_voice.st].topbar + cfmt.vocalspace
				if (y < top)
					y = top;
				y *= sc
				for (j = nly; --j >= 0;) { 
					draw_lyric_line(p_voice, j, y);
					y += a_h[j] * 1.1
				}
				return y / sc
			}
			
			// -- draw all the lyrics --
			/* (the staves are not yet defined) */
			private function draw_all_lyrics() : *  {
				var	p_voice, s, v, nly, i, x, y, w, a_ly, ly,
				lyst_tb = new Array(nstaff),
					nv = voice_tb.length,
					h_tb = new Array(nv),
					nly_tb = new Array(nv),
					above_tb = new Array(nv),
					rv_tb = new Array(nv),
					top = 0,
					bot = 0,
					st = -1
				
				/* compute the number of lyrics per voice - staff
				* and their y offset on the staff */
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v]
					if (!p_voice.sym)
						continue
					if (p_voice.st != st) {
						top = 0;
						bot = 0;
						st = p_voice.st
					}
					nly = 0
					if (p_voice.have_ly) {
						if (!h_tb[v])
							h_tb[v] = []
						for (s = p_voice.sym; s; s = s.next) { 
							a_ly = s.a_ly
							if (!a_ly)
								continue
							/*fixme:should get the real width*/
							x = s.x;
							w = 10
							for (i = 0; i < a_ly.length; i++) { 
								ly = a_ly[i]
								if (ly && ly.w != 0) {
									x -= ly.shift;
									w = ly.w
									break
								}
							}
							y = y_get(p_voice.st, 1, x, w)
							if (top < y)
								top = y;
							y = y_get(p_voice.st, 0, x, w)
							if (bot > y)
								bot = y
							while (nly < a_ly.length) { 
								h_tb[v][nly++] = 0;
							}
							for (i = 0; i < a_ly.length; i++) { 
								ly = a_ly[i]
								if (!ly)
									continue
								if (!h_tb[v][i]
									|| ly.font.size > h_tb[v][i])
									h_tb[v][i] = ly.font.size
							}
						}
					} else {
						y = y_get(p_voice.st, 1, 0, realwidth)
						if (top < y)
							top = y;
						y = y_get(p_voice.st, 0, 0, realwidth)
						if (bot > y)
							bot = y
					}
					if (!lyst_tb[st])
						lyst_tb[st] = {}
					lyst_tb[st].top = top;
					lyst_tb[st].bot = bot;
					nly_tb[v] = nly
					if (nly == 0)
						continue
					if (p_voice.pos.voc)
						above_tb[v] = p_voice.pos.voc == C.SL_ABOVE
					else if (voice_tb[v + 1]
						/*fixme:%%staves:KO - find an other way..*/
						&& voice_tb[v + 1].st == st
						&& voice_tb[v + 1].have_ly)
						above_tb[v] = true
					else
						above_tb[v] = false
					if (above_tb[v])
						lyst_tb[st].a = true
					else
						lyst_tb[st].b = true
				}
				
				/* draw the lyrics under the staves */
				i = 0
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v]
					if (!p_voice.sym)
						continue
					if (!p_voice.have_ly)
						continue
					if (above_tb[v]) {
						rv_tb[i++] = v
						continue
					}
					st = p_voice.st;
					// don't scale the lyrics
					set_dscale(st, true)
					if (nly_tb[v] > 0)
						lyst_tb[st].bot = draw_lyrics(p_voice, nly_tb[v],
							h_tb[v],
							lyst_tb[st].bot, 1)
				}
				
				/* draw the lyrics above the staff */
				while (--i >= 0) { 
					v = rv_tb[i];
					p_voice = voice_tb[v];
					st = p_voice.st;
					set_dscale(st, true);
					lyst_tb[st].top = draw_lyrics(p_voice, nly_tb[v],
						h_tb[v],
						lyst_tb[st].top, -1)
				}
				
				/* set the max y offsets of all symbols */
				for (v = 0; v < nv; v++) { 
					p_voice = voice_tb[v]
					if (!p_voice.sym)
						continue
					st = p_voice.st;
					if (lyst_tb[st].a) {
						top = lyst_tb[st].top + 2
						for (s = p_voice.sym.next; s; s = s.next) { 
							/*fixme: may have lyrics crossing a next symbol*/
							if (s.a_ly) {
								/*fixme:should set the real width*/
								y_set(st, 1, s.x - 2, 10, top)
							}
						}
					}
					if (lyst_tb[st].b) {
						bot = lyst_tb[st].bot - 2
						if (nly_tb[p_voice.v] > 0) {
							for (s = p_voice.sym.next; s; s = s.next) { 
								if (s.a_ly) {
									/*fixme:should set the real width*/
									y_set(st, 0, s.x - 2, 10, bot)
								}
							}
						} else {
							y_set(st, 0, 0, realwidth, bot)
						}
					}
				}
			}
			
			// ----------------------------------
			
			
			// abc2svg - gchord.js - chord symbols
			//
			// Copyright (C) 2014-2018 Jean-Francois Moine
			//
			// This file is part of abc2svg-core.
			//
			// abc2svg-core is free software: you can redistribute it and/or modify
			// it under the terms of the GNU Lesser General Public License as published by
			// the Free Software Foundation, either version 3 of the License, or
			// (at your option) any later version.
			//
			// abc2svg-core is distributed in the hope that it will be useful,
			// but WITHOUT ANY WARRANTY; without even the implied warranty of
			// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			// GNU Lesser General Public License for more details.
			//
			// You should have received a copy of the GNU Lesser General Public License
			// along with abc2svg-core.  If not, see <http://www.gnu.org/licenses/>.
			
			// -- parse a chord symbol / annotation --
			// the result is added in the global variable a_gch
			// 'type' may be a single '"' or a string '"xxx"' created by U:
			private function parse_gchord(type) : *  {
				var	c, text, gch, x_abs, y_abs, type,
				i, istart, iend,
				ann_font = get_font("annotation"),
					h_ann = ann_font.size,
					line = parse.line;
				
				function get_float()  :* {
					var txt = ''
					
					while (1) { 
						c = text[i++]
						if ("1234567890.-".indexOf(c) < 0)
							return parseFloat(txt)
						txt += c
					}
				} // get_float()
				
				istart = parse.bol + line.index
				if (type.length > 1) {			// U:
					text = type.slice(1, -1);
					iend = istart + 1
				} else {
					text = ""
					while (1) { 
						c = line.next_char()
						if (!c) {
							syntax(1, "No end of guitar chord")
							return
						}
						if (c == '"')
							break
						if (c == '\\') {
							text += c;
							c = line.next_char()
						}
						text += c
					}
					iend = parse.bol + line.index + 1
				}
				
				if (curvoice.pos.gch == C.SL_HIDDEN)
					return
				
				i = 0;
				type = 'g'
				while (true) { 
					c = text.charAt(i)
					if (!c)
						break
					gch = {
						text: "",
						istart: istart,
						iend: iend,
						font: ann_font
					}
					switch (c) {
						case '@':
							type = c;
							i++;
							x_abs = get_float()
							if (c != ',') {
								syntax(1, "',' lacking in annotation '@x,y'");
								y_abs = 0
							} else {
								y_abs = get_float()
								if (c != ' ')
									i--
							}
							gch.x = x_abs;
							gch.y = y_abs - h_ann / 2
							break
						case '^':
						case '_':
						case '<':
						case '>':
							i++;
							type = c
							break
						default:
							switch (type) {
								case 'g':
									gch.font = get_font("gchord")
									break
								case '@':
									gch.x = x_abs;
									y_abs -= h_ann;
									gch.y = y_abs - h_ann / 2
									break
							}
							break
					}
					gch.type = type
					while (true) { 
						c = text.charAt(i);
						if (!c)
							break
						switch (c) {
							case '\\':
								c = text.charAt(++i)
								if (!c || c == 'n')
									break
								gch.text += '\\'
							default:
								gch.text += c;
								i++
								continue
							case '&':			/* skip "&xxx;" */
								while (1) { 
									gch.text += c;
									c = text[++i]
									switch (c) {
										default:
											continue
										case ';':
										case undefined:
										case '\\':
											break
									}
									break
								}
								if (c == ';') {
									gch.text += c
									continue
								}
								break
							case ';':
								break
						}
						i++
						break
					}
					if (!a_gch)
						a_gch = []
					a_gch.push(gch)
				}
			}
			
			// transpose a chord symbol
			private var	note_names : String = "CDEFGAB";
			private var latin_names : Array = [ "Do", "Re", "Mi", "Fa", "Sol", "La", "Si" ];
			private var acc_name : Array = ["bb", "b", "", "#", "##"];
			
			private function gch_tr1(p, i2) : *  {
				var	new_txt, l,
				n, i1, i3, i4, ix, a, ip, ip2,
				latin = 0
				
				/* main chord */
				switch (p[0]) {
					case 'A': n = 5; break
					case 'B': n = 6; break
					case 'C': n = 0; break
					case 'D':
						if (p[1] == 'o') {
							latin++;
							n = 0		/* Do */
							break
						}
						n = 1
						break
					case 'E': n = 2; break
					case 'F':
						if (p[1] == 'a')
							latin++;	/* Fa */
						n = 3
						break
					case 'G': n = 4; break
					case 'L':
						latin++;		/* La */
						n = 5
						break
					case 'M':
						latin++;		/* Mi */
						n = 2
						break
					case 'R':
						latin++
						n = 1			/* Re */
						break
					case 'S':
						latin++
						if (p[1] == 'o') {
						latin++;
						n = 4		/* Sol */
					} else {
						n = 6		/* Si */
					}
						break
					case '/':			// bass only
					latin--
					break
					default:
					return p
				}
				
				a = 0;
				ip = latin + 1
				if (latin >= 0) {		// if some chord
					while (p[ip] == '#') { 
						a++;
						ip++
					}
					while (p[ip] == 'b') { 
						a--;
						ip++
					}
					//			if (p[ip] == '=')
					//				ip++
					i3 = cde2fcg[n] + i2 + a * 7;
					i4 = cgd2cde[(i3 + 16 * 7) % 7];	// note
					i1 = ((((i3 + 22) / 7) | 0) + 159) % 5;	// accidental
					new_txt = (latin ? latin_names[i4] : note_names[i4]) +
						acc_name[i1]
				} else {
					new_txt = ''
				}
				
				ip2 = p.indexOf('/', ip)	// skip 'm'/'dim'..
				if (ip2 < 0)
					return new_txt + p.slice(ip);
				
				/* bass */
				n = note_names.indexOf(p[++ip2])
				if (n < 0)
					return new_txt + p.slice(ip);
				//fixme: latin names not treated
				new_txt += p.slice(ip, ip2);
				a = 0
				if (p[++ip2] == '#') {
					a++
					if (p[++ip2] == '#') {
						a++;
						ip2++
					}
				} else if (p[ip2] == 'b') {
					a--
					if (p[++ip2] == 'b') {
						a--;
						ip2++
					}
				}
				i3 = cde2fcg[n] + i2 + a * 7;
				i4 = cgd2cde[(i3 + 16 * 7) % 7];	// note
				i1 = ((((i3 + 22) / 7) | 0) + 159) % 5;	// accidental
				return new_txt + note_names[i4] + acc_name[i1] + p.slice(ip2)
			} // get_tr1
			
			private function gch_transp(s) : *  {
				var	gch, p, j,
				i = 0,
					i2 = curvoice.ckey.k_sf - curvoice.okey.k_sf
				
				while (1) { 
					gch = s.a_gch[i++]
					if (!gch)
						return
					if (gch.type != 'g')
						continue
					p = gch.text;
					j = p.indexOf('\t')
					if (j >= 0) {
						j++;
						p = p.slice(0, j) + gch_tr1(p.slice(j), i2)
					}
					gch.text = gch_tr1(p, i2)
				}
			}
			
			/**
			 * Builds the chord indications / annotations.
			 * (possible hook)
			 */
			private function gch_build(s) : void {
				
				// Split the chord indications / annotations and initialize their vertical offsets
				var text : String;
				var	gch : Object; 
				var wh : Array; 
				var xspc : Number; 
				var ix : int;
				var pos : int = (curvoice.pos.gch == C.SL_BELOW)? -1 : 1;
				var y_above : Number = 0;
				var y_below : Number = 0;
				var y_left : Number = 0;
				var y_right : Number = 0;
				var box : Boolean = cfmt.gchordbox;
					
				// Portion of chord before note
				const GCHPRE : Number = .4;
				
				s.a_gch = a_gch;
				a_gch = null;

				if (curvoice.vtransp) {
					gch_transp(s);
				}
				
				// Change the accidentals in the chord symbols, convert the escape sequences in
				// annotations, and set the offsets
				for (ix = 0; ix < s.a_gch.length; ix++) { 
					gch = s.a_gch[ix];
					
					// We do not want to output annotations that contain the "¦" (broken bar) symbol.
					// They must not influence the position of other elements either: they are only
					// there as helpers for locating elements on the score.
					text = gch.text;
					var isHelperAnnotation : Boolean = (text.charAt (text.length - 1) == '¦');
					if (isHelperAnnotation) {
						continue;
					}
					
					if (gch.type == 'g') {
						if (cfmt.chordnames) {
							
							// Save for %%diagram
							gch.otext = gch.text;
							gch.text = gch.text.replace (/A|B|C|D|E|F|G/g, function(c) : String {return cfmt.chordnames[c]});
							if (cfmt.chordnames.B == 'H') {
								gch.text = gch.text.replace (/Hb/g, 'Bb');
							}
						}
						gch.text = gch.text.replace (/##|#|=|bb|b/g,
							function(x) : String {
								switch (x) {
									case '##': return "&#x1d12a;";
									case '#': return "\u266f";
									case '=': return "\u266e";
									case 'b': return "\u266d";
								}
								return "&#x1d12b;";
							});
					} else {
						gch.text = cnv_escape(gch.text);
						
						// No width
						if (gch.type == '@' && !user.anno_start && !user.anno_stop) {
							continue;
						}
					}
					
					// Set the offsets and widths
					gene.curfont = gch.font;
					wh = strwh(gch.text);
					gch.w = wh[0];
					switch (gch.type) {
						case '@':
							break;
						
						// Above
						case '^':
							xspc = wh[0] * GCHPRE;
							if (xspc > 8) {
								xspc = 8;
							}
							gch.x = -xspc;
							y_above -= wh[1];
							gch.y = y_above;
							break;
						
						// Below
						case '_':
							xspc = wh[0] * GCHPRE;
							if (xspc > 8) {
								xspc = 8;
							}
							gch.x = -xspc;
							y_below -= wh[1];
							gch.y = y_below;
							break;
						
						// Left
						case '<':
							gch.x = -(wh[0] + 6);
							y_left -= wh[1];
							gch.y = y_left + wh[1] / 2;
							break;
						
						// Right
						case '>':
							gch.x = 6;
							y_right -= wh[1];
							gch.y = y_right + wh[1] / 2;
							break;
						
						// Chord symbol
						default:
							gch.box = box;
							xspc = wh[0] * GCHPRE;
							if (xspc > 8) {
								xspc = 8;
							}
							gch.x = -xspc;
							
							// Below
							if (pos < 0) {
								y_below -= wh[1];
								gch.y = y_below;
								if (box) {
									y_below -= 2;
									gch.y -= 1;
								}
							} else {
								y_above -= wh[1];
								gch.y = y_above;
								if (box) {
									y_above -= 2;
									gch.y -= 1;
								}
							}
							break;
					}
				}
				
				// Move upwards the top and middle texts
				y_left /= 2;
				y_right /= 2;
				for (ix = 0; ix < s.a_gch.length; ix++) { 
					gch = s.a_gch[ix];
					switch (gch.type) {
						
						// Above
						case '^':
							gch.y -= y_above;
							break;
						
						// Left
						case '<':
							gch.y -= y_left;
							break;
						
						// Right
						case '>':
							gch.y -= y_right;
							break;
						
						// Chord symbol
						case 'g':
							if (pos > 0) {
								gch.y -= y_above;
							}
							break;
					}
				}
			}
			
			/**
			 * Draws chord symbols and annotations.
			 * The staves are not yet defined.
			 * Unscaled delayed output.
			 * Possible hook.
			 */
			private function draw_gchord (s : Object, gchy_min, gchy_max) : void {
				var	gch : Object; 
				var gch2 : Object; 
				var text : String; 
				var ix : int; 
				var x : Number; 
				var y : Number; 
				var y2 : Number; 
				var i : int; 
				var j : int; 
				var hbox : int; 
				var h : Number;
				var nameSegments : Array;
				var annotationId : String;
				
				var annotationClass : String;
				var abcStartIndex : int;
				var abcEndIndex : int;
				var areaX : Number;
				var areaY : Number;
				var areaW : Number;
				var areaH : Number;
				
				// Adjust the vertical offset according to the chord symbols
				// FIXME: w may be too small
				var	w : Number = s.a_gch[0].w;
				var y_above : Number = y_get(s.st, 1, s.x - 2, w);	
				var y_below : Number = y_get (s.st, 0, s.x - 2, w);
				
				// Static or dynamic offset on measure bars
				var yav : Number = s.dur? (((s.notes[s.nhd].pit + s.notes[0].pit) >> 1) - 18) * 3 : 12;
				
				for (ix = 0; ix < s.a_gch.length; ix++) { 
					gch = s.a_gch[ix];
					if (gch.type != 'g') {
						continue;
					}
						
					// Chord symbol closest to the staff
					gch2 = gch;
					if (gch.y < 0) {
						break;
					}
				}
				if (gch2) {
					if (gch2.y >= 0) {
						if (y_above < gchy_max) {
							y_above = gchy_max;
						}
					} else {
						if (y_below > gchy_min) {
							y_below = gchy_min;
						}
					}
				}
				set_dscale (s.st);
				for (ix = 0; ix < s.a_gch.length; ix++) { 
					gch = s.a_gch[ix];
					use_font (gch.font);
					set_font (gch.font);
					text = gch.text;
					
					// We do not want to output annotations that contain the "¦" (broken bar) symbol.
					// They should not influence the position of other elements either: they are only
					// there as helpers for locating elements on the score.
					var isHelperAnnotation : Boolean = (text.charAt (text.length - 1) == '¦');
					h = isHelperAnnotation? 0 : gch.font.size;
					w = isHelperAnnotation? 0 : gch.w;
					x = isHelperAnnotation? s.x : s.x + gch.x;
					if (!isHelperAnnotation) {
						switch (gch.type) {
							
							// Chord notation below a note
							case '_':
								y = gch.y + y_below;
								y_set (s.st, 0, x, w, y - h * .2 - 2);
								break;
							
							// Chord notation above a note
							case '^':
								y = gch.y + y_above;
								y_set (s.st, 1, x, w, y + h * .8 + 2);
								break;
							
							// Chord notation to the left of a note
							// FIXME: what symbol space?
							case '<':
								if (s.notes[0].acc) {
									x -= s.notes[0].shac;
								}
								y = gch.y + yav - h / 2;
								break;
							
							// Chord notation to the right of a note
							case '>':
								x += s.xmx;
								if (s.dots > 0) {
									x += 1.5 + 3.5 * s.dots;
								}
								y = gch.y + yav - h / 2;
								break;
							
							// Chord symbol
							default:
								hbox = gch.box ? 3 : 2;
								if (gch.y >= 0) {
									y = gch.y + y_above;
									y_set (s.st, true, x, w, y + h + hbox);
								} else {
									y = gch.y + y_below;
									y_set (s.st, false, x, w, y - hbox);
								}
								i = text.indexOf('\t');
								
								// If some TAB: expand the chord symbol
								if (i >= 0) {
									x = realwidth;
									for (var next : Object = s.next; next; next = next.next) { 
										switch (next.type) {
											default:
												continue;
											case C.NOTE:
											case C.REST:
											case C.BAR:
												x = next.x;
												break;
										}
										break;
									}
									j = 2;
									while (true) { 
										i = text.indexOf ('\t', i + 1);
										if (i < 0) {
											break;
										}
										j++;
									}
									var expdx : Number = (x - s.x) / j;
									x = s.x;
									y *= staff_tb[s.st].staffscale;
									anno_start ("gchord", gch.istart, gch.iend, x - 2, y + h + 2, w + 4, h + 4, s);
									i = 0;
									j = i;
									while (true) { 
										i = text.indexOf('\t', j);
										if (i < 0) {
											break;
										}
										xy_str (x, y, text.slice(j, i), 'c');
										x += expdx;
										j = i + 1;
									}
									xy_str(x, y, text.slice(j), 'c');
									anno_stop ("gchord", gch.istart, gch.iend, s.x - 2, y + h + 2, w + 4, h + 4, s);
									continue
								}
								break;
							
							// Absolute
							case '@':
								y = gch.y + yav;
								if (y > 0) {
									y2 = y + h;
									if (y2 > staff_tb[s.st].ann_top) {
										staff_tb[s.st].ann_top = y2;
									}
								} else {
									if (y < staff_tb[s.st].ann_bot) {
										staff_tb[s.st].ann_bot = y;
									}
								}
								break;
						}
						
						// If this annotation is encoded with an ID, separate them and
						// tag the resulting SVG text element with the ID
						if (text.indexOf('¦') != -1) {
							nameSegments = text.split ('¦');
							annotationId = nameSegments[0] as String;
							text = nameSegments.pop() as String;
							annotationClass = (nameSegments.length == 3)? "section" : (annotationId == '-1')? "project" : "annot";
						}
						if (annotationId) {
							abcStartIndex = gch.istart;
							abcEndIndex = gch.iend;
							areaX = (x + posx);
							areaY = sy (y - 8);
							areaW = w + 4;
							areaH = h + 6;
							if (user.anno_start) {
								user.anno_start (annotationClass, abcStartIndex, abcEndIndex, areaX, areaY, areaW, areaH, annotationId);
							}
						}
						
						if (gch.box) {
							xy_str_b (x, y, text, null, NaN, annotationId, annotationClass);
						} else {
							xy_str (x, y, text, null, NaN, annotationId, annotationClass);
						}					
						if (user.anno_stop) {
							user.anno_stop ("annot", gch.istart, gch.iend, x - 2, y + h + 2, w + 4, h + 4, s, text, gch.type);
						}
					}
					
					// If this IS a helper annotation
					else {
						var noteDefinition : Object = s.notes[0];
						if (!("ids" in noteDefinition)) {
							noteDefinition.ids = [];
						}
						var noteIds : Array = noteDefinition.ids;
						var nodeId : String = text.split ('¦').join ('');
						if (noteIds.indexOf(nodeId) == -1) {
							noteIds.push (nodeId);
						}
					}
				}
			}
			
			// PostScript hooks. They do nothing, but code is intertwined with these
			private function psdeco(...args) : *  { return false }
			private function psxygl(...args) : *  { return false }
		}
}