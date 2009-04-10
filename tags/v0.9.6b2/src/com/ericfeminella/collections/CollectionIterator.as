/*
 Copyright (c) 2006 - 2008  Eric J. Feminella  <eric@ericfeminella.com>
 All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 @internal
 */

package com.ericfeminella.collections
{
    import mx.collections.CursorBookmark;
    import mx.collections.ICollectionView;
    import mx.collections.IViewCursor;

    /**
     *
     * Concrete <code>Iterator</code> implementation which provides an API
     * for iterating over an <code>ICollectionView</code>.
     *
     * @example The following is a basic <code>CollectionIterator</code> 
     * example:
     * 
     * <listing version="3.0">
     *
     * var collection:ICollectionView = new ArrayCollection(["a","b","c"]);
     * var it:Iterator = new CollectionIterator( collection );
     *
     * while ( it.hasNext() )
     * {
     *     trace( it.next(), it.position() );
     * }
     *
     * // a, 0
     * // b, 1
     * // c, 2
     *
     * </listing>
     *
     * @see com.ericfeminella.collections.Iterator
     * @see mx.collections.ICollectionView
     * @see mx.collections.CursorBookmark
     * @see mx.collections.IViewCursor
     *
     */
    public class CollectionIterator implements Iterator
    {
        /**
         *
         * Defines the <code>ICollectionView</code> instance
         *
         * @see mx.collections.ICollectionView
         *
         */
        protected var collection:ICollectionView;

        /**
         *
         * Defines the <code>IViewCursor</code> instance to the aggregate
         *
         * @see mx.collections.IViewCursor
         *
         */
        protected var cursor:IViewCursor;

        /**
         *
         * Contains the current indexed position in the collection
         *
         */
        protected var index:int;

        /**
         *
         * Instantiates a new <code>CollectionIterator</code> instance
         *
         * @param the collection in which to iterate over
         *
         */
        public function CollectionIterator(collection:ICollectionView)
        {
            setCollection( collection );
        }

        /**
         *
         * Sets the collection in which to iterate over
         *
         * @param an ICollectionView instance
         *
         */
        public function setCollection(collection:ICollectionView) : void
        {
            this.collection = collection;
            cursor = collection.createCursor();
        }

        /**
         *
         * Determines if there are elements remaining in the ICollectionView
         *
         * @return  true if an element remains, false if not
         *
         */
        public function hasNext() : Boolean
        {
            var result:Boolean = true;

            if ( cursor.beforeFirst || cursor.afterLast )
            {
                result=  false;
            }

            return result;
        }

        /**
         *
         * Returns the next item in the ICollectionView
         *
         * @retrun an arbitrary object in the collection
         *
         */
        public function next() : *
        {
            var current:Object = cursor.current;

            index = cursor.bookmark.getViewIndex();
            cursor.moveNext();

            return current;
        }

        /**
         *
         * Resets the IViewCursor to a zero based indexed position
         *
         * @see mx.collections.CursorBookmark#FIRST
         *
         */
        public function reset() : void
        {
            cursor.seek( CursorBookmark.FIRST );
        }

        /**
         *
         * Determines the IViewCursor position of the ICollectionView
         *
         * @return  the current position of the aggreagate
         *
         */
        public function position() : int
        {
            return index;
        }
    }
}
