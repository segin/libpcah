#include "pcah.bi"
#include "crt.bi"

Dim As pcah_keyArray Ptr ap
Dim i As Integer = 42
ap = pcah_createArray
pcah_addElem(ap, "fred", INDEXTYPE_PTR, 0, 0)
pcah_addElem(ap, "barney", INDEXTYPE_PTR, 0, 0)
pcah_addElem(ap, "VAW", INDEXTYPE_INT, @i, sizeof(Integer))
printf !"Element \"fred\" is index %d\n", pcah_getIndexNum(ap, "fred")
printf !"Element \"barney\" is index %d\n", pcah_getIndexNum(ap, "barney")
print !"Element \"VAW\" is index " & pcah_getIndexNum(ap, "VAW")
printf !"Asking for the index for key \"spam\" returns %d because it doesn't exist.\n", _
	pcah_getIndexNum(ap, "spam")
printf !"Deleting \"fred\"...\n"
pcah_delElem(ap, "fred")
printf !"Element \"barney\" is now index %d\n", pcah_getIndexNum(ap, "barney")
printf !"Element \"VAW\" is now index %d\n", pcah_getIndexNum(ap, "VAW")
print !"Adding key \"spam\""
pcah_addIntElem(ap, "spam", 420)
print !"Element \"spam\" is element " & pcah_getIndexNum(ap, "spam") & _
	" and holds a integer with value " & pcah_getIntElem(ap, "spam")
print !"Deleting \"VAW\"..."
pcah_delElem(ap, "VAW")
print !"Element \"barney\" is still index " & pcah_getIndexNum(ap, "barney")
print !"Element \"spam\" is now index " & pcah_getIndexNum(ap, "spam")
pcah_destroyArray(ap)
