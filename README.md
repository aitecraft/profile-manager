# Aitecraft Profile Manager

Introducing the Aitecraft Profile Manager, a heavily customizable profile manager built from the ground up, specifically for Fabric modpacks. Featuring multi-language support and a easy to modify configuration for all your modpack needs.

Coming Q1 2021. Built and supported by the Aitecraft team.

### Development Status

⚠ Currently in development.

Currently only the multi-language support and the basic backbone of the configuration / user preferences systems have been completed. Work on the functional part of the Profile Manager is yet to begin.

## Features

Most of these features are yet to be implemented.

### Multi-language support
Modify the `resources/lang/languages.json` file and add `.json` files as required to add new languages. No code changes required!

### Extremely Customizable
Modify the `resources/config.json` file to fit your exact needs for your modpack. Everything from changing the API root to even disabling the Aitecraft-related features are fully supported. Tweak RAM values as appropriate for your modpack or change the default MC install directory as you see fit for your audience! Even the Profile Manager branding can be changed!

Other customizable options include: Default Language, Profile Icon (for Vanilla Launcher), JVM arguments, and of course the Profile ID and Name.

Once again, all these significant changes can all be applied without any code changes.

### OptiFine or CaffeineMC? Let your users decide.
Stop having to worry about legal issues with shipping OptiFine in your modpacks. Let the Aitecraft Profile Manager handle it for you. The user will be guided by the Profile Manager to correctly download and setup OptiFine.

Or would your users rather have CaffeineMC's mods? That's totally supported as well.

### Fabric First
Fabric is at the forefront of Aitecraft Profile Manager. It will automatically install any version of Fabric as instructed by your API! No more manually updating Fabric.

### User Preferences Storage
User Preferences are stored permanently by the Profile Manager to make installing future updates far more easier.

### Incremental Updates
If you put the time to ensuring your API fully supports incremental updates, updating large modpacks will be a breeze for your users thanks to a modern update system.

### Built for All Hardware
Built on AutoIt3, Aitecraft Profile Manager is supported across a wide range of Windows versions, from 7 to the latest builds of 10, without any sacrifices on any version. Thanks to the lightweight nature of AutoIt, Aitecraft Profile Manager consumes <10 MB of memory! This is far lower than anything using web-based technologies. All that while having a far simpler and easier to customize codebase than a similar C/C++ codebase! (Especially GUIs)

## Planned Features

These are nice-to-have features that we are planning to add post-launch.

### Single-file Download Option



Tweak just a couple of lines of code and build the Profile Manager as a standalone executable that downloads the configuration files on its own, from your own API instead of having to ship ZIP files and then spending time helping less tech savvy users.

### Import Feature



Helps users import Minecraft settings and resource packs from any of their existing Minecraft installations directly into the custom directory for your modpack.

#### Expanded Import for Aitecraft Launcher
Should you choose to enable the option, users of the Aitecraft Launcher will have the option to import almost everything to the modpack custom directory, including screenshots, schematics and world saves in addition to the Minecraft settings and resource packs.

### Language Fallbacks
Incomplete translations? No worries! The Profile Manager will use translation strings from a fallback language of your choosing!

## Other stuff

Few things regarding this repo:

- The resources directory will soon have its own repository, since the changes to it aren't necessarily updates to the profile manager itself, but rather updates to just our own implementatation of it.
    - The license will remain the same, however.
- We will not make any code changes privately just for our modpack. In the event we do so, we will make that very clear. We want this project to be something the modpack community can use to easily distribute their mods.
