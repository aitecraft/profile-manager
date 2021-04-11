# Aitecraft Profile Manager

Introducing the Aitecraft Profile Manager, a heavily customizable profile manager built from the ground up, specifically for Fabric modpacks. Featuring multi-language support and an easy to modify configuration for all your modpack needs.

Built and supported by the Aitecraft team.

### Development Status

⚠ Currently in development.

So far, the basic functionality of the profile manager has been completed. We have currently paused development as we believe the profile manager is useable for most cases. If there are any features you would like (us) to add, please create an issue or pull request.

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

### Incremental Updates
Updating even large modpacks will be a breeze for your users thanks to a modern update system, that works by only downloading files that have been updated or were never on your install.

### Built for All Hardware
Built on AutoIt3, Aitecraft Profile Manager is supported across a wide range of Windows versions, from 7 to the latest builds of 10, without any sacrifices on any version. Thanks to the lightweight nature of AutoIt, Aitecraft Profile Manager consumes <20 MB of memory! This is far lower than anything using web-based technologies. All that while having a far simpler and easier to customize codebase than a similar C/C++ codebase! (Especially GUIs)

## Planned Features

These are features that we plan to add before reaching v1.0.

### Download via Browser
Looking at you OptiFine.

## Planned Features II

These are nice-to-have features that we are planning to add post v1.0. No promises though.

### Single-file Download Option
Tweak just a couple of lines of code and build the Profile Manager as a standalone executable that downloads the configuration files on its own, from your own API instead of having to ship ZIP files and then spending time helping less tech savvy users.

Note: Since an EXE compiled via AutoIt is almost always flagged as a trojan by Windows Security / Defender, just shipping the ZIP with a standard `AutoIt3.exe`, a compiled `au3` file and a batch script to launch the Profile Manager might be more user friendly than this solution.

### Import Feature
Helps users import Minecraft settings and resource packs from any of their existing Minecraft installations directly into the custom directory for your modpack.

#### Expanded Import for Aitecraft Launcher
Should you choose to enable the option, users of the Aitecraft Launcher will have the option to import almost everything to the modpack custom directory, including screenshots, schematics and world saves in addition to the Minecraft settings and resource packs.

### Language Fallbacks
Incomplete translations? No worries! The Profile Manager will use translation strings from a fallback language of your choosing!

## Other stuff

Few things regarding this repo:

- The resources directory will probably be removed soon, since the changes to it aren't necessarily updates to the profile manager itself, but rather updates to just our own implementatation of it.
    - We will provide a wiki to help configure the API and `config.json` in the future.
- We will not make any code changes privately just for our modpack. In the event we do so, we will make that very clear. We want this project to be something the modpack community can use to easily distribute their mods.
