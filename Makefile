# Drinkmod Flutter Development Commands

.PHONY: help dev dev-web dev-android dev-ios build-web build-android build-ios test clean analyze format generate

help: ## Show this help message
	@echo "Drinkmod Flutter Development Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Start development server with hot reload for Chrome
	flutter run -d chrome

dev-web: ## Start development server for web with custom port
	flutter run -d web-server --web-port=3000

dev-android: ## Start development server for Android
	flutter run -d android

dev-ios: ## Start development server for iOS
	flutter run -d ios

build-web: ## Build for web production
	flutter build web

build-android: ## Build Android APK
	flutter build apk

build-ios: ## Build iOS app
	flutter build ios

test: ## Run all tests
	flutter test

test-watch: ## Run tests in watch mode
	flutter test --watch

clean: ## Clean build files and get dependencies
	flutter clean && flutter pub get

analyze: ## Analyze code for issues
	flutter analyze

format: ## Format all Dart code
	dart format .

generate: ## Generate code (database, etc.)
	flutter packages pub run build_runner build

generate-watch: ## Generate code in watch mode
	flutter packages pub run build_runner watch --delete-conflicting-outputs

deps: ## Get dependencies
	flutter pub get

upgrade: ## Upgrade dependencies
	flutter pub upgrade
