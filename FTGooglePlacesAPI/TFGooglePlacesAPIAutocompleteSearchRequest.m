//
//  TFGooglePlacesAPIAutocompleteSearchRequest.m
//  Pods
//
//  Created by Tarik Fayad on 6/17/15.
//
//

#import "TFGooglePlacesAPIAutocompleteSearchRequest.h"

static const NSUInteger kMaxRadius = 50000;

@implementation TFGooglePlacesAPIAutocompleteSearchRequest

#pragma Lifecycle

- (instancetype)initWithInput:(NSString *)input
{
    self =  [super init];
    if(self)
    {
        //  Validate query
        if ([input length] == 0) {
            NSLog(@"WARNING: %s: Search query is empty, returning nil", __PRETTY_FUNCTION__);
            return nil;
        }
        
        _input = input;
        
        //  Default values
        _radius = kMaxRadius+1; // Indicate "no value" by overflowing max radius value
        _locationCoordinate = CLLocationCoordinate2DMake(10000, 10000); // Default is invalid value
        _language = [FTGooglePlacesAPIUtils deviceLanguage];
        _minPrice = NSUIntegerMax;
        _maxPrice = NSUIntegerMax;
    }
    return self;
}

#pragma mark - Accessors

- (void)setRadius:(NSUInteger)radius
{
    [self willChangeValueForKey:@"radius"];
    
    //  Validate radius
    _radius = radius;
    if (_radius > kMaxRadius) {
        NSLog(@"WARNING: %s: Radius %ldm is too big. Maximum radius is %ldm, using maximum", __PRETTY_FUNCTION__, (unsigned long)radius, (unsigned long)kMaxRadius);
        _radius = kMaxRadius;
    }
    
    [self didChangeValueForKey:@"radius"];
}

- (void)setMinPrice:(NSUInteger)minPrice
{
    [self willChangeValueForKey:@"minPrice"];
    
    //  value ranges 0-4
    _minPrice = MAX(0,MIN(4, minPrice));
    
    [self didChangeValueForKey:@"minPrice"];
}

- (void)setMaxPrice:(NSUInteger)maxPrice
{
    [self willChangeValueForKey:@"maxPrice"];
    
    //  value ranges 0-4
    _maxPrice = MAX(0,MIN(4, maxPrice));
    
    [self didChangeValueForKey:@"maxPrice"];
}

#pragma mark - Superclass overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, [self placesAPIRequestParams]];
}

#pragma mark - FTGooglePlacesAPIRequest protocol

- (NSString *)placesAPIRequestMethod
{
    return @"autocomplete";
}

- (NSDictionary *)placesAPIRequestParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if(_input) {
        params[@"input"] = _input;
    }
    
    //  Required parameters
    if (CLLocationCoordinate2DIsValid(_locationCoordinate)) {
        params[@"location"] = [NSString stringWithFormat:@"%.7f,%.7f", _locationCoordinate.latitude, _locationCoordinate.longitude];
    }
    
    //  Radius is optional for text search
    if (_radius <= kMaxRadius) {
        params[@"radius"] = [NSString stringWithFormat:@"%ld", (unsigned long)_radius];
    }
    
    //  Optional parameters
    if (_language) {
        params[@"language"] = _language;
    };
    
    if (_minPrice != NSUIntegerMax) {
        params[@"minprice"] = [NSString stringWithFormat:@"%ld", (unsigned long)_minPrice];
    }
    
    if (_maxPrice != NSUIntegerMax) {
        params[@"maxprice"] = [NSString stringWithFormat:@"%ld", (unsigned long)_maxPrice];
    }
    
    if (_openNow) {
        params[@"opennow"] = [NSNull null];
    }
    
    if ([_types count] > 0) {
        params[@"types"] = [_types componentsJoinedByString:@"|"];
    }
    
    return [params copy];
}

@end
