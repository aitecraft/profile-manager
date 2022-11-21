# Aitecraft Profile Manager

A heavily customizable profile manager built specifically for Fabric modpacks. Featuring multi-language support and an easy to modify configuration for all your modpack needs.

Interested to use this with your modpack? Check the [wiki](https://github.com/aitecraft/profile-manager/wiki).

Built and supported by the Aitecraft team.

### Development Status

The basic functionality of the profile manager is complete. The profile manager is useable for most cases and we will continue to provide fixes if needed. If there are any features or documentation changes you would like (us) to add, please create an issue or pull request.

## Implemented Features

### Multi-language support
Modify the `resources/lang/languages.json` file and add `.json` files as required to add new languages. No code changes required!

### Extremely Customizable
Modify the `resources/config.json` file to fit your exact needs for your modpack. Everything from changing the API root to even disabling the Aitecraft-related features are fully supported. Tweak RAM values as appropriate for your modpack or change the default MC install directory as you see fit for your audience! Even the Profile Manager branding can be changed!

Other customizable options include: Default Language, Profile Icon (for Vanilla Launcher), JVM arguments, and of course the Profile ID and Name.

Once again, all these significant changes can all be applied without any code changes.

### Optimizer Mod Selection
Have mods that only certain users prefer? You can now let them choose the mod they prefer. Although referred to as the "Optimizer Mod Selection", thanks to the customizable API, you can use it to let the user choose any specific mod or set of mods.

### Fabric First
Fabric is at the forefront of Aitecraft Profile Manager. It will automatically install any version of Fabric as instructed by your API! No more manually updating Fabric.

### Modrinth & Curseforge Support
Aitecraft Profile Manager can fetch mod files directly from Modrinth or CurseForge. For Modrinth, providing the project slugs and version names is enough for the profile manager to download the mod files. For CurseForge, providing the mod ID and file ID is sufficient.

File verification also works on Modrinth-provided and CurseForge-provided files.

### Incremental Updates
Updating even large modpacks will be a breeze for your users thanks to an incremental update system, that works by only downloading files that have been updated or were never on your install.

### Built for All Hardware
Built on AutoIt3, Aitecraft Profile Manager is supported across a wide range of Windows versions, from 7 to the latest builds of 11, without any sacrifices on any version. Thanks to the lightweight nature of AutoIt, Aitecraft Profile Manager consumes <20 MB of memory! This is far lower than anything using web-based technologies. All that while having a far simpler and easier to customize codebase than a similar C/C++ codebase! (Especially GUIs)

### Bootstrapper
Included as part of this source code is the Bootstrapper, a simple tool that downloads the profile manager and keeps it updated.

### Import Feature
Helps users import Minecraft settings and mod configurations from any of their existing Minecraft installations directly into the custom directory for your modpack.

## Planned Features

These are features that we plan to add before reaching v1.0.

### Download via Browser
Looking at you OptiFine.
