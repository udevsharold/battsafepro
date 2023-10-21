ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TOOL_NAME = bts

bts_FILES = main.mm
bts_CFLAGS = -fobjc-arc
bts_CODESIGN_FLAGS = -Sentitlements.plist
bts_INSTALL_PATH = /usr/local/bin
bts_PRIVATE_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tool.mk
