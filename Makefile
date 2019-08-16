export ARCHS = armv7s arm64 arm64e
export TARGET = iphone:latest:9.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FLEXing
FLEXing_FILES = Tweak.xm
FLEXing_CFLAGS += -fobjc-arc -w

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

after-install::
	install.exec "killall -9 SpringBoard"

# For printing variables from the makefile
print-%  : ; @echo $* = $($*)

SUBPROJECTS += libflex
include $(THEOS_MAKE_PATH)/aggregate.mk
