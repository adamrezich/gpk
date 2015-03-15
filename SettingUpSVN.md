# Introduction #
Many people want to know how to get the latest, greatest GPK files to test; usually because they're making a map and want to test out the newest features. To do this, you need to access GPK's SVN repository. This article explains in detail how to set up your system to download GPK's SVN code by creating a local SVN folder for GPK.

# The procedure #
  1. Download the latest version of [TortoiseSVN](http://tortoisesvn.tigris.org/).
  1. Install it.
  1. Restart your computer.
    1. Alternatively, press CTRL+SHIFT+ESC, and, under the "Processes" tab, find "explorer.exe."
    1. Select it and press "Delete."
    1. Click "File -> New Task (Run...)."
    1. Type in "explorer.exe" and press Enter.
  1. Set up your Garry's Mod folder to look like this:
```
[+] garrysmod
 |--[+] garrysmod
     |--[+] gamemodes
         |--[+] gpk
```
  1. Right-click on the newly created "gpk" folder and click "SVN Checkout."
  1. Fill in "https://gpk.googlecode.com/svn/trunk/" (without the quotes) into the "URL of repository" blank, if you're planning on committing anything (i.e. you're a member). Otherwise, put "http://gpk.googlecode.com/svn/trunk/" (again, without the quotes) in instead.
  1. Press "OK."
  1. If you're asked for a username and password, then that means that you're a developer. Type in your Google Code username and password, and you'll be able to commit changes as well as download the updates.
    1. Your Google Code username is most likely your Gmail address.
    1. It's advisable to check the "Save Login" box so you don't have to go back and find your obscure, randomly-generated password from the Google Code website.
  1. In the future, simply right-click on the "gpk" folder and click "SVN Update..." to update to the latest version of GPK.