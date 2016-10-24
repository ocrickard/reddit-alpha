//
//  RDFrontPageViewController.m
//  reddit
//
//  Created by Oliver Rickard on 10/8/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDStreamViewController.h"

#import <ComponentKit/CKCollectionViewTransactionalDataSource.h>
#import <ComponentKit/CKTransactionalComponentDataSourceConfiguration.h>
#import <ComponentKit/CKTransactionalComponentDataSourceChangeset.h>
#import <ComponentKit/CKComponentFlexibleSizeRangeProvider.h>

#import "RDStreamController.h"
#import "RDFrontPageStreamNetworkSource.h"
#import "RDListModelController.h"
#import "RKLink.h"
#import "RDArticleSummaryComponent.h"
#import "RDUserSession.h"

@interface RDStreamViewController () <
RDStreamControllerDelegate,
RDListModelControllerDelegate,
UICollectionViewDelegateFlowLayout
>

@end

@implementation RDStreamViewController
{
  Class<CKComponentProvider> _componentProvider;
  id _componentContext;
  UIRefreshControl *_headLoadRefreshControl;
  UIRefreshControl *_tailLoadRefreshControl;
  RDUserSession *_session;
  RDStreamController *_streamController;
  RDListModelController *_modelController;
  UICollectionView *_collectionView;
  CKCollectionViewTransactionalDataSource *_dataSource;
}

- (instancetype)initWithTitle:(NSString *)title
                networkSource:(id<RDStreamControllerNetworkSource>)networkSource
            componentProvider:(Class<CKComponentProvider>)componentProvider
             componentContext:(id)componentContext
                      session:(RDUserSession *)session
{
  if (self = [super init]) {
    _session = session;
    _streamController = [[RDStreamController alloc]
                         initWithNetworkSource:networkSource
                         paginationInfo:nil
                         items:nil
                         session:session];
    _streamController.delegate = self;
    _modelController = [[RDListModelController alloc]
                        initWithUserSession:session
                        persistenceCoordinator:nil];
    _modelController.delegate = self;
    _componentProvider = componentProvider;
    _componentContext = componentContext;

    self.title = title;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  flowLayout.minimumInteritemSpacing = 0;
  flowLayout.minimumLineSpacing = 0;

  _collectionView =
  [[UICollectionView alloc]
   initWithFrame:self.view.bounds
   collectionViewLayout:flowLayout];
  _collectionView.delegate = self;
  _collectionView.backgroundColor = self.view.backgroundColor;
  _collectionView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleWidth);
  [self.view addSubview:_collectionView];

  CKTransactionalComponentDataSourceConfiguration *config =
  [[CKTransactionalComponentDataSourceConfiguration alloc]
   initWithComponentProvider:_componentProvider
   context:_componentContext
   sizeRange:{
     CGSizeMake(_collectionView.bounds.size.width, 0),
     CGSizeMake(_collectionView.bounds.size.width, INFINITY)
   }];

  _dataSource =
  [[CKCollectionViewTransactionalDataSource alloc]
   initWithCollectionView:_collectionView
   supplementaryViewDataSource:nil
   configuration:config];

  CKTransactionalComponentDataSourceChangeset *changeset =
  [[CKTransactionalComponentDataSourceChangeset alloc]
   initWithUpdatedItems:nil
   removedItems:nil
   removedSections:nil
   movedItems:nil
   insertedSections:[NSIndexSet indexSetWithIndex:0]
   insertedItems:nil];
  [_dataSource applyChangeset:changeset
                         mode:CKUpdateModeSynchronous
                     userInfo:nil];

  _headLoadRefreshControl = [[UIRefreshControl alloc] init];
  [_collectionView addSubview:_headLoadRefreshControl];
  [_headLoadRefreshControl addTarget:self
                              action:@selector(_pullToRefresh)
                    forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (_streamController.items.count == 0) {
    [_headLoadRefreshControl beginRefreshing];
//    [_collectionView setContentOffset:CGPointMake(0, _collectionView.contentOffset.y - _headLoadRefreshControl.frame.size.height)
//                             animated:YES];
    [_headLoadRefreshControl sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

#pragma mark - Internal

- (void)_pullToRefresh
{
  [_streamController loadHead];
}

#pragma mark - RDStreamControllerDelegate

- (void)streamControllerDidCompleteLoad:(RDStreamController *)controller
                              withError:(NSError *)error
{
  DDLogVerbose(@"completed load:%@", controller.items);
  _modelController.items = [NSOrderedSet orderedSetWithArray:controller.items];

  [_headLoadRefreshControl endRefreshing];
}

#pragma mark - RDListModelControllerDelegate

- (void)listModelController:(RDListModelController *)modelController
     insertedItemsAtIndices:(NSIndexSet *)inserted
      removedItemsAtIndices:(NSIndexSet *)removed
     reloadedItemsAtIndices:(NSIndexSet *)reloaded
              originalItems:(NSOrderedSet *)originalItems
                   userInfo:(NSDictionary *)userInfo
{
  NSOrderedSet *items = modelController.items;
  NSMutableDictionary *updatedDictionary = [NSMutableDictionary dictionary];
  [reloaded enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    const NSUInteger newIndex =
    [items indexOfObject:[originalItems objectAtIndex:idx]];
    updatedDictionary[[NSIndexPath indexPathForRow:newIndex inSection:0]] =
    items[newIndex];
  }];
  NSMutableSet *removedSet = [NSMutableSet set];
  [removed enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [removedSet addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
  }];
  NSMutableDictionary *insertedDictionary = [NSMutableDictionary dictionary];
  [inserted enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    insertedDictionary[[NSIndexPath indexPathForRow:idx inSection:0]] =
    items[idx];
  }];

  CKTransactionalComponentDataSourceChangeset *changeset =
  [[CKTransactionalComponentDataSourceChangeset alloc]
   initWithUpdatedItems:updatedDictionary
   removedItems:removedSet
   removedSections:nil
   movedItems:nil
   insertedSections:nil
   insertedItems:insertedDictionary];
  [_dataSource applyChangeset:changeset
                         mode:CKUpdateModeAsynchronous
                     userInfo:userInfo];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return [_dataSource sizeForItemAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (_streamController.items.count > 0
      && !_streamController.isLoading
      && CGRectGetMaxY(scrollView.bounds) > scrollView.contentSize.height - self.view.bounds.size.height/2) {
    [_streamController loadTail];
  }
}

@end
