/*
 * Copyright (C) 2018 Fuzhou Rockchip Electronics Co.Ltd.
 *
 * Modification based on code covered by the Apache License, Version 2.0 (the "License").
 * You may not use this software except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS TO YOU ON AN "AS IS" BASIS
 * AND ANY AND ALL WARRANTIES AND REPRESENTATIONS WITH RESPECT TO SUCH SOFTWARE, WHETHER EXPRESS,
 * IMPLIED, STATUTORY OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF TITLE,
 * NON-INFRINGEMENT, MERCHANTABILITY, SATISFACTROY QUALITY, ACCURACY OR FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.
 *
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ANDROID_DRM_DISPLAY_COMPOSITION_H_
#define ANDROID_DRM_DISPLAY_COMPOSITION_H_

#include "drmcrtc.h"
#include "drmhwcomposer.h"
#include "drmplane.h"
#include "glworker.h"

#include <sstream>
#include <vector>
#include <map>
#include <inttypes.h>

#include <hardware/gralloc.h>
#include <hardware/hardware.h>
#include <hardware/hwcomposer.h>

namespace android {

class Importer;
class Planner;
class SquashState;

  typedef std::map<int, std::vector<DrmHwcLayer*>> LayerMap;
  typedef LayerMap::iterator LayerMapIter;


enum DrmCompositionType {
  DRM_COMPOSITION_TYPE_EMPTY,
  DRM_COMPOSITION_TYPE_FRAME,
  DRM_COMPOSITION_TYPE_DPMS,
  DRM_COMPOSITION_TYPE_MODESET,
};

struct DrmCompositionRegion {
  DrmHwcRect<int> frame;
  std::vector<size_t> source_layers;
};

class DrmCompositionPlane {
 public:
  enum class Type : int32_t {
    kDisable,
    kLayer,
    kPrecomp,
    kSquash,
  };

  DrmCompositionPlane() = default;
  DrmCompositionPlane(DrmCompositionPlane &&rhs) = default;
  DrmCompositionPlane &operator=(DrmCompositionPlane &&other) = default;
  DrmCompositionPlane(Type type, DrmPlane *plane, DrmCrtc *crtc)
      : type_(type), plane_(plane), crtc_(crtc) {
  }
  DrmCompositionPlane(Type type, DrmPlane *plane, DrmCrtc *crtc,
                      size_t source_layer)
      : type_(type),
        plane_(plane),
        crtc_(crtc),
        source_layers_(1, source_layer) {
  }

  Type type() const {
    return type_;
  }

  DrmPlane *plane() const {
    return plane_;
  }
  void set_plane(DrmPlane *plane) {
    plane_ = plane;
  }

  DrmCrtc *crtc() const {
    return crtc_;
  }

  std::vector<size_t> &source_layers() {
    return source_layers_;
  }

  const std::vector<size_t> &source_layers() const {
    return source_layers_;
  }

  int get_zpos() { return zpos_; }
  void set_zpos( int zpos) { zpos_ =  zpos; }

  void dump_drm_com_plane(int index, std::ostringstream *out) const;

 private:
  int zpos_;
  Type type_ = Type::kDisable;
  DrmPlane *plane_ = NULL;
  DrmCrtc *crtc_ = NULL;
  std::vector<size_t> source_layers_;
};

class DrmDisplayComposition {
 public:
  DrmDisplayComposition() = default;
  DrmDisplayComposition(const DrmDisplayComposition &) = delete;
  ~DrmDisplayComposition();

  int Init(DrmResources *drm, DrmCrtc *crtc, Importer *importer,
           Planner *planner, uint64_t frame_no);

  int SetLayers(DrmHwcLayer *layers, size_t num_layers, bool geometry_changed);
  int AddPlaneComposition(DrmCompositionPlane plane);
  int AddPlaneDisable(DrmPlane *plane);
  int SetDpmsMode(uint32_t dpms_mode);
  int SetDisplayMode(const DrmMode &display_mode);
  int SetCompPlanes(std::vector<DrmCompositionPlane>& composition_planes);

  int Plan(SquashState *squash, std::vector<DrmPlane *> *primary_planes,
           std::vector<DrmPlane *> *overlay_planes);

  int FinalizeComposition();

  int CreateNextTimelineFence(const char* fence_name);
  int SignalSquashDone() {
    return IncreaseTimelineToPoint(timeline_squash_done_);
  }
  int SignalPreCompDone() {
    return IncreaseTimelineToPoint(timeline_pre_comp_done_);
  }
  int SignalCompositionDone() {
    ALOGD_IF(log_level(DBG_DEBUG),"%s: signal frame = %" PRIu64 "", __FUNCTION__, frame_no_);
    return IncreaseTimelineToPoint(timeline_);
  }

  std::vector<DrmHwcLayer> &layers() {
    return layers_;
  }

  std::vector<DrmCompositionRegion> &squash_regions() {
    return squash_regions_;
  }

  std::vector<DrmCompositionRegion> &pre_comp_regions() {
    return pre_comp_regions_;
  }

  std::vector<DrmCompositionPlane> &composition_planes() {
    return composition_planes_;
  }

  bool geometry_changed() const {
    return geometry_changed_;
  }

  uint64_t frame_no() const {
    return frame_no_;
  }

  DrmCompositionType type() const {
    return type_;
  }

  uint32_t dpms_mode() const {
    return dpms_mode_;
  }

  const DrmMode &display_mode() const {
    return display_mode_;
  }

  DrmCrtc *crtc() const {
    return crtc_;
  }

  Importer *importer() const {
    return importer_;
  }

  Planner *planner() const {
    return planner_;
  }

  void Dump(std::ostringstream *out) const;

 private:
  bool validate_composition_type(DrmCompositionType desired);

  int IncreaseTimelineToPoint(int point);

  int FinalizeComposition(DrmHwcRect<int> *exclude_rects,
                          size_t num_exclude_rects);
  void SeparateLayers(DrmHwcRect<int> *exclude_rects, size_t num_exclude_rects);
  int CreateAndAssignReleaseFences();
  int combine_layer();

  DrmResources *drm_ = NULL;
  DrmCrtc *crtc_ = NULL;
  Importer *importer_ = NULL;
  Planner *planner_ = NULL;

  DrmCompositionType type_ = DRM_COMPOSITION_TYPE_EMPTY;
  uint32_t dpms_mode_ = DRM_MODE_DPMS_ON;
  DrmMode display_mode_;
  //Mode3D  mode_3d_;

  int timeline_fd_ = -1;
  int timeline_ = 0;
  int timeline_current_ = 0;
  int timeline_squash_done_ = 0;
  int timeline_pre_comp_done_ = 0;

  bool geometry_changed_;
  std::vector<DrmHwcLayer> layers_;
  std::vector<DrmCompositionRegion> squash_regions_;
  std::vector<DrmCompositionRegion> pre_comp_regions_;
  std::vector<DrmCompositionPlane> composition_planes_;

  LayerMap layer_map_;

  uint64_t frame_no_ = 0;
};
}

#endif  // ANDROID_DRM_DISPLAY_COMPOSITION_H_
