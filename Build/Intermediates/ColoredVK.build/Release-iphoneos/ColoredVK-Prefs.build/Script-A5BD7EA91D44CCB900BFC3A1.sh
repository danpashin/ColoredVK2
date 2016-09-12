#!/bin/sh
cd ${PROJECT_DIR}

cp -r ${PROJECT_DIR}/ColoredVK.bundle/. ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.bundle

if [ -f ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb ];
then rm -rf ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb 
fi

cp -r ColoredVK-Prefs/Package ~/Desktop/
cp -r ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.bundle ~/Desktop/Package/Library/PreferenceBundles
cp ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.dylib ~/Desktop/Package/Library/MobileSubstrate/DynamicLibraries
echo "{ Filter = { Bundles = ( \"com.vk.vkclient\" ); }; }" >> ~/Desktop/Package/Library/MobileSubstrate/DynamicLibraries/${PRODUCT_NAME}.plist
cd ~/Desktop
dpkg-deb -b -Zgzip Package ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb
rm -rf Package
