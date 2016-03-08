#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY=$(cd "${1%/*}" && pwd)
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "PEPhotoCropEditor/Resources/PEPhotoCropEditor.bundle"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/approve.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/approve@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/approve@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/close.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/close@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/close@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/pause.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/pause@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/pause@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/play.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/play@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/play@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/record.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/record@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/record@3x.png"
  install_resource "RSKImageCropper/RSKImageCropper/RSKImageCropperStrings.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/UMSocialSDKResourcesNew.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_Extra_Frameworks/TencentOpenAPI/TencentOpenApi_IOS_Bundle.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_Extra_Frameworks/SinaSSO/WeiboSDK.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSCommentDetailController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSCommentInputController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSCommentInputControlleriPad.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMShareEditViewController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMShareEditViewControlleriPad.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSLoginViewController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSnsAccountViewController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSShareListController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/en.lproj"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/zh-Hans.lproj"
  install_resource "WechatShortVideo/WechatShortVideo/WechatShortVideoController.xib"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_37x-Checkmark.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_37x-Checkmark@2x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_close.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_close@2x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_close@3x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_scan_focus.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_scan_focus@2x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_scan_focus@3x.png"
  install_resource "${BUILT_PRODUCTS_DIR}/FDWaveformView.bundle"
  install_resource "${BUILT_PRODUCTS_DIR}/QBImagePicker.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "PEPhotoCropEditor/Resources/PEPhotoCropEditor.bundle"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/approve.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/approve@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/approve@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/close.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/close@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/close@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/pause.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/pause@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/pause@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/play.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/play@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/play@3x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/record.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/record@2x.png"
  install_resource "PMAudioRecorderViewController/AudioNoteRecorderViewController/Images/record@3x.png"
  install_resource "RSKImageCropper/RSKImageCropper/RSKImageCropperStrings.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/UMSocialSDKResourcesNew.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_Extra_Frameworks/TencentOpenAPI/TencentOpenApi_IOS_Bundle.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_Extra_Frameworks/SinaSSO/WeiboSDK.bundle"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSCommentDetailController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSCommentInputController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSCommentInputControlleriPad.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMShareEditViewController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMShareEditViewControlleriPad.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSLoginViewController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSnsAccountViewController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/SocialSDKXib/UMSShareListController.xib"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/en.lproj"
  install_resource "UMengSocial/Umeng_SDK_Social_iOS_ARM64_5.0/UMSocial_Sdk_5.0/zh-Hans.lproj"
  install_resource "WechatShortVideo/WechatShortVideo/WechatShortVideoController.xib"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_37x-Checkmark.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_37x-Checkmark@2x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_close.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_close@2x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_close@3x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_scan_focus.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_scan_focus@2x.png"
  install_resource "WechatShortVideo/WechatShortVideo/Resources/WechatShortVideo_scan_focus@3x.png"
  install_resource "${BUILT_PRODUCTS_DIR}/FDWaveformView.bundle"
  install_resource "${BUILT_PRODUCTS_DIR}/QBImagePicker.bundle"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
