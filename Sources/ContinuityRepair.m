#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kRepositoryURLString = @"https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair";
static NSString * const kLatestReleasesURLString = @"https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases/latest";

@interface CommandRunner : NSObject
+ (void)runScript:(NSString *)script completion:(void (^)(NSString *, int))completion;
@end

@implementation CommandRunner
+ (void)runScript:(NSString *)script completion:(void (^)(NSString *, int))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        NSPipe *pipe = [NSPipe pipe];
        task.launchPath = @"/bin/zsh";
        task.arguments = @[ @"-c", script ];
        task.standardOutput = pipe;
        task.standardError = pipe;

        @try {
            [task launch];
            NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
            [task waitUntilExit];
            NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
            int status = task.terminationStatus;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(output, status);
            });
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([NSString stringWithFormat:@"Error: %@", exception.reason ?: @"unknown error"], 1);
            });
        }
    });
}
@end

@interface RaisedButton : NSButton
@property(nonatomic, strong) CAGradientLayer *gradientLayer;
- (void)setTopColor:(NSColor *)topColor bottomColor:(NSColor *)bottomColor;
@end

@implementation RaisedButton
- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (!self) return nil;

    self.bordered = NO;
    self.buttonType = NSButtonTypeMomentaryPushIn;
    self.focusRingType = NSFocusRingTypeNone;
    self.wantsLayer = YES;
    self.layer.cornerRadius = 9;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor colorWithWhite:0 alpha:0.16].CGColor;
    self.layer.shadowColor = [NSColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.25;
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeMake(0, 3);

    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    self.gradientLayer.cornerRadius = 9;
    [self.layer addSublayer:self.gradientLayer];
    return self;
}

- (void)layout {
    [super layout];
    self.gradientLayer.frame = self.bounds;
    self.gradientLayer.cornerRadius = self.layer.cornerRadius;
}

- (void)setTopColor:(NSColor *)topColor bottomColor:(NSColor *)bottomColor {
    self.gradientLayer.colors = @[ (id)topColor.CGColor, (id)bottomColor.CGColor ];
}

- (void)mouseDown:(NSEvent *)event {
    if (self.enabled) {
        NSSound *sound = [NSSound soundNamed:@"Pop"] ?: [NSSound soundNamed:@"Tink"];
        if (sound) {
            [sound play];
        } else {
            NSBeep();
        }

        [CATransaction begin];
        [CATransaction setAnimationDuration:0.08];
        self.layer.transform = CATransform3DMakeTranslation(0, 2, 0);
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.12;
        [CATransaction commit];
    }

    [super mouseDown:event];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.12];
    self.layer.transform = CATransform3DIdentity;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowOpacity = 0.25;
    [CATransaction commit];
}
@end

@interface StatusRow : NSObject
@property(nonatomic, strong) NSStackView *container;
@property(nonatomic, strong) NSTextField *valueLabel;
@property(nonatomic, strong) NSButton *indicator;
- (instancetype)initWithTitle:(NSString *)title;
- (void)setText:(NSString *)text healthy:(BOOL)healthy known:(BOOL)known;
@end

