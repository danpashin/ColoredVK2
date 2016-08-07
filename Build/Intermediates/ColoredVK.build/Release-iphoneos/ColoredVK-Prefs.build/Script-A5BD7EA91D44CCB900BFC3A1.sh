#!/bin/sh
cd ${PROJECT_DIR}

cp -r ColoredVK.bundle/. ${BUILT_PRODUCTS_DIR}/ColoredVK.bundle

if [ -f ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb ];
then rm -rf ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb 
fi

cp -r ColoredVK-Prefs/Package ~/Desktop/
cp -r ${BUILT_PRODUCTS_DIR}/ColoredVK.bundle ~/Desktop/Package/Library/PreferenceBundles
cp ${BUILT_PRODUCTS_DIR}/ColoredVK.dylib ~/Desktop/Package/Library/MobileSubstrate/DynamicLibraries
cd ~/Desktop
dpkg-deb -b -Zgzip Package ${PRODUCT_BUNDLE_IDENTIFIER}_${APP_VERSION}_${PLATFORM_NAME}-arm.deb
rm -rf Package
