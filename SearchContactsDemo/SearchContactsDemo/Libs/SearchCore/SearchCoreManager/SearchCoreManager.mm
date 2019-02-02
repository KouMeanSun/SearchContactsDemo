/*
 ============================================================================
 Name		: SearchCore.cpp
 Author	  : gaomingyang
 Version	 : 1.0
 Description : CSearchCore implementation
 ============================================================================
 */

#include "SearchCoreManager.h"

static SearchCoreManager *searchCoreManager = nil;

@implementation SearchCoreManager
+ (SearchCoreManager *)share {
    if (!searchCoreManager) {
        searchCoreManager = [[SearchCoreManager alloc] init];
    }
    return searchCoreManager;
}


- (id)init {
    if (self = [super init]) {
        SearchTreeInit(&iSearchTree);
        NSString *multiPYinpath = [[NSBundle mainBundle] pathForResource:@"multipy_unicode" ofType:@"dat"];
        LoadMultiPYinWords([multiPYinpath UTF8String]);
        separateWord = [NSString stringWithFormat:@"%c",KSeparateWord];
    }
    return self;
}

- (void)SetMatchFunction:(NSString*) matchFunc {
    if (matchFunction==matchFunc || [matchFunction isEqualToString:matchFunc]) {
        return;
    }
    
	u2char buf[256];
	[self string_u2char:matchFunc u2char:buf];
	
	Tree_SetMatchFunction(&iSearchTree,buf);
}

//string 转 u2char
- (void)string_u2char:(NSString*)src u2char:(u2char*)des {
    u2char* ptr = des;
    for (NSInteger i = 0; i < [src length]; i ++) {
        unichar word = [src characterAtIndex:i];
        *ptr = word;
        ptr ++;
    }
    *ptr = 0;
}

//PASEArray 转 NSArray
- (void)PASEArrayToNSArray:(PASEArray*)PASEArray NSArray:(NSMutableArray*)PASEArrayDes {
    [PASEArrayDes removeAllObjects];
    
    for (NSInteger i = 0; i < PASEArray->size; i ++) {
        NSInteger aID = PASEArray->GetValue(PASEArray,i);
        [PASEArrayDes addObject:[NSNumber numberWithInteger:aID]];
    }
}
- (void)AddContact:(NSNumber*)localID name:(NSString*)name phone:(NSArray*)phonePASEArray {
    //将联系人的号码用分隔符拼接添加到搜索,不直接用PASEArray,为了优化号码搜索(KMP复杂度M+N)
    
    NSMutableString *phoneStr = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < [phonePASEArray count]; i ++) {
        NSString *phone = [phonePASEArray objectAtIndex:i];
        [phoneStr appendString:phone];
        [phoneStr appendString:separateWord];
    }
    
    u2char nameBuf[name.length + 1];
    [self string_u2char:name u2char:nameBuf];
    
    u2char phoneBuf[phoneStr.length + 1];
    [self string_u2char:phoneStr u2char:phoneBuf];
    
    Tree_AddData(&iSearchTree,[localID intValue],nameBuf,phoneBuf);
    
    
}

- (void)ReplaceContact:(NSNumber*)localID name:(NSString*)name phone:(NSArray*)phonePASEArray {
    
    NSMutableString *phoneStr = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < [phonePASEArray count]; i ++) {
        NSString *phone = [phonePASEArray objectAtIndex:i];
        [phoneStr appendString:phone];
        [phoneStr appendString:separateWord];
    }
    
    u2char nameBuf[name.length + 1];
    [self string_u2char:name u2char:nameBuf];
    
    u2char phoneBuf[phoneStr.length + 1];
    [self string_u2char:phoneStr u2char:phoneBuf];
    
    Tree_ReplaceData(&iSearchTree,[localID intValue],nameBuf,phoneBuf);

}

- (void)DeleteContact:(NSNumber*)localID {
	Tree_DeleteData(&iSearchTree,[localID integerValue]);
}

- (void)SearchDefault:(NSString*)searchText searchArray:(NSArray*)aSearchedArray nameMatch:(NSMutableArray*)nameMatchArray phoneMatch:(NSMutableArray*)phoneMatchArray {
    
    u2char searchTextBuf[searchText.length + 1];
    [self string_u2char:searchText u2char:searchTextBuf];
    
    PASEArray* searchedPASEArray = NULL;
	PASEArray* nameMatchHits = NULL;
	PASEArray* phoneMatchHits = NULL;
	if (aSearchedArray) {
		searchedPASEArray = new PASEArray;
		PASEArrayInit(searchedPASEArray);
        
        for (NSInteger i = 0; i < [aSearchedArray count]; i ++) {
            NSNumber *number = [aSearchedArray objectAtIndex:i];
            searchedPASEArray->Append(searchedPASEArray,[number intValue]);
        }
    }
	
	if (nameMatchArray) {
        [nameMatchArray removeAllObjects];
        
		nameMatchHits = new PASEArray;
		PASEArrayInit(nameMatchHits);
    }
	
	if (phoneMatchArray) {
        [phoneMatchArray removeAllObjects];
        
		phoneMatchHits = new PASEArray;
		PASEArrayInit(phoneMatchHits);
    }
	
	Tree_Search(&iSearchTree,searchTextBuf,searchedPASEArray,nameMatchHits,phoneMatchHits);
	
	if (nameMatchHits) {
        [self PASEArrayToNSArray:nameMatchHits NSArray:nameMatchArray];
		nameMatchHits->Reset(nameMatchHits);
		delete nameMatchHits;
    }
	
	if (phoneMatchHits) {
        [self PASEArrayToNSArray:phoneMatchHits NSArray:phoneMatchArray];
		phoneMatchHits->Reset(phoneMatchHits);
		delete phoneMatchHits;
    }
	
	if (searchedPASEArray) {
		searchedPASEArray->Reset(searchedPASEArray);
		delete searchedPASEArray;
    }
    
}