@implementation StatusRow
- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (!self) return nil;

    NSTextField *titleLabel = [NSTextField labelWithString:title];
    titleLabel.font = [NSFont systemFontOfSize:13];
    titleLabel.alignment = NSTextAlignmentRight;
    [titleLabel setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [[titleLabel widthAnchor] constraintEqualToConstant:230].active = YES;

    self.valueLabel = [NSTextField labelWithString:@"读取中…"];
    self.valueLabel.font = [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
    self.valueLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.indicator = [NSButton checkboxWithTitle:@"" target:nil action:nil];
    self.indicator.buttonType = NSButtonTypeSwitch;
    self.indicator.enabled = NO;
    [self.indicator setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];

    self.container = [NSStackView stackViewWithViews:@[ titleLabel, self.valueLabel, self.indicator ]];
    self.container.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    self.container.alignment = NSLayoutAttributeCenterY;
    self.container.spacing = 10;
    self.container.edgeInsets = NSEdgeInsetsMake(0, 8, 0, 8);
    self.container.wantsLayer = YES;
    self.container.layer.cornerRadius = 6;
    self.container.layer.borderWidth = 0.5;
    self.container.layer.borderColor = [NSColor colorWithWhite:0 alpha:0.08].CGColor;
    self.container.layer.backgroundColor = [NSColor.controlBackgroundColor colorWithAlphaComponent:0.38].CGColor;
    [[self.container heightAnchor] constraintEqualToConstant:26].active = YES;
    return self;
}

- (void)setText:(NSString *)text healthy:(BOOL)healthy known:(BOOL)known {
    self.valueLabel.stringValue = text ?: @"UNKNOWN";
    self.indicator.state = known ? (healthy ? NSControlStateValueOn : NSControlStateValueOff) : NSControlStateValueMixed;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) NSStackView *statusStack;
@property(nonatomic, strong) NSTextView *outputView;
@property(nonatomic, strong) NSMutableDictionary<NSString *, StatusRow *> *rows;
@property(nonatomic, strong) NSArray<NSButton *> *actionButtons;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"AppIcon" ofType:@"icns"];
    NSImage *appIcon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    if (appIcon != nil) {
        [NSApp setApplicationIconImage:appIcon];
    }
    self.rows = [NSMutableDictionary dictionary];
    [self buildWindow];
    [self refreshStatuses];
    [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(refreshStatuses) userInfo:nil repeats:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (RaisedButton *)buttonWithTitle:(NSString *)title
                           action:(SEL)action
                        topColor:(NSColor *)topColor
                     bottomColor:(NSColor *)bottomColor
                            width:(CGFloat)width {
    RaisedButton *button = [[RaisedButton alloc] initWithFrame:NSZeroRect];
    button.title = title;
    button.target = self;
    button.action = action;
    button.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{
        NSForegroundColorAttributeName: NSColor.whiteColor,
        NSFontAttributeName: [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold]
    }];
    [button setTopColor:topColor bottomColor:bottomColor];
    [button.widthAnchor constraintEqualToConstant:width].active = YES;
    [button.heightAnchor constraintEqualToConstant:40].active = YES;
    [button setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    return button;
}

- (NSButton *)footerButtonWithTitle:(NSString *)title action:(SEL)action underlined:(BOOL)underlined {
    NSButton *button = [NSButton buttonWithTitle:title target:self action:action];
    button.bordered = NO;
    button.focusRingType = NSFocusRingTypeNone;
    button.font = [NSFont systemFontOfSize:11 weight:NSFontWeightMedium];
    NSMutableDictionary *attributes = [@{
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.12 alpha:1],
        NSFontAttributeName: button.font
    } mutableCopy];
    if (underlined) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    return button;
}

- (void)openRepository:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kRepositoryURLString]];
}

- (void)checkForUpdates:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kLatestReleasesURLString]];
    self.outputView.string = @"已打开 GitHub Releases，请查看最新版本。";
}

