#!/bin/sh

PRODUCT=ColoredVK2
CERTIFICATE_NAME="iPhone Developer: dytre18@gmail.com (A6W3ZT3UD6)"
APP_NAME=vkclient.app
FOLDER_TO_PACK=~/Desktop;

cd ${PROJECT_DIR}

echo "[->] Copying resources to temp directory..."
cp -r ColoredVK.bundle/. ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle
echo "[->] Signing binaries..."
codesign -f -v -s "$CERTIFICATE_NAME" ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/$PRODUCT


makeIPA () {
#    echo "[->] Compiling additional resources..."
#    find ${PROJECT_DIR}/ColoredVK-Prefs -iname '*.xcassets' -exec ${DEVELOPER_BIN_DIR}/actool  --output-format human-readable-text --notices --warnings --compress-pngs --enable-on-demand-resources NO --target-device iphone --target-device ipad --minimum-deployment-target 8.0 --platform iphoneos --product-type com.apple.product-type.bundle --compile  ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle "{}" \;
#    find ${PROJECT_DIR}/ColoredVK-Prefs -iname '*.storyboard' -exec ${DEVELOPER_BIN_DIR}/ibtool --auto-activate-custom-fonts --target-device iphone --target-device ipad --minimum-deployment-target 8.0 --output-format human-readable-text --compilation-directory ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle "{}" \;
    
    echo "[->] Copying resources to temp directory..."
    TEMP_FOLDER=${BUILT_PRODUCTS_DIR}/Temp
    mkdir $TEMP_FOLDER
    cp -r $FOLDER_TO_PACK/vkUnarch/Payload $TEMP_FOLDER
    cp -r ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle $TEMP_FOLDER/Payload/$APP_NAME
    cp    ${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib  $TEMP_FOLDER/Payload/$APP_NAME
    
    cd $TEMP_FOLDER/Payload/$APP_NAME
    
    echo "[->] Signing binaries..."
    optool install -c load -p "@executable_path/$PRODUCT.dylib" -t vkclient
    
    echo "[->] Archiving..."
    find ../. -name ".DS_Store" -exec rm -rf {} \;
    find . -name ".DS_Store" -exec rm -rf {} \;
    cd $TEMP_FOLDER
    zip -9qr buffer.ipa ./Payload
    cd ${BUILT_PRODUCTS_DIR}
    zip -9qr bndl.zip ./$PRODUCT.bundle ./$PRODUCT.dylib
    
    echo "[->] Copying to destination folder..."
    mv $TEMP_FOLDER/buffer.ipa ~/Desktop/$PRODUCT.ipa
    mv bndl.zip $FOLDER_TO_PACK/$PRODUCT.zip
    
    echo "[->] Cleaning..."
    rm -rf $TEMP_FOLDER
}

makeDEB () {
    mkdir -p $FOLDER_TO_PACK/Package/{DEBIAN,Library/{MobileSubstrate/DynamicLibraries,PreferenceBundles,PreferenceLoader/Preferences}}
    cp -r ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle $FOLDER_TO_PACK/Package/Library/PreferenceBundles
    cp ColoredVK-Prefs/Package/DEBIAN/control $FOLDER_TO_PACK/Package/DEBIAN
    cp ${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib $FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries
    echo "{ Filter = { Bundles = ( \"com.vk.vkclient\" ); }; }" >> $FOLDER_TO_PACK/Package/Library/MobileSubstrate/DynamicLibraries/$PRODUCT.plist
    cd $FOLDER_TO_PACK
    dpkg-deb -b -Zlzma Package ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb
    rm -rf Package
}

case ${CONFIGURATION} in
    "Release_DEB") makeDEB;;
    "Release_IPA") makeIPA;;
esac
