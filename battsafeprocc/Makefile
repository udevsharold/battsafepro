ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TARGET = iphone:clang:11.2:11.0

BUNDLE_NAME = BattSafePro
BattSafePro_BUNDLE_EXTENSION = bundle
BattSafePro_FILES = BattSafeProCC.m
BattSafePro_PRIVATE_FRAMEWORKS = ControlCenterUIKit
BattSafePro_FRAMEWORKS = UIKit
BattSafePro_INSTALL_PATH = /Library/ControlCenter/Bundles/
BattSafePro_CFLAGS = -fobjc-arc

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/bundle.mk
