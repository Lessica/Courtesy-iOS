//
//  CourtesyMarkdownParser.m
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMarkdownParser.h"

@implementation CourtesyMarkdownParser {
    UIFont *_font;
    NSMutableArray *_headerFonts; ///< h1~h6
    UIFont *_boldFont;
    UIFont *_italicFont;
    UIFont *_boldItalicFont;
    UIFont *_monospaceFont;
    YYTextBorder *_border;
    
    NSRegularExpression *_regexEscape;          ///< escape
    NSRegularExpression *_regexHeader;          ///< #header
    NSRegularExpression *_regexH1;              ///< header\n====
    NSRegularExpression *_regexH2;              ///< header\n----
    NSRegularExpression *_regexBreakline;       ///< ******
    NSRegularExpression *_regexEmphasis;        ///< *text*  _text_
    NSRegularExpression *_regexStrong;          ///< **text**
    NSRegularExpression *_regexStrongEmphasis;  ///< ***text*** ___text___
    NSRegularExpression *_regexInlineCode;      ///< `text`
    NSRegularExpression *_regexLink;            ///< [name](link)
    NSRegularExpression *_regexLinkRefer;       ///< [ref]:
    NSRegularExpression *_regexList;            ///< 1.text 2.text 3.text
    NSRegularExpression *_regexBlockQuote;      ///< > quote
    NSRegularExpression *_regexNotEmptyLine;
}

- (void)initRegex {
#define regexp(reg, option) [NSRegularExpression regularExpressionWithPattern : @reg options : option error : NULL]
    _regexEscape = regexp("(\\\\\\\\|\\\\\\`|\\\\\\*|\\\\\\_|\\\\\\(|\\\\\\)|\\\\\\[|\\\\\\]|\\\\#|\\\\\\+|\\\\\\-|\\\\\\!)", 0);
    _regexHeader = regexp("^((\\#{1,6}[^#].*)|(\\#{6}.+))$", NSRegularExpressionAnchorsMatchLines);
    _regexH1 = regexp("^[^=\\n][^\\n]*\\n=+$", NSRegularExpressionAnchorsMatchLines);
    _regexH2 = regexp("^[^-\\n][^\\n]*\\n-+$", NSRegularExpressionAnchorsMatchLines);
    _regexBreakline = regexp("^[ \\t]*([*-])[ \\t]*((\\1)[ \\t]*){2,}[ \\t]*$", NSRegularExpressionAnchorsMatchLines);
    _regexEmphasis = regexp("((?<!\\*)\\*(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*(?!\\*)|(?<!_)_(?=[^ \\t_])(.+?)(?<=[^ \\t_])_(?!_))", 0);
    _regexStrong = regexp("(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)", 0);
    _regexStrongEmphasis =  regexp("((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))", 0);
    _regexInlineCode = regexp("(?<!`)(`{1,3})([^`\n]+?)\\1(?!`)", 0);
    _regexLink = regexp("!?\\[([^\\[\\]]+)\\] ?(\\(([^\\(\\)]+)\\)|\\[([^\\[\\]]+)\\])", 0);
    _regexLinkRefer = regexp("^[ \\t]*\\[[^\\[\\]]*\\]:", NSRegularExpressionAnchorsMatchLines);
    _regexList = regexp("^[ \\t]*([*+-]|\\d+[.])[ \\t]+", NSRegularExpressionAnchorsMatchLines);
    _regexBlockQuote = regexp("^[ \\t]*>[ \\t>]*", NSRegularExpressionAnchorsMatchLines);
    _regexNotEmptyLine = regexp("^[ \\t]*[^ \\t]+[ \\t]*$", NSRegularExpressionAnchorsMatchLines);
#undef regexp
}

- (instancetype)init {
    self = [super init];
    _fontSize = 14;
    _headerFontSize = 20;
    [self initRegex];
    return self;
}

- (void)setFontSize:(CGFloat)fontSize {
    if (fontSize < 1) fontSize = 12;
    _fontSize = fontSize;
    [self _updateFonts];
}

- (void)setHeaderFontSize:(CGFloat)headerFontSize {
    if (headerFontSize < 1) headerFontSize = 20;
    _headerFontSize = headerFontSize;
    [self _updateFonts];
}

- (void)_updateFonts {
#warning "Why would you replace my fonts?"
    _font = _currentFont ? [_currentFont fontWithSize:_fontSize] : [UIFont systemFontOfSize:_fontSize];
    _headerFonts = [NSMutableArray new];
    for (int i = 0; i < 6; i++) {
        CGFloat size = _headerFontSize - (_headerFontSize - _fontSize) / 5.0 * i;
        [_headerFonts addObject:[_currentFont fontWithSize:size]];
    }
    _boldFont = [_font fontWithBold];
    _italicFont = [_font fontWithItalic];
    _boldItalicFont = [_font fontWithBoldItalic];
    _monospaceFont = [UIFont fontWithName:@"Menlo" size:_fontSize]; // Since iOS 7
    if (!_monospaceFont) _monospaceFont = [UIFont fontWithName:@"Courier" size:_fontSize]; // Since iOS 3
}

- (NSUInteger)lenghOfBeginWhiteInString:(NSString *)str withRange:(NSRange)range{
    for (NSUInteger i = 0; i < range.length; i++) {
        unichar c = [str characterAtIndex:i + range.location];
        if (c != ' ' && c != '\t' && c != '\n') return i;
    }
    return str.length;
}

