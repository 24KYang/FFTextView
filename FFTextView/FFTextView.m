//
//  FFTextView.m
//  FBSnapshotTestCase
//
//  Created by 四五20 on 2022/3/24.
//

#import "FFTextView.h"

#import <Masonry/Masonry.h>

@interface FFTextView ()
<
    UITextViewDelegate
>

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, strong) UIView *alertBackView;
@property (nonatomic, strong) UILabel *alertLabel;

@end

@implementation FFTextView
{
    FFTextConfig *_config;
    NSString *_placeholder;
    BOOL _hasPlaceholder;
}

#pragma mark ---- Init
- (instancetype)initWithPlaceholder:(NSString *)placeholder {
    return [[FFTextView alloc] initWithPlaceholder:placeholder config:nil];
}

- (instancetype)initWithPlaceholder:(NSString *)placeholder config:(FFTextConfig * __nullable)config {
    if (self = [super init]) {
        _placeholder = placeholder;
        _config = config;
        self.delegate = self;

        if (config) _formatter = FFTextFormatter.new;
        if (placeholder.length > 0) _hasPlaceholder = YES;
            
        [self loadCountUI];
        [self loadPlaceholderUI];
    }
    return self;
}

#pragma mark ---- Public

#pragma mark ---- Event Response

#pragma mark - Delegate - <UITextViewDelegate>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (!position && self.maxLength > 0 && text.length == 1) {
        return (self.includeLineBreak ? string.length : string.no_line_break_length) <= self.maxLength;
    }
    if (!self.includeLineBreak && self.maxLength > 0) {
        //换行符不记为字符串长度时, 字符串长度输入限制后, 不允许继续输入
        if ([text isEqualToString:@"\n"] && string.no_line_break_length >= self.maxLength) return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _placeholderLabel.hidden = textView.hasText;
    if (self.maxLength <= 0) return;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    NSString *string = textView.text;
    if (!position && (self.includeLineBreak ? string.length : string.no_line_break_length) > self.maxLength) {
        NSUInteger location = textView.selectedRange.location;
        __block NSUInteger limit = 0;
        if (!self.includeLineBreak) {
            NSString *suff_string = [string substringWithRange:NSMakeRange(location, string.length - location)];
            __block NSUInteger length = self.maxLength - suff_string.no_line_break_length;
            NSString *pre_string = [string substringWithRange:NSMakeRange(0, location)];
            NSArray <NSString *>*pre_array = [pre_string componentsSeparatedByString:@"\n"];
            __block NSString *result_string = @"";
            [pre_array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *str = [NSString stringWithString:obj];
                if (str.length >= length) {
                    //判断超出字符串限制的位置是否为emoji中间, 是中间则提前一位, 截取字符串
                    NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:length];
                    if (range.location != NSNotFound) {
                        length -= 1;
                    }
                    str = [str substringToIndex:length];
                    result_string = [result_string stringByAppendingString:str];
                    *stop = YES;
                }else {
                    if (str.length > 0) result_string = [result_string stringByAppendingString:str];
                    length -= str.length;
                }
                if (idx != pre_array.count - 1) result_string = [result_string stringByAppendingString:@"\n"];
            }];
            string = [NSString stringWithFormat:@"%@%@", result_string, suff_string];
            limit = pre_string.length - result_string.length;
        }else {
            limit = string.length - self.maxLength;
            //判断超出字符串限制的位置是否为emoji中间, 是中间则提前一位, 截取字符串
            NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:location - limit];
            if (range.location != NSNotFound) {
                limit += 1;
            }
            string = [string stringByReplacingCharactersInRange:NSMakeRange(location - limit, limit) withString:@""];
        }
        [textView setText:string];
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView setSelectedRange:NSMakeRange(location - limit, 0)];
        });
    }else {
        ///iOS 16后的手机没显示问题 还按照原来逻辑处理
        if (@available(iOS 16.0, *)) [textView setText:string];
    }
    [self setObs_text:string];
    if (_config) {
        [_config setValue:@(MIN(_maxLength, (self.includeLineBreak ? string.length : string.no_line_break_length))) forKey:@"_current_count"];
        _alertLabel.text = [self.formatter stringFromConfig:_config];
    }
}

#pragma mark ---- Private Methods
- (void)setText:(NSString *)text {
    [super setText:text];
    [self setObs_text:text];
    _placeholderLabel.hidden = text.length > 0;
    if (_config) {
        [_config setValue:@(MIN(_maxLength, (self.includeLineBreak ? text.length : text.no_line_break_length))) forKey:@"_current_count"];
        _alertLabel.text = [self.formatter stringFromConfig:_config];
    }
}
#pragma mark ---- UI
- (void)loadPlaceholderUI {
    if (!_hasPlaceholder) return;
    _placeholderLabel = UILabel.new;
    _placeholderLabel.font = self.font ? : [UIFont systemFontOfSize:14];
    _placeholderLabel.backgroundColor = UIColor.clearColor;
    _placeholderLabel.textColor = UIColor.lightGrayColor;
    _placeholderLabel.textAlignment = self.textAlignment;
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.text = _placeholder;
    
    [self addSubview:_placeholderLabel];
}

