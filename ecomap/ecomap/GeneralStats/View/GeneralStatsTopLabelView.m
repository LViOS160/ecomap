//
//  GeneralStatsTopLabelView.m
//  ecomap
//
//  Created by ohuratc on 16.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "GeneralStatsTopLabelView.h"

#define TOP_LABEL_STANDART_HEIGHT 128
#define OFFSET_BETWEEN_NUMBER_AND_NAME 3

@implementation GeneralStatsTopLabelView

#pragma mark - Properties

- (void)setNumberOfInstances:(NSUInteger)numberOfInstances
{
    _numberOfInstances = numberOfInstances;
    [self setNeedsDisplay];
}

- (void)setNameOfInstances:(NSString *)nameOfInstances
{
    _nameOfInstances = nameOfInstances;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code    
    [self drawLabel];
}

- (void)drawLabel
{
    //NSLog(@"Fonts: %@", [UIFont familyNames]);
    
    /*NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)

    {
     
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
     
        fontNames = [[NSArray alloc] initWithArray:
                
                     [UIFont fontNamesForFamilyName:
              
                      [familyNames objectAtIndex:indFamily]]];
     
        for (indFont=0; indFont<[fontNames count]; ++indFont)
    
        {
      
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
       
        }
     
    }*/
    
    // Drawing number of instances
    
    UIFont *numberFont = [UIFont fontWithName:@"OpenSans-Light" size:76.0f];
    
    NSAttributedString *numberText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", self.numberOfInstances]
                                                                     attributes:@{ NSFontAttributeName : numberFont}];
    
    CGRect numberTextBounds;
    numberTextBounds.size = [numberText size];
    numberTextBounds.origin = CGPointMake((self.bounds.size.width - numberTextBounds.size.width) / 2, 0);
    [numberText drawInRect:numberTextBounds];
    
    // Drawing name of instances
    
    UIFont *nameFont = [UIFont fontWithName:@"OpenSans-Semibold" size:20.0f];
    
    UIColor *fontColor = [UIColor lightGrayColor];
    
    NSAttributedString *nameText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.nameOfInstances]
                                                                   attributes:@{ NSFontAttributeName : nameFont,
                                                                                 NSForegroundColorAttributeName: fontColor}];
    
    CGRect nameTextBounds;
    nameTextBounds.size = [nameText size];
    nameTextBounds.origin = CGPointMake((self.bounds.size.width - nameTextBounds.size.width) / 2, numberTextBounds.size.height);
    [nameText drawInRect:nameTextBounds];
}

#pragma mark - Initialization

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        // Initialization code
        [self setup];
    }
    
    return self;
}

@end
