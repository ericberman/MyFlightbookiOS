/*
 *  logging.h
 * 
 *
 *  Created by steve woodcock on 28/02/2008.
 *  Copyright 2008. All rights reserved.
 *
 */

// Logging.h
#define gLogging NO
#define Debug(FMT,...)  if(!gLogging) ; else  NSLog(@"DEBUG: " FMT, ##__VA_ARGS__)
#define Warn(FMT,...)   NSLog(@"WARNING: " FMT, ##__VA_ARGS__)
