#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kRepositoryURLString = @"https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair";
static NSString * const kLatestReleasesURLString = @"https://github.com/0xAAcodeislaw/macos-universal-clipboard-repair/releases/latest";
static NSString * const kLanguagePreferenceKey = @"ContinuityRepairLanguage";

static NSDictionary<NSString *, NSString *> *LocalizationTable(BOOL chinese) {
    static NSDictionary<NSString *, NSString *> *zh;
    static NSDictionary<NSString *, NSString *> *en;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zh = @{
            @"windowTitle": @"通用剪贴板修复",
            @"appTitle": @"通用剪贴板修复",
            @"subtitle": @"观察 Handoff、Universal Clipboard、共享摄像头和连接条件。两个修复按钮彼此独立，不退出 iCloud、不重置网络、无需 sudo。",
            @"repairHandoff": @"修复 Handoff / 剪贴板",
            @"repairCamera": @"修复共享摄像头",
            @"refresh": @"刷新状态",
            @"statusHeader": @"当前状态（每 20 秒自动刷新）",
            @"rowHandoff": @"ClipboardSharingEnabled（defaults read）",
            @"rowUserActivity": @"useractivityd（接力服务）",
            @"rowSharing": @"sharingd（共享服务）",
            @"rowPboard": @"pboard（本机剪贴板）",
            @"rowCameraAgent": @"ContinuityCaptureAgent（摄像头服务）",
            @"rowWifi": @"Wi‑Fi 电源",
            @"rowBluetooth": @"蓝牙控制器",
            @"rowProxy": @"科学插件 / 系统代理",
            @"rowMagic": @"Camera magic（应为 1）",
            @"rowUsable": @"Camera usable（应为 1）",
            @"rowNearby": @"Camera nearby（应为 1）",
            @"rowWired": @"Camera wired（无线正常应为 0）",
            @"ready": @"准备就绪。",
            @"finalTip": @"最终提示：可以尝试来回切换科学插件的“全局/规则”模式。如以上都无法修复，只有分别重启两端的设备，属于三十六计中的最后一计。",
            @"versionFormat": @"当前版本 v%@",
            @"repository": @"GitHub 仓库",
            @"checkUpdates": @"检查新版本",
            @"releasesOpened": @"已打开 GitHub Releases，请查看最新版本。",
            @"statusExit": @"状态读取退出码：%d\n%@",
            @"runningFormat": @"%@ 正在执行…\n",
            @"finishedFormat": @"%@（退出码 %d）\n%@",
            @"loading": @"读取中…",
            @"development": @"开发版",
            @"handoffOn": @"ON（1）",
            @"on": @"开启",
            @"off": @"关闭",
            @"unknown": @"未知",
            @"languageChinese": @"中文",
            @"languageEnglish": @"English"
        };
        en = @{
            @"windowTitle": @"Universal Clipboard Repair",
            @"appTitle": @"Universal Clipboard Repair",
            @"subtitle": @"Monitor Handoff, Universal Clipboard, Continuity Camera, and connection conditions. The repair actions are independent; no iCloud sign-out, network reset, or sudo required.",
            @"repairHandoff": @"Repair Handoff / Clipboard",
            @"repairCamera": @"Repair Continuity Camera",
            @"refresh": @"Refresh Status",
            @"statusHeader": @"Current Status (auto-refreshes every 20 seconds)",
            @"rowHandoff": @"ClipboardSharingEnabled (defaults read)",
            @"rowUserActivity": @"useractivityd (Handoff service)",
            @"rowSharing": @"sharingd (sharing service)",
            @"rowPboard": @"pboard (local clipboard)",
            @"rowCameraAgent": @"ContinuityCaptureAgent (camera service)",
            @"rowWifi": @"Wi‑Fi power",
            @"rowBluetooth": @"Bluetooth controller",
            @"rowProxy": @"Proxy plugin / system proxy",
            @"rowMagic": @"Camera magic (expected 1)",
            @"rowUsable": @"Camera usable (expected 1)",
            @"rowNearby": @"Camera nearby (expected 1)",
            @"rowWired": @"Camera wired (wireless normal = 0)",
            @"ready": @"Ready.",
            @"finalTip": @"Final tip: try switching the scientific-networking plugin between “Global” and “Rule” mode. If none of the steps above works, restart both devices separately—the final move of the Thirty-Six Stratagems.",
            @"versionFormat": @"Version v%@",
            @"repository": @"GitHub Repository",
            @"checkUpdates": @"Check for Updates",
            @"releasesOpened": @"GitHub Releases opened. Check for the latest version.",
            @"statusExit": @"Status command exited with code %d\n%@",
            @"runningFormat": @"%@ is running…\n",
            @"finishedFormat": @"%@ (exit code %d)\n%@",
            @"loading": @"Loading…",
            @"development": @"Development",
            @"handoffOn": @"ON (1)",
            @"on": @"ON",
            @"off": @"OFF",
            @"unknown": @"UNKNOWN",
            @"languageChinese": @"中文",
            @"languageEnglish": @"English"
        };
    });
    return chinese ? zh : en;
}

