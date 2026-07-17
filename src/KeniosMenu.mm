// =============================================
// KENIOS HAX - MENU UI (ĐA NGÔN NGỮ - iOS 16-26.5)
// =============================================

#import "KeniosCommon.h"
#import "KeniosConfig.h"
#import "KeniosKeyAuth.h"
#import "KeniosSkinChanger.h"
#import "KeniosAntiBanPro.h"

@interface KeniosMenuView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSDictionary *lang;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) CGPoint dragStart;
@end

@implementation KeniosMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = KENIOS_RGBA(10, 10, 15, 0.97);
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor cyanColor].CGColor;
        self.layer.shadowColor = [UIColor cyanColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 15;
        self.layer.shadowOpacity = 0.5;
        
        [self setupHeader];
        [self setupSections];
        [self setupTableView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 98, self.frame.size.width, 2);
    gradient.colors = @[(id)[UIColor cyanColor].CGColor, (id)[UIColor magentaColor].CGColor];
    [header.layer addSublayer:gradient];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.frame.size.width - 20, 25)];
    self.titleLabel.text = @"🔥 KENIOS HAX v4.5.0";
    self.titleLabel.textColor = [UIColor cyanColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:self.titleLabel];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, self.frame.size.width - 20, 20)];
    self.statusLabel.text = @"🛡 Anti-Ban: ACTIVE | 📱 iOS 16-26.5";
    self.statusLabel.textColor = [UIColor greenColor];
    self.statusLabel.font = [UIFont systemFontOfSize:10];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:self.statusLabel];
    
    self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 68, self.frame.size.width - 20, 20)];
    self.fpsLabel.text = @"📊 FPS: -- | 📡 Ping: --ms";
    self.fpsLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.8];
    self.fpsLabel.font = [UIFont systemFontOfSize:11];
    self.fpsLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:self.fpsLabel];
    
    [self addSubview:header];
}

