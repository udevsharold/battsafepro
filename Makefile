export ARCHS = arm64 arm64e
export DEBUG = 0
export FINALPACKAGE = 1

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BattSafePro

BattSafePro_FILES = $(wildcard *.xm) $(wildcard *.mm)
BattSafePro_CFLAGS = -fobjc-arc
BattSafePro_PRIVATE_FRAMEWORKS = IOKit AppSupport
BattSafePro_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += battsafeproprefs
SUBPROJECTS += battsafeprocc
SUBPROJECTS += battsafepropowermanager
SUBPROJECTS += bts
include $(THEOS_MAKE_PATH)/aggregate.mk
