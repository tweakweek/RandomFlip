include theos/makefiles/common.mk

TWEAK_NAME = RandomIconsFlip
RandomIconsFlip_FILES = Tweak.xm
RandomIconsFlip_FRAMEWORKS =  QuartzCore UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
