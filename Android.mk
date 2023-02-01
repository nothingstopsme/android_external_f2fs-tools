LOCAL_PATH:= $(call my-dir)

# f2fs-tools depends on Linux kernel headers being in the system include path.
ifneq (,$(filter linux darwin,$(HOST_OS)))

# The versions depend on $(LOCAL_PATH)/VERSION
version_CFLAGS := -DF2FS_MAJOR_VERSION=1 -DF2FS_MINOR_VERSION=15 -DF2FS_TOOLS_VERSION=\"1.15.0\" -DF2FS_TOOLS_DATE=\"2022-05-20\"

default_CFLAGS := -DWITH_ANDROID -Wall -Werror -Wno-macro-redefined -Wno-missing-field-initializers -Wno-pointer-arith -Wno-sign-compare

# external/e2fsprogs/lib is needed for uuid/uuid.h
common_C_INCLUDES := $(LOCAL_PATH)/include external/e2fsprogs/lib/ $(LOCAL_PATH)/mkfs $(LOCAL_PATH)/fsck
#common_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/mkfs $(LOCAL_PATH)/fsck


#----------------------------------------------------------
#libf2fs_src_files := lib/libf2fs.c lib/libf2fs_io.c lib/zbc.c
libf2fs_src_files := lib/libf2fs.c lib/libf2fs_zoned.c lib/nls_utf8.c lib/libf2fs_io.c

include $(CLEAR_VARS)
LOCAL_MODULE := libf2fs
LOCAL_SRC_FILES := $(libf2fs_src_files)
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS) -DWITH_BLKDISCARD
#LOCAL_SHARED_LIBRARIES := libext2_uuid libsparse libz
LOCAL_SHARED_LIBRARIES := libext2_uuid
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libf2fs_static
LOCAL_SRC_FILES := $(libf2fs_src_files)
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS) -DWITH_BLKDISCARD
LOCAL_STATIC_LIBRARIES := libext2_uuid
include $(BUILD_STATIC_LIBRARY)

#----------------------------------------------------------
mkfs_f2fs_src_files := mkfs/f2fs_format_main.c mkfs/f2fs_format.c mkfs/f2fs_format_utils.c 
#mkfs_f2fs_src_files := \
#	mkfs/f2fs_format.c \
#	mkfs/f2fs_format_utils.c \
#	mkfs/f2fs_format_main.c

include $(CLEAR_VARS)
LOCAL_MODULE := mkfs.f2fs
LOCAL_SRC_FILES := $(mkfs_f2fs_src_files)
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS)
LOCAL_CLANG := false
#LOCAL_SHARED_LIBRARIES := libf2fs libext2_uuid
#LOCAL_STATIC_LIBRARIES := libf2fs_static
LOCAL_SHARED_LIBRARIES := libext2_uuid libsparse libbase libf2fs
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)


include $(CLEAR_VARS)
LOCAL_MODULE := libf2fs_mkfs_static
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
LOCAL_MODULE_SUFFIX := .a
TARGET_OUT_STATIC_LIBRARIES := $(PRODUCT_OUT)/obj/STATIC_LIBRARIES
LOCAL_SRC_FILES := $(mkfs_f2fs_src_files)
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS)


include $(BUILD_SYSTEM)/binary.mk

$(LOCAL_BUILT_MODULE): ALL_OBJS := $(all_objects)
$(LOCAL_BUILT_MODULE): PRIVATE_ALL_OBJECTS := $(patsubst %.a,%.o,$(LOCAL_BUILT_MODULE))
$(LOCAL_BUILT_MODULE): $(LOCAL_PATH)/Android.mk $(all_objects)
	$(TARGET_LD) -r $(ALL_OBJS) -o $(PRIVATE_ALL_OBJECTS)
	$(transform-o-to-static-lib)
	$(TARGET_OBJCOPY) --redefine-sym main=mkfs_f2fs_main $@
	$(TARGET_OBJCOPY) --keep-global-symbol mkfs_f2fs_main $@
	

#----------------------------------------------------------
fsck_f2fs_src_files := \
	fsck/dir.c \
	fsck/dict.c \
	fsck/mkquota.c \
	fsck/quotaio.c \
	fsck/quotaio_tree.c \
	fsck/quotaio_v2.c \
	fsck/node.c \
	fsck/segment.c \
	fsck/xattr.c \
	fsck/main.c \
	fsck/mount.c \
	fsck/dump.c \
	fsck/fsck.c \
	fsck/resize.c \
	fsck/defrag.c

#	lib/libf2fs.c \
#	lib/libf2fs_io.c \
#	lib/libf2fs_zoned.c \
#	lib/nls_utf8.c \


include $(CLEAR_VARS)
LOCAL_MODULE := fsck.f2fs
LOCAL_SRC_FILES := $(fsck_f2fs_src_files)
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS) -DWITH_RESIZE -DWITH_DEFRAG -DWITH_DUMP
#LOCAL_SHARED_LIBRARIES := libf2fs libselinux
LOCAL_SHARED_LIBRARIES := libext2_uuid libsparse libbase libf2fs
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)


include $(CLEAR_VARS)
LOCAL_MODULE := libf2fs_fsck_static
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
LOCAL_MODULE_SUFFIX := .a
TARGET_OUT_STATIC_LIBRARIES := $(PRODUCT_OUT)/obj/STATIC_LIBRARIES
LOCAL_SRC_FILES := $(fsck_f2fs_src_files)
LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS)
#LOCAL_STATIC_LIBRARIES := libselinux


include $(BUILD_SYSTEM)/binary.mk

$(LOCAL_BUILT_MODULE): ALL_OBJS := $(all_objects)
$(LOCAL_BUILT_MODULE): PRIVATE_ALL_OBJECTS := $(patsubst %.a,%.o,$(LOCAL_BUILT_MODULE))
$(LOCAL_BUILT_MODULE): $(LOCAL_PATH)/Android.mk $(all_objects)
	$(TARGET_LD) -r $(ALL_OBJS) -o $(PRIVATE_ALL_OBJECTS)
	$(transform-o-to-static-lib)
	$(TARGET_OBJCOPY) --redefine-sym main=fsck_f2fs_main $@
	$(TARGET_OBJCOPY) --keep-global-symbol fsck_f2fs_main $@


#----------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE := libf2fs_static-host
LOCAL_SRC_FILES := $(libf2fs_src_files)
#LOCAL_SRC_FILES := \
    lib/libf2fs.c \
    lib/zbc.c \
    mkfs/f2fs_format.c \
    mkfs/f2fs_format_utils.c \

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS)
LOCAL_EXPORT_CFLAGS := $(version_CFLAGS) $(default_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/mkfs
include $(BUILD_HOST_STATIC_LIBRARY)

#----------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE := libf2fs-host
#LOCAL_SRC_FILES := \
#    lib/libf2fs.c \
#    lib/zbc.c \
#    mkfs/f2fs_format.c \

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS) $(default_CFLAGS) -DANDROID_HOST
LOCAL_EXPORT_CFLAGS := $(version_CFLAGS) $(default_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/mkfs
LOCAL_STATIC_LIBRARIES := \
     libf2fs_fmt-host \

#     libf2fs_ioutils_host \
#     libext2_uuid-host \
#     libsparse_host \
#     libz
# LOCAL_LDLIBS := -ldl
include $(BUILD_HOST_SHARED_LIBRARY)

endif
