export ARCHS = arm64 arm64e
export DEBUG = 0
export FINALPACKAGE = 1

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BattSafePro

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.mm)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DWRITELOG=0 -DPACKNAME=$(THEOS_PACKAGE_NAME) -DPACKVERSION=$(THEOS_PACKAGE_BASE_VERSION)
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = IOKit AppSupport
$(TWEAK_NAME)_LIBRARIES = rocketbootstrap
$(TWEAK_NAME)_FRAMEWORKS = QuartzCore UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += battsafeproprefs
SUBPROJECTS += battsafeprocc
SUBPROJECTS += battsafepropowermanager
SUBPROJECTS += bts
include $(THEOS_MAKE_PATH)/aggregate.mk
