all: android osx ios

.PHONY: clean
.PHONY: clean-android
.PHONY: clean-osx
.PHONY: clean-ios
.PHONY: android
.PHONY: osx
.PHONY: ios
.PHONY: check-ndk
.PHONY: cmake-osx
.PHONY: cmake-android
.PHONY: cmake-ios
.PHONY: install-android

ANDROID_BUILD_DIR = build/android
OSX_BUILD_DIR = build/osx
IOS_BUILD_DIR = build/ios

TOOLCHAIN_DIR = build/toolchains
IOS_TARGET = tangram
IOS_XCODE_PROJ = tangram.xcodeproj

ifndef ANDROID_ARCH
	ANDROID_ARCH = x86
endif

ANDROID_CMAKE_PARAMS = \
	-DPLATFORM_TARGET=android \
	-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_DIR}/android.toolchain.cmake \
	-DMAKE_BUILD_TOOL=$$ANDROID_NDK/prebuilt/darwin-x86_64/bin/make \
	-DANDROID_ABI=${ANDROID_ARCH} \
	-DANDROID_STL=c++_shared \
	-DANDROID_NATIVE_API_LEVEL=android-19 

IOS_CMAKE_PARAMS = \
	-DPLATFORM_TARGET=ios \
	-DIOS_PLATFORM=SIMULATOR \
	-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_DIR}/iOS.toolchain.cmake \
	-G Xcode

DARWIN_CMAKE_PARAMS = \
	-DPLATFORM_TARGET=darwin

clean: clean-android clean-osx clean-ios

clean-android:
	ndk-build -C android/jni clean
	ant -f android/build.xml clean
	rm -rf ${ANDROID_BUILD_DIR}
	rm -rf android/libs android/obj

clean-osx:
	rm -rf ${OSX_BUILD_DIR}

clean-ios:
	rm -rf ${IOS_BUILD_DIR}

android: install-android android/libs/${ANDROID_ARCH}/libtangram.so android/build.xml
	ant -f android/build.xml debug

install-android: check-ndk cmake-android ${ANDROID_BUILD_DIR}/Makefile
	cd ${ANDROID_BUILD_DIR} && \
	${MAKE} && \
	${MAKE} install

cmake-android:
	mkdir -p ${ANDROID_BUILD_DIR} 
	cd ${ANDROID_BUILD_DIR} && \
	cmake ../.. ${ANDROID_CMAKE_PARAMS}

osx: cmake-osx ${OSX_BUILD_DIR}/Makefile
	cd ${OSX_BUILD_DIR} && \
	${MAKE}

cmake-osx: 
	mkdir -p ${OSX_BUILD_DIR} 
	cd ${OSX_BUILD_DIR} && \
	cmake ../.. ${DARWIN_CMAKE_PARAMS}

ios: cmake-ios ${IOS_BUILD_DIR}/${IOS_XCODE_PROJ}
	xcodebuild -target ${IOS_TARGET} -project ${IOS_BUILD_DIR}/${IOS_XCODE_PROJ}

cmake-ios:
ifeq ($(wildcard ${IOS_BUILD_DIR}/${IOS_XCODE_PROJ}/.*),)
	mkdir -p ${IOS_BUILD_DIR}
	cd ${IOS_BUILD_DIR} && \
	cmake ../.. ${IOS_CMAKE_PARAMS}
endif

check-ndk:
ifndef ANDROID_NDK
	$(error ANDROID_NDK is undefined
endif