- (void)setupSections {
    [self loadLanguage];
    
    self.sections = [NSMutableArray new];
    
    [self.sections addObject:@{
        @"title": self.lang[@"aimbot"] ?: @"🎯 AIMBOT",
        @"items": @[
            @{@"type":@"switch",@"label":self.lang[@"aimbot_enable"]?:@"Enable",@"key":@"aimbot_enabled",@"val":@(YES)},
            @{@"type":@"segment",@"label":self.lang[@"aimbot_target"]?:@"Target",@"key":@"aim_target",@"segs":@[self.lang[@"aimbot_head"]?:@"Head",self.lang[@"aimbot_neck"]?:@"Neck",self.lang[@"aimbot_chest"]?:@"Chest",self.lang[@"aimbot_body"]?:@"Body"],@"val":@(0)},
            @{@"type":@"slider",@"label":@"FOV",@"key":@"aim_fov",@"min":@(1),@"max":@(360),@"val":@(180)},
            @{@"type":@"slider",@"label":@"Smooth",@"key":@"aim_smooth",@"min":@(1),@"max":@(20),@"val":@(2)},
            @{@"type":@"slider",@"label":@"Max Distance",@"key":@"aim_distance",@"min":@(0),@"max":@(500),@"val":@(500)}
        ]
    }];
    
    [self.sections addObject:@{
        @"title": self.lang[@"esp"] ?: @"👁 ESP",
        @"items": @[
            @{@"type":@"switch",@"label":self.lang[@"esp_enable"]?:@"Enable",@"key":@"esp_enabled",@"val":@(YES)},
            @{@"type":@"switch",@"label":self.lang[@"esp_box"]?:@"Box",@"key":@"esp_box",@"val":@(YES)},
            @{@"type":@"switch",@"label":self.lang[@"esp_skeleton"]?:@"Skeleton",@"key":@"esp_skeleton",@"val":@(YES)},
            @{@"type":@"color",@"label":@"Box Color",@"key":@"esp_box_color",@"val":@"#FF0000"},
            @{@"type":@"color",@"label":@"Skeleton Color",@"key":@"esp_sk_color",@"val":@"#FFFFFF"}
        ]
    }];
    
    [self.sections addObject:@{
        @"title": self.lang[@"bomb"] ?: @"💣 BOMB ALERT",
        @"items": @[
            @{@"type":@"switch",@"label":self.lang[@"bomb_enable"]?:@"Enable",@"key":@"bomb_enabled",@"val":@(YES)},
            @{@"type":@"slider",@"label":@"Range (m)",@"key":@"bomb_range",@"min":@(10),@"max":@(200),@"val":@(50)},
            @{@"type":@"switch",@"label":self.lang[@"bomb_grenade"]?:@"Grenade",@"key":@"bomb_grenade",@"val":@(YES)},
            @{@"type":@"switch",@"label":self.lang[@"bomb_molotov"]?:@"Molotov",@"key":@"bomb_molotov",@"val":@(YES)},
            @{@"type":@"switch",@"label":self.lang[@"bomb_c4"]?:@"C4",@"key":@"bomb_c4",@"val":@(YES)}
        ]
    }];
    
    [self.sections addObject:@{
        @"title": self.lang[@"skins"] ?: @"👗 SKINS",
        @"items": @[
            @{@"type":@"slider",@"label":@"Weapon Skin (1-76)",@"key":@"skin_weapon",@"min":@(1),@"max":@(76),@"val":@(2)},
            @{@"type":@"slider",@"label":@"Character (100-154)",@"key":@"skin_char",@"min":@(100),@"max":@(154),@"val":@(101)},
            @{@"type":@"slider",@"label":@"Vehicle (200-293)",@"key":@"skin_vehicle",@"min":@(200),@"max":@(293),@"val":@(271)},
            @{@"type":@"slider",@"label":@"Effect (1-10)",@"key":@"skin_effect",@"min":@(1),@"max":@(10),@"val":@(7)},
            @{@"type":@"button",@"label":@"Apply All Best",@"action":@"apply_best"},
            @{@"type":@"button",@"label":@"Randomize",@"action":@"randomize"}
        ]
    }];
    
    [self.sections addObject:@{
        @"title": self.lang[@"anti_ban"] ?: @"🛡 ANTI-BAN",
        @"items": @[
            @{@"type":@"switch",@"label":@"Enable",@"key":@"antiband_enabled",@"val":@(YES)},
            @{@"type":@"segment",@"label":@"Mode",@"key":@"antiband_mode",@"segs":@[self.lang[@"anti_ban_safe"]?:@"Safe",self.lang[@"anti_ban_aggressive"]?:@"Aggressive",self.lang[@"anti_ban_auto"]?:@"Auto"],@"val":@(2)},
            @{@"type":@"slider",@"label":@"Miss %",@"key":@"antiband_miss",@"min":@(0),@"max":@(30),@"val":@(5)}
        ]
    }];
    
    [self.sections addObject:@{
        @"title": self.lang[@"settings"] ?: @"⚙ SETTINGS",
        @"items": @[
            @{@"type":@"segment",@"label":self.lang[@"language"]?:@"Language",@"key":@"language",@"segs":@[@"🇻🇳 VI",@"🇺🇸 EN",@"🇨🇳 ZH",@"🇷🇺 RU",@"🇸🇦 AR",@"🇪🇸 ES",@"🇧🇷 PT",@"🇯🇵 JA",@"🇰🇷 KO",@"🇹🇭 TH",@"🇮🇩 ID"],@"val":@(0)},
            @{@"type":@"button",@"label":@"Hide Menu",@"action":@"hide_menu",@"color":@"#FF4444"}
        ]
    }];
}

- (void)loadLanguage {
    NSString *langCode = [KeniosConfig sharedInstance].currentLanguage ?: @"vi";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    if (!path) path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KeniosHax/languages.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSDictionary *langs = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *lang = langs[@"languages"][langCode];
        self.lang = lang[@"translations"] ?: @{};
        self.titleLabel.text = self.lang[@"menu_title"] ?: @"🔥 KENIOS HAX v4.5.0";
    }
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.frame.size.width, self.frame.size.height - 100) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = KENIOS_RGBA(0, 255, 255, 0.2);
    [self addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return self.sections.count; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s { return [self.sections[s][@"items"] count]; }
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)s { return self.sections[s][@"title"]; }

