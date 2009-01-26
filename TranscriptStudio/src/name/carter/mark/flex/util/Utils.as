/*
   Transcript Markups Editor: An XML based application that allows users to define 
   and store contextual metadata for contiguous sections within a text document. 

   Copyright 2008 Mark Carter, Swami Kevala

   This file is part of Transcript Markups Editor.

   Transcript Markups Editor is free software: you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free Software 
   Foundation, either version 3 of the License, or (at your option) any later version.

   Transcript Markups Editor is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with 
   Transcript Markups Editor. If not, see http://www.gnu.org/licenses/.
*/

package name.carter.mark.flex.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	import mx.controls.TextArea;
	import mx.controls.Tree;
	import mx.core.Application;
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	public class Utils
	{
		[Embed(source="../assets/default.png")]
		public static const DEFAULT_ICON_CLASS:Class;
		[Embed(source="../assets/pencil.png")]
		public static const PENCIL_ICON_CLASS:Class;
		[Embed(source="../assets/search.png")]
		public static const SEARCH_ICON_CLASS:Class;
		
		private static const ASSETS_PATH:String = "./assets";
		private static const ICON_EXT:String = ".png";
		public static const DEFAULT_ICON_PATH:String = ASSETS_PATH + "/default" + ICON_EXT;

		public static const DIVIDER_SIZE:int = 5;
		
		//[Embed("./TranscriptMarkupsEditor-app.xml", mimeType="application/octet-stream")]
		//private static const descriptorXMLClass:Class;
		//[Embed("./TranscriptMarkupsEditorDemo-app.xml", mimeType="application/octet-stream")]
		//private static const demoDescriptorXMLClass:Class;
		private static var descriptorXML:XML = null;

		private static function isDemo():Boolean {
			return Application.application.className.indexOf("Demo") >= 0;
		}
		
		/*private static function getDescriptorXML():XML {
			if (descriptorXML == null) {
				var cls:Class = isDemo() ? demoDescriptorXMLClass : descriptorXMLClass;
				descriptorXML = getXML(cls);
			}
			return descriptorXML;
		}*/
		
		public static function getApplicationVersion():String {
			/*var ns:Namespace = getDescriptorXML().namespace();
			return getDescriptorXML()..ns::version[0].toString();*/
			return "1.0.0";
		}
		
		public static function getApplicationName():String {
			/*var ns:Namespace = getDescriptorXML().namespace();
			return getDescriptorXML()..ns::name[0].toString();*/
			return "Transcript Studio";
		}
		
		public static function getClassName(obj:Object):String {
			var describeXML:XML = describeType(obj);
			var qName:String = describeXML.@name;
			if (qName == null) {
				return null;
			}
			var index:int = qName.lastIndexOf(".");
			if (index < 0) {
				return qName;
			}
			else {
				return qName.substring(index + 1);
			}
		}

		public static function expandToItem(item:XML, tree:Tree, showChildren:Boolean = false):void {
			if (item == null) {
				throw new Error("Passed a null item");
			}
			var tempKList:Array = new Array();
			tempKList.push(item);
			while (tempKList[0].parent() != null) {
				tempKList.unshift(tempKList[0].parent() as XML);
				if (tree.isItemVisible(tempKList[0])) {
					// this item (we just added) is already visible so no need to expand parent
					break;
				}
			}
			for each (var tempK:XML in tempKList) {
				if (showChildren || tempK != item) {
					tree.expandItem(tempK, true);
				}
			}			
		}
		
		public static function getIconPath(iconName:String):String {
			return ASSETS_PATH + "/" + iconName + ICON_EXT;
		}
		
		/**
		 * Removes leading/trailing whitespace and condenses consecutive (one or more) whitespace to a single space
		 */
		public static function normalizeSpace(text:String):String {
			var result:String = StringUtil.trim(text);
			var consecutiveWhitespacePattern:RegExp = /\s+/g;
			result = result.replace(consecutiveWhitespacePattern, " ");
			return result;
		}
		
		/**
		 * For each item, removes leading/trailing whitespace and condenses consecutive (one or more) whitespace to a single space
		 * If the item is reduced to an empty string then that item is removed from the array
		 * 
		 * Does not modify the given array.
		 */
		public static function condenseWhitespaceForArray(texts:Array):Array {
			var result:Array = new Array();
			for each (var text:String in texts) {
				text = normalizeSpace(text);
				if (text != "") {
					result.push(text);
				}
			}
			return result;
		}
		
		public static function getStyleSheet(StyleSheetClass:Class):StyleSheet {
			var ba:ByteArray = new StyleSheetClass();
			var cssText:String = ba.readUTFBytes(ba.length);
			var styleSheet:StyleSheet = new StyleSheet();
			styleSheet.parseCSS(cssText);
			return styleSheet;
		}
		
		public static function getTextField(container:DisplayObjectContainer):TextField {
			return getChildByClass(container, TextField) as TextField;
		}
		
        public static function getChildByClass(container:DisplayObjectContainer, cls:Class):Object {
            var len:int = container.numChildren;
            for (var i:int=0; i < len; i++){
                var thisChild:DisplayObject = container.getChildAt(i);
                if (thisChild is cls){
                    return thisChild;
                }
            }
            return null;
        }
                
        public static function getFirstVisibleLineIndex(ta:TextArea):int {
        	var tf:TextField = getTextField(ta);
			return tf.getLineIndexAtPoint(5, 5);
        }
        
        public static function getLastVisibleLineIndex(ta:TextArea):int {
        	var tf:TextField = getTextField(ta);
			return tf.getLineIndexAtPoint(5, ta.height - 5);
        }
        
        public static function getFirstVisibleCharIndex(ta:TextArea):int {
        	var tf:TextField = getTextField(ta);
        	return tf.getLineOffset(getFirstVisibleLineIndex(ta));
        }
        
        public static function getNowDateString():String {
        	return getDateString(new Date());
        }
        
		public static function getDateString(date:Date = null):String {
			if (date == null) {
				return null;
			}
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYY-MM-DDTJJ:NN:SS";
			return df.format(date);
		}
		
		public static function copyArray(arr:Array):Array {
			return arr.slice();
		}
		
		public static function arrayEquals(arr1:Array, arr2:Array):Boolean {
			if (arr1 == arr2) {
				return true;
			}
			if (arr1 == null || arr2 == null) {
				return false;
			}
			if (arr1.length != arr2.length) {
				return false;
			}
			for (var i:int; i < arr1.length; i++) {
				if (arr1[i] != arr2[i]) {
					return false;
				}
			}
			return true;
		}
		
		public static function arrayToLowerCase(arr:Array):Array {
			var result:Array = new Array();
			for each (var s:String in arr) {
				result.push(s.toLowerCase());
			}
			return result;
		}
		
		public static function trimFromFront(arr1:Array, arr2:Array):void {
			while (arr1.length > 0 && arr2.length > 0) {
				if (arr1[0] == arr2[0]) {
					arr1.splice(0, 1);
					arr2.splice(0, 1);
				}
				else {
					break;
				}
			}
		}
		
		public static function trimFromBack(arr1:Array, arr2:Array):void {
			while (arr1.length > 0 && arr2.length > 0) {
				if (arr1[arr1.length - 1] == arr2[arr2.length - 1]) {
					arr1.splice(arr1.length - 1, 1);
					arr2.splice(arr2.length - 1, 1);
				}
				else {
					break;
				}
			}
		}
		
		public static function switchItems(arr:Array, index1:int, index2:int):void {
			var item1:Object = arr[index1];
			var item2:Object = arr[index2];
			arr[index1] = item2;
			arr[index2] = item1;			
		}

		/**
		 * Returns a comparator function by comparing strings returned by the specified toString function. 
		 * 
		 * toString(element:XML):String 
		 */
		public static function getStringCompareFunction(toString:Function):Function {
			return function compare(element1:XML, element2:XML):int {
				var str1:String = toString(element1);
				var str2:String = toString(element2);
				if (str1 < str2) {
					return -1;
				}
				else if (str1 > str2) {
					return +1;
				}
				else {
					return 0;
				}
			};
		}
		
		public static function getFunction(host:Object, funcName:String):Function {
			if (host.hasOwnProperty(funcName)) {
				return host[funcName];
			}
			else {
				return null;
			}
		}
		
		public static function encodePath(path:String):String {
			var index:int = path.lastIndexOf("/");
			var result:String = path.substring(0, index + 1) + encodeURIComponent(path.substring(index + 1));
			return result; 
		}

	}
}