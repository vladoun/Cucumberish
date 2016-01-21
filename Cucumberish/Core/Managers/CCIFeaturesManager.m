//
//  CCIFeaturesManager.m

//
//  Created by Ahmed Ali on 02/01/16.
//  Copyright © 2016 Ahmed Ali. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CCIFeaturesManager.h"
#import "GHParser+Extensions.h"
#import "NSObject+Dictionary.h"
#import "CCIFeature.h"
#import "CCIStepsManager.h"
#import "Cucumberish.h"
#import "CCIStepDefinition.h"

static CCIFeaturesManager * instance = nil;

@interface CCIFeaturesManager()

@property NSMutableDictionary * featureClassMap;

@end

@implementation CCIFeaturesManager
+ (instancetype)instance {
    
    @synchronized(self) {
        if(instance == nil){
            instance = [[CCIFeaturesManager alloc] init];
        }
    }
    return instance;
}


- (instancetype) init
{
    self = [super init];
    self.featureClassMap = [@{} mutableCopy];
    return self;
}
- (void)parseFeatureFiles:(NSArray *)featureFiles withTags:(NSArray *)tags
{
    NSMutableArray * parsedFeatures = [NSMutableArray array];
    
    
    GHParser * featureParser = [[GHParser alloc] init];
    for (NSURL * filePath in featureFiles) {
        NSString * content = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
        if([content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
            continue;
        }
        id result = [featureParser parseContent:content];
        
        if(result){
            NSMutableDictionary * featureData = [[result dictionary] mutableCopy];
            
            NSString * localPath = [[filePath.absoluteString stringByReplacingOccurrencesOfString:[[NSBundle bundleForClass:[self class]] bundlePath] withString:@""] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            featureData[@"filePath"] = localPath;
            CCIFeature * feature = [[CCIFeature alloc] initWithDictionary:featureData];
  
            
            if(tags == nil || tags.count == 0){
                [parsedFeatures addObject:feature];
            }else{
                for (CCITag * featureTag in feature.tags) {
                    if ([tags containsObject:featureTag.name]) {
                        [parsedFeatures addObject:feature];
                        break;
                    }
                }
            }
            
        }
    }
    
    self.features = parsedFeatures;
}



- (void)setClass:(Class)klass forFeature:(CCIFeature *)feature
{
    NSString * className = NSStringFromClass(klass);
    self.featureClassMap[className] = feature;
}

- (CCIFeature *)getFeatureForClass:(Class)klass
{
    NSString * className = NSStringFromClass(klass);
    return self.featureClassMap[className];
}

@end