static NSString *Localized(BOOL chinese, NSString *key) {
    return LocalizationTable(chinese)[key] ?: key;
}

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
@property(nonatomic, strong) NSTextField *titleLabel;
@property(nonatomic, strong) NSTextField *valueLabel;
@property(nonatomic, strong) NSButton *indicator;
@property(nonatomic, assign) BOOL hasValue;
- (instancetype)initWithTitle:(NSString *)title;
- (void)setTitle:(NSString *)title;
- (void)setLoadingText:(NSString *)text;
- (void)setText:(NSString *)text healthy:(BOOL)healthy known:(BOOL)known;
@end

@implementation StatusRow
- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (!self) return nil;

    self.titleLabel = [NSTextField labelWithString:title];
    self.titleLabel.font = [NSFont systemFontOfSize:13];
    self.titleLabel.alignment = NSTextAlignmentRight;
    [self.titleLabel setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [[self.titleLabel widthAnchor] constraintEqualToConstant:285].active = YES;

    self.valueLabel = [NSTextField labelWithString:@""];
    self.valueLabel.font = [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
    self.valueLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.indicator = [NSButton checkboxWithTitle:@"" target:nil action:nil];
    self.indicator.buttonType = NSButtonTypeSwitch;
    self.indicator.enabled = NO;
    [self.indicator setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];

    self.container = [NSStackView stackViewWithViews:@[ self.titleLabel, self.valueLabel, self.indicator ]];
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

- (void)setTitle:(NSString *)title {
    self.titleLabel.stringValue = title ?: @"";
}

- (void)setLoadingText:(NSString *)text {
    if (!self.hasValue) {
        self.valueLabel.stringValue = text ?: @"";
    }
}

- (void)setText:(NSString *)text healthy:(BOOL)healthy known:(BOOL)known {
    self.hasValue = YES;
    self.valueLabel.stringValue = text ?: @"UNKNOWN";
    self.indicator.state = known ? (healthy ? NSControlStateValueOn : NSControlStateValueOff) : NSControlStateValueMixed;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, assign) BOOL chineseLanguage;
@property(nonatomic, strong) NSSegmentedControl *languageSwitcher;
@property(nonatomic, strong) NSTextField *titleLabel;
@property(nonatomic, strong) NSTextField *subtitleLabel;
@property(nonatomic, strong) NSTextField *statusTitleLabel;
@property(nonatomic, strong) NSTextField *noteLabel;
@property(nonatomic, strong) NSTextField *versionLabel;
@property(nonatomic, strong) RaisedButton *handoffButton;
@property(nonatomic, strong) RaisedButton *cameraButton;
@property(nonatomic, strong) RaisedButton *refreshButton;
@property(nonatomic, strong) NSButton *repositoryButton;
@property(nonatomic, strong) NSButton *updateButton;
@property(nonatomic, strong) NSStackView *statusStack;
@property(nonatomic, strong) NSTextView *outputView;
@property(nonatomic, strong) NSMutableDictionary<NSString *, StatusRow *> *rows;
@property(nonatomic, strong) NSArray<NSButton *> *actionButtons;
@property(nonatomic, assign) BOOL actionRunning;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"AppIcon" ofType:@"icns"];
    NSImage *appIcon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    if (appIcon != nil) {
        [NSApp setApplicationIconImage:appIcon];
    }
    NSNumber *savedLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kLanguagePreferenceKey];
    if (savedLanguage != nil) {
        self.chineseLanguage = savedLanguage.boolValue;
    } else {
        self.chineseLanguage = [[NSLocale currentLocale].languageCode.lowercaseString hasPrefix:@"zh"];
    }
    self.rows = [NSMutableDictionary dictionary];
    [self buildWindow];
    [self updateLocalizedText];
    [self refreshStatuses];
    [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(refreshStatuses) userInfo:nil repeats:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (NSString *)localized:(NSString *)key {
    return Localized(self.chineseLanguage, key);
}

- (void)setRaisedButton:(RaisedButton *)button title:(NSString *)title {
    button.title = title;
    button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{
        NSForegroundColorAttributeName: NSColor.whiteColor,
        NSFontAttributeName: [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold]
    }];
}

