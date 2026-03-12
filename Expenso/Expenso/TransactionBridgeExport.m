//
//  TransactionBridgeExport.m
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TransactionBridge, RCTEventEmitter)
RCT_EXTERN_METHOD(deleteTransaction:(NSString *)id)
@end
