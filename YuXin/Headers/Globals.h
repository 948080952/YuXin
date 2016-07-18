//
//  Globals.h
//  YuXin
//
//  Created by Dai Pei on 16/7/16.
//  Copyright © 2016年 Dai Pei. All rights reserved.
//

#ifndef Globals_h
#define Globals_h

//reuse identifier
#define DPArticleTitleCellReuseIdentifier           @"article_cell"
#define DPArticleDetailCellReuseIdentifier          @"article_detail"
#define DPArticleCommentCellReuseIdentifier         @"article_comment"


//color parameter
#define DPTextColorParameterBlack                   @"30"
#define DPTextColorParameterRed                     @"31"
#define DPTextColorParameterGreen                   @"32"
#define DPTextColorParameterYellow                  @"33"
#define DPTextColorParameterDarkBlue                @"34"
#define DPTextColorParameterPink                    @"35"
#define DPTextColorParameterLightBlue               @"36"
#define DPTextColorParameterWhite                   @"37"

//regular express
#define DPRegExColor                                @".{1}[0-9]{0,2}[;[0-9]{1,2}]*m"
#define DPRegExTime1                                @"[0-9]{4}年[0-9]{2}月[0-9]{2}日[0-9]{2}:[0-9]{2}:[0-9]{2}"
#define DPRegExTime2                                @"\\w{3}\\s{1,2}\\d{1,2} \\d{2}:\\d{2}:\\d{2} \\d{4}"
#define DPRegExName                                 @" .+[(.+)]{1}"
#define DPRegExReply                                @"【 在 .+"
#define DPRegExHeader                               @"发信站:"
#define DPRegExFooter                               @"※ "


#endif /* Globals_h */
