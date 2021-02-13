export DEBUG = 0
export FINALPACKAGE = 1

export XCODE_12_SLICE ?= 0
ifeq ($(XCODE_12_SLICE), 1)
	export ARCHS = arm64e
else
	export ARCHS = arm64 arm64e
	export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
endif

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