- (void)buildWindow {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 760, 800)
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"Universal Clipboard Repair";
    self.window.minSize = NSMakeSize(650, 720);
    [self.window center];

    NSView *root = [[NSView alloc] init];
    self.window.contentView = root;

    NSTextField *title = [NSTextField labelWithString:@"Universal Clipboard Repair"];
    title.font = [NSFont systemFontOfSize:24 weight:NSFontWeightSemibold];

    NSTextField *subtitle = [NSTextField wrappingLabelWithString:@"观察 Handoff、Universal Clipboard、共享摄像头和连接条件。两个修复按钮彼此独立，不退出 iCloud、不重置网络、无需 sudo。"];
    subtitle.font = [NSFont systemFontOfSize:13];
    subtitle.textColor = NSColor.secondaryLabelColor;

    RaisedButton *handoffButton = [self buttonWithTitle:@"修复 Handoff / 剪贴板"
                                                 action:@selector(repairHandoff)
                                              topColor:[NSColor colorWithSRGBRed:0.29 green:0.59 blue:0.96 alpha:1]
                                           bottomColor:[NSColor colorWithSRGBRed:0.12 green:0.38 blue:0.80 alpha:1]
                                                  width:184];
    RaisedButton *cameraButton = [self buttonWithTitle:@"修复共享摄像头"
                                                 action:@selector(repairCamera)
                                              topColor:[NSColor colorWithSRGBRed:0.63 green:0.42 blue:0.89 alpha:1]
                                           bottomColor:[NSColor colorWithSRGBRed:0.37 green:0.19 blue:0.68 alpha:1]
                                                  width:168];
    RaisedButton *refreshButton = [self buttonWithTitle:@"刷新状态"
                                                  action:@selector(refreshStatuses)
                                               topColor:[NSColor colorWithSRGBRed:0.48 green:0.52 blue:0.58 alpha:1]
                                            bottomColor:[NSColor colorWithSRGBRed:0.27 green:0.30 blue:0.36 alpha:1]
                                                   width:108];
    self.actionButtons = @[ handoffButton, cameraButton, refreshButton ];

    NSStackView *buttons = [NSStackView stackViewWithViews:@[ handoffButton, cameraButton, refreshButton ]];
    buttons.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    buttons.spacing = 10;

    NSTextField *statusTitle = [NSTextField labelWithString:@"当前状态（每 20 秒自动刷新）"];
    statusTitle.font = [NSFont systemFontOfSize:15 weight:NSFontWeightMedium];

    self.statusStack = [[NSStackView alloc] init];
    self.statusStack.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.statusStack.alignment = NSLayoutAttributeLeading;
    self.statusStack.spacing = 4;

    [self addRowWithKey:@"handoff" title:@"ClipboardSharingEnabled（defaults read）"];
    [self addRowWithKey:@"useractivityd" title:@"useractivityd（接力服务）"];
    [self addRowWithKey:@"sharingd" title:@"sharingd（共享服务）"];
    [self addRowWithKey:@"pboard" title:@"pboard（本机剪贴板）"];
    [self addRowWithKey:@"cameraAgent" title:@"ContinuityCaptureAgent（摄像头服务）"];
    [self addRowWithKey:@"wifi" title:@"Wi‑Fi 电源"];
    [self addRowWithKey:@"bluetooth" title:@"蓝牙控制器"];
    [self addRowWithKey:@"proxy" title:@"科学插件 / 系统代理"];
    [self addRowWithKey:@"cameraMagic" title:@"Camera magic（应为 1）"];
    [self addRowWithKey:@"cameraUsable" title:@"Camera usable（应为 1）"];
    [self addRowWithKey:@"cameraNearby" title:@"Camera nearby（应为 1）"];
    [self addRowWithKey:@"cameraWired" title:@"Camera wired（无线正常应为 0）"];

    self.outputView = [[NSTextView alloc] init];
    self.outputView.editable = NO;
    self.outputView.selectable = YES;
    self.outputView.font = [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
    self.outputView.backgroundColor = NSColor.textBackgroundColor;
    self.outputView.string = @"准备就绪。";
    [self.outputView.heightAnchor constraintEqualToConstant:88].active = YES;

    NSTextField *note = [NSTextField wrappingLabelWithString:@"穷途末路的提示：如以上都无法修复，可以尝试切换科学插件的“全局/规则”模式，恢复之后大概率可以再切回全局模式。"];
    note.font = [NSFont systemFontOfSize:11];
    note.textColor = NSColor.systemRedColor;

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"开发版";
    NSTextField *versionLabel = [NSTextField labelWithString:[NSString stringWithFormat:@"当前版本 v%@", version]];
    versionLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightMedium];
    versionLabel.textColor = [NSColor colorWithWhite:0.12 alpha:1];

    NSButton *repositoryButton = [self footerButtonWithTitle:@"GitHub 仓库" action:@selector(openRepository:) underlined:YES];
    NSButton *updateButton = [self footerButtonWithTitle:@"检查新版本" action:@selector(checkForUpdates:) underlined:NO];
    NSStackView *footerContent = [NSStackView stackViewWithViews:@[ versionLabel, repositoryButton, updateButton ]];
    footerContent.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    footerContent.alignment = NSLayoutAttributeCenterY;
    footerContent.spacing = 12;

    NSView *footerCard = [[NSView alloc] init];
    footerCard.wantsLayer = YES;
    footerCard.layer.cornerRadius = 8;
    footerCard.layer.borderWidth = 0.5;
    footerCard.layer.borderColor = [NSColor colorWithWhite:0 alpha:0.10].CGColor;
    footerCard.layer.backgroundColor = [NSColor colorWithWhite:0.96 alpha:1].CGColor;
    [footerCard addSubview:footerContent];
    [NSLayoutConstraint activateConstraints:@[
        [footerCard.heightAnchor constraintEqualToConstant:36],
        [footerContent.leadingAnchor constraintEqualToAnchor:footerCard.leadingAnchor constant:12],
        [footerContent.trailingAnchor constraintLessThanOrEqualToAnchor:footerCard.trailingAnchor constant:-12],
        [footerContent.centerYAnchor constraintEqualToAnchor:footerCard.centerYAnchor]
    ]];

    NSStackView *stack = [NSStackView stackViewWithViews:@[ title, subtitle, buttons, statusTitle, self.statusStack, self.outputView, note, footerCard ]];
    stack.orientation = NSUserInterfaceLayoutOrientationVertical;
    stack.alignment = NSLayoutAttributeLeading;
    stack.spacing = 12;
    [root addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:root.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:root.trailingAnchor constant:-24],
        [stack.topAnchor constraintEqualToAnchor:root.topAnchor constant:22],
        [stack.bottomAnchor constraintEqualToAnchor:root.bottomAnchor constant:-18],
        [subtitle.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [self.statusStack.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [self.outputView.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [note.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [footerCard.widthAnchor constraintEqualToAnchor:stack.widthAnchor]
    ]];

    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)addRowWithKey:(NSString *)key title:(NSString *)title {
    StatusRow *row = [[StatusRow alloc] initWithTitle:title];
    self.rows[key] = row;
    [self.statusStack addArrangedSubview:row.container];
    [row.container.widthAnchor constraintEqualToAnchor:self.statusStack.widthAnchor].active = YES;
}

- (NSString *)resourceScript:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"sh"];
    return path ? ([NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] ?: @"") : @"";
}

