'
' Header for PCAH
'

#ifndef __PCAH_BI__
#define __PCAH_BI__

Type pcah_keyArrayElems
	key As ZString * 128
	IndexType As Integer
	Size As Integer
	Value As Any Ptr
End Type

Type pcah_keyArray
	Elems As Integer
	Array As pcah_keyArrayElems Ptr
End Type

Type pcah_return
	IndexType As Integer
	Size As Integer
	Value As Any Ptr
End Type

#define INDEXTYPE_CHAR		1
#define INDEXTYPE_SHORT		2
#define INDEXTYPE_INT		3
#define INDEXTYPE_FLOAT		4
#define INDEXTYPE_LONG_LONG	5
#define INDEXTYPE_DOUBLE	6
#define INDEXTYPE_LONG_DOUBLE	7
#define INDEXTYPE_STRING	8
#define INDEXTYPE_USER		9
#define INDEXTYPE_FUNCTION	10
#define INDEXTYPE_PTR		256

Declare Function pcah_init cdecl Alias "pcah_init" () As Integer
Declare Function pcah_createArray cdecl Alias "pcah_createArray" () As Any Ptr
Declare Function pcah_addElem cdecl Alias "pcah_addElem" (ByVal array As pcah_keyArray Ptr, _ 
				ByVal key As ZString Ptr, _
				ByVal itype As Integer, ByVal T As Any Ptr, _
				ByVal size As Integer) As Integer
Declare Function pcah_updateElem cdecl Alias "pcah_updateElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr, _
				ByVal itype As Integer, ByVal T As Any Ptr, _
				ByVal size As Integer) As Integer
Declare Function pcah_arrayLength cdecl Alias "pcah_arrayLength" _
				(ByVal array As pcah_keyArray Ptr) As Integer
Declare Function pcah_getIndexNum cdecl Alias "pcah_getIndexNum" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr) _
				As Integer
Declare Function pcah_getKeyFromIndex cdecl Alias "pcah_getKeyFromIndex" _
				(ByVal array As pcah_keyArray Ptr, ByVal index As Integer) _
				As ZString Ptr
Declare Function pcah_delElemByIndex cdecl Alias "pcah_delElemByIndex" _
				(ByVal array As pcah_keyArray Ptr, ByVal index As Integer) _
				As Integer
Declare Function pcah_delElem cdecl Alias "pcah_delElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr) _
				As Integer
Declare Function pcah_destroyArray cdecl Alias "pcah_destroyArray" _
				(ByVal array As pcah_keyArray Ptr) As Integer
Declare Function pcah_getElem cdecl Alias "pcah_getElem" _
				(ByVal array As pcah_keyArray Ptr, _
				 ByVal key As ZString Ptr) As pcah_return Ptr
Declare Sub pcah_cleanupReturn cdecl Alias "pcah_cleanupReturn" _
				(ByVal ret As pcah_return Ptr)
Declare Function pcah_addIntElem cdecl Alias "pcah_addIntElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr, _
				 ByVal value As Integer) _
				As Integer
Declare Function pcah_updateIntElem cdecl Alias "pcah_updateIntElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr, _
				 ByVal value As Integer) _
				As Integer
Declare Function pcah_getIntElem cdecl Alias "pcah_getIntElem" _
				(ByVal array As pcah_keyArray Ptr, ByVal key As ZString Ptr) _
				As Integer
#endif
