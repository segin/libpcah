/* 
 * PCAH - Perl-copied Array Keying
 * Copyright © 2008 Segin Takushiro
 *
 * Header for libpcah
 *
 */

#ifndef __PCAH_H__
#define __PCAH_H__

struct pcah_keyArrayElems {
	char key[128];
	int IndexType;
	int Size;
	void *Value;
}

struct pcah_return {
	int IndexType;
	int Size;
	void *Value;
}

struct pcah_keyArray {
	int Elems;
	struct pcah_keyArrayElems Array[];
}

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

extern int pcah_init();
extern struct pcah_keyArray *pcah_createArray();
extern int pcah_addElem(struct pcah_keyArray *array,
	       		char *key, int itype, void *T, int size);
extern int pcah_updateElem(struct pcah_keyArray *array, 
				char *key, int itype, void *T, int size);

extern int pcah_arrayLength(struct pcah_keyArray *array);
extern int pcah_getIndexNum(struct pcah_keyArray *array, char *key);
extern char *pcah_getKeyFromIndex(struct pcah_keyArray *array, int index);
extern int pcah_delElem(struct pcah_keyArray *array, char *key);
extern int pcah_delElemByIndex(struct pcah_keyArray *array, int index);
extern int pcah_destroyArray(struct pcah_keyArray *array);
extern struct pcah_return *pcah_getElem(struct pcah_keyArray *array, char *key);
extern void pcah_cleanupReturn(struct pcah_return *ret);

#endif /* __PCAH_H__ */

// vim: ai si sw=4 ts=4 encoding=utf8