//搜索 MatchFunction为空
- (void)Search:(NSString*)searchText searchArray:(NSArray*)aSearchedArray nameMatch:(NSMutableArray*)nameMatchArray phoneMatch:(NSMutableArray*)phoneMatchArray {
    [self SetMatchFunction:KStringNull];
    [self SearchDefault:searchText searchArray:aSearchedArray nameMatch:nameMatchArray phoneMatch:phoneMatchArray];
}

//搜索 带MatchFunction
- (void)SearchWithFunc:(NSString*)matchFunc searchText:(NSString*)searchText searchArray:(NSArray*)aSearchedArray nameMatch:(NSMutableArray*)nameMatchArray phoneMatch:(NSMutableArray*)phoneMatchArray {
    [self SetMatchFunction:matchFunc];
    [self SearchDefault:searchText searchArray:aSearchedArray nameMatch:nameMatchArray phoneMatch:phoneMatchArray];
}
- (BOOL)GetPinYin:(NSNumber*)localID pinYin:(NSMutableString*)pinyinDes matchPos:(NSMutableArray*)matchPosInPinYin {
    [pinyinDes setString:@""];

    u2char pinyinBuf[256];
    
    PASEArray* aMatchPosInPinYin = NULL;
	if (matchPosInPinYin ) {
		aMatchPosInPinYin = new PASEArray;
		PASEArrayInit(aMatchPosInPinYin);
    }
	
	BOOL result = Tree_GetPinYin(&iSearchTree,[localID intValue],pinyinBuf,aMatchPosInPinYin);
    
    NSInteger length = u2slen(pinyinBuf);
    [pinyinDes appendString:[NSString stringWithCharacters:(unichar*)pinyinBuf length:length]];
	
	if (aMatchPosInPinYin) {
        [self PASEArrayToNSArray:aMatchPosInPinYin NSArray:matchPosInPinYin];
        aMatchPosInPinYin->Reset(aMatchPosInPinYin);
		delete aMatchPosInPinYin;
    }
	
	return result;
}

//用分隔符拼接的号码，转换到原有的样式，提取匹配的号码及匹配位置
- (void) ChangeToOranagePhones:(NSString*)phones matchPos:(NSArray*)matchPos phoneArray:(NSMutableArray*)phoneArray matchPosArray:(NSMutableArray*)matchPosArray {
    
    NSInteger start = [[matchPos objectAtIndex:0] intValue];
    while (start >= 0) {
        unichar word = [phones characterAtIndex:start];
        if (word == KSeparateWord) {
            break;
        }
        start --;
    }
    start ++;
    
    NSInteger end = [[matchPos objectAtIndex:matchPos.count-1] intValue];
    while (end < [phones length]) {
        unichar word = [phones characterAtIndex:end];
        if (word == KSeparateWord) {
            break;
        }
        end ++;
    }
    NSRange range = NSMakeRange(start, end - start);
    NSString *phone = [phones substringWithRange:range];
    
    NSMutableArray *matchPosDes = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [matchPos count]; i ++) {
        NSInteger pos = [[matchPos objectAtIndex:i] intValue];
        pos -= start;
        [matchPosDes addObject:[NSNumber numberWithInteger:pos]];
    }
    [phoneArray addObject:phone];
    [matchPosArray addObject:matchPosDes];
}

- (BOOL)GetPhoneNum:(NSNumber*)localID phone:(NSMutableArray*)phoneArray matchPos:(NSMutableArray*)matchPosArray {
    [phoneArray removeAllObjects];
    [matchPosArray removeAllObjects];
    
    u2char phoneBuf[256];
    
    PASEArray* aMatchPosInPhoneNum = NULL;
	if  (matchPosArray) {
		aMatchPosInPhoneNum = new PASEArray;
		PASEArrayInit(aMatchPosInPhoneNum);
    }
    
    NSMutableString *phoneDes = [[NSMutableString alloc] init];
    NSMutableArray *matchPos = [[NSMutableArray alloc] init];
    BOOL result = Tree_GetPhoneNum(&iSearchTree,[localID intValue],(u2char*)phoneBuf,aMatchPosInPhoneNum);
    NSInteger length = u2slen(phoneBuf);
    [phoneDes appendString:[NSString stringWithCharacters:(unichar*)phoneBuf length:length]];
	if (aMatchPosInPhoneNum) {
        [self PASEArrayToNSArray:aMatchPosInPhoneNum NSArray:matchPos];
        aMatchPosInPhoneNum->Reset(aMatchPosInPhoneNum);
		delete aMatchPosInPhoneNum;
    }
    
    [self ChangeToOranagePhones:phoneDes matchPos:matchPos phoneArray:phoneArray matchPosArray:matchPosArray];

    return result;
}

- (void)Reset {
    
    FreeSearchTree(&iSearchTree);
    SearchTreeInit(&iSearchTree);
}
- (void)dealloc {
    //释放多音字库
    ReleaseMultiPYinWords();
    
    //释放搜索库
    FreeSearchTree(&iSearchTree);

}

@end