- (NSUInteger)lenghOfEndWhiteInString:(NSString *)str withRange:(NSRange)range{
    for (NSInteger i = range.length - 1; i >= 0; i--) {
        unichar c = [str characterAtIndex:i + range.location];
        if (c != ' ' && c != '\t' && c != '\n') return range.length - i;
    }
    return str.length;
}

- (NSUInteger)lenghOfBeginChar:(unichar)c inString:(NSString *)str withRange:(NSRange)range{
    for (NSUInteger i = 0; i < range.length; i++) {
        if ([str characterAtIndex:i + range.location] != c) return i;
    }
    return str.length;
}

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)range {
    if (text.length == 0) return NO;
    text.font = _font;
    text.color = _textColor;
    
    NSMutableString *str = text.string.mutableCopy;
    [_regexEscape replaceMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) withTemplate:@"@@"];
    
    [_regexHeader enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSUInteger whiteLen = [self lenghOfBeginWhiteInString:str withRange:r];
        NSUInteger sharpLen = [self lenghOfBeginChar:'#' inString:str withRange:NSMakeRange(r.location + whiteLen, r.length - whiteLen)];
        if (sharpLen > 6) sharpLen = 6;
        [text setColor:_controlTextColor range:NSMakeRange(r.location, whiteLen + sharpLen)];
        [text setColor:_headerTextColor range:NSMakeRange(r.location + whiteLen + sharpLen, r.length - whiteLen - sharpLen)];
        [text setFont:_headerFonts[sharpLen - 1] range:result.range];
    }];
    
    [_regexH1 enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange linebreak = [str rangeOfString:@"\n" options:0 range:result.range locale:nil];
        if (linebreak.location != NSNotFound) {
            [text setColor:_headerTextColor range:NSMakeRange(r.location, linebreak.location - r.location)];
            [text setFont:_headerFonts[0] range:NSMakeRange(r.location, linebreak.location - r.location + 1)];
            [text setColor:_controlTextColor range:NSMakeRange(linebreak.location + linebreak.length, r.location + r.length - linebreak.location - linebreak.length)];
        }
    }];
    
    [_regexH2 enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange linebreak = [str rangeOfString:@"\n" options:0 range:result.range locale:nil];
        if (linebreak.location != NSNotFound) {
            [text setColor:_headerTextColor range:NSMakeRange(r.location, linebreak.location - r.location)];
            [text setFont:_headerFonts[1] range:NSMakeRange(r.location, linebreak.location - r.location + 1)];
            [text setColor:_controlTextColor range:NSMakeRange(linebreak.location + linebreak.length, r.location + r.length - linebreak.location - linebreak.length)];
        }
    }];
    
    [_regexBreakline enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [text setColor:_controlTextColor range:result.range];
    }];
    
    [_regexEmphasis enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:_controlTextColor range:NSMakeRange(r.location, 1)];
        [text setColor:_controlTextColor range:NSMakeRange(r.location + r.length - 1, 1)];
        [text setFont:_italicFont range:NSMakeRange(r.location + 1, r.length - 2)];
    }];
    
    [_regexStrong enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:_controlTextColor range:NSMakeRange(r.location, 2)];
        [text setColor:_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text setFont:_boldFont range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexStrongEmphasis enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:_controlTextColor range:NSMakeRange(r.location, 3)];
        [text setColor:_controlTextColor range:NSMakeRange(r.location + r.length - 3, 3)];
        [text setFont:_boldItalicFont range:NSMakeRange(r.location + 3, r.length - 6)];
    }];
    
    [_regexInlineCode enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSUInteger len = [self lenghOfBeginChar:'`' inString:str withRange:r];
        [text setColor:_controlTextColor range:NSMakeRange(r.location, len)];
        [text setColor:_controlTextColor range:NSMakeRange(r.location + r.length - len, len)];
        [text setColor:_inlineTextColor range:NSMakeRange(r.location + len, r.length - 2 * len)];
        [text setFont:_monospaceFont range:r];
        [text setTextBorder:_border.copy range:r];
    }];
    
    [_regexLink enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
        [text setTextBinding:binding range:r];
        [text setTextHighlightRange:r
                              color:_linkTextColor
                    backgroundColor:[UIColor clearColor]
                          tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                              NSString *realStr = [[[text attributedSubstringFromRange:range] string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                              NSRange range1 = [realStr rangeOfString:@"("];
                              NSRange range2 = [realStr rangeOfString:@")"];
                              if (range1.location == NSNotFound || range2.location == NSNotFound) return;
                              NSInteger loc = range1.location;
                              NSInteger len = range2.location - range1.location;
                              realStr = [realStr substringWithRange:NSMakeRange(loc + 1, len - 1)];
                              if ([realStr isEmail]) realStr = [NSString stringWithFormat:@"mailto://%@", realStr];
                              else if ([realStr isUrl]);
                              else return;
                              NSURL *realURL = [NSURL URLWithString:realStr];
                              CYLog(@"%@", realURL);
                              
                              if ([[UIApplication sharedApplication] canOpenURL:realURL]) {
                                  [[UIApplication sharedApplication] openURL:realURL];
                              }
                          }];
    }];
    
    [_regexLinkRefer enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:_controlTextColor range:r];
    }];
    
    [_regexList enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:_controlTextColor range:r];
    }];
    
    [_regexBlockQuote enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:_controlTextColor range:r];
    }];
    
    return YES;
}

@end
