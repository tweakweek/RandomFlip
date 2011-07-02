#import <SBIcon.h>
#import <SBIconController.h>
#import <SBIconListView.h>
#import <SpringBoard-Class.h>
#import <substrate.h>
#import <UIKit/UIView.h>

static BOOL hasAnimatingIcon=0;
static BOOL hasUnscattered=NO;

@interface RandomIconFlipManager : NSObject 
+(id)sharedInstance;
-(BOOL)isSpringBoardVisible;
-(void)performRandomAnimation;
@end

@implementation RandomIconFlipManager
static id sharedInstance=nil;
-(id)init{
	sharedInstance=[super init];
	return sharedInstance;
}
+(id)sharedInstance{
	if (!sharedInstance){
		[[self alloc] init];
	}
	return sharedInstance;
}
-(BOOL)isSpringBoardVisible{
	return ![[objc_getClass("SpringBoard") sharedApplication] _accessibilityTopDisplay];
}
-(void)clearAnimatingIconState{
	hasAnimatingIcon=0;
}

-(void)performRandomAnimation{
	SBIconController *sbic=[objc_getClass("SBIconController") sharedInstance];
	if ([self isSpringBoardVisible] && ![sbic isShowingSearch]  && ![sbic isScrolling] && !hasAnimatingIcon)
	{
		NSArray *icons=[[sbic currentRootIconList] icons];
		SBDockIconListView *dock=[sbic dock];
		unsigned count=[icons count];
		unsigned dockcount=[[dock icons] count];
		unsigned r = rand() % count+dockcount ;
		SBIcon *icon=r<count ? [icons objectAtIndex:r] : [[dock icons] objectAtIndex:r-count];
		srand(time(0));
		int transition=rand() % 2 ;
		if (icon && ![icon isGrabbed]){
			hasAnimatingIcon=1;
			float duration = (rand() % 10 )+5;	
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:duration/10];
	 		[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(clearAnimatingIconState)];
			UIViewAnimationTransition realTrans;
			realTrans= transition == 1 ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight;
			if ([icon isInDock]){
				[UIView setAnimationTransition:realTrans  forView:[[icon subviews] objectOfClass:objc_getClass("SBIconImageContainerView")] cache:1];
			}
			else{
				[UIView setAnimationTransition:realTrans  forView:[icon iconImageView] cache:1];
			}
			[UIView commitAnimations];
		 }
		
	}
		float repeat = (rand() % 360) +50 ;
		repeat=repeat/100;
		[self performSelector:@selector(performRandomAnimation) withObject:nil afterDelay:repeat];
}

@end

%hook SBUIController
-(void)finishedUnscattering{
	%orig;
	if (!hasUnscattered)
		[[RandomIconFlipManager sharedInstance] performRandomAnimation];	
	hasUnscattered=YES;
}
%end
