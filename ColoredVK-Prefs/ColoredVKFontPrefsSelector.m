//
//  ColoredVKFontPrefsSelector.m
//  ColoredVK2
//
//  Created by Даниил on 28.12.17.
//

#import "ColoredVKFontPrefsSelector.h"
#import <CoreText/CoreText.h>

@interface ColoredVKFontPrefsSelector ()

@end

@implementation ColoredVKFontPrefsSelector

- (void)loadView
{
    [super loadView];
    
    NSArray <NSString *> *allFontsFamilies = [UIFont familyNames];
    NSMutableArray *mutableCyrillicFonts = [NSMutableArray array];
    [mutableCyrillicFonts addObject:@".SFUIText"];
    
    for (NSString *fontName in allFontsFamilies) {
        if ([self fontSupportsCyrillic:fontName]) {
            [mutableCyrillicFonts addObject:fontName];
        }
    }
    [self.specifier setProperty:mutableCyrillicFonts forKey:@"validTitles"];
    [self.specifier setProperty:mutableCyrillicFonts forKey:@"validValues"];
}

- (BOOL)fontSupportsCyrillic:(NSString *)fontName
{
    @autoreleasepool {
        NSString *string = @"БВГ";
        unichar characters[string.length];
        [string getCharacters:characters range:NSMakeRange(0, string.length)];
        CGGlyph glyphs[string.length];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[(id)kCTFontFamilyNameAttribute] = fontName;
        attributes[(id)kCTFontSizeAttribute] = @36.0f;
        CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
        CTFontRef font = CTFontCreateWithFontDescriptor(fontDescriptor, 36.0f, nil);
        
        BOOL supports = CTFontGetGlyphsForCharacters(font, characters, glyphs, string.length);
        CFRelease(font);
        CFRelease(fontDescriptor);
        
        return supports;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont fontWithName:cell.specifier.properties[@"selectorValue"] size:[UIFont labelFontSize]];
    
    
    return cell;
}

- (void)didSelectValue:(id)value forKey:(NSString *)key
{
    
}

@end
