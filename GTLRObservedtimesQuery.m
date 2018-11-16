// NOTE: This file was generated by the ServiceGenerator.

// ----------------------------------------------------------------------------
// API:
//   observedtimes/v1
// Description:
//   ObservedTimes API v1. This API allows the GET method to get a collection of
//   observed times since the last time the user asked for a list and a POST
//   method
//   to record new times

#import "GTLRObservedtimesQuery.h"

#import "GTLRObservedtimesObjects.h"

@implementation GTLRObservedtimesQuery

@dynamic fields;

@end

@implementation GTLRObservedtimesQuery_ClockClockcheck

+ (instancetype)queryWithObject:(GTLRObservedtimes_RowTimePackageClockSyncRequest *)object {
  if (object == nil) {
    GTLR_DEBUG_ASSERT(object != nil, @"Got a nil object");
    return nil;
  }
  NSString *pathURITemplate = @"clock";
  GTLRObservedtimesQuery_ClockClockcheck *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:@"POST"
                       pathParameterNames:nil];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLRObservedtimes_RowTimePackageClockSyncReply class];
  query.loggingName = @"observedtimes.clock.clockcheck";
  return query;
}

@end

@implementation GTLRObservedtimesQuery_CrewList

@dynamic eventId;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  return @{ @"eventId" : @"event_id" };
}

+ (instancetype)query {
  NSString *pathURITemplate = @"crew";
  GTLRObservedtimesQuery_CrewList *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.expectedObjectClass = [GTLRObservedtimes_RowTimePackageCrewList class];
  query.loggingName = @"observedtimes.crew.list";
  return query;
}

@end

@implementation GTLRObservedtimesQuery_EventList

@dynamic searchString;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  return @{ @"searchString" : @"search_string" };
}

+ (instancetype)query {
  NSString *pathURITemplate = @"event";
  GTLRObservedtimesQuery_EventList *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.expectedObjectClass = [GTLRObservedtimes_RowTimePackageEventList class];
  query.loggingName = @"observedtimes.event.list";
  return query;
}

@end

@implementation GTLRObservedtimesQuery_TimesListtimes

@dynamic eventId, lastTimestamp;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"eventId" : @"event_id",
    @"lastTimestamp" : @"last_timestamp"
  };
  return map;
}

+ (instancetype)query {
  NSString *pathURITemplate = @"times";
  GTLRObservedtimesQuery_TimesListtimes *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.expectedObjectClass = [GTLRObservedtimes_RowTimePackageObservedTimeList class];
  query.loggingName = @"observedtimes.times.listtimes";
  return query;
}

@end

@implementation GTLRObservedtimesQuery_TimesTimecreate

+ (instancetype)queryWithObject:(GTLRObservedtimes_RowTimePackageObservedTime *)object {
  if (object == nil) {
    GTLR_DEBUG_ASSERT(object != nil, @"Got a nil object");
    return nil;
  }
  NSString *pathURITemplate = @"times";
  GTLRObservedtimesQuery_TimesTimecreate *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:@"POST"
                       pathParameterNames:nil];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLRObservedtimes_RowTimePackageObservedTime class];
  query.loggingName = @"observedtimes.times.timecreate";
  return query;
}

@end
