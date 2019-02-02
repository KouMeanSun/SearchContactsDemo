#ifndef PASEArray_H
#define PASEArray_H

/*
 ============================================================================
 Author: gaomingyang

	注意 PASEArray使用，定义后需进行初始化PASEArrayInit，使用后需释放资源Reset
	例如:
	PASEArray text;
	PASEArrayInit( &text );
	text.Reset( &text );
 ============================================================================
*/


#include <stdio.h>
#include <stdlib.h>

#import <Foundation/Foundation.h>
//最大空间为   MALLOC_SIZE*INDEX_NUM_MAX = 12800

#define MALLOC_NUM  8   //2进制  个数为1<<MALLOC_NUM
#define MALLOC_SIZE 256 // = 1<<MALLOC_NUM
#define INDEX_NUM_MAX  50



#define MallocIndexByte (INDEX_NUM_MAX*sizeof(NSInteger))
#define MallocByte (MALLOC_SIZE*sizeof(NSInteger))

typedef struct PASEArrayData
{
	NSInteger* pData;
	struct PASEArrayData* next;
}PASEArrayData;

typedef struct PASEArray
{	
	NSInteger size;
	NSInteger mallocsize;       //数据域个数

	NSInteger** pIndexData;	  //索引空间首地址
	NSInteger pIndexNum;        //索引空间个数

	NSInteger* pDataEnd;

	void (*Append)(struct PASEArray* A,NSInteger value);
	void (*Insert)(struct PASEArray* A,NSInteger value,NSInteger pos);
	void (*Remove)(struct PASEArray* A,NSInteger index);
	void (*Reset)(struct PASEArray* A);
	NSInteger (*GetValue)(struct PASEArray* A,NSInteger index);

}PASEArray;

void PASEArrayInit(struct PASEArray* A);
void PASEArrayAppend(PASEArray* A,NSInteger value);
void PASEArrayInsert(PASEArray* A,NSInteger value,NSInteger pos);
void PASEArrayRemove(PASEArray* A,NSInteger index);
void PASEArrayReset(PASEArray* A);
NSInteger PASEArrayReSize(PASEArray* A);
NSInteger PASEArrayGetValue(PASEArray* A,NSInteger index);


typedef struct PASEArrayC
{	
	NSInteger  size;
	NSInteger  pDataSize;       //数据域个数
	NSInteger *pData;         //空间首地址
	
	NSInteger* pDataEnd;

	void (*Append)(struct PASEArrayC* A,NSInteger value);
	void (*Reset)(struct PASEArrayC* A);
	void (*SetSize)(struct PASEArrayC* A,NSInteger size);
	NSInteger (*GetValue)(struct PASEArrayC* A,NSInteger index);

}PASEArrayC;


void PASEArrayCInit(struct PASEArrayC* A);
void PASEArrayCAppend(PASEArrayC* A,NSInteger value);
void PASEArrayCReset(PASEArrayC* A);
NSInteger  PASEArrayCGetValue(PASEArrayC* A,NSInteger index);
void PASEArrayCSetSize(struct PASEArrayC* A,NSInteger size);

#endif
