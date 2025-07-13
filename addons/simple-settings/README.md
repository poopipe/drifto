# Simple Settings

A simple settings manager for Godot 4+.

## What Is This

When we started working on our first major project with Godot, we decided that
for the sake of standardization, we wanted a simple, reusable settings manager.
The closest we could find to what we were looking for was a little addon called
[Godot Settings Manager], but it was a bit outdated and didn't comply with our
code standards. So... we thought we could improve on it! Simple Settings is the
result.

## Installation

_**Note:** Simple Settings requires [Godot] or [Redot] 4 or later._

### Using the Asset Library

* Open the editor.
* Navigate to the **AssetLib** tab at the top of the editor and search for
  "Simple Settings".
* Install the Simple Settings plugin.
* Open **Project > Project Settings**, go to **Plugins** and enable the Simple
  Settings plugin.

### Manual Installation

Manual installation lets you use pre-release versions of this plugin by
following the `main` branch.

* [Download the latest release] or clone this Git repository:

  ```sh
  git clone https://gitlab.com/widgitgaming/godot/simple-settings.git
  ```

* Move the `simple-settings/` folder to the `addons` folder in your project.
* Open **Project > Project Settings**, go to **Plugins** and enable the Simple
  Settings plugin.

## Usage

Once you have the plugin installed and activated, you can start building your
settings. First off, you'll have to tell the plugin what settings files to
implement. To do so, set the `config_files` variable as follows:

```js
SimpleSettings.config_files = {
	game = {
		path = "user://game.ini",
	},
	player = {
		path = "user://player.ini",
	},
}
```

The above example will create a `game.ini` file and a `player.ini` file in the
user directory defined in Project Settings.

Once you've defined your config files, load the library:

```js
SimpleSettings.load()
```

Once Simple Settings is loaded, the rest is up to you! Using the above config
file array as an example, you can save a setting to `game.ini` like so:

```js
// Params: <file>, <section/setting>, <value>
SimpleSettings.set_value("game", "misc/first_run", false)
```

The above code will result in the following being written to `game.ini`:

```ini
[misc]

first_run = false
```

Similarly, you can get a value from a config file as follows:

```js
// Params: <file>, <section/setting>, <default value>
SimpleSettings.get_value("game", "misc/first_run", true)
```

Simple Settings is capable of much more, and the code is well documented.
We encourage you to explore and provide feedback, and check back regularly
for updates!

[Godot Settings Manager]: https://github.com/Calinou/godot-settings-manager
[Godot]: https://godotengine.org/
[Redot]: https://www.redotengine.org
[Download the latest release]: https://gitlab.com/widgitgaming/godot/simple-settings/-/archive/main/simple-settings-main.zip
