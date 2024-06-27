# Evening jam: Discovery

"The pun is mightier than the word"

[Play it here](https://thewarlock.itch.io/discovery)

## Stipulation: Text based

try to find as many words as possible

Goal: collect specific words to increase high score

## 1.0 roadmap

- Fix mac export
- Make all ambiance "loopable"
- Attribution
  - Mia Karlsen
  - Marja Gundersen
  - Axel Gundersen
  - Ola (?)

- Finish TODOs
- Still support web export
  - Add steam link

### Bugs

### Feedback

### Optimization

### Steam integration

- Achievements
  - Add icons

#### Rich Presence

- Upload rich_presence.txt to: https://partner.steamgames.com/apps/richpresence/3033230
  - Docs: https://partner.steamgames.com/doc/features/enhancedrichpresence

### Future Scope

- Power-ups?
- Chapter transition

## Tools & Resources

- Godot
- ChatGPT
- [RichTextEffects](https://github.com/teebarjunk/godot-text_effects)
- [Freesound](https://freesound.org/)
  - Attribution:
    - Select, Denied 01.wav by MATRIXXX_ -- https://freesound.org/s/404150/ -- License: Creative Commons 0
    - Retro, Coin 06.wav by MATRIXXX_ -- https://freesound.org/s/515736/ -- License: Creative Commons 0
    - Retro, Explosion 07.wav by MATRIXXX_ -- https://freesound.org/s/521105/ -- License: Creative Commons 0
    - Diamond Click.wav by MATRIXXX_ -- https://freesound.org/s/703884/ -- License: Creative Commons 0
    - Coin Pickup.mp3 by Phenala -- https://freesound.org/s/478647/ -- License: Creative Commons 0
    
- [Google fonts](https://fonts.google.com/)
  - [VT323](https://fonts.google.com/specimen/VT323)
- [fontspace.com](https://www.fontspace.com/)
  - [UnifontEX](https://www.fontspace.com/unifontex-font-f26370)
- [Pixabay](https://pixabay.com/)



### MacOS codesign/notarization

From [here](https://www.reddit.com/r/godot/comments/17ql1mv/publishing_on_steam_for_macos/)

A dev has recently told me, it's possible to have unsigned macOS games on Steam without notarization, and it has been reported to be working without issues on the Mac of the dev's acquaintance. Perhaps downloading from a trusted and well-known source like Steam reduces the paranoia of macOS, at least for the time being.

I only know that Steam is specifically requiring macOS games to be notarized, but I haven't tried uploading a build without notarization, so I don't know if it's truly necessary in every case. I have always had all my builds notarized, and they were working on my test Steam accounts on both on my Macs. I haven't yet sold a single macOS version on Steam so I have no info from the user's perspective. (By the way, my game is also v3.5, pure GDScript, but I don't think C# would present any problem in this regard.)

Generally speaking, if you don't notarize your macOS builds, downloading the app from a non-local network will make macOS refuse to start it without modifying the file's attribute via an xattr -cr <path-to-your.app> command, so it's still possible to run it but it requires some technical aptitude.

For notarization, you need to be an active Apple developer, which requires a yearly payment of $100 and some paperwork. The current Godot 3.x export template can do the code signing, but at this moment you cannot perform the notarization, because the 3.x branch still uses altool, which has been deprecated since 2023-11-01 (yes, about a week's time). I understand that switching to the replacement, notarytool, is being worked on, but the PR hasn't been merged yet. Thankfully, using notarytool is a much better experience than altool was, as you no longer need to wait like a caveman until you receive the approval via email from Apple, because notarytool will actually wait for the decision (like curl, for example). EDIT: (By mistake I wrote the following sentence incorrectly, the other way around. The current text has it right, sorry.) You still need to manually staple your .app (not a .zip file, which is needed by notarytool).

In case you're wondering, this is what I do to notarize the signed macOS build:

xcrun notarytool store-credentials $MY_NAME --apple-id $APPLE_ID_NAME --team-id $APPLE_TEAM_ID --password $APP_PASSWORD
xcrun notarytool submit "$ZIP_FILENAME" --keychain-profile $MY_NAME --wait
Once that's done, I'm also stapling the game like so:

xcrun stapler staple "$APP_NAME"
xcrun stapler validate "$APP_NAME"
Good luck!