
/*
-- Find a value in an array that matches this given key (23421).
-- Assume the array to be sorted.
-- The algorithm must only compare values at the center of scope with the key; scope means the array locations that are being searched in one iteration.
-- the algorithm must discard of the half of the scope that definitely cannot have the key within.
-- The key may not always be in the array
scope size >= array size
scope size <= array size

key = 9
1st iteration:
-1 0 1 2 3 4 5 6 7 8 9 scope center = n/2; where n is the size; 

if scope center < key then discard the left half and traverse the right half
else traverse left half and discard right half
2nd iteration:
4 5 6 7 8

3rd iteration:
7 8

4th iteration:
8


5th iteration:


Using binary search, write an algorithm and c++ code that determine if an array A contains the key K. return the index location of the key if found or -1 if not found.

*/