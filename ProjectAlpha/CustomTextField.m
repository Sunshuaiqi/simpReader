//
//  CustomTextField.m
//  IndefiniteProgram
//
//  Created by lanou3g on 10/12/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import "CustomTextField.h"
#import <Masonry.h>

@implementation CustomTextField

- (instancetype)initWithFrame:(CGRect)frame Name:(NSString *)name color:(UIColor *)color{
    self = [super initWithFrame:frame];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.bounds) - _nameLabel.frame.size.height / 2, CGRectGetWidth(self.frame), 30)];                                                         // 占位名
        _nameLabel.text = name;
        _nameLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        [self addSubview:_nameLabel];
        
        _bottomLine = [UIView new];                             // 底部线段
        _bottomLine.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:_bottomLine];
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make){
            make.height.mas_equalTo(1);
            make.width.equalTo(self.mas_width);
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
        }];
        
        _bottomLineAnimation = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds)-2, 0, 2)];            // 底部线段动画
        _bottomLineAnimation.backgroundColor = color;
        [self addSubview:_bottomLineAnimation];
        
    }
    return self;
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
        //return CGRectInset( bounds, 10 , 0 );
    
    CGRect inset = CGRectMake(bounds.origin.x, CGRectGetMaxY(bounds) - 45, bounds.size.width -10, bounds.size.height);
    return inset;
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
        //return CGRectInset(bounds, 50, 0);
    CGRect inset = CGRectMake(bounds.origin.x, CGRectGetMaxY(bounds) - 45, bounds.size.width -10, bounds.size.height);//更好理解些
    
    return inset;
}

+(CustomTextField *) textFiledWithFrame:(CGRect)frame Name:(NSString *)name color:(UIColor *)color{
    
    return [[CustomTextField alloc] initWithFrame:frame Name:name color:color];;
}

@end
