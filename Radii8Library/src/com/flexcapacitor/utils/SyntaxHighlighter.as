
package com.flexcapacitor.utils {
	import flash.events.TimerEvent;
	import flash.text.StyleSheet;
	import flash.utils.Timer;
	
	import mx.controls.TextArea;
	import mx.controls.textClasses.TextRange;
	
	import net.anirudh.as3syntaxhighlight.CodePrettyPrint;
	import net.anirudh.as3syntaxhighlight.PseudoThread;
	
	/**
	 * Adds syntax highlighting to the text area
	 * */
	public class SyntaxHighlighter {
		
		/**
		 * spl = "var" or "function" token
		 * str = string - ("something")
		 * kwd = keyword
		 * com = comment
		 * typ = type
		 * lit = literal
		 * pun = punctuation - <,=
		 * pln = plain
		 * tag = tag - <(tag)
		 * atn = attribute name
		 * atv = attribute value - name="(value)"
		 * src = source
		 * dec = declaration
		 * 
		 * 
		 * */
		public static var CRIMSON_EDITOR_CSS:String = "" +
			".spl {color: #4f94cd;} " +
			".str {color: #800080;} " +
			".kwd {color: #000088;} " +
			".com {color: #008800;} " +
			".typ {color: #0068CF;} " +
			".lit {color: #006666;} " +
			".pun {color: #1C02FF;} " +
			".tag {color: #1C02FF;} " +
			".pln {color: #222222;} " +
			".atn {color: #660066;} " +
			".atv {color: #880000;} " +
			".dec {color: #660066;}";
		
		public function SyntaxHighlighter(textarea:TextArea = null) {
			this.textarea = textarea;
		}
		
		//public var cssString:String =".spl {font-family:sandboxcode;color: #4f94cd;} .str { font-family:sandboxcode; color: #880000; } .kwd { font-family:sandboxcode; color: #000088; } .com { font-family:sandboxcode; color: #008800; } .typ { font-family:sandboxcode; color: #0068CF; } .lit { font-family:sandboxcode; color: #006666; } .pun { font-family:sandboxcode; color: #666600; } .pln { font-family:sandboxcode; color: #222222; } .tag { font-family:sandboxcode; color: #000088; } .atn { font-family:sandboxcode; color: #660066; } .atv { font-family:sandboxcode; color: #880000; } .dec { font-family:sandboxcode; color: #660066; } ";
		public var cssString:String = ".spl {color: #4f94cd;} .str {color: #880000; } .kwd {color: #000088;} .com {color: #008800;} .typ {color: #0068CF;} .lit {color: #006666;} .pun {color: #666600;} .pln {color: #222222;} .tag {color: #000088; } .atn {color: #660066;} .atv {color: #880000; } .dec {color: #660066; } ";
		private var codeStyle:StyleSheet;
		private var codePrettyPrint:CodePrettyPrint;
		private var codeTimer:Timer;
		private var asyncStop:Boolean;
		private var asyncRunning:Boolean;
		private var codeStylePF:StyleSheet;
		private var srclenPF:int;
		private var arrPF:Array;
		private var lenPF:int;
		private var firstNodePF:Boolean;
		private var firstIndexPF:int;
		private var pfasyncrunning:Boolean;
		private var pfasyncstop:Boolean;
		private var desclenPF:int;
		private var colorThread:PseudoThread;
		
		public var debug:Boolean;
		
		/**
		 * Interval in milliseconds to wait before
		 * */
		public var timerInterval:int = 200;
		
		/**
		 * TextArea 
		 * */
		[Bindable]
		public var textarea:TextArea; 
		
		[Bindable]
		private var asyncCodeState:String;
		
		/**
		 * Highlights the code in the text area
		 * */
		public function highlightCode():void {
		    if (!codeTimer) {
		        codeTimer = new Timer(timerInterval, 1);
		        codeTimer.addEventListener(TimerEvent.TIMER, doPrettyPrint);
		    }
		    
		    if (codeTimer.running) {
		        codeTimer.stop();
		    }
			
		    codeTimer.reset();
		    // wait for some time to see if we need to highlight or not
		    codeTimer.start();
		}
		
		/**
		 * 
		 * */
		private function doPrettyPrint(event:TimerEvent=null):void {
		    if (!codeStyle) {
		        codeStyle = new StyleSheet();
		        codePrettyPrint = new CodePrettyPrint();
		        codeStyle.parseCSS(cssString);
		    }
		    
		    if (codePrettyPrint.asyncRunning) {
		        codePrettyPrint.prettyPrintStopAsyc = true;
		        textarea.callLater(doPrettyPrint);
		        return;
		    }
		    
		    if (pfasyncrunning) {
		        pfasyncstop = true;
		        textarea.callLater(doPrettyPrint);
		        return;
		    }
			
		    codeHighlightInPlace();
		    
		}
		
		private function pfinit(startIndex:int, endIndex:int):void {
		    codeStylePF = codeStyle;
		    srclenPF = endIndex - startIndex;
		    arrPF = codePrettyPrint.mainDecorations;
		    lenPF = arrPF.length;
		    desclenPF = textarea.text.length;
		    firstNodePF = false;
		    firstIndexPF = 0;
		    pfasyncrunning = false;
		    pfasyncstop = false;	
		}
		
		
		private function processFormattedCodeAsync(startIndex:int, endIndex:int, completeFunction:Function, optIdx:int=0):Boolean {
			
		    if (pfasyncstop) {
		        pfasyncrunning = false;
		        pfasyncstop = false;
		        return false;
		    }
			
		    pfasyncrunning = true;
		    
			if (arrPF==null || srclenPF<1) {
		    	pfasyncrunning = false;
		        return false;
		    }
			
		    if (debug) trace("color worker " + optIdx);
		    var tr:TextRange;
		    var thecolor:Object;
		    var i:int = optIdx;
			
		    if ( i > 0 && i % 5 == 0 ) {
		    	asyncCodeState = "Coloring (" + int((i / lenPF) * 100) + "%)...";
		    }
			
		    if ( i < lenPF ) {
				
		        /* find first node */
		        if ( arrPF[i] == 0 && firstNodePF == false ) {        
		        	firstNodePF = true;					
		            return true;
		        }
		        else if ( arrPF[i] == 0 && firstNodePF == true ) {
		            firstNodePF = false;
		            firstIndexPF = i;
		        }
				
		        if ( i - 2 > 0 ) {
		            if ( arrPF[i-2]  != arrPF[i] && arrPF[i] < textarea.text.length )
		            {
		            	tr = new TextRange(textarea, false, arrPF[i-2] + startIndex, arrPF[i] + startIndex);
		            	thecolor = codeStylePF.getStyle("." + arrPF[i-1]).color;
		            	tr.color = thecolor;
		            }
		            
		        }
		        return true;
		        
		        
		    }
			
		    if ( i > 0 ) {
		        i -= 2;
				
		        if ( arrPF[i] + startIndex < endIndex ) {
		            tr = new TextRange(textarea, false, arrPF[i] + startIndex, endIndex);
		            thecolor = codeStylePF.getStyle("." + arrPF[i+1]).color;            
		            var totalLength:int = textarea.text.length;
					
		            if ( totalLength >= endIndex ) {
		            	tr.color = thecolor;
					}
		            
		        }
		    }
			
		    if ( completeFunction != null ) {
		    	completeFunction();
			}
			
		    if (debug) trace("color worker done");
		    pfasyncrunning = false;
		    return false;			
		    
		}
		
		private function codePFComplete():void {
			asyncCodeState = "";
		}
		
		private function codeInPlaceComplete():void {	
		    asyncCodeState = "Coloring...";
			
		    if (pfasyncrunning) {
		        pfasyncstop = true;
		        textarea.callLater(codeInPlaceComplete);
		        return;
		    }
			
		    asyncRunning = false;
		    
		    pfinit(0, textarea.length);
		    colorThread = new PseudoThread(textarea.systemManager, processFormattedCodeAsync, this, [0, textarea.length, codePFComplete, 0], 3, 2);
		}
		
		private function lexInt(index:int, total:int):void {
			if ( index > 0 && index % 5 == 0 ) {
				asyncCodeState = "Lexing (" + int((index / total) * 100) + "%)...";
			}
		}
		
		private function codeHighlightInPlace():void {
		    asyncRunning = true;
		    asyncCodeState = "Lexing...";
		    codePrettyPrint.prettyPrintAsync(textarea.text, null, codeInPlaceComplete, lexInt, textarea.systemManager);
		    
		}
	}
}