- (void)setFooterButton:(NSButton *)button title:(NSString *)title underlined:(BOOL)underlined {
    button.title = title;
    NSMutableDictionary *attributes = [@{
        NSForegroundColorAttributeName: [NSColor colorWithWhite:0.12 alpha:1],
        NSFontAttributeName: button.font
    } mutableCopy];
    if (underlined) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (NSString *)displayStatusValue:(NSString *)value {
    if ([value isEqualToString:@"UNKNOWN"]) return [self localized:@"unknown"];
    if ([value isEqualToString:@"ON"]) return [self localized:@"on"];
    if ([value isEqualToString:@"OFF"]) return [self localized:@"off"];
    return value ?: [self localized:@"unknown"];
}

- (void)languageChanged:(NSSegmentedControl *)sender {
    self.chineseLanguage = sender.selectedSegment == 0;
    [[NSUserDefaults standardUserDefaults] setBool:self.chineseLanguage forKey:kLanguagePreferenceKey];
    [self updateLocalizedText];
}

- (void)updateLocalizedText {
    self.window.title = [self localized:@"windowTitle"];
    self.titleLabel.stringValue = [self localized:@"appTitle"];
    self.subtitleLabel.stringValue = [self localized:@"subtitle"];
    self.statusTitleLabel.stringValue = [self localized:@"statusHeader"];
    self.noteLabel.stringValue = [self localized:@"finalTip"];
    [self setRaisedButton:self.handoffButton title:[self localized:@"repairHandoff"]];
    [self setRaisedButton:self.cameraButton title:[self localized:@"repairCamera"]];
    [self setRaisedButton:self.refreshButton title:[self localized:@"refresh"]];
    [self setFooterButton:self.repositoryButton title:[self localized:@"repository"] underlined:YES];
    [self setFooterButton:self.updateButton title:[self localized:@"checkUpdates"] underlined:NO];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: [self localized:@"development"];
    self.versionLabel.stringValue = [NSString stringWithFormat:[self localized:@"versionFormat"], version];
    [self.languageSwitcher setLabel:[self localized:@"languageChinese"] forSegment:0];
    [self.languageSwitcher setLabel:[self localized:@"languageEnglish"] forSegment:1];
    self.languageSwitcher.selectedSegment = self.chineseLanguage ? 0 : 1;

    NSDictionary<NSString *, NSString *> *rowTitles = @{
        @"handoff": [self localized:@"rowHandoff"],
        @"useractivityd": [self localized:@"rowUserActivity"],
        @"sharingd": [self localized:@"rowSharing"],
        @"pboard": [self localized:@"rowPboard"],
        @"cameraAgent": [self localized:@"rowCameraAgent"],
        @"wifi": [self localized:@"rowWifi"],
        @"bluetooth": [self localized:@"rowBluetooth"],
        @"proxy": [self localized:@"rowProxy"],
        @"cameraMagic": [self localized:@"rowMagic"],
        @"cameraUsable": [self localized:@"rowUsable"],
        @"cameraNearby": [self localized:@"rowNearby"],
        @"cameraWired": [self localized:@"rowWired"]
    };
    [rowTitles enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *title, BOOL *stop) {
        [self.rows[key] setTitle:title];
        [self.rows[key] setLoadingText:[self localized:@"loading"]];
    }];

    if (!self.actionRunning && self.outputView.string.length == 0) {
        self.outputView.string = [self localized:@"ready"];
    }
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
    self.outputView.string = [self localized:@"releasesOpened"];
}

