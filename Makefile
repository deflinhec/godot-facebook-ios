GODOT_VERSION=3.4.2
GODOT_RELEASE=https://github.com/godotengine/godot/releases/download/
GODOT_PACKAGE=$(GODOT_VERSION)-stable/godot-$(GODOT_VERSION)-stable.tar.xz
FBSDK_RELEASE=https://github.com/facebook/facebook-ios-sdk/releases/latest/download/

# Download and unzip stable Godot engine
godot-engine-%: clean-all
godot-engine-%: export GODOT_VERSION=$*
godot-engine-%:
	curl -LO $(GODOT_RELEASE)$(GODOT_PACKAGE)
	tar -xf godot-$(GODOT_VERSION)-stable.tar.xz
	mv godot-$(GODOT_VERSION)-stable godot
	rm godot-$(GODOT_VERSION)-stable.tar.xz

# Download and unzip 3.4.2 stable Godot engine
godot-engine: clean-all
	curl -LO $(GODOT_RELEASE)$(GODOT_PACKAGE)
	tar -xf godot-$(GODOT_VERSION)-stable.tar.xz
	mv godot-$(GODOT_VERSION)-stable godot
	rm godot-$(GODOT_VERSION)-stable.tar.xz

# Download and unzip latest facebook sdk
sdklibs:
	mkdir .sdk/ || true
	cd ./.sdk; \
		curl -LO $(FBSDK_RELEASE)FBAEMKit-Static_XCFramework.zip; \
		curl -LO $(FBSDK_RELEASE)FBSDKCoreKit-Static_XCFramework.zip; \
		curl -LO $(FBSDK_RELEASE)FBSDKCoreKit_Basics-Static_XCFramework.zip; \
		curl -LO $(FBSDK_RELEASE)FBSDKShareKit-Static_XCFramework.zip; \
		curl -LO $(FBSDK_RELEASE)FBSDKLoginKit-Static_XCFramework.zip; \
		unzip \*.zip; \

deploylibs:
	mkdir -p plugin/facebook/
	cd ./.sdk; \
		cp *.xcframework ../plugin/facebook/lib/ 

# Build plugin
build: clean
	mkdir bin
	./scripts/generate_headers.sh || true
	./scripts/release_static_library.sh 3.x

clean:
	rm -rf bin

clean-all: clean
	rm -rf godot godot-*
	rm -rf .sconsign.dblite

default: godot-engine build

        