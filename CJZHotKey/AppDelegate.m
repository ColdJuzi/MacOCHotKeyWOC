//
//  AppDelegate.m
//  CJZHotKey
//
//  Created by lianghao on 2024/4/10.
//

#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface AppDelegate ()
{
    EventHotKeyRef* _hotKeyRefs;
}

@property (weak) IBOutlet NSMenu* systemMenu;

@property (nonatomic, strong) NSStatusItem* statusItem;

@end

@implementation AppDelegate

- (void)dealloc {
    [self removeAllHotKey];
    free(_hotKeyRefs);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self signinAllHotKey];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSButton* statusButtn = [self.statusItem button];
    [statusButtn setImage:[NSImage imageNamed:@"StatusIcon"]];
    [statusButtn sendActionOn:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown];
    [statusButtn setAction:@selector(useClickMenu:)];
    
}

- (void)useClickMenu:(NSButton *)sender {
    NSEvent* event = [NSApp currentEvent];
    switch (event.type) {
        case NSEventTypeLeftMouseDown:
        case NSEventTypeRightMouseDown: {
            [self.statusItem setMenu:self.systemMenu];
            NSButton* statusBtton = [self.statusItem button];
            [statusBtton performClick:nil];
        }
            break;
        default:
            break;
    }
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    NSButton* statusButtn = [self.statusItem button];
    [statusButtn setImage:[NSImage imageNamed:@"StatusIcon"]];
    [statusButtn sendActionOn:NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown];
    [statusButtn setAction:@selector(useClickMenu:)];
}

- (IBAction)disableHotKey:(NSMenuItem *)sender {
    if (sender.state == NSControlStateValueOn) {
        [self signinAllHotKey];
    } else {
        [self removeAllHotKey];
    }
    sender.state = sender.state == NSControlStateValueOn ? NSControlStateValueOff : NSControlStateValueOn;
}

#pragma mark - HotKey
- (void)removeAllHotKey {
    for (int i = 0; i < 4; i++) {
        OSStatus err = UnregisterEventHotKey(_hotKeyRefs[i]);
        if (err != noErr) {
        }
    }
}

- (void)signinAllHotKey {
    EventTypeSpec eventType;
    // 设置事件类型为热键按下
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    _hotKeyRefs = malloc(sizeof(EventHotKeyRef) * 4);
    
    EventHotKeyID hotKeyIDs[4];
    int hotKeyCodes[4] = {123, 124, 126, 125};
    for (int i = 0; i < 4; i++) {
        hotKeyIDs[i].id = 1000 + i;
        const char* cString = [NSString stringWithFormat:@"%d", 1000 + i].UTF8String;
        OSType type = *(const UInt32 *)(cString);
        hotKeyIDs[i].signature = CFSwapInt32HostToBig(type);
        
        //  control | option | command
        UInt32 hotKeyModifiers = 256 | 2048 | 4096;
        
        //  L-123,R-124,T-126,B-125
        void* selfPointer = (__bridge void *)(self);
        InstallApplicationEventHandler(&MyHotKeyHandler, 1, &eventType, selfPointer, NULL);
        RegisterEventHotKey(hotKeyCodes[i], hotKeyModifiers, hotKeyIDs[i], GetApplicationEventTarget(), 0, &_hotKeyRefs[i]);
    }
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
    EventHotKeyID hotKeyID;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
    NSLog(@"tag:%d", hotKeyID.id);
    id selfObject = (__bridge  id)userData;
    switch (hotKeyID.id) {
        case 1001:
            [selfObject hkToLeft];
            break;
        case 1002:
            [selfObject hkToRight];
            break;
        case 1003:
            [selfObject hkToUp];
            break;
        case 1004:
            [selfObject hkToBottom];
            break;
        default:
            break;
    }
    return noErr;
}

- (void)hkToUp {
    
}

- (void)hkToBottom {
    
}

- (void)hkToLeft {
    
}

- (void)hkToRight {
    
}

@end
