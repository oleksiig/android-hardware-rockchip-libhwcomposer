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

#include "hwc_util.h"
#define LOG_TAG "hwcomposer-util"

#ifdef ANDROID_P
#include <log/log.h>
#else
#include <cutils/log.h>
#endif

#include <cutils/properties.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

/*
static int sysfs_read(const char *path)
{
    char buf[80];
    char freq[50];
    int len;
    int fd = open(path, O_RDONLY);

    ALOGV("%s: [%s:]", __FUNCTION__, path);
    if (fd < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("%s: [%s]", __FUNCTION__, path);
        ALOGE("Error opening %s: %s\n", path, buf);
        return -1;
    }

    len = read(fd, freq, 10);
    if (len < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("%s: [%s]", __FUNCTION__, path);
        ALOGE("Error writing to %s: %s\n", path, buf);
    }

    close(fd);

    return atoi(freq)/1000;
}

static void sysfs_write(const char *path,const char *s)
{
    char buf[80];
    int len;
    int fd = open(path, O_WRONLY);

    ALOGV("%s: [%s: %s]", __FUNCTION__, path, s);
    if (fd < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("%s: [%s: %s]", __FUNCTION__, path, s);
        ALOGE("Error opening %s: %s\n", path, buf);
        return;
    }

    len = write(fd, s, strlen(s));
    if (len < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("%s: [%s: %s]", __FUNCTION__, path, s);
        ALOGE("Error writing to %s: %s\n", path, buf);
    }

    close(fd);
}
*/
/*
 * Control cpu performance mode.
 * Parameters:
 *  on:
 *      1: open performance
 *      0: close performance
 *  type:
 *      1: big cpu
 *      0: little cpu
 */
/*void ctl_cpu_performance(int on, int type)
{
    if((on != 0 && on != 1) ||
        (type != 0 && type != 1))
    {
        ALOGE("%s: invalid parameters,on=%d,type=%d", __FUNCTION__, on, type);
        return;
    }

    if(type)
    {
        sysfs_write(CPU_CLUST1_GOV_PATH, on ? "performance" : "interactive");
    }
    else
    {
        sysfs_write(CPU_CLUST0_GOV_PATH, on ? "performance" : "interactive");
    }
}*/

/*
 * Control little cpu.
 * Parameters:
 *  on:
 *      1: Enable little cpu
 *      0: Disable little cpu
 */
 /*
void ctl_little_cpu(int on)
{
    if(on != 0 && on != 1)
    {
        ALOGE("%s: invalid parameters,on=%d", __FUNCTION__, on);
        return;
    }

    sysfs_write("/sys/devices/system/cpu/cpu0/online", on ? "1" : "0");
    sysfs_write("/sys/devices/system/cpu/cpu1/online", on ? "1" : "0");
    sysfs_write("/sys/devices/system/cpu/cpu2/online", on ? "1" : "0");
    sysfs_write("/sys/devices/system/cpu/cpu3/online", on ? "1" : "0");
}
*/
int hwc_get_int_property(const char* pcProperty,const char* default_value)
{
    char value[PROPERTY_VALUE_MAX];
    int new_value = 0;

    if(pcProperty == NULL || default_value == NULL)
    {
        ALOGE("hwc_get_int_property: invalid param");
        return -1;
    }

    property_get(pcProperty, value, default_value);
    new_value = atoi(value);

    return new_value;
}

bool hwc_get_bool_property(const char* pcProperty, const char* default_value)
{
    char value[PROPERTY_VALUE_MAX];
    bool result = false;

    if(pcProperty == NULL || default_value == NULL)
    {
        ALOGE("hwc_get_int_property: invalid param");
        return -1;
    }

    property_get(pcProperty, value, default_value);
    if(!strcmp(value,"true"))
        result = true;
    else
        result = false;

    return result;
}


int hwc_get_string_property(const char* pcProperty,const char* default_value,char* retult)
{
    if(pcProperty == NULL || default_value == NULL || retult == NULL)
    {
        ALOGE("hwc_get_string_property: invalid param");
        return -1;
    }

    property_get(pcProperty, retult, default_value);

    return 0;
}

