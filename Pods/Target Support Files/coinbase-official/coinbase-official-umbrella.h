#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CoinbaseOAuth.h"
#import "Coinbase.h"
#import "CoinbaseAccount.h"
#import "CoinbaseAccountChange.h"
#import "CoinbaseAddress.h"
#import "CoinbaseApplication.h"
#import "CoinbaseAuthorization.h"
#import "CoinbaseBalance.h"
#import "CoinbaseButton.h"
#import "CoinbaseCertificatePinning.h"
#import "CoinbaseContact.h"
#import "CoinbaseCurrency.h"
#import "CoinbaseInternal.h"
#import "CoinbaseObject.h"
#import "CoinbaseOrder.h"
#import "CoinbasePagingHelper.h"
#import "CoinbasePaymentMethod.h"
#import "CoinbasePrice.h"
#import "CoinbaseRecurringPayment.h"
#import "CoinbaseRefund.h"
#import "CoinbaseReport.h"
#import "CoinbaseToken.h"
#import "CoinbaseTransaction.h"
#import "CoinbaseTransfer.h"
#import "CoinbaseUser.h"
#import "CoinbaseDefines.h"

FOUNDATION_EXPORT double coinbase_officialVersionNumber;
FOUNDATION_EXPORT const unsigned char coinbase_officialVersionString[];

