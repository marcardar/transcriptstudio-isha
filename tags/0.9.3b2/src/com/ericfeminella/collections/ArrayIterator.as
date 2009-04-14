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
    import flash.errors.IllegalOperationError;

    /**
     *
     * Concrete Iterator implementation which provides an API for 
     * iterating over an <code>Array</code>.
     *
     * @example A basic example is as follows:
     *
     * <listing version="3.0" >
     * 
     * var array:Array = new Array( "A", "B", "C" );
     * var it:Iterator = new ArrayIterator( array );
     *
     * while ( it.hasNext() )
     * {
     *     trace( it.next(), it.position());
     * }
     *
     * //outputs:
     * //A, 0
     * //B, 1
     * //C, 2
     *
     * </listing>
     *
     * @see com.ericfeminella.collections.Iterator
     *
     */
    public class ArrayIterator implements Iterator
    {
        /**
         *
         * <code>Array</code> in which the <code>ArrayIterator</code>
         * is to traverse.
         *
         */
        private var items:Array;

        /**
         *
         * Defines the index in which the <code>ArrayIterator</code>
         * is to traverse.
         *
         */
        private var index:int = 0;

        /**
         *
         * Instantiates a new <code>ArrayIterator</code> instance
         *
         * @param the Array in which to iterate over
         *
         */
        public function ArrayIterator(array:Array = null)
        {
            items = array;
        }

        /**
         *
         * Determines if elements remain in the <code>Array</code>.
         *
         * @inheritDoc
         *
         */
        public function hasNext() : Boolean
        {
            return index < items.length;
        }

        /**
         *
         * Returns the next item element in the <code>Array</code>.
         *
         * @return next array element based on the current index
         *
         */
        public function next() : *
        {
            return items[index++];
        }

        /**
         *
         * Resets the index of the <code>ArrayIterator</code>
         * instance to 0.
         *
         */
        public function reset() : void
        {
            index = 0;
        }

        /**
         *
         * Determines the indexed position of the <code>Array</code>.
         *
         */
        public function position() : int
        {
            return index;
        }
    }
}
