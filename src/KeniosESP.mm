#import "KeniosCommon.h"
#import "KeniosOffsets.h"
#import "KeniosConfig.h"

@interface KeniosESPOverlay : UIView
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) NSMutableArray *bombs;
@property (nonatomic, strong) KeniosESPConfig *config;
@property (nonatomic, assign) KeniosMatrix4x4 viewMatrix;
@property (nonatomic, assign) CGFloat sw, sh;
@end

@implementation KeniosESPOverlay

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) { self.backgroundColor = [UIColor clearColor]; self.userInteractionEnabled = NO; self.players = [NSMutableArray new]; self.bombs = [NSMutableArray new]; self.config = [KeniosConfig sharedInstance].esp; }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (!self.config.enabled) return;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) return;
    
    for (NSValue *v in self.players) {
        KeniosPlayer *p = (KeniosPlayer *)[v pointerValue];
        if (!p || !p->isAlive) continue;
        [self renderPlayer:p ctx:ctx];
    }
    for (NSValue *v in self.bombs) {
        KeniosBomb *b = (KeniosBomb *)[v pointerValue];
        if (b->isActive) [self renderBomb:b ctx:ctx];
    }
    if (self.config.fovCircleEnabled) [self drawFOVCircle:ctx];
    if (self.config.crosshairEnabled) [self drawCrosshair:ctx];
}

- (void)renderPlayer:(KeniosPlayer *)p ctx:(CGContextRef)ctx {
    KeniosVector2 head = [self w2s:p->head], pelvis = [self w2s:p->pelvis];
    if (head.x < 0 || pelvis.x < 0) return;
    CGFloat bh = pelvis.y - head.y, bw = bh * 0.4f, bx = head.x - bw/2, by = head.y;
    UIColor *color = p->isTeammate ? self.config.boxColorTeam : p->isBot ? self.config.boxColorBot : self.config.boxColorVisible;
    
    if (self.config.boxEnabled) { CGContextSetStrokeColorWithColor(ctx, color.CGColor); CGContextSetLineWidth(ctx, self.config.boxThickness); CGContextStrokeRect(ctx, CGRectMake(bx, by, bw, bh)); }
    if (self.config.skeletonEnabled) { CGContextSetStrokeColorWithColor(ctx, self.config.skeletonColorVisible.CGColor); CGContextSetLineWidth(ctx, self.config.skeletonThickness);
        KeniosVector2 neck = [self w2s:p->neck], chest = [self w2s:p->chest];
        CGPoint lines[] = {CGPointMake(head.x,head.y),CGPointMake(neck.x,neck.y), CGPointMake(neck.x,neck.y),CGPointMake(chest.x,chest.y), CGPointMake(chest.x,chest.y),CGPointMake(pelvis.x,pelvis.y)};
        CGContextStrokeLineSegments(ctx, lines, 6);
    }
    if (self.config.healthBarEnabled) { CGFloat hbX = bx - 8, hp = p->health/100.0f; CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.5].CGColor); CGContextFillRect(ctx, CGRectMake(hbX, by, 3, bh)); UIColor *hc = hp > 0.6 ? [UIColor greenColor] : hp > 0.3 ? [UIColor yellowColor] : [UIColor redColor]; CGContextSetFillColorWithColor(ctx, hc.CGColor); CGContextFillRect(ctx, CGRectMake(hbX, by+bh*(1-hp), 3, bh*hp)); }
    if (self.config.nameEnabled) { NSDictionary *a = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.config.nameFontSize], NSForegroundColorAttributeName:self.config.nameColor}; [[NSString stringWithUTF8String:p->name] drawAtPoint:CGPointMake(head.x-30, head.y-15) withAttributes:a]; }
    if (self.config.distanceEnabled) { NSDictionary *a = @{NSFontAttributeName:[UIFont systemFontOfSize:11], NSForegroundColorAttributeName:self.config.distanceColor}; [[NSString stringWithFormat:@"%.0fm", p->distance] drawAtPoint:CGPointMake(head.x-20, pelvis.y+5) withAttributes:a]; }
}

