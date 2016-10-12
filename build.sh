#!/bin/sh

PRODUCT=ColoredVK2
CERTIFICATE_NAME="iPhone Developer: dytre18@gmail.com (A6W3ZT3UD6)"
APP_NAME=vkclient.app

cd ${PROJECT_DIR}

echo "[->] Copying files to temp directory..."
cp -r ColoredVK.bundle/. ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle
echo "[->] Signing binaries..."
codesign -f -v -s "$CERTIFICATE_NAME" ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle/$PRODUCT


makeIPA () {
    echo "[->] Copying files to temp directory..."
    TEMP_FOLDER=${BUILT_PRODUCTS_DIR}/Temp
    mkdir $TEMP_FOLDER
    cp -r ~/Desktop/vkUnarch/Payload $TEMP_FOLDER
    cp -r ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle $TEMP_FOLDER/Payload/$APP_NAME
    cp    ${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib $TEMP_FOLDER/Payload/$APP_NAME
    
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
    mv bndl.zip ~/Desktop/$PRODUCT.zip
    
    echo "[->] Cleaning..."
    rm -rf $TEMP_FOLDER
}

makeDEB () {    
    cp -r ColoredVK-Prefs/Package ~/Desktop/
    cp -r ${BUILT_PRODUCTS_DIR}/$PRODUCT.bundle ~/Desktop/Package/Library/PreferenceBundles
    cp ${BUILT_PRODUCTS_DIR}/$PRODUCT.dylib ~/Desktop/Package/Library/MobileSubstrate/DynamicLibraries
    echo "{ Filter = { Bundles = ( \"com.vk.vkclient\" ); }; }" >> ~/Desktop/Package/Library/MobileSubstrate/DynamicLibraries/$PRODUCT.plist
    cd ~/Desktop
    dpkg-deb -b -Zlzma Package ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb
    rm -rf Package
}

case ${CONFIGURATION} in
    "Release_DEB") makeDEB;;
    "Release_IPA") makeIPA;;
esac
