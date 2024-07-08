//
//  FFTextView.h
//  FBSnapshotTestCase
//
//  Created by 四五20 on 2022/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FFTextConfig, FFTextFormatter;

@interface FFTextView : UITextView

- (instancetype)initWithPlaceholder:(NSString * __nullable)placeholder;
- (instancetype)initWithPlaceholder:(NSString * __nullable)placeholder
                              config:(FFTextConfig * __nullable)config;

/// 用于监听字符串变化
@property (nonatomic, copy) NSString *obs_text;

@property (nonatomic, strong) FFTextFormatter *formatter;

@property (nonatomic, assign) NSUInteger maxLength;

/// 计算字符串长度时 是否包含换行符(默认为NO)
@property (nonatomic, assign) BOOL includeLineBreak;

@end

@interface NSString (EHTextView)

/// 不包含换行符的字符串长度
@property (nonatomic, assign, readonly) NSUInteger no_line_break_length;

- (NSString *)conversionFormatterOccurrencesOfString:(NSString *)target WithString:(NSString *)string;

@end

/// 仅在设置maxLength属性后, 此配置才有效果
@interface FFTextConfig : NSObject

/// 默认透明
@property (nonatomic, strong) UIColor *backgroundColor;
/// 默认黑色
@property (nonatomic, strong) UIColor *textColor;
/// 默认14
@property (nonatomic, strong) UIFont *font;
/// 默认30
@property (nonatomic, assign) CGFloat height;

@end

/// 提示输入文本信息格式
/// eg: C#T     CC##TT      C$$$$TTT
@interface FFTextFormatter : NSFormatter

- (NSString *)stringFromConfig:(FFTextConfig *)config;

typedef NS_ENUM(NSUInteger, FFTextFormatterStyle) {
    FFTextFormatterNoStyle = 0,         //T
    FFTextFormatterFullStyle,           //C/T
    FFTextFormatterCustomStyle          //自定义(必须实现configFormat)
};

/// C表示当前字数占位符
/// T表示总计字数占位符
@property (nonatomic, copy) NSString *configFormat;
@property (nonatomic) FFTextFormatterStyle configStyle;

@end

NS_ASSUME_NONNULL_END


/// TODO
/// 限制输入类型(小写字母、大写字母、数字、汉字和特殊符号)
/// rangeOfComposedCharacterSequenceAtIndex 截取表情字符是会将表情当做一个连续字符
/// [^\\w\\s]+  匹配特殊字符并且非空白符(空格、制表符、Tab)
/// \\d+ 匹配数字
/// [a-z]+ 匹配小写字母
/// [A-Z]+ 匹配大写字母
/// [^\\u4e00-\\u9fa5]+ 匹配汉字
/// emoji
/// review
