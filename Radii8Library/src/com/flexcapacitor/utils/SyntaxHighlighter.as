
package com.flexcapacitor.utils {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.text.StyleSheet;
	import flash.utils.Timer;
	
	import mx.controls.TextArea;
	import mx.controls.textClasses.TextRange;
	
	import spark.components.TextArea;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import net.anirudh.as3syntaxhighlight.CodePrettyPrint;
	import net.anirudh.as3syntaxhighlight.PseudoThread;
	
	
	[Event(name="complete")]
	
	/**
	 * Adds syntax highlighting to the text area. 
	 * 
	 * This class wraps around the AS3SyntaxHighlighter
	 * and makes it easier to setup the text area. 
	 * 
	 * This class is incomplete it appears. 
	 * Some code may be from the example projects.
	 * 
	 * http://code.google.com/p/as3syntaxhighlight/
	 * */
	public class SyntaxHighlighter extends EventDispatcher {
		
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
		
		public function SyntaxHighlighter(textarea:Object = null) {
			
			if (textarea is mx.controls.TextArea) {
				this.mxTextArea = mx.controls.TextArea(textarea);
			}
			else if (textarea is spark.components.TextArea) {
				this.sparkTextArea = spark.components.TextArea(textarea);
			}
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
		
		public var dispatchEvents:Boolean = true;
		
		/**
		 * Interval in milliseconds to wait before.
		 * Not sure this is working.
		 * */
		public var timerInterval:int = 200;
		
		/**
		 * MX TextArea 
		 * */
		[Bindable]
		public var mxTextArea:mx.controls.TextArea; 
		
		/**
		 * Spark TextArea 
		 * */
		[Bindable]
		public var sparkTextArea:spark.components.TextArea; 
		
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
			//trace("start highlighting gettimer="  + getTimer());
			
			doPrettyPrint();
		}
		
		/**
		 * 
		 * */
		private function doPrettyPrint(event:TimerEvent=null):void {
			//trace("start doPrettyPrint gettimer="  + getTimer());
		    if (!codeStyle) {
		        codeStyle = new StyleSheet();
		        codePrettyPrint = new CodePrettyPrint();
		        codeStyle.parseCSS(cssString);
		    }
		    
		    if (codePrettyPrint.asyncRunning) {
		        codePrettyPrint.prettyPrintStopAsyc = true;
				if (mxTextArea) {
		        	mxTextArea.callLater(doPrettyPrint);
				}
				else if (sparkTextArea) {
		        	sparkTextArea.callLater(doPrettyPrint);
				}
		        return;
		    }
		    
		    if (pfasyncrunning) {
		        pfasyncstop = true;
				if (mxTextArea) {
		        	mxTextArea.callLater(doPrettyPrint);
				}
				else if (sparkTextArea) {
		        	sparkTextArea.callLater(doPrettyPrint);
				}
		        return;
		    }
			
			//trace("start code in place gettimer="  + getTimer());
		    codeHighlightInPlace();
		    
		}
		
		private function pfinit(startIndex:int, endIndex:int):void {
		    codeStylePF = codeStyle;
		    srclenPF = endIndex - startIndex;
		    arrPF = codePrettyPrint.mainDecorations;
		    lenPF = arrPF.length;
		    desclenPF = mxTextArea ? mxTextArea.text.length : sparkTextArea.text.length;
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
			var txtLayFmt:TextLayoutFormat;
		    var thecolor:Object;
		    var i:int = optIdx;
			
		    if ( i > 0 && i % 5 == 0 ) {
		    	asyncCodeState = "Coloring (" + int((i / lenPF) * 100) + "%)...";
		    }
			
			var textLength:int;
			
			if (mxTextArea) {
	        	textLength = mxTextArea.text.length;
			}
			else if (sparkTextArea) {
	        	textLength = sparkTextArea.text.length;
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
		            if ( arrPF[i-2]  != arrPF[i] && arrPF[i] < textLength )
		            {
						
						
						if (mxTextArea) {
			            	tr = new TextRange(mxTextArea, false, arrPF[i-2] + startIndex, arrPF[i] + startIndex);
			            	thecolor = codeStylePF.getStyle("." + arrPF[i-1]).color;
							// RangeError: Error #2006: The supplied index is out of bounds.
							// if we are not on the stage
			            	tr.color = thecolor;
						}
						else if (sparkTextArea) {
							//var txtLayFmt:TextLayoutFormat = sparkTextArea.getFormatOfRange(null, start, end);
							txtLayFmt = sparkTextArea.getFormatOfRange(null, arrPF[i-2] + startIndex, arrPF[i] + startIndex);
			            	txtLayFmt.color = codeStylePF.getStyle("." + arrPF[i-1]).color;
			            	sparkTextArea.setFormatOfRange(txtLayFmt,  arrPF[i-2] + startIndex, arrPF[i] + startIndex);
						}
		            }
		            
		        }
		        return true;
		        
		        
		    }
			
		    if ( i > 0 ) {
		        i -= 2;
				
		        if ( arrPF[i] + startIndex < endIndex ) {
					
					if (mxTextArea) {
			            tr = new TextRange(mxTextArea, false, arrPF[i] + startIndex, endIndex);
			            thecolor = codeStylePF.getStyle("." + arrPF[i+1]).color;
					}
					else if (sparkTextArea) {
						txtLayFmt = sparkTextArea.getFormatOfRange(null, arrPF[i] + startIndex, endIndex);
		            	txtLayFmt.color = codeStylePF.getStyle("." + arrPF[i-1]).color;
					}
					
		            var totalLength:int = mxTextArea ? mxTextArea.text.length : sparkTextArea.text.length;
					
		            if ( totalLength >= endIndex ) {
						if (mxTextArea) {
		            		tr.color = thecolor;
						}
						else if (sparkTextArea) {
			            	sparkTextArea.setFormatOfRange(txtLayFmt,  arrPF[i] + startIndex, endIndex);
						}
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
			
			if (dispatchEvents) {
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function codeInPlaceComplete():void {	
		    asyncCodeState = "Coloring...";
			
			if (dispatchEvents && hasEventListener(Event.OPEN)) {
				dispatchEvent(new Event(Event.OPEN));
			}
			
		    if (pfasyncrunning) {
		        pfasyncstop = true;
				
				if (mxTextArea) {
		        	mxTextArea.callLater(codeInPlaceComplete);
				}
				else if (sparkTextArea) {
		        	sparkTextArea.callLater(codeInPlaceComplete);
				}
		        return;
		    }
			
		    asyncRunning = false;
		    
			if (mxTextArea) {
			    pfinit(0, mxTextArea.text.length);
			    colorThread = new PseudoThread(mxTextArea.systemManager, processFormattedCodeAsync, this, [0, mxTextArea.text.length, codePFComplete, 0], 3, 2);
			}
			else if (sparkTextArea) {
			    pfinit(0, sparkTextArea.text.length);
			    colorThread = new PseudoThread(sparkTextArea.systemManager, processFormattedCodeAsync, this, [0, sparkTextArea.text.length, codePFComplete, 0], 3, 2);
			}
		}
		
		private function lexInt(index:int, total:int):void {
			if ( index > 0 && index % 5 == 0 ) {
				asyncCodeState = "Lexing (" + int((index / total) * 100) + "%)...";
			}
		}
		
		private function codeHighlightInPlace():void {
		    asyncRunning = true;
		    asyncCodeState = "Lexing...";
			
			if (mxTextArea) {
		    	codePrettyPrint.prettyPrintAsync(mxTextArea.text, null, codeInPlaceComplete, lexInt, mxTextArea.systemManager);
			}
			else if (sparkTextArea) {
		    	codePrettyPrint.prettyPrintAsync(sparkTextArea.text, null, codeInPlaceComplete, lexInt, sparkTextArea.systemManager);
			}
		    
			if (dispatchEvents) {
				dispatchEvent(new Event(Event.INIT));
			}
		}
	}
}