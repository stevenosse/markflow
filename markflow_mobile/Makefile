clean-ios:
	@echo "Cleaning iOS build files..."
	flutter clean
	rm -rf ios/Pods ios/Podfile.lock 
	flutter pub get 
	cd ios && pod install && cd ..

codegen:
	@echo "Generating code..."
	fvm dart run build_runner build --delete-conflicting-outputs

i18n:
	@echo "Generating i18n..."
	fvm dart run intl_utils:generate

build-macos:
	@echo "Building macOS..."
	fvm flutter build macos

get:
	@echo "Getting dependencies..."
	fvm flutter pub get

dmg: 
	appdmg config.json ./mf.dmg

pkg:
	make build-macos
	make dmg