//
//  FavoriteTableViewCell.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/30.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "FavoriteTableViewCell.h"
@implementation FavoriteTableViewCell

// 初始化cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    if (self) {
        
        // 图片
        self.imgView = [UIImageView new];
        [self addSubview:self.imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.left.equalTo(self).offset(10);
            make.width.mas_equalTo(50);
            
        }];
        
        
        // 标题
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerY.equalTo(self.imgView.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-10);
            make.left.equalTo(self.imgView.mas_right).offset(10);
            make.height.mas_equalTo(30);
            
        }];
        
        
    }
    
    return self;
}



- (void)setFavoriteModel:(FavoriteModel *)favoriteModel
{

    if (_favoriteModel != favoriteModel) {
        
        _favoriteModel = favoriteModel;
        
        _titleLabel.text = favoriteModel.titleStr;
        
        [_imgView sd_setImageWithURL:[NSURL URLWithString:favoriteModel.imgUrl]];
    }


}






- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
