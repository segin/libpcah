'
' libpcah - Some weird string-key map.
'
' Copyright © 2008, 2010 Kirn Gill <segin2005@gmail.com>
'
' Works (or rather, should work), on the idea that array indexes are a Bad
' Thing. Instead, arrays should have an associated string for each list element.
' The idea is best explained like this: 
'
' Let's say you have a list of people who owe you money. There are three
' people, named 'Ann', 'Cameron', and 'Robert'. You then make a table of their
' indebtedness like so: (note: ASCIIArt)
' 
' +-----------+--------+ 
' |    name   |  owes  |
' +-----------+--------+
' | Cameron   |  23.72 |
' | Ann       | 120.95 |
' | Robert    |  45.34 |
' +-----------+--------+
' Ok, query took 0.02s.
'
' calling pcah_getElem with the string "Ann" would return a pointer to a float
' with the value 120.95.
'
' For now, you can only get a single-dimension variable-length key array 
' with, however, support for user-defined types, data being independently
' stored and managed by the library. Memory management for this is also
' library=managed. 
'
' One will get the idea from reading the source that I didn't totally
' abandon array indexes. This is not to be taken to mean that you should
' use indexes. Sorry, but the functions that manipulate array elements 
' by index are meant for use within the library itself (it keeps code simple)
' and are exported for the sake of testcases/torture tests/debugging, and 
' it's probably a Good Thing to export those functions for that reason.
'

#include once "crt.bi"
#include once "pcah.bi"
#if __FB_OUT_EXE__ = -1
	#error This is a library, not a standalone program
	#error Please compile with the -dll option.
#endif

Function pcah_init cdecl Alias "pcah_init" () As Integer Export
	' Any run-time initalizations needed will go here.
	' At the moment, none are needed, but still, just call this
	' function anyways and still make sure it returns 0,
	' as future versions MAY actually need to set things up 
	' before use. Doubt it, but you never know...
	Return 0
End Function


Function pcah_createArray cdecl Alias "pcah_createArray" () As Any Ptr Export
	Dim array As pcah_keyArray Ptr
	array = Allocate(sizeof(pcah_keyArray))
	array->Elems = 0
	array->Array = Allocate(0)
	Return array
End Function

Function pcah_addElem cdecl Alias "pcah_addElem" (ByVal array As pcah_keyArray Ptr, _ 
				ByVal key As ZString Ptr, _
				ByVal itype As Integer, ByVal T As Any Ptr, _
				ByVal size As Integer) As Integer Export
	Dim elems As Integer
	Dim index As Integer
	' If the key already exists, overwrite it (to prevent duplicates)
	index = pcah_getIndexNum(array, key)
	If index <> -1 Then Return pcah_updateElem(array, key, itype, T, size)
	If array->Elems = 0 Then
		array->Elems = 1
		array->Array = Allocate(sizeof(pcah_keyArrayElems))
	Else
		elems = array->Elems
		Dim As Any Ptr Temp = 0
		While Temp = 0
			Temp = Reallocate(array->Array,sizeof(pcah_keyArrayElems) * (elems + 1))
		WEnd
		array->Elems += 1
		array->Array = Temp
	End If
	memcpy(@array->Array[array->Elems-1].key,key,127)
	memset(@array->Array[array->Elems-1].key+127,0,1)
	array->Array[array->Elems-1].IndexType = itype
	array->Array[array->Elems-1].Size = size
	If (itype And INDEXTYPE_PTR) = 0 Then
		array->Array[array->Elems-1].Value = Allocate(size)
		memcpy(array->Array[array->Elems-1].Value,T,size)
	Else
		' Is a pointer being added to array, store it differently
		array->Array[array->Elems-1].Value = T
		array->Array[array->Elems-1].Size = sizeof(Any Ptr)
	End If
	Return 0
End Function

Function pcah_updateElem cdecl Alias "pcah_updateElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr, _
				ByVal itype As Integer, ByVal T As Any Ptr, _
				ByVal size As Integer) As Integer Export
	Dim i As Integer
	i = pcah_getIndexNum(array, key)
	if i = -1 Then Return i
	memcpy(@array->Array[i].key,key,127)
	memset(@array->Array[i].key+127,0,1)
	array->Array[i].IndexType = itype
	array->Array[i].Size = size
	If (itype And INDEXTYPE_PTR) = 0 Then
		If (array->Array[i].IndexType And INDEXTYPE_PTR) = 0 Then
			array->Array[i].Value = Reallocate _ 
				(array->Array[i].Value,size)
			memcpy(array->Array[i].Value,T,size)
			array->Array[i].Size = size
		Else
			array->Array[i].Value = Allocate(size)
			memcpy(array->Array[i].Value,T,size)
			array->Array[i].Size = size
		End If
	Else
		If (array->Array[i].IndexType And INDEXTYPE_PTR) = 0 Then
			Deallocate(array->Array[i].Value)
			array->Array[i].Size = sizeof(Any Ptr)
			array->Array[i].Value = T
		Else
			array->Array[i].Size = sizeof(Any Ptr)
			array->Array[i].Value = T
		End If
	End If
	Return 0
End Function

Function pcah_arrayLength cdecl Alias "pcah_arrayLength" _
				(ByVal array As pcah_keyArray Ptr) As Integer Export
	Return array->Elems
End Function

Function pcah_getIndexNum cdecl Alias "pcah_getIndexNum" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr) _
				As Integer Export
	Dim As Integer i, j, elems
	i = 0
	Do While I < Array->Elems
		If strncmp(@array->Array[i].key, key, 127) = 0 Then
			Return i
		End If
		I += 1
	Loop
	Return -1
End Function

