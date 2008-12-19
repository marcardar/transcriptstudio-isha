package name.carter.mark.flex.util.collection
{
	import com.ericfeminella.collections.Iterator;
	
	public interface ISet
	{
		function add(obj:*):void;
		function addAll(objs:Array):void;
		function clear():void;
		function contains(obj:*):Boolean;
		function containsAll(objs:Array):Boolean;
		function equals(obj:Object):Boolean;
		// function hashCode():int;
		function isEmpty():Boolean;
		function iterator():Iterator;
		function remove(obj:*):void;
		function removeAll(objs:Array):void;
		function retainAll(objs:Array):void;
		function size():int;
		function toArray():Array;
	}
}