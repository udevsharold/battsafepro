export XCODE_12_SLICE ?= 0
ifeq ($(XCODE_12_SLICE), 1)
	export ARCHS = arm64e
else
	export ARCHS = arm64 arm64e
	export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
endif

TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BattSafeProPowerManager

BattSafeProPowerManager_FILES = $(wildcard *.xm) $(wildcard *.mm)
BattSafeProPowerManager_CFLAGS = -fobjc-arc
BattSafeProPowerManager_PRIVATE_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk
