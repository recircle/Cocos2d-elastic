//
//  FFPage.m
//  MrWolf
//
//  Created by dennis on 20/10/14.
//  Copyright 2014 Foofoo. All rights reserved.
//


#import "FFElastic.h"


@implementation FFElastic
{
    int screenWidth;
    int screenHeight;
    
    CCSprite9Slice* dotSprite;
    float rotAngle;
}


+ (FFElastic *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    self.userInteractionEnabled = YES;
    
    CGSize size = [[CCDirector sharedDirector] viewSize];
    screenWidth = size.width;
    screenHeight = size.height;
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]];
    [self addChild:background];
    
    [self makeElasticDot];
    
    return self;
    
}


-(void)makeElasticDot
{
    CCShader *shader = [[CCShader alloc] initWithFragmentShaderSource:CC_GLSL(
      precision mediump float;
      
      vec2 v_texCoord = cc_FragTexCoord1;
      uniform float u_normalizedStretch;
      
      void main() {
          float xNormalizedPreserve = 0.2;
          float xNormalizedProgress = clamp((v_texCoord.x - xNormalizedPreserve) / (1.0 - 2.0*xNormalizedPreserve), 0.0, 1.0);
          float yStretch = -sin(3.1415 * xNormalizedProgress) * u_normalizedStretch;
          float yCoordinate = 0.5 + ((v_texCoord.y - 0.5) * (1.0 - yStretch));
          gl_FragColor = texture2D(cc_MainTexture, vec2(v_texCoord.x, yCoordinate));
      }
      
    )];
    
    dotSprite = [CCSprite9Slice spriteWithImageNamed:@"blob.png"];
    dotSprite.shader = shader;
    dotSprite.position = ccp(200, 200);
    dotSprite.anchorPoint = ccp(0, 0.5);
    dotSprite.margin = 0.2;
    dotSprite.contentSize = CGSizeMake(500, 200);
    dotSprite.scale = 0.25;
    dotSprite.visible = NO;
    [self addChild:dotSprite];
    
}

-(float)makeAngle:(CGPoint)pos1 touch:(CGPoint)pos2
{
    float theta = atan((pos1.y-pos2.y)/(pos1.x-pos2.x))*180*0.31;
    
    if(pos1.y - pos2.y > 0)
    {
        if(pos1.x - pos2.x < 0)
            rotAngle = (0-theta);
        else if(pos1.x - pos2.x > 0)
            rotAngle = (180-theta);
    }
    else if(pos1.y - pos2.y < 0)
    {
        if(pos1.x - pos2.x < 0) rotAngle = (0-theta);
        else if(pos1.x - pos2.x > 0) rotAngle = (180-theta);
    }
    
    return rotAngle;
    
}

#pragma mark - Touch

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    dotSprite.contentSize = CGSizeMake(0, 200);
    dotSprite.position = location;
    
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    float distance = sqrt(pow(dotSprite.position.x - location.x, 2.0) + pow(dotSprite.position.y - location.y, 2.0));
    float scale = distance / screenWidth*2;
    
    if (distance>50)  dotSprite.visible = YES;
    else dotSprite.visible = NO;
    
    dotSprite.rotation=[self makeAngle:dotSprite.position touch:location];
    dotSprite.shaderUniforms[@"u_normalizedStretch"] = [NSNumber numberWithFloat:scale*2];
    dotSprite.contentSize = CGSizeMake(distance*4, 200);
    dotSprite.opacity = 1;
    
//    CCLOG(@"%f", distance);
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    dotSprite.visible = NO;
    dotSprite.shaderUniforms[@"u_normalizedStretch"] = [NSNumber numberWithFloat:0];
    dotSprite.contentSize = CGSizeMake(500, 200);
    
    
    
}


























@end
