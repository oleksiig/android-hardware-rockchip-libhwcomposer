# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(strip $(BOARD_USES_DRM_HWCOMPOSER)),true)

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := \
	libcutils \
	libdrm \
	libEGL \
	libGLESv2 \
	libGLESv1_CM \
	libhardware \
	liblog \
	libui \
	libsync_hwc \
	libutils \
	librga

LOCAL_STATIC_LIBRARIES := \
	libtinyxml2

LOCAL_C_INCLUDES := \
    hardware/rockchip/libgralloc \
	external/tinyxml2 \
	external/libdrm \
	external/libdrm/include/drm \
	system/core/include/utils \
	hardware/rockchip/librga \
	frameworks/native/include \
	system/core/libsync/include \
	system/core/libsync

LOCAL_SRC_FILES := \
	autolock.cpp \
	drmresources.cpp \
	drmcomposition.cpp \
	drmcompositor.cpp \
	drmcompositorworker.cpp \
	drmconnector.cpp \
	drmcrtc.cpp \
	drmdisplaycomposition.cpp \
	drmdisplaycompositor.cpp \
	drmencoder.cpp \
	drmeventlistener.cpp \
	drmmode.cpp \
	drmplane.cpp \
	drmproperty.cpp \
	glworker.cpp \
	hwcomposer.cpp \
	platform.cpp \
	platformdrmgeneric.cpp \
	platformnv.cpp \
	separate_rects.cpp \
	virtualcompositorworker.cpp \
	vsyncworker.cpp \
	worker.cpp \
	hwc_util.cpp \
	hwc_rockchip.cpp \
	hwc_debug.cpp

# Disable afbc by default.
USE_AFBC_LAYER ?= 0
# RGA1: 0  RGA1_plus: 1  RGA2-Lite: 2  RGA2: 3  RGA2-Enhance: 4
RGA_VER ?= 3
RK_RGA_SCALE_AND_ROTATE ?= 1
RK_3D_VIDEO ?= 0
RK_PRINT_LAYER_NAME ?= 0

# vop Multi-Zone sort
RK_SORT_AREA_BY_XPOS = 1
# vop Multi-Zone can intersect in horizontal line.
RK_HOR_INTERSECT_LIMIT = 0

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t860)
USE_AFBC_LAYER := 1
LOCAL_CPPFLAGS += -DMALI_PRODUCT_ID_T86X=1
else
$(error "Unsupported platform GPU $(TARGET_BOARD_PLATFORM_GPU)")
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM)),rk3399)
RGA_VER := 4
RK_3D_VIDEO := 0
RK_RGA_SCALE_AND_ROTATE := 0

LOCAL_CPPFLAGS += \
	-DTARGET_BOARD_PLATFORM_RK3399 \
	-DRK_DRM_GRALLOC=1 \
    -DMALI_AFBC_GRALLOC=1
else
$(error "Unsupported platform $(TARGET_BOARD_PLATFORM)")
endif

ifeq ($(TARGET_USES_HWC2),true)
    LOCAL_CFLAGS += -DUSE_HWC2
endif

# RK_RGA_PREPARE_ASYNC and RK_RGA_COMPSITE_SYNC are exclusive.
# 	RK_RGA_PREPARE_ASYNC: use async rga in hwc_prepare.
#	RK_RGA_COMPSITE_SYNC: use sync rga in composite thread.
LOCAL_CPPFLAGS += \
	-DUSE_SQUASH=0 \
	-DRK_RGA_TEST=0 \
	-DRK_VR=0 \
	-DRK_STEREO=0 \
	-DUSE_GL_WORKER=0 \
	-DUSE_DRM_GENERIC_IMPORTER \
	-DUSE_MULTI_AREAS=1 \
	-DRK_RGA_PREPARE_ASYNC=1 \
	-DRK_RGA_COMPSITE_SYNC=0 \
	-DUSE_AFBC_LAYER=$(USE_AFBC_LAYER) \
	-DRK_SKIP_SUB=1 \
	-DRK_VIDEO_UI_OPT=0 \
	-DRK_VIDEO_SKIP_LINE=1 \
	-DRK_INVALID_REFRESH=1 \
	-DRK_HDR_PERF_MODE=0 \
	-DRK_PRINT_LAYER_NAME=$(RK_PRINT_LAYER_NAME) \
	-DRK_SORT_AREA_BY_XPOS=$(RK_SORT_AREA_BY_XPOS) \
	-DRK_HOR_INTERSECT_LIMIT=$(RK_HOR_INTERSECT_LIMIT) \
	-DENABLE_RELEASE_FENCE=1 \
	-DFORCE_WAIT_ACQUIRE_FENCE=0 \
	-DRK_RGA_SCALE_AND_ROTATE=$(RK_RGA_SCALE_AND_ROTATE) \
	-DRGA_VER=$(RGA_VER)

MAJOR_VERSION := "RK_GRAPHICS_VER=commit-id:$(shell cd $(LOCAL_PATH) && git log  -1 --oneline | awk '{print $$1}')"
LOCAL_CPPFLAGS += -DRK_GRAPHICS_VER=\"$(MAJOR_VERSION)\"

LOCAL_MODULE := hwcomposer.$(TARGET_BOARD_PLATFORM)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := $(TARGET_SHLIB_SUFFIX)

LOCAL_VENDOR_MODULE := true

include $(BUILD_SHARED_LIBRARY)

endif
