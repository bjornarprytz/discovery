# Evening jam: Discovery

"The pun is mightier than the word"

[Play it here](https://thewarlock.itch.io/discovery)

## Stipulation: Text based

try to find as many words as possible

Goal: collect specific words to increase high score

## Short term implementation

- Show Player Trophy Room (run stats)
  - Highlight best scores with some BBCode
  - Clarify meaning of: Highest score, Most words, Most Quests, Most moves
  - Color from palette

- UI
  - Settings / Main Menu (Rework)
    - Choose seed
    - Palette
    - Choose Corpus
    - See stats + leaderboard

- OnDeadEnd
  - Show run Stats
  - Zoom Out
    - Add additional segments as needed in order to see the whole path

- QoL
  - When there are no available moves (not even duplicate), count down to tutorialize the Dead End

- Verify that cloud saves work on steam

- Achievements:
  - No Place Like Home

## 1.1 roadmap (October Update)

- Add main menu (after the player has done their first run)
  - Set seed
  - Choose corpus
- OnDeadEnd
  - Stats from the run
  - Other visual representation of the run
    - Zoom out to see the path?
    - See every letter
    - See the words
  - Get seed
- New ambience
  - Group into themed ambiance
- Extra Corpus
  - How does this affect the leaderboard?
  - Maybe one per official text?
- OnNewQuest
  - Highlight the quest words more?

### Nice to have

- Ingest custom texts
- Use VisibleOnScreenNotifier2D on the text-segment
- Make all ambiance "loopable"
- New Game Mode: Vertical Limit
  - Limited number of vertical moves
  - New Lose condition: running out of vertical moves
  - Get additional moves when completing a word (depending on length?)

- Still support web export
  - Branch, and remove steam references from that version, and update the export templates
  - Add steam link

### Bugs

### Feedback

- More rewards for progression
  - Do something more with the chapters
- More game modes

### Optimization

### Steam integration

- Push tag `steam-v*`
- Move the release branch up to default
  - TODO: Figure out if I can deploy to 'default' branch directly

#### Rich Presence

- Upload rich_presence.txt to: https://partner.steamgames.com/apps/richpresence/3033230
  - Docs: https://partner.steamgames.com/doc/features/enhancedrichpresence

### Future Scope

- Seed
- Workshop integration with the corpus
- Power-ups?
- Chapter transition
- MacOS support?

### Add

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