- (NSDictionary<NSString *, NSString *> *)parseOutput:(NSString *)output {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    [output enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSRange range = [line rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString *key = [line substringToIndex:range.location];
            NSString *value = [line substringFromIndex:range.location + 1];
            values[key] = value;
        }
    }];
    return values;
}

- (void)refreshStatuses {
    NSString *script = [self resourceScript:@"status"];
    if (script.length == 0) return;
    [CommandRunner runScript:script completion:^(NSString *output, int status) {
        NSDictionary *values = [self parseOutput:output];
        NSString *handoff = values[@"handoff"] ?: @"UNKNOWN";
        [self.rows[@"handoff"] setText:[handoff isEqualToString:@"1"] ? @"ON（1）" : handoff healthy:[handoff isEqualToString:@"1"] known:![handoff isEqualToString:@"UNKNOWN"]];

        for (NSString *key in @[ @"useractivityd", @"sharingd", @"pboard", @"cameraAgent", @"wifi", @"bluetooth" ]) {
            NSString *value = values[key] ?: @"UNKNOWN";
            [self.rows[key] setText:value healthy:[value isEqualToString:@"ON"] known:![value isEqualToString:@"UNKNOWN"]];
        }

        NSString *cameraMagic = values[@"cameraMagic"] ?: @"UNKNOWN";
        NSString *cameraUsable = values[@"cameraUsable"] ?: @"UNKNOWN";
        NSString *cameraNearby = values[@"cameraNearby"] ?: @"UNKNOWN";
        NSString *cameraWired = values[@"cameraWired"] ?: @"UNKNOWN";
        [self.rows[@"cameraMagic"] setText:cameraMagic healthy:[cameraMagic isEqualToString:@"1"] known:![cameraMagic isEqualToString:@"UNKNOWN"]];
        [self.rows[@"cameraUsable"] setText:cameraUsable healthy:[cameraUsable isEqualToString:@"1"] known:![cameraUsable isEqualToString:@"UNKNOWN"]];
        [self.rows[@"cameraNearby"] setText:cameraNearby healthy:[cameraNearby isEqualToString:@"1"] known:![cameraNearby isEqualToString:@"UNKNOWN"]];
        [self.rows[@"cameraWired"] setText:cameraWired healthy:[cameraWired isEqualToString:@"0"] known:![cameraWired isEqualToString:@"UNKNOWN"]];

        NSString *proxy = values[@"proxy"] ?: @"UNKNOWN";
        [self.rows[@"proxy"] setText:proxy healthy:NO known:NO];
        if (status != 0) {
            self.outputView.string = [NSString stringWithFormat:@"状态读取退出码：%d\n%@", status, output];
        }
    }];
}

- (void)repairHandoff {
    [self runActionNamed:@"Handoff 修复" resource:@"repair-handoff"];
}

- (void)repairCamera {
    [self runActionNamed:@"共享摄像头修复" resource:@"repair-camera"];
}

- (void)runActionNamed:(NSString *)name resource:(NSString *)resource {
    NSString *script = [self resourceScript:resource];
    if (script.length == 0) return;
    for (NSButton *button in self.actionButtons) button.enabled = NO;
    self.outputView.string = [NSString stringWithFormat:@"%@ 正在执行…\n", name];

    [CommandRunner runScript:script completion:^(NSString *output, int status) {
        for (NSButton *button in self.actionButtons) button.enabled = YES;
        self.outputView.string = [NSString stringWithFormat:@"%@（退出码 %d）\n%@", name, status, output];
        [self refreshStatuses];
    }];
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app run];
    }
    return 0;
}
