#
# Copyright (C) 2018 Fuzhou Rockchip Electronics Co.Ltd.
#
# Modification based on code covered by the Apache License, Version 2.0 (the "License").
# You may not use this software except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS TO YOU ON AN "AS IS" BASIS
# AND ANY AND ALL WARRANTIES AND REPRESENTATIONS WITH RESPECT TO SUCH SOFTWARE, WHETHER EXPRESS,
# IMPLIED, STATUTORY OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF TITLE,
# NON-INFRINGEMENT, MERCHANTABILITY, SATISFACTROY QUALITY, ACCURACY OR FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.
#
# IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Copyright (C) 2021 The Android Open Source Project
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
    libhardware \
    liblog \
    libui \
    libutils \
    librga

LOCAL_STATIC_LIBRARIES := \
    libtinyxml2

LOCAL_C_INCLUDES := \
    hardware/rockchip/libgralloc \
    hardware/rockchip/librga \
    external/tinyxml2 \
    external/libdrm \
    external/libdrm/include/drm \
    system/core/include/utils

# API 29 -> Android 10.0
ifneq (1,$(strip $(shell expr $(PLATFORM_SDK_VERSION) \< 29)))

#DRM driver version is 2.0,kernel version is 4.19
LOCAL_CFLAGS += -DDRM_DRIVER_VERSION=2 -DUSE_NO_ASPECT_RATIO=1

ifneq (,$(filter mali-t860 mali-t760, $(TARGET_BOARD_PLATFORM_GPU)))
LOCAL_C_INCLUDES += \
    hardware/rockchip/libgralloc/midgard
endif
endif

# API 28 -> Android 9.0
ifneq (1,$(strip $(shell expr $(PLATFORM_SDK_VERSION) \< 28)))

LOCAL_CFLAGS += -DANDROID_P

LOCAL_SHARED_LIBRARIES += \
    libsync_vendor

LOCAL_C_INCLUDES += \
    system/core \
    system/core/liblog/include \
    frameworks/native/include
else # Android 9.0

LOCAL_SHARED_LIBRARIES +=  \
        libsync

LOCAL_C_INCLUDES += \
    system/core/libsync \
    system/core/libsync/include

endif

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
    separate_rects.cpp \
    virtualcompositorworker.cpp \
    vsyncworker.cpp \
    worker.cpp \
    hwc_util.cpp \
    hwc_rockchip.cpp \
    hwc_debug.cpp


# Disable afbc by default.
USE_AFBC_LAYER = 0
# RGA1: 0  RGA1_plus: 1  RGA2-Lite: 2  RGA2: 3  RGA2-Enhance: 4
RGA_VER = 3
RK_RGA_SCALE_AND_ROTATE = 1

# When enter rotate video,we need improve cpu freq in some platforms.
RK_ROTATE_VIDEO_MODE = 0

# In performance mode,we get handle's parameters from gralloc_drm_handle_t instead of gralloc's perform.
# it will lead reduce compatibility. So we disable it by default.
RK_PER_MODE = 0
ifeq ($(strip $(RK_PER_MODE)), 1)
RK_PRINT_LAYER_NAME = 0
else
RK_PRINT_LAYER_NAME = 1
endif

# vop Multi-Zone sort
RK_SORT_AREA_BY_XPOS = 1
# vop Multi-Zone can intersect in horizontal line.
RK_HOR_INTERSECT_LIMIT = 0

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t860)
USE_AFBC_LAYER = 1
LOCAL_CPPFLAGS += -DMALI_PRODUCT_ID_T86X=1
else
$(error "Unsupported platform GPU $(TARGET_BOARD_PLATFORM_GPU)")
endif

ifneq ($(filter rk3399 rk3399pro, $(strip $(TARGET_BOARD_PLATFORM))), )
RGA_VER = 4
USE_AFBC_LAYER = 0
LOCAL_CPPFLAGS += \
    -DTARGET_BOARD_PLATFORM_RK3399 \
    -DRK_DRM_GRALLOC=1 \
    -DMALI_AFBC_GRALLOC=1
else
$(error "Unsupported platform $(TARGET_BOARD_PLATFORM)")
endif

RK_INVALID_REFRESH = 1

ifeq ($(TARGET_USES_HWC2),true)
    LOCAL_CFLAGS += -DUSE_HWC2
endif

#USE_PLANE_RESERVED enable
#LOCAL_CPPFLAGS += -DUSE_PLANE_RESERVED

# RK_RGA_PREPARE_ASYNC and RK_RGA_COMPSITE_SYNC are exclusive.
#       RK_RGA_PREPARE_ASYNC: use async rga in hwc_prepare.
#       RK_RGA_COMPSITE_SYNC: use sync rga in composite thread.
LOCAL_CPPFLAGS += -DUSE_SQUASH=0 -DRK_RGA_TEST=0 -DUSE_GL_WORKER=0
LOCAL_CPPFLAGS += -DUSE_DRM_GENERIC_IMPORTER \
               -DUSE_MULTI_AREAS=1 -DRK_RGA_PREPARE_ASYNC=1 -DRK_RGA_COMPSITE_SYNC=0 \
               -DUSE_AFBC_LAYER=$(USE_AFBC_LAYER) -DRK_SKIP_SUB=1 \
               -DRK_VIDEO_SKIP_LINE=1 \
               -DRK_INVALID_REFRESH=$(RK_INVALID_REFRESH) -DRK_HDR_PERF_MODE=0 \
               -DRK_PRINT_LAYER_NAME=$(RK_PRINT_LAYER_NAME) \
               -DRK_SORT_AREA_BY_XPOS=$(RK_SORT_AREA_BY_XPOS) -DRK_HOR_INTERSECT_LIMIT=$(RK_HOR_INTERSECT_LIMIT) \
               -DRK_RGA_SCALE_AND_ROTATE=$(RK_RGA_SCALE_AND_ROTATE) \
               -DRGA_VER=$(RGA_VER) -DRK_PER_MODE=$(RK_PER_MODE) -DRK_ROTATE_VIDEO_MODE=$(RK_ROTATE_VIDEO_MODE)

MAJOR_VERSION := "RK_GRAPHICS_VER=commit-id:$(shell cd $(LOCAL_PATH) && git log  -1 --oneline | awk '{print $$1}')"
LOCAL_CPPFLAGS += -DRK_GRAPHICS_VER=\"$(MAJOR_VERSION)\"

LOCAL_CPPFLAGS += -DPLATFORM_SDK_VERSION=$(PLATFORM_SDK_VERSION)
LOCAL_CPPFLAGS += -Wno-unreachable-code-loop-increment -Wno-error

# API 26 -> Android 8.0
ifeq (1,$(strip $(shell expr $(PLATFORM_SDK_VERSION) \>= 26)))
LOCAL_PROPRIETARY_MODULE := true
endif
LOCAL_MODULE := hwcomposer.$(TARGET_BOARD_PLATFORM)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := $(TARGET_SHLIB_SUFFIX)
include $(BUILD_SHARED_LIBRARY)

endif
