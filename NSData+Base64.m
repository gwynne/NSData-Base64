//
//  NSData+Base64.h
//
//  Created by Gwynne Raskind on 2012/07/06.
//  Copyright 2012 Gwynne Raskind. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "NSData+Base64.h"
#import <Security/Security.h>

@implementation NSData (Base64)

 + (NSData *)dataWithBase64String:(NSString *)string
 {
	SecTransformRef		decoder = NULL;
	NSData				*result = nil;
	
	decoder = SecDecodeTransformCreate(kSecBase64Encoding, NULL);
	SecTransformSetAttribute(decoder, kSecTransformInputAttributeName, (__bridge CFDataRef)[string dataUsingEncoding:NSASCIIStringEncoding], NULL);
	result = (__bridge_transfer NSData *)SecTransformExecute(decoder, NULL);
	CFRelease(decoder);
	return result;
}

- (NSString *)stringByEncodingWithBase64
{
	return [self stringByEncodingWithBase64SeparatedByLines:NO];
}

- (NSString *)stringByEncodingWithBase64SeparatedByLines:(BOOL)separateLines
{
	SecTransformRef		encoder = NULL;
	NSString			*result = nil;
	
	encoder = SecEncodeTransformCreate(kSecBase64Encoding, NULL);
	SecTransformSetAttribute(encoder, kSecTransformInputAttributeName, (__bridge CFDataRef)self, NULL);
	result = [[NSString alloc] initWithData:(__bridge_transfer NSData *)SecTransformExecute(encoder, NULL) encoding:NSASCIIStringEncoding];
	CFRelease(encoder);
	if (separateLines)
	{
#if USE_REGEX
		result = [[NSRegularExpression regularExpressionWithPattern:@"(.{64})(?!\\n)" options:0 error:nil]
					stringByReplacingMatchesInString:result
					options:0
					range:(NSRange){ 0, result.length }
					withTemplate:@"$1\n"];
#else
		NSUInteger				len = result.length;
		NSMutableString			*scratch = [NSMutableString stringWithCapacity:len + (len >> 6)];
		
		for (NSUInteger i = 0; i < result.length; i += 64)
			[scratch appendFormat:@"%@\n", [result substringWithRange:(NSRange){ i, MIN(64UL, result.length - i) }]];
		result = scratch;
#endif
	}
	return result;
}

@end
