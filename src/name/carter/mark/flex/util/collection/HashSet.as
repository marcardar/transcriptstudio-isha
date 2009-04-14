package name.carter.mark.flex.util.collection
{
	import com.ericfeminella.collections.ArrayIterator;
	import com.ericfeminella.collections.HashMap;
	import com.ericfeminella.collections.IMap;
	import com.ericfeminella.collections.Iterator;

	public class HashSet implements ISet
	{
		private var wrappedMap:IMap;
		
		public function HashSet(useWeakReferences:Boolean = true)
		{
			this.wrappedMap = new HashMap(useWeakReferences);
		}

		public function add(obj:*):void
		{
			this.wrappedMap.put(obj, null);
		}
		
		public function addAll(objs:Array):void
		{
			for each (var obj:* in objs) {
				add(obj);
			}
		}
		
		public function clear():void
		{
			this.wrappedMap.clear();
		}
		
		public function contains(obj:*):Boolean
		{
			return this.wrappedMap.containsKey(obj);
		}
		
		public function containsAll(objs:Array):Boolean
		{
			for each (var obj:* in objs) {
				if (!this.wrappedMap.containsKey(obj)) {
					return false;
				}
			}
			return true;
		}
		
		public function equals(obj:Object):Boolean
		{
			if (obj == this) {
				return true;
			}
			if (!(obj is ISet)) {
				return false;
			}
			var guest:ISet = obj as ISet;
			if (size() != guest.size()) {
				return false;
			}
			return containsAll(guest.toArray());
		}
		
		public function isEmpty():Boolean
		{
			return this.wrappedMap.isEmpty();
		}
		
		public function iterator():Iterator
		{
			return new ArrayIterator(toArray());
		}
		
		public function remove(obj:*):void
		{
			return this.wrappedMap.remove(obj);
		}
		
		public function removeAll(objs:Array):void
		{
			for each (var obj:* in objs) {
				remove(obj);
			}
		}
		
		public function retainAll(objs:Array):void {
			var guestSet:ISet = new HashSet();
			guestSet.addAll(objs);
			for each (var obj:* in this.wrappedMap.getKeys()) {
				if (!guestSet.contains(obj)) {
					remove(obj);
				}
			}
		}

		public function size():int
		{
			return this.wrappedMap.size();
		}
		
		public function toArray():Array
		{
			return this.wrappedMap.getKeys();
		}
		
		public function toString():String {
			return this.toArray().toString();
		}
	}
}