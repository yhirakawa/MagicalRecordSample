//
//  AppDelegate.m
//  MagicalRecordSample
//
//  Created by yuta hirakawa on 2013/04/30.
//  Copyright (c) 2013年 yuta hirakawa. All rights reserved.
//

#import "AppDelegate.h"
#import "Cat.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // *** 設定 ***
    // 保存方法を指定
    [MagicalRecord setupCoreDataStack];
    
    [self allDelete]; // 全データを消去
    
    // *** Default CoreData ***
    
    NSManagedObjectContext *context = [self managedObjectContext];
    Cat *cat1 = [NSEntityDescription insertNewObjectForEntityForName:@"Cat" inManagedObjectContext:context];
    cat1.name = @"mike";
    cat1.age  = [NSNumber numberWithInt: 2];
    Cat *cat2 = [NSEntityDescription insertNewObjectForEntityForName:@"Cat" inManagedObjectContext:context];
    cat2.name = @"tama";
    cat2.age  = [NSNumber numberWithInt: 5];
    Cat* cat3 = [NSEntityDescription insertNewObjectForEntityForName:@"Cat" inManagedObjectContext:context];
    cat3.name = @"tora";
    cat3.age  = [NSNumber numberWithInt: 1];
    
    // update
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Cat" inManagedObjectContext:context];
    fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = 'tama'"];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchArr = [context executeFetchRequest:fetchRequest error:&error];
    Cat *tama = [fetchArr objectAtIndex:0];
    NSLog(@"tama age : %@", [tama age]);
    tama.age = [NSNumber numberWithInt: 3];
    
    // delete
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"name = 'mike'"];
    [fetchRequest setPredicate:predicate];
    fetchArr = [context executeFetchRequest:fetchRequest error:&error];
    Cat *mike = [fetchArr objectAtIndex:0];
    [context deleteObject:mike];
    
    // save
    error = nil;
    if (![context save:&error]) {
        NSLog(@"error = %@", error);
    }
    
    // check
    
    fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Cat"];
    error = nil;
    NSArray *all = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"all count : %d", [all count]);
    NSLog(@"all : %@", all);
    
    [self allDelete]; // 全データを消去
    
    // *** MagicalRecord ***
    
    NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
    
    // insert
    Cat* magicalCat1 = [Cat MR_createEntity];
    magicalCat1.name = @"mike";
    magicalCat1.age  = [NSNumber numberWithInt: 2];
    Cat* magicalCat2 = [Cat MR_createEntity];
    magicalCat2.name = @"tama";
    magicalCat2.age  = [NSNumber numberWithInt: 5];
    Cat* magicalCat3 = [Cat MR_createEntity];
    magicalCat3.name = @"tora";
    magicalCat3.age  = [NSNumber numberWithInt: 1];
    
    // update
    Cat *magicalTama = [Cat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name = 'tama'"]];
    NSLog(@"magicalTama age : %@", [magicalTama age]);
    magicalTama.age = [NSNumber numberWithInt: 3];
    
    // delete
    Cat *magicalMike = [Cat MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name = 'mike'"]];
    [magicalMike MR_deleteEntity];
    
    // save
    [magicalContext MR_saveOnlySelfAndWait];
    
    // check
    
    NSArray *magicalAll = [Cat MR_findAll];
    
    NSLog(@"magicalAll count : %d", [magicalAll count]);
    NSLog(@"magicalAll : %@", magicalAll);
    return YES;
}

- (void) allDelete
{
    NSArray *all = [Cat MR_findAll];
    int len = [all count];
    for ( int i = 0 ; i < len ; i++ ) {
        Cat *cat = [all objectAtIndex:i];
        [cat MR_deleteEntity];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MagicalRecordSample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MagicalRecordSample.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