- (void)tableView:(UITableView *)tv willDisplayHeaderView:(UIView *)v forSection:(NSInteger)s {
    UITableViewHeaderFooterView *h = (UITableViewHeaderFooterView *)v;
    h.textLabel.textColor = [UIColor cyanColor];
    h.textLabel.font = [UIFont boldSystemFontOfSize:13];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    NSDictionary *item = self.sections[ip.section][@"items"][ip.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = KENIOS_RGBA(8, 8, 15, 0.9);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = item[@"label"];
    
    if ([item[@"type"] isEqualToString:@"switch"]) {
        UISwitch *sw = [[UISwitch alloc] init];
        sw.on = [item[@"val"] boolValue];
        sw.onTintColor = [UIColor cyanColor];
        cell.accessoryView = sw;
    } else if ([item[@"type"] isEqualToString:@"segment"]) {
        UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:item[@"segs"]];
        seg.selectedSegmentIndex = [item[@"val"] integerValue];
        seg.tintColor = [UIColor cyanColor];
        seg.frame = CGRectMake(0, 0, 200, 30);
        cell.accessoryView = seg;
    } else if ([item[@"type"] isEqualToString:@"slider"]) {
        UISlider *sl = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        sl.minimumValue = [item[@"min"] floatValue];
        sl.maximumValue = [item[@"max"] floatValue];
        sl.value = [item[@"val"] floatValue];
        sl.tintColor = [UIColor cyanColor];
        cell.accessoryView = sl;
    } else if ([item[@"type"] isEqualToString:@"color"]) {
        UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        colorPreview.backgroundColor = [UIColor redColor];
        colorPreview.layer.cornerRadius = 15;
        colorPreview.layer.borderWidth = 2;
        colorPreview.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.accessoryView = colorPreview;
    } else if ([item[@"type"] isEqualToString:@"button"]) {
        cell.textLabel.textColor = item[@"color"] ? [UIColor redColor] : [UIColor cyanColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    [tv deselectRowAtIndexPath:ip animated:YES];
    NSDictionary *item = self.sections[ip.section][@"items"][ip.row];
    NSString *action = item[@"action"];
    
    if ([action isEqualToString:@"apply_best"]) [[KeniosSkinChanger sharedInstance] applyAllBestSkins];
    else if ([action isEqualToString:@"randomize"]) [[KeniosSkinChanger sharedInstance] randomizeSkins];
    else if ([action isEqualToString:@"hide_menu"]) [[KeniosMenu sharedInstance] hideMenu];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint t = [gesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}
@end

@interface KeniosMenu ()
@property (nonatomic, strong) KeniosMenuView *menuView;
@end

@implementation KeniosMenu

+ (instancetype)sharedInstance {
    static KeniosMenu *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosMenu alloc] init]; }); return i;
}

- (void)showMenu {
    if (self.menuView) [self.menuView removeFromSuperview];
    self.menuView = [[KeniosMenuView alloc] initWithFrame:CGRectMake(10, 120, 320, 500)];
    self.menuView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.menuView];
    [UIView animateWithDuration:0.3 animations:^{ self.menuView.alpha = 1; }];
}

- (void)hideMenu {
    [UIView animateWithDuration:0.3 animations:^{ self.menuView.alpha = 0; } completion:^(BOOL f) { [self.menuView removeFromSuperview]; self.menuView = nil; }];
}

- (void)updateMenuStatus {
    if (self.menuView) {
        self.menuView.fpsLabel.text = [NSString stringWithFormat:@"📊 FPS: %d | 📡 Ping: %dms | 📱 iOS %@", [[KeniosFPS sharedInstance] getCurrentFPS], 0, g_iosVersion ?: @"--"];
    }
}
@end
