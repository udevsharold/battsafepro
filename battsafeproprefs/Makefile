ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BattSafeProPrefs

BattSafeProPrefs_FILES = $(wildcard *.m)
BattSafeProPrefs_INSTALL_PATH = /Library/PreferenceBundles
BattSafeProPrefs_FRAMEWORKS = UIKit
BattSafeProPrefs_PRIVATE_FRAMEWORKS = Preferences IOKit
BattSafeProPrefs_WEAK_FRAMEWORKS = OnBoardingKit
BattSafeProPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BattSafeProPrefs.plist$(ECHO_END)
