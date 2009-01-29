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
	import flash.utils.ByteArray;
	
	import mx.core.ByteArrayAsset;
	import mx.utils.StringUtil;
	
	import name.carter.mark.flex.util.collection.HashSet;
	import name.carter.mark.flex.util.collection.ISet;
	
	public class XMLUtils
	{
		public static function getXML(xmlClass:Class):XML {
			var ba:ByteArrayAsset = ByteArrayAsset(new xmlClass());
			var xml:XML = new XML(ba.readUTFBytes(ba.length));
			return xml;
		}      
		
		public static function getTopLevelElement(element:XML):XML {
			var parentElement:XML = element.parent();
			if (parentElement == null) {
				return element;
			}
			else {
				return getTopLevelElement(parentElement);
			}
		}
		
		public static function embedXML(embedClass:Class):XML {
			var ba:ByteArray = new embedClass();
			return new XML(ba.readUTFBytes(ba.length));			
		}

		/**
		 * compare(element1:XML, element2:XML):int
		 * 
		 * Compares its two arguments for order. Returns a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second. 
		 */
		public static function insertElementInOrder(newElement:XML, parentElement:XML, compare:Function):void {
			for each (var existingElement:XML in parentElement.*) {
				if (compare(newElement, existingElement) < 0) {
					// must come before this existing element
					insertSiblingBefore(existingElement, newElement);
					return;
				}
			}
			parentElement.appendChild(newElement);
		}
		
		public static function removeElement(element:XML, shiftUpChildren:Boolean = false):void {
			if (shiftUpChildren) {
				replaceElement(element, element.*);
			}
			else {
				var parent:XML = element.parent();
				if (parent == null) {
					return;
				}
				delete parent.*[element.childIndex()];
			}
		}

		public static function removeAllElements(elements:XMLList, shiftUpChildren:Boolean = false):void {
			for each (var element:XML in elements) {
				removeElement(element, shiftUpChildren);
			}
		}
		
		/**
		 * If the value is null (or equal to the default) then the attribute is removed
		 */
		public static function setAttributeValue(element:XML, attrName:String, attrValue:Object, defaultValue:Object = null):void {
			if (attrValue is String) {
				attrValue = StringUtil.trim(attrValue as String);
			}
			if (attrValue == null || attrValue.toString() == "" || attrValue == defaultValue) {
				delete element.@[attrName];
			}
			else {
				element.@[attrName] = attrValue.toString();
			}
		}
		
		public static function getAttributeValue(element:XML, attrName:String, defaultValue:String = null):String {
			if (!element.hasOwnProperty("@" + attrName)) {
				return defaultValue;
			}
			return element.@[attrName];
		}
		
		public static function getAttributeValueAsBoolean(element:XML, attrName:String, defaultValue:Boolean):Boolean {
			return getAttributeValue(element, attrName, defaultValue.toString()) == "true";
		}
		
		public static function getAttributeAsDate(element:XML, attrName:String):Date {
			var dateStr:String = getAttributeValue(element, attrName);
			var result:Date = DateUtils.parseStandardDateString(dateStr);
			return result;
		}
		
		public static function setAttributeAsDate(element:XML, attrName:String, date:Date, includeTime:Boolean = true):void {
			var dateStr:String = Utils.getDateString(date);
			if (!includeTime && dateStr != null) {
				var index:int = dateStr.indexOf("T");
				dateStr = dateStr.substring(0, index);
			}
			setAttributeValue(element, attrName, dateStr);
		}
		
		public static function removeAllTextNodes(element:XML, deep:Boolean = false):void {
			if (element.localName() == "tag") {
				// TODO: this is a hack until we refactor tags
				return;
			}
			//removeAllElements(element..*.(nodeKind() == "text"));
			for each (var child:XML in element.*) {
				if (child.nodeKind() == "text") {
					removeElement(child);
				}
				else {
					if (deep) {
						removeAllTextNodes(child, deep);
					}
				}
			}
		}
		
		public static function getTextNodes(element:XML, deep:Boolean):XMLList {
			var result:XMLList = new XMLList;
			var descendants:XMLList = deep ? element..* : element.*;
			for each (var descendant:XML in descendants) {
				if (descendant.nodeKind() == "text") {
					if (descendant.parent().localName() == "tag") {
						// TODO: this is a hack until we refactor tags
						continue;
					}
					result += descendant;
				}
			}
			return result;
		}
		
		public static function getLastTextNode(element:XML, deep:Boolean):XML {
			var textNodes:XMLList = getTextNodes(element, deep);
			return textNodes[textNodes.length() - 1];
		}
		
		public static function replaceElement(oldElement:XML, newElements:XMLList):void {
			var parent:XML = oldElement.parent();
			for each (var newElement:XML in newElements) {
				removeElement(newElement); // make sure it doesnt have a parent
				insertSiblingBefore(oldElement, newElement);
			}
			removeElement(oldElement);
		}
		
		/**
		 * Only returns elements (so not text nodes) with the specified tagName.
		 * 
		 * If the tagName is null then all elements are returned.
		 */
		public static function getChildElements(parentElement:XML, tagName:String = null):XMLList {
			var result:XMLList = new XMLList();
			for each (var child:XML in parentElement.*) {
				if (child.nodeKind() != "element") {
					continue;
				}
				if (tagName == null || child.localName() == tagName) {
					result += child;
				}
			}
			return result;
		}

		public static function getPrecedingSibling(element:XML):XML {
			if (element.parent() == null) {
				return null;
			}
			var index:int = element.childIndex();
			if (index == 0) {
				return null;
			}
			else {
				var result:XML = element.parent().*[index - 1];
				return result;
			}
		}

		public static function getFollowingSibling(element:XML):XML {
			if (element.parent() == null) {
				return null;
			}
			var index:int = element.childIndex();
			var siblings:XMLList = element.parent().*;
			if (index >= siblings.length() - 1) {
				return null;
			}
			else {
				var result:XML = siblings[index + 1];
				return result;
			}
		}
		
		/**
		 * Returns [firstSibling,...., lastSibling]
		 */
		public static function getSiblingsBetweenAndSelves(firstSibling:XML, lastSibling:XML):XMLList {
			var result:XMLList = new XMLList();
			var currentSibling:XML = firstSibling;
			while (currentSibling != null) {
				result += currentSibling;
				if (currentSibling == lastSibling) {
					// we've just added the lastSibling
					break;
				}
				currentSibling = getFollowingSibling(currentSibling);
			}			
			return result;
		}
		
		public static function getAncestorOrSelfElement(element:XML, tagName:String):XML {
			if (element == null) {
				return null;
			}
			else if (element.localName() == tagName) {
				return element;
			}
			else {
				return getAncestorOrSelfElement(element.parent(), tagName);
			}
		}

		/**
		 * Convenience method
		 */
		public static function getCommonAncestor(element1:XML, element2:XML):XML {
			var siblingAncestors:XMLList = getCorrespondingAncestorSiblings(element1, element2);
			return (siblingAncestors[0] as XML).parent() as XML;
		}
		
		/**
		 * Returns siblings where the first element is an ancestor (or self) of element1
		 * and the last element is an ancestor (or self) of element2.
		 * 
		 * The siblings' parent is the common ancestor of element1 and element2.
		 *
		 * If element1 or element2 is null then an Error is thrown.
		 * If element1 == element2 then element1 is returned (i.e. single element list)
		 * If element1 and element2 have the same parent then the siblings from element1 to element2 (inclusive) are returned
		 * If element1 is an ancestor of element2 then element1 is returned.
		 * If element2 is an ancestor of element1 then element2 is returned.
		 * If element1 and element2 have no common ancestor (i.e. different XML documents) then null is returned.
		 * 
		 * If the two elements are the same or have no common ancestor, then null is returned.
		 */
		public static function getCorrespondingAncestorSiblings(element1:XML, element2:XML):XMLList {
			if (element1 == null) {
				throw new ArgumentError("Passed a null element1");
			}
			if (element2 == null) {
				throw new ArgumentError("Passed a null element2");
			}
			if (element1 == element2) {
				var result:XMLList = new XMLList();
				result += element1;
				return result;
			}
			// expand selection at front to include appropriate complete outlines
			var ancestors1:XMLList = getAncestorsIncludingSelf(element1);
			var ancestors2:XMLList = getAncestorsIncludingSelf(element2);
			if (ancestors1[0] != ancestors2[0]) {
				// no common ancestor
				return null;
			}
			// find out where they deviate
			for (var i:int = 0; i < Math.min(ancestors1.length(), ancestors2.length()); i++) {
				if (ancestors1[i] != ancestors2[i]) {
					return getSiblingsBetweenAndSelves(ancestors1[i], ancestors2[i]);
				}
			}
			throw new Error("This code should not be reachable");			
		}
		
		// starts with markups element and finishes with self (element)
		public static function getAncestorsIncludingSelf(element:XML):XMLList {
			if (element == null) {
				throw new Error("Passed a null element");
			}
			var result:XMLList = new XMLList();
			result += element;
			do {
				element = element.parent();
				result = element + result;
			} while (element.parent() != null)
			return result;
		}
		
		public static function prependChildren(parent:XML, children:XMLList):void {
			for (var i:int = children.length() - 1; i >= 0; i--) {
				parent.prependChild(children[i]);
			}
		}
		
		/**
		 * Inserts the specified parentElement in between the childElements and the childElements existing parent
		 */
		public static function insertParentElement(newParent:XML, children:XMLList):void {
			var oldParent:XML = (children[0] as XML).parent();
			insertSiblingBefore(children[0], newParent);
			for each (var child:XML in children) {
				// we've already found first child (either just now or earlier)
				removeElement(child); // TODO - does the next line do this for us????
				newParent.appendChild(child);
			}								
		}
		
		public static function insertSiblingBefore(existingElement:XML, elementToInsert:XML):void {
			var parent:XML = existingElement.parent();
			var res:* = parent.insertChildBefore(existingElement, elementToInsert);
			if (res == undefined) {
				throw new Error("Could not insert child: " + elementToInsert.toXMLString() + " before: " + existingElement.toXMLString());
			}
		} 
		
		public static function insertSiblingsBefore(existingElement:XML, siblings:XMLList):void {
			for each (var sibling:XML in siblings) {
				insertSiblingBefore(existingElement, sibling);
			}
		}
		
		public static function insertTextSiblingBefore(existingElement:XML, text:String):void {
			var parent:XML = existingElement.parent();
			var res:* = parent.insertChildBefore(existingElement, text);
			if (res == undefined) {
				throw new Error("Could not insert child: '" + text + "' before: " + existingElement.toXMLString());
			}
		}
		
		public static function insertSiblingAfter(existingElement:XML, elementToInsert:XML):void {
			var parent:XML = existingElement.parent();
			var res:* = parent.insertChildAfter(existingElement, elementToInsert);
			if (res == undefined) {
				throw new Error("Could not insert child: " + elementToInsert.toXMLString() + " after: " + existingElement.toXMLString());
			}
		} 
		
		public static function insertSiblingsAfter(existingElement:XML, siblings:XMLList):void {
			var current:XML = existingElement;
			for each (var sibling:XML in siblings) {
				insertSiblingAfter(current, sibling);
				current = sibling;
			}
		}
		
		public static function insertTextSiblingAfter(existingNode:XML, text:String):void {
			var parent:XML = existingNode.parent();
			parent.insertChildAfter(existingNode, text);				
		}
		
		/**
		 * Removes all existing children of the element and then puts a new text node as the only child.
		 */
		public static function setElementText(element:XML, text:String):void {
			removeAllElements(element.*);
			element.appendChild(text);
		}
		
		/**
		 * Recurses into all descendant elements (excluding self).
		 */
		public static function convertToStringISet(elements:XMLList):ISet {
			var result:ISet = new HashSet();
			for each (var element:XML in elements) {
				result.add(element.toString());
			}
			return result;
		}		
	}
}