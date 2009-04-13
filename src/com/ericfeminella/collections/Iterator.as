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
    /**
     * 
     * Defines the contract for object which are to provide an API 
     * for traversing an aggregate object.
     * 
     * <p>
     * <code>Iterator</code> provides a set of standard operations 
     * which allow client implementations to manage the traversal
     * of an aggregate object. <code>Iterator</code> implementations
     * are not to modify an aggregate, but rather they are to simply
     * provide an interface into the aggregate.
     * </p>
     * 
     */
    public interface Iterator
    {
        /**
         *
         * Determines if there are elements remaining in the 
         * aggregate.
         *
         * @return true if an element remains, false if not
         *
         */
       function hasNext() : Boolean;

        /**
         *
         * Retrieves the next element in the aggregate.
         *
         * @return next element based on the current index
         *
         */
       function next() : *;

       /**
        *
        * Resets the cursor / index of the Iterator to 0.
        *
        */
       function reset() : void;

       /**
        *
        * Determines the position of the current element in 
        * the aggreagate.
        *
        * @return  the current index of the aggreagate
        *
        */
       function position() : int;
   }
}
