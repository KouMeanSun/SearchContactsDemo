#include "PASEArray.h"

NSInteger sizeof_int = sizeof(NSInteger);

void PASEArrayInit(struct PASEArray* A)
{
	A->size = 0;
	A->mallocsize = 0;

	A->pIndexData = 0;
	A->pIndexNum = 0;

	A->pDataEnd = 0;

	A->Append = &PASEArrayAppend;
	A->Insert =	&PASEArrayInsert;
	A->Remove = &PASEArrayRemove;
	A->Reset = &PASEArrayReset;
	A->GetValue = &PASEArrayGetValue;
	return;
}

void PASEArrayAppend(PASEArray* A,NSInteger value)
{
	if( A->size < A->mallocsize || PASEArrayReSize( A ) > 0 )
	{
		*A->pDataEnd = value;
		A->size ++;

		if( A->size < A->mallocsize )
			A->pDataEnd ++;
	}

	return;
}
void PASEArrayInsert(PASEArray* A,NSInteger value,NSInteger pos)
{
	NSInteger size = A->size;
	NSInteger i = 0;
	NSInteger* ptr = 0;
	NSInteger* ptr0 = 0;
	NSInteger** ptr_index = 0;

	if(pos >= 0 && pos <= size)
	{
		if( size < A->mallocsize || PASEArrayReSize(A) )	
		{
			ptr = A->pDataEnd;
			i = size;
			ptr_index = A->pIndexData + (A->size >> MALLOC_NUM);
			while(i > pos)
			{
				if( ptr == *ptr_index )
				{
					ptr_index --;
					ptr0 = *ptr_index;
					ptr0 = ptr0 + MALLOC_SIZE - 1;
				}
				else
				{
					ptr0 = ptr - 1;
				}

				*ptr = *ptr0;
				ptr = ptr0;
				i --;
			}

			*ptr = value;
			size ++;
			A->size = size;

			if( size < A->mallocsize )
				A->pDataEnd ++;
		}
	}

	return;
}
void PASEArrayRemove(PASEArray* A,NSInteger index)
{
	NSInteger size = A->size;
	NSInteger i;
	NSInteger* ptr0 = 0;
	NSInteger* ptr = 0;
	NSInteger* ptr_temp = 0;
	NSInteger** ptr_index = 0;
	NSInteger pIndex = 0;
	
	if(index >= 0 && index < size)
	{	
		i = index;

		pIndex = index >> MALLOC_NUM;
		ptr_index = A->pIndexData + pIndex;
		index = index & (MALLOC_SIZE - 1);
		ptr_temp = *ptr_index;
		ptr0 = ptr = ptr_temp + index;
		size --;
	
		while(i < size)
		{
			index ++;
			if( index >= MALLOC_SIZE )
			{
				ptr_index ++;
				ptr = *ptr_index;
				index = 0;
			}
			else
			{
				ptr = ptr0 + 1;
			}
			*ptr0 = *ptr;
			ptr0 = ptr;
			i ++;
		} 

		A->size = size;
		A->pDataEnd = ptr;
	}

	return;
}
void PASEArrayReset(PASEArray* A)
{
	NSInteger i = 0;
	
	for(i = 0;i < A->pIndexNum;i ++)
		free(*(A->pIndexData+i));	

	if( A->pIndexData )
		free(A->pIndexData);
	
	
	PASEArrayInit(A);
}

NSInteger PASEArrayReSize(PASEArray* A)
{
	NSInteger	newsize;
	NSInteger* desData;
	NSInteger mallocsize = MallocByte;
	NSInteger mallocindexsize = MallocIndexByte;

	//内存不够
	if(A->pIndexNum + 1 >= INDEX_NUM_MAX )
		return 0;

	if( !A->pIndexData )
		A->pIndexData = (NSInteger**)malloc(mallocindexsize);
	
	newsize = A->mallocsize + MALLOC_SIZE;
	desData = (NSInteger*)malloc(mallocsize);

	*(A->pIndexData+A->pIndexNum) = desData;
	A->pIndexNum ++;

	A->pDataEnd = desData;
	A->mallocsize = newsize;

	return 1;
}

NSInteger PASEArrayGetValue(PASEArray* A,NSInteger index)
{
	NSInteger* ptr = 0;
	NSInteger* ptr_index = 0;
	NSInteger pIndex = 0;

	if(index >= 0 && index < A->size)
	{
		pIndex = index >> MALLOC_NUM;
		ptr_index = *(A->pIndexData + pIndex);
		index = index & (MALLOC_SIZE - 1);
		ptr = ptr_index + index;

		return *ptr;
	}
	return -1;
}

void PASEArrayCInit(struct PASEArrayC* A)
{
	A->pData = 0;
	A->size = 0;
	A->pDataSize = 0;
	A->pDataEnd = 0;
	
	A->Append = &PASEArrayCAppend;
	A->Reset = &PASEArrayCReset;
	A->GetValue = &PASEArrayCGetValue;
	A->SetSize = &PASEArrayCSetSize;
	return;
}
void PASEArrayCAppend(PASEArrayC* A,NSInteger value)
{
	if( A->size < A->pDataSize )
		{
		*A->pDataEnd = value;
		A->size ++;

		if( A->size < A->pDataSize )
			A->pDataEnd ++;
		}
	return;
}
void PASEArrayCReset(PASEArrayC* A)
{
	if( A->pData )
	{
		free(A->pData);
	}

	PASEArrayCInit(A);
}
NSInteger  PASEArrayCGetValue(PASEArrayC* A,NSInteger index)
{
	if( index >= 0 && index < A->size )
		return *(A->pData + index);
	
	return -1;
}

void PASEArrayCSetSize(struct PASEArrayC* A,NSInteger size)
{
    if( A->pDataSize > 0 )
    	return;
    
    A->pDataSize = size;
    A->pData = (NSInteger*)malloc(size*sizeof_int);
	A->pDataEnd = A->pData;
}
