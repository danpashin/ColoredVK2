#!/bin/bash

PRODUCT="ColoredVK2"
APP_NAME="vkclient.app"
FOLDER_TO_PACK="/Users/$USER/Desktop"

cd ${PROJECT_DIR}

echo "[->] Copying resources to temp directory (1)..."
cp -r "${PROJECT_DIR}/ColoredVK.bundle/." "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle"
#rm "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/Icon*"
#ls "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/"
mv "${BUILT_PRODUCTS_DIR}/$PRODUCT.mom"  "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/"
find "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle" -iname '*.strings' -exec plutil -convert binary1 "{}" \;
find "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle" -iname '*.plist'   -exec plutil -convert binary1 "{}" \;

makeIPA () {
    cp "${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib"  "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle"
    cp "${PROJECT_DIR}/${INFOPLIST_FILE}" "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle"
    
    echo "[->] Compiling additional resources..."
    ${DEVELOPER_BIN_DIR}/actool --minimum-deployment-target ${IPHONEOS_DEPLOYMENT_TARGET} --platform ${PLATFORM_NAME} --compile "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle" "${PROJECT_DIR}/ColoredVK-Prefs/Images.xcassets" >/dev/null
    find ${PROJECT_DIR} -iname '*.xib' -exec bash -c 'FULL_XIB=$(basename {}); XIB_NAME="${FULL_XIB%.*}"; ${DEVELOPER_BIN_DIR}/ibtool --compile "${BUILT_PRODUCTS_DIR}/$XIB_NAME.nib" {} >> /dev/null' \;
    find ${PROJECT_DIR} -type f \( -iname '*.storyboard' ! -iname "Launch Screen.storyboard" ! -iname "Main.storyboard" \) -exec bash -c 'FULL_SB=$(basename {}); SB_NAME="${FULL_SB%.*}"; ${DEVELOPER_BIN_DIR}/ibtool --target-device iphone --target-device ipad --minimum-deployment-target 9.0 --compilation-directory "${BUILT_PRODUCTS_DIR}" "{}" >> /dev/null' \;
    rm -rf ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/*.nib
    rm -rf ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/*.storyboardc
    mv ${BUILT_PRODUCTS_DIR}/*.nib "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/"
    mv ${BUILT_PRODUCTS_DIR}/*.storyboardc "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/"
    
    echo "[->] Copying resources to temp directory (2)..."
    TEMP_FOLDER="${BUILT_PRODUCTS_DIR}/Temp"
    mkdir "$TEMP_FOLDER"
    cp -r "$FOLDER_TO_PACK/vkclient/Payload" "$TEMP_FOLDER"
    cp -r "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle" "$TEMP_FOLDER/Payload/$APP_NAME"
    
    echo "[->] Injecting LOAD commands..."
    EXECUTABLE_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$TEMP_FOLDER/Payload/$APP_NAME/Info.plist")
    optool install -c load -p "@executable_path/$PRODUCT.bundle/$PRODUCT.dylib" -t "$TEMP_FOLDER/Payload/$APP_NAME/$EXECUTABLE_NAME" >/dev/null
    
    echo "[->] Cleaning (1)..."
    find "$TEMP_FOLDER" -name ".DS_Store" -exec rm -rf {} \;
    
    echo "[->] Archiving..."
    cd "$TEMP_FOLDER"
    zip -9qr "$FOLDER_TO_PACK/${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}.ipa" "./Payload"
    cd "${BUILT_PRODUCTS_DIR}"
    zip -9qr "$FOLDER_TO_PACK/${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}.bundle.zip" "./$PRODUCT.bundle"
    
    echo "[->] Cleaning (2)..."
    rm -rf "$TEMP_FOLDER"
}

makeDEB () {
    echo "[->] Signing binaries..."
    codesign -f -v -s "iPhone Distribution: Vektum Tsentr, OOO" "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle"
    codesign -f -v -s "iPhone Distribution: Vektum Tsentr, OOO" "${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib"
    mkdir -p $FOLDER_TO_PACK/Package/{DEBIAN,Library/{MobileSubstrate/DynamicLibraries,PreferenceBundles,PreferenceLoader/Preferences}}
    cp "ColoredVK-Prefs/control" "$FOLDER_TO_PACK/Package/DEBIAN"
    cp -r "${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle" "$FOLDER_TO_PACK/Package/Library/PreferenceBundles"
    cp "${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib" "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries"
    cp "ColoredVK-Prefs/$PRODUCT.plist" "$FOLDER_TO_PACK/Package/Library/PreferenceLoader/Preferences"
    cp "ColoredVK-Prefs/$PRODUCT-dylib.plist" "$FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries/$PRODUCT.plist"
    cd $FOLDER_TO_PACK
    dpkg-deb -b -Zlzma "Package" "${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb"
    rm -rf Package
}

case ${CONFIGURATION} in
    "Release_DEB") makeDEB;;
    "Release_IPA") makeIPA;;
esac
