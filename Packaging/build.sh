#!/bin/bash

APP_NAME="vkclient.app"
FOLDER_TO_PACK="/Users/$USER/Desktop"

cd ${PROJECT_DIR}
[ -e "${BUILT_PRODUCTS_DIR}/ColoredVK2.dylib" ] || exit 1;

echo "[->] Copying resources to temp directory (stage 1)..."
cp -r "${PROJECT_DIR}/ColoredVK.bundle/." "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle"
#mv "${BUILT_PRODUCTS_DIR}/ColoredVK2.mom"  "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/"
find "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle" -iname '*.strings' -iname '*.plist' -exec plutil -convert binary1 "{}" \;

makeIPA () {
    cp "${BUILT_PRODUCTS_DIR}/ColoredVK2.dylib"  "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle"
    cp "${INFOPLIST_FILE}"                       "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle"

    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${APP_VERSION}" "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${PRODUCT_BUNDLE_IDENTIFIER}" "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/Info.plist"
    
    echo "[->] Compiling additional resources..."
    ${DEVELOPER_BIN_DIR}/actool --minimum-deployment-target ${IPHONEOS_DEPLOYMENT_TARGET} --platform ${PLATFORM_NAME} --compile "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle" "${PROJECT_DIR}/ColoredVK-Prefs/Support/Images.xcassets" >/dev/null
    find ${PROJECT_DIR} -iname '*.xib' -exec bash -c 'FULL_XIB=$(basename {}); XIB_NAME="${FULL_XIB%.*}"; ${DEVELOPER_BIN_DIR}/ibtool --target-device iphone --target-device ipad --minimum-deployment-target 9.0 --compile "${BUILT_PRODUCTS_DIR}/$XIB_NAME.nib" {} >> /dev/null' \;
    find ${PROJECT_DIR} -type f \( -iname '*.storyboard' ! -iname "Launch Screen.storyboard" ! -iname "Main.storyboard" \) -exec bash -c 'FULL_SB=$(basename {}); SB_NAME="${FULL_SB%.*}"; ${DEVELOPER_BIN_DIR}/ibtool --target-device iphone --target-device ipad --minimum-deployment-target 9.0 --compilation-directory "${BUILT_PRODUCTS_DIR}" "{}" >> /dev/null' \;
    rm -rf ${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/*.nib
    rm -rf ${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/*.storyboardc
    mv ${BUILT_PRODUCTS_DIR}/*.nib "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/"
    mv ${BUILT_PRODUCTS_DIR}/*.storyboardc "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/"
    
    echo "[->] Copying resources to temp directory (stage 2)..."
    TEMP_FOLDER="${BUILT_PRODUCTS_DIR}/Temp"
    mkdir "$TEMP_FOLDER"
    cp -r "$FOLDER_TO_PACK/vkclient/Payload" "$TEMP_FOLDER"
    cp -r "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle" "$TEMP_FOLDER/Payload/$APP_NAME"
    
    echo "[->] Injecting LOAD commands..."
    EXECUTABLE_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$TEMP_FOLDER/Payload/$APP_NAME/Info.plist")
    optool install -c load -p "@executable_path/ColoredVK2.bundle/ColoredVK2.dylib" -t "$TEMP_FOLDER/Payload/$APP_NAME/$EXECUTABLE_NAME" >/dev/null
    
    echo "[->] Cleaning (stage 1)..."
    find "$TEMP_FOLDER" -name ".DS_Store" -exec rm -f {} \;
    
    echo "[->] Archiving..."
    cd "$TEMP_FOLDER"
    zip -9qr "$FOLDER_TO_PACK/${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}.ipa" "./Payload"
    cd "${BUILT_PRODUCTS_DIR}"
    zip -9qr "$FOLDER_TO_PACK/${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}.bundle.zip" "./ColoredVK2.bundle"
    
    echo "[->] Cleaning (stage 2)..."
    rm -rf "$TEMP_FOLDER"
}

makeDEB () {
    [ -e "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle/ColoredVK2" ] || exit 1;

    echo "[->] Signing binaries..."
    ldid2 -S "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle"
    ldid2 -S "${BUILT_PRODUCTS_DIR}/ColoredVK2.dylib"
    ldid2 -S "${BUILT_PRODUCTS_DIR}/ColoredVK2_SBHelper.dylib"
    ldid2 -S "${BUILT_PRODUCTS_DIR}/ColoredVK2_Prefs.dylib"

    echo "[->] Copying resources to temp directory (stage 2)..."
    mkdir -p $FOLDER_TO_PACK/Package/{DEBIAN,Library/{MobileSubstrate/DynamicLibraries,PreferenceBundles,PreferenceLoader/Preferences}}
    
    case ${CONFIGURATION} in
        "Debug_DEB")
            cp "${PROJECT_DIR}/Packaging/control_debug" "$FOLDER_TO_PACK/Package/DEBIAN/control"
            cp "${PROJECT_DIR}/Packaging/respring" "$FOLDER_TO_PACK/Package/DEBIAN/postinst"
            cp "${PROJECT_DIR}/Packaging/respring" "$FOLDER_TO_PACK/Package/DEBIAN/postrm"
            ;;
        "Release_DEB")
            cp "${PROJECT_DIR}/Packaging/control_release" "$FOLDER_TO_PACK/Package/DEBIAN/control"
            ;;
    esac
    
    sed -i '' "s/PACKAGE_VERSION/${APP_VERSION}/g" "$FOLDER_TO_PACK/Package/DEBIAN/control"
    
    cp -r "${BUILT_PRODUCTS_DIR}/ColoredVK2.bundle"         "$FOLDER_TO_PACK/Package/Library/PreferenceBundles"
    cp "${BUILT_PRODUCTS_DIR}/ColoredVK2.dylib"             "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries"
    cp "${BUILT_PRODUCTS_DIR}/ColoredVK2_SBHelper.dylib" "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries"
    cp "${BUILT_PRODUCTS_DIR}/ColoredVK2_Prefs.dylib" "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries"

    cp "${PROJECT_DIR}/Packaging/ColoredVK2.plist"              "$FOLDER_TO_PACK/Package/Library/PreferenceLoader/Preferences"
    cp "${PROJECT_DIR}/Packaging/ColoredVK2-dylib.plist"        "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries/ColoredVK2.plist"
    cp "${PROJECT_DIR}/Packaging/ColoredVK2_SBHelper.plist"  "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries/"
    cp "${PROJECT_DIR}/Packaging/ColoredVK2_Prefs.plist"  "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries/"

    cd $FOLDER_TO_PACK

    echo "[->] Cleaning (stage 1)..."
    find "Package" -name ".DS_Store" -exec rm -f {} \;

    FOLDER_SIZE=$(du -sk "Package")
    INSTALLED_SIZE=$(echo $FOLDER_SIZE | tr -dc '0-9' )
    sed -i '' "s/PACKAGE_SIZE/${INSTALLED_SIZE}/g" "$FOLDER_TO_PACK/Package/DEBIAN/control"

    echo "[->] Packaging..."
    dpkg-deb -b -Zlzma "Package" "${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb" 2> /dev/null

    echo "[->] Cleaning (stage 2)..."
    rm -rf Package
}

case ${CONFIGURATION} in
    "Release_DEB")
        makeDEB
        ;;
    "Debug_DEB")
        makeDEB
        ;;
    "Release_IPA")
        makeIPA
        ;;
    "Debug_IPA")
        makeIPA
        ;;
esac
