#ifndef KENIOS_MENU_H
#define KENIOS_MENU_H

#import <Foundation/Foundation.h>

@interface KeniosMenu : NSObject
+ (instancetype)sharedInstance;
- (void)showMenu;
- (void)hideMenu;
- (void)updateMenuStatus;
@end

#endif