- (void)buildWindow {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 760, 800)
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = [self localized:@"windowTitle"];
    self.window.minSize = NSMakeSize(650, 720);
    [self.window center];

    NSView *root = [[NSView alloc] init];
    self.window.contentView = root;

    self.titleLabel = [NSTextField labelWithString:[self localized:@"appTitle"]];
    self.titleLabel.font = [NSFont systemFontOfSize:24 weight:NSFontWeightSemibold];

    self.subtitleLabel = [NSTextField wrappingLabelWithString:[self localized:@"subtitle"]];
    self.subtitleLabel.font = [NSFont systemFontOfSize:13];
    self.subtitleLabel.textColor = NSColor.secondaryLabelColor;

    self.languageSwitcher = [[NSSegmentedControl alloc] initWithFrame:NSZeroRect];
    self.languageSwitcher.segmentCount = 2;
    [self.languageSwitcher setLabel:[self localized:@"languageChinese"] forSegment:0];
    [self.languageSwitcher setLabel:[self localized:@"languageEnglish"] forSegment:1];
    self.languageSwitcher.selectedSegment = self.chineseLanguage ? 0 : 1;
    self.languageSwitcher.target = self;
    self.languageSwitcher.action = @selector(languageChanged:);
    self.languageSwitcher.trackingMode = NSSegmentSwitchTrackingSelectOne;
    [self.languageSwitcher.widthAnchor constraintEqualToConstant:124].active = YES;
    [self.languageSwitcher.heightAnchor constraintEqualToConstant:26].active = YES;
    NSStackView *header = [NSStackView stackViewWithViews:@[ self.titleLabel, self.languageSwitcher ]];
    header.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    header.alignment = NSLayoutAttributeCenterY;
    header.distribution = NSStackViewDistributionFill;
    header.spacing = 12;

    self.handoffButton = [self buttonWithTitle:[self localized:@"repairHandoff"]
                                         action:@selector(repairHandoff)
                                      topColor:[NSColor colorWithSRGBRed:0.29 green:0.59 blue:0.96 alpha:1]
                                   bottomColor:[NSColor colorWithSRGBRed:0.12 green:0.38 blue:0.80 alpha:1]
                                          width:200];
    self.cameraButton = [self buttonWithTitle:[self localized:@"repairCamera"]
                                        action:@selector(repairCamera)
                                     topColor:[NSColor colorWithSRGBRed:0.63 green:0.42 blue:0.89 alpha:1]
                                  bottomColor:[NSColor colorWithSRGBRed:0.37 green:0.19 blue:0.68 alpha:1]
                                         width:190];
    self.refreshButton = [self buttonWithTitle:[self localized:@"refresh"]
                                         action:@selector(refreshStatuses)
                                      topColor:[NSColor colorWithSRGBRed:0.48 green:0.52 blue:0.58 alpha:1]
                                   bottomColor:[NSColor colorWithSRGBRed:0.27 green:0.30 blue:0.36 alpha:1]
                                          width:120];
    self.actionButtons = @[ self.handoffButton, self.cameraButton, self.refreshButton ];

    NSStackView *buttons = [NSStackView stackViewWithViews:self.actionButtons];
    buttons.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    buttons.spacing = 10;

    self.statusTitleLabel = [NSTextField labelWithString:[self localized:@"statusHeader"]];
    self.statusTitleLabel.font = [NSFont systemFontOfSize:15 weight:NSFontWeightMedium];

    self.statusStack = [[NSStackView alloc] init];
    self.statusStack.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.statusStack.alignment = NSLayoutAttributeLeading;
    self.statusStack.spacing = 4;

    [self addRowWithKey:@"handoff" title:[self localized:@"rowHandoff"]];
    [self addRowWithKey:@"useractivityd" title:[self localized:@"rowUserActivity"]];
    [self addRowWithKey:@"sharingd" title:[self localized:@"rowSharing"]];
    [self addRowWithKey:@"pboard" title:[self localized:@"rowPboard"]];
    [self addRowWithKey:@"cameraAgent" title:[self localized:@"rowCameraAgent"]];
    [self addRowWithKey:@"wifi" title:[self localized:@"rowWifi"]];
    [self addRowWithKey:@"bluetooth" title:[self localized:@"rowBluetooth"]];
    [self addRowWithKey:@"proxy" title:[self localized:@"rowProxy"]];
    [self addRowWithKey:@"cameraMagic" title:[self localized:@"rowMagic"]];
    [self addRowWithKey:@"cameraUsable" title:[self localized:@"rowUsable"]];
    [self addRowWithKey:@"cameraNearby" title:[self localized:@"rowNearby"]];
    [self addRowWithKey:@"cameraWired" title:[self localized:@"rowWired"]];

    self.outputView = [[NSTextView alloc] init];
    self.outputView.editable = NO;
    self.outputView.selectable = YES;
    self.outputView.font = [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
    self.outputView.backgroundColor = NSColor.textBackgroundColor;
    self.outputView.string = [self localized:@"ready"];
    [self.outputView.heightAnchor constraintEqualToConstant:88].active = YES;

    self.noteLabel = [NSTextField wrappingLabelWithString:[self localized:@"finalTip"]];
    self.noteLabel.font = [NSFont systemFontOfSize:11];
    self.noteLabel.textColor = NSColor.systemRedColor;

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: [self localized:@"development"];
    self.versionLabel = [NSTextField labelWithString:[NSString stringWithFormat:[self localized:@"versionFormat"], version]];
    self.versionLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightMedium];
    self.versionLabel.textColor = [NSColor colorWithWhite:0.12 alpha:1];

    self.repositoryButton = [self footerButtonWithTitle:[self localized:@"repository"] action:@selector(openRepository:) underlined:YES];
    self.updateButton = [self footerButtonWithTitle:[self localized:@"checkUpdates"] action:@selector(checkForUpdates:) underlined:NO];
    NSStackView *footerContent = [NSStackView stackViewWithViews:@[ self.versionLabel, self.repositoryButton, self.updateButton ]];
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

    NSStackView *stack = [NSStackView stackViewWithViews:@[ header, self.subtitleLabel, buttons, self.statusTitleLabel, self.statusStack, self.outputView, self.noteLabel, footerCard ]];
    stack.orientation = NSUserInterfaceLayoutOrientationVertical;
    stack.alignment = NSLayoutAttributeLeading;
    stack.spacing = 12;
    [root addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:root.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:root.trailingAnchor constant:-24],
        [stack.topAnchor constraintEqualToAnchor:root.topAnchor constant:22],
        [stack.bottomAnchor constraintEqualToAnchor:root.bottomAnchor constant:-18],
        [header.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [self.subtitleLabel.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [self.statusStack.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [self.outputView.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
        [self.noteLabel.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
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
        NSString *handoffText = [handoff isEqualToString:@"1"] ? [self localized:@"handoffOn"] : [self displayStatusValue:handoff];
        [self.rows[@"handoff"] setText:handoffText healthy:[handoff isEqualToString:@"1"] known:![handoff isEqualToString:@"UNKNOWN"]];

        for (NSString *key in @[ @"useractivityd", @"sharingd", @"pboard", @"cameraAgent", @"wifi", @"bluetooth" ]) {
            NSString *value = values[key] ?: @"UNKNOWN";
            [self.rows[key] setText:[self displayStatusValue:value] healthy:[value isEqualToString:@"ON"] known:![value isEqualToString:@"UNKNOWN"]];
        }

        NSString *cameraMagic = values[@"cameraMagic"] ?: @"UNKNOWN";
        NSString *cameraUsable = values[@"cameraUsable"] ?: @"UNKNOWN";
        NSString *cameraNearby = values[@"cameraNearby"] ?: @"UNKNOWN";
        NSString *cameraWired = values[@"cameraWired"] ?: @"UNKNOWN";
        [self.rows[@"cameraMagic"] setText:[self displayStatusValue:cameraMagic] healthy:[cameraMagic isEqualToString:@"1"] known:![cameraMagic isEqualToString:@"UNKNOWN"]];
        [self.rows[@"cameraUsable"] setText:[self displayStatusValue:cameraUsable] healthy:[cameraUsable isEqualToString:@"1"] known:![cameraUsable isEqualToString:@"UNKNOWN"]];
        [self.rows[@"cameraNearby"] setText:[self displayStatusValue:cameraNearby] healthy:[cameraNearby isEqualToString:@"1"] known:![cameraNearby isEqualToString:@"UNKNOWN"]];
        [self.rows[@"cameraWired"] setText:[self displayStatusValue:cameraWired] healthy:[cameraWired isEqualToString:@"0"] known:![cameraWired isEqualToString:@"UNKNOWN"]];

        NSString *proxy = values[@"proxy"] ?: @"UNKNOWN";
        [self.rows[@"proxy"] setText:[self displayStatusValue:proxy] healthy:NO known:NO];
        if (status != 0) {
            self.outputView.string = [NSString stringWithFormat:[self localized:@"statusExit"], status, output];
        }
    }];
}

- (void)repairHandoff {
    [self runActionNamed:[self localized:@"repairHandoff"] resource:@"repair-handoff"];
}

- (void)repairCamera {
    [self runActionNamed:[self localized:@"repairCamera"] resource:@"repair-camera"];
}

- (void)runActionNamed:(NSString *)name resource:(NSString *)resource {
    NSString *script = [self resourceScript:resource];
    if (script.length == 0) return;
    self.actionRunning = YES;
    for (NSButton *button in self.actionButtons) button.enabled = NO;
    NSString *language = self.chineseLanguage ? @"zh" : @"en";
    script = [NSString stringWithFormat:@"export CONTINUITY_REPAIR_LANG=%@\n%@", language, script];
    self.outputView.string = [NSString stringWithFormat:[self localized:@"runningFormat"], name];

    [CommandRunner runScript:script completion:^(NSString *output, int status) {
        self.actionRunning = NO;
        for (NSButton *button in self.actionButtons) button.enabled = YES;
        self.outputView.string = [NSString stringWithFormat:[self localized:@"finishedFormat"], name, status, output];
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
