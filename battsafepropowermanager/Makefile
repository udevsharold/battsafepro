ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BattSafeProPowerManager

BattSafeProPowerManager_FILES = $(wildcard *.xm) $(wildcard *.mm)
BattSafeProPowerManager_CFLAGS = -fobjc-arc
BattSafeProPowerManager_PRIVATE_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk
