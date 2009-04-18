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
    import mx.collections.ICollectionView;
    import mx.collections.SortField;
    import mx.collections.Sort;
    
    /**
     * 
     * Utility class which provides an all static API for sorting an 
     * <code>ICollectionView</code>.
     * 
     * @see mx.collections.ICollectionView;
     * @see mx.collections.SortField
     * @see mx.collections.Sort 
     * 
     */
    public final class CollectionSortUtil
    {
        /**
         * 
         * Sorts a concrete <code>ICollectionView</code> implementation, 
         * such as <code>ArrayCollection</code>, based on a specified key.
         * 
         * @param  property in which to base the sort
         * @param  collection of items in which the sort is to be applied
         * @param  specifies if a caseInsensitive sort is to be applied
         * @param  specifies if a descending sort is to be applied
         * @param  specifies if a numeric sort is to be applied
         * 
         */
        public static function sortOn(key:String, 
                                      collection:ICollectionView, 
                                      caseInsensitive:Boolean = false, 
                                      descending:Boolean = false, 
                                      numeric:Boolean = false) : void
        {
            var sort:Sort = new Sort();
            sort.fields = [new SortField(key, caseInsensitive, descending, numeric)];
            
            collection.sort = sort;
            collection.refresh();
        }
    }
}
