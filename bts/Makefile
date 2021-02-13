export XCODE_12_SLICE ?= 0
ifeq ($(XCODE_12_SLICE), 1)
	export ARCHS = arm64e
else
	export ARCHS = arm64 arm64e
	export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
endif

TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = bts

bts_FILES = main.mm
bts_CFLAGS = -fobjc-arc
bts_CODESIGN_FLAGS = -Sentitlements.plist
bts_INSTALL_PATH = /usr/local/bin
bts_PRIVATE_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tool.mk