- (void)loadCountUI {
    if (!_config) return;
    
    self.contentInset = UIEdgeInsetsMake(0, 0, _config.height, 0);
    
    _alertBackView = UIView.new;
    _alertBackView.backgroundColor = _config.backgroundColor;
    [self addSubview:_alertBackView];

    _alertLabel = UILabel.new;
    _alertLabel.font = _config.font;
    _alertLabel.textColor = _config.textColor;
    _alertLabel.textAlignment = NSTextAlignmentRight;
    [_alertBackView addSubview:_alertLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_hasPlaceholder) {
        [_placeholderLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(self.textContainerInset.left + self.textContainer.lineFragmentPadding);
            make.top.offset(self.textContainerInset.top);
            make.width.mas_equalTo(CGRectGetWidth(self.frame) - self.textContainerInset.left - self.textContainer.lineFragmentPadding * 2 - self.textContainerInset.right);
            //获取占位符单行高度
            CGSize size = [_placeholderLabel.text sizeWithAttributes:@{NSFontAttributeName : _placeholderLabel.font}];
            //计算整体可显示几行 向下取整 获取占位符最大高度
            //做小于等于约束
            make.height.lessThanOrEqualTo(@(size.height * floor((CGRectGetHeight(self.frame) - self.contentInset.bottom - self.textContainerInset.top) / size.height)));
        }];
    }
    if (_config) {
        [_alertBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(0);
            make.top.offset(CGRectGetHeight(self.frame) - _config.height + self.contentOffset.y);
            make.width.mas_equalTo(CGRectGetWidth(self.frame));
            make.height.mas_equalTo(_config.height);
        }];

        [_alertLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(0, self.textContainer.lineFragmentPadding, 0, self.textContainer.lineFragmentPadding));
        }];
    }
}
#pragma mark ---- Setter & Getter
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    if (_placeholderLabel) _placeholderLabel.font = font;
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    if (_placeholderLabel) _placeholderLabel.textAlignment = textAlignment;
}
- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    if ([delegate isEqual:self]) [super setDelegate:delegate];
}
- (void)setMaxLength:(NSUInteger)maxLength {
    _maxLength = maxLength;
    if (_config) {
        [_config setValue:@(maxLength) forKey:@"_total_count"];
        _alertLabel.text = [self.formatter stringFromConfig:_config];
    }
}
- (void)setFormatter:(FFTextFormatter *)formatter {
    _formatter = formatter;
    if (_config) _alertLabel.text = [formatter stringFromConfig:_config];
}
#pragma mark ---- Other
- (void)dealloc {
    NSLog(@"%@", self.class);
}

@end

@implementation NSString (EHTextView)

- (NSUInteger)no_line_break_length {
    NSString *string = [NSString stringWithString:self];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return string.length;
}

- (NSString *)conversionFormatterOccurrencesOfString:(NSString *)target WithString:(NSString *)string {
    if ([target isEqualToString:string]) return self;
    NSString *regex = [NSString stringWithFormat:@"[%@]{1,}", target];
    NSRange r;
    NSMutableString *newString = [NSMutableString stringWithString:self];
    
    BOOL flag = false;
    
    while (flag == false) {
        
        r = [newString rangeOfString:regex options:NSRegularExpressionSearch];
        if (r.location != NSNotFound) {
            [newString replaceCharactersInRange:r withString:string];
        } else {
            flag = true;
        }
    }
    return newString;
}

@end

@interface FFTextConfig()

@property (nonatomic, assign) NSUInteger current_count;
@property (nonatomic, copy) NSString *separator;
@property (nonatomic, assign) NSUInteger total_count;

@end

@implementation FFTextConfig

- (instancetype)init {
    if (self = [super init]) {
        self.current_count = 0;
        self.separator = @"/";
        self.total_count = 0;
        
        self.backgroundColor = UIColor.clearColor;
        self.textColor = UIColor.blackColor;
        self.font = [UIFont systemFontOfSize:14];
        self.height = 30.f;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"cur：%@\nsep：%@\ntotal：%@\nbackgroundColor：%@\ntextColor：%@\nfont：%@\nheight：%@", @(self.current_count).stringValue, self.separator, @(self.total_count).stringValue, self.backgroundColor, self.textColor, self.font, @(self.height).stringValue];
}

@end

@implementation FFTextFormatter

- (instancetype)init {
    if (self = [super init]) {
        self.configStyle = FFTextFormatterFullStyle;
    }
    return self;
}

- (NSString *)stringFromConfig:(FFTextConfig *)config {
    if (!config) return @"";
    if (self.configFormat.length == 0) return @"";
    NSString *string = [self.configFormat conversionFormatterOccurrencesOfString:@"C" WithString:@(config.current_count).stringValue];
    string = [string conversionFormatterOccurrencesOfString:@"T" WithString:@(config.total_count).stringValue];
    if (self.configStyle == FFTextFormatterFullStyle) string = [string conversionFormatterOccurrencesOfString:@"/" WithString:config.separator];
    return string;
}

- (void)setConfigStyle:(FFTextFormatterStyle)configStyle {
    _configStyle = configStyle;
    if (configStyle == FFTextFormatterNoStyle) {
        _configFormat = @"C";
    }else if (configStyle == FFTextFormatterFullStyle) {
        _configFormat = @"C/T";
    }
}

- (void)setConfigFormat:(NSString *)configFormat {
    _configFormat = configFormat;
    _configStyle = FFTextFormatterCustomStyle;
}

@end