Function pcah_getKeyFromIndex cdecl Alias "pcah_getKeyFromIndex" _
				(ByVal array As pcah_keyArray Ptr, ByVal index As Integer) _
				As ZString Ptr Export
	Dim length As Integer
	Dim As ZString Ptr key
	If index > array->Elems - 1 Then
		Return NULL
	End If
	length = Len(array->Array[index].key)
	If length > 127 Then length = 127
	key = Allocate(length)
	memcpy(key, @array->Array[index].key, length + 1)
	Return key
End Function

Function pcah_delElemByIndex cdecl Alias "pcah_delElemByIndex" _
				(ByVal array As pcah_keyArray Ptr, ByVal index As Integer) _
				As Integer Export
	Dim As Any Ptr tmp, buf
	If index > array->Elems - 1 Then Return -1
	' If the array element is supposed to store a value, 
	' the Value struct member will hold that pointer, not a
	' pointer to library-managed memory containing the data
	' (which in this case would be a pointer)
	If (array->Array[index].IndexType And INDEXTYPE_PTR) = 0 Then	
		Deallocate(array->Array[index].Value)
	End If
	' Not needed if the index is the last element, since the realloc() 
	' will just truncate the structure for it.
	If index < array->Elems - 1 Then
		memmove(@array->Array[index], @array->Array[index + 1], _
		       sizeof(pcah_keyArrayElems) * (array->Elems - 1) - index)
	End If
	While tmp = 0
		tmp = Allocate(sizeof(pcah_keyArrayElems) * array->Elems - 1)
	WEnd
	memcpy(tmp, array->Array,sizeof(pcah_keyArrayElems) * array->Elems - 1)
	Deallocate(array->Array)
	array->Array = tmp
	array->Elems -= 1
	Return 0
End Function

Function pcah_delElem cdecl Alias "pcah_delElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr) _
				As Integer Export
	Dim as Integer index
	index = pcah_getIndexNum(array, key)
	If index = -1 Then Return -1
	Return pcah_delElemByIndex(array, index)
End Function

Function pcah_destroyArray cdecl Alias "pcah_destroyArray" _
				(ByVal array As pcah_keyArray Ptr) As Integer Export
	If array->Elems > 0 Then
		Do While array->Elems > 0 
			' Possibly the slowest way to do it, but the safest.
			pcah_delElemByIndex(array, 0)
		Loop
	End If
	Deallocate(array->Array)
	Deallocate(array)
	Return 0
End Function

'
' Generic element fetching function.
' Please, PLEASE, only use it for user-defined types.
'
' NOTE: Since this is a rather unwieldy interface (but there's really no better
' way to go about it, trust me), I even provide a function to cleanup this one's 
' returned array (which is malloc()'d)
'
Function pcah_getElem cdecl Alias "pcah_getElem" _
				(ByVal array As pcah_keyArray Ptr, _
				 ByVal key As ZString Ptr) As pcah_return Ptr Export
	Dim retval As pcah_return Ptr
	Dim i As Integer
	retval = Allocate(sizeof(pcah_return))
	if retval = 0 Then return 0
	i = pcah_getIndexNum(array, key)
	if i = -1 Then
		Deallocate(retval)
		Return 0
	End If
	retval->IndexType = array->Array[i].IndexType
	retval->Size = array->Array[i].Size
	If (retval->IndexType And INDEXTYPE_PTR) = 0 Then	
		retval->Value = Allocate(retval->Size)
		if retval->Value = 0 Then
			Deallocate(retval)
			Return 0
		End If
		memcpy(retval->Value, array->Array[i].Value, retval->Size)
	Else
		retval->Value = array->Array[i].Value
	End If
	Return retval
End Function

'
' These three functions are wrappers to make your day a little easier.
'
Function pcah_addIntElem cdecl Alias "pcah_addIntElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr, _
				 ByVal value As Integer) _
				As Integer Export
	Dim i As Integer
	i = pcah_getIndexNum(array, key)
	if i <> -1 Then Return pcah_updateIntElem(array, key, value)
	return pcah_addElem(array, key, INDEXTYPE_INT, @value, sizeof(Integer))
End Function

Function pcah_updateIntElem cdecl Alias "pcah_updateIntElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr, _
				 ByVal value As Integer) _
				As Integer Export
	Dim i As Integer
	i = pcah_getIndexNum(array, key)
	if i = -1 Then Return i
	return pcah_updateElem(array, key, INDEXTYPE_INT, @value, sizeof(Integer))
End Function 

'
' There's one problem with this function; It is impossible (from return alone)
' to determine if a returned value of -1 means that the array actually held the
' value -1 at the key, or if it failed (because the key doesn't exist).
' 
' When in doubt, if the return is -1, check the key to see if it exists.
' pcah_getIndexNum is the proverbial existence checking function.
'
Function pcah_getIntElem cdecl Alias "pcah_getIntElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr) _
				As Integer Export
	Dim retval As pcah_return ptr
	Dim i as Integer
	i = pcah_getIndexNum(array, key)
	If i = -1 Then Return i
	retval = pcah_getElem(array, key) 
	if retval->IndexType <> INDEXTYPE_INT Then
		pcah_cleanupReturn(retval)
		Return -1
	End If
	Function = *CPtr(Integer Ptr, retval->Value)
	pcah_cleanupReturn(retval)
End Function

Sub pcah_cleanupReturn cdecl Alias "pcah_cleanupReturn" _
				(ByVal ret As pcah_return Ptr) Export
	if ret = 0 Then Return
	If (ret->IndexType And INDEXTYPE_PTR) = 0 Then Deallocate(ret->Value)
	Deallocate(ret)
End Sub