- (void)renderBomb:(KeniosBomb *)b ctx:(CGContextRef)ctx {
    KeniosVector2 sp = [self w2s:b->position];
    if (sp.x < 0) return;
    UIColor *bc = b->type == 1 ? [UIColor redColor] : b->type == 2 ? [UIColor orangeColor] : [UIColor yellowColor];
    CGContextSetStrokeColorWithColor(ctx, bc.CGColor); CGContextSetLineWidth(ctx, 2);
    CGFloat r = b->radius / 10.0f;
    CGContextAddArc(ctx, sp.x, sp.y, r, 0, 2*M_PI, 0); CGContextStrokePath(ctx);
    NSString *t = [NSString stringWithFormat:@"%.1fs", b->timeToExplode];
    [t drawAtPoint:CGPointMake(sp.x-15, sp.y-20) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:[UIColor redColor]}];
}

- (void)drawFOVCircle:(CGContextRef)ctx {
    CGContextSetStrokeColorWithColor(ctx, [self.config.fovCircleColor colorWithAlphaComponent:self.config.fovCircleAlpha].CGColor);
    CGContextSetLineWidth(ctx, 2); CGContextAddArc(ctx, self.sw/2, self.sh/2, self.config.fovCircleRadius, 0, 2*M_PI, 0); CGContextStrokePath(ctx);
}

- (void)drawCrosshair:(CGContextRef)ctx {
    CGFloat cx = self.sw/2, cy = self.sh/2, s = self.config.crosshairSize;
    CGContextSetStrokeColorWithColor(ctx, self.config.crosshairColor.CGColor); CGContextSetLineWidth(ctx, 1);
    CGContextMoveToPoint(ctx, cx-s, cy); CGContextAddLineToPoint(ctx, cx+s, cy);
    CGContextMoveToPoint(ctx, cx, cy-s); CGContextAddLineToPoint(ctx, cx, cy+s); CGContextStrokePath(ctx);
}

- (KeniosVector2)w2s:(KeniosVector3)wp {
    KeniosVector2 sp = {-1,-1};
    float w = self.viewMatrix.m[3][0]*wp.x + self.viewMatrix.m[3][1]*wp.y + self.viewMatrix.m[3][2]*wp.z + self.viewMatrix.m[3][3];
    if (w < 0.01f) return sp;
    sp.x = (self.viewMatrix.m[0][0]*wp.x + self.viewMatrix.m[0][1]*wp.y + self.viewMatrix.m[0][2]*wp.z + self.viewMatrix.m[0][3]) / w;
    sp.y = (self.viewMatrix.m[1][0]*wp.x + self.viewMatrix.m[1][1]*wp.y + self.viewMatrix.m[1][2]*wp.z + self.viewMatrix.m[1][3]) / w;
    sp.x = (sp.x*0.5f+0.5f)*self.sw; sp.y = (1.0f-sp.y*0.5f-0.5f)*self.sh;
    return sp;
}
@end

@interface KeniosESP ()
@property (nonatomic, strong) KeniosESPOverlay *overlay;
@end

@implementation KeniosESP

+ (instancetype)sharedInstance {
    static KeniosESP *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosESP alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat w = [UIScreen mainScreen].bounds.size.width, h = [UIScreen mainScreen].bounds.size.height;
        self.overlay = [[KeniosESPOverlay alloc] initWithFrame:CGRectMake(0,0,w,h)];
        self.overlay.sw = w; self.overlay.sh = h;
        dispatch_async(dispatch_get_main_queue(), ^{ [[UIApplication sharedApplication].keyWindow addSubview:self.overlay]; });
    }
    return self;
}

- (void)renderESP {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t lc = [self getLocalController];
    if (!lc) return;
    uint64_t cm = *(uint64_t *)(lc + o.PlayerCameraManager);
    if (!cm) return;
    self.overlay.viewMatrix = *(KeniosMatrix4x4 *)(cm + o.ViewMatrix);
    dispatch_async(dispatch_get_main_queue(), ^{ [self.overlay setNeedsDisplay]; });
}

- (uint64_t)getLocalController {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t gi = *(uint64_t *)(g_GWorld + o.OwningGameInstance);
    if (!gi) return 0;
    uint64_t lp = *(uint64_t *)(gi + 0x38);
    return lp ? *(uint64_t *)lp : 0;
}

- (void)updatePlayers:(NSMutableArray *)p { self.overlay.players = p; }
- (void)updateBombs:(NSMutableArray *)b { self.overlay.bombs = b; }
- (void)updateConfig:(KeniosESPConfig *)c { self.overlay.config = c; }
@end
