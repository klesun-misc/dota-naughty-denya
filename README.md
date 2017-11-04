### Setup

- Open Git Bash inside your `C:\g\Steam\steamapps\common\dota 2 beta` directory.
- Enter these commands:
```bash
git init
git remote add origin https://github.com/klesun/green-envy-xmas-defense
git fetch
git reset origin/master  # this is required if files in the non-empty directory are in the repo
git checkout -t origin/master
```

- Now you can open this map from the Hammer (map editor) and launch it normally (though it has .txt extension, so you'll need to select "All Files" in dropdown menu).

In Steam Repo: http://steamcommunity.com/sharedfiles/filedetails/?id=1170060197
___________________________

### Creeps vs Towers X-Mas Defenders

Two teams, each has heroes. Good guys build towers to help them defend the christmas tree while it is "being decorated" (30 minutes or so), they survive - they win. Bad guys spawn creeps to help them defeat good guys, each spawned creep increases their income.

Unlike other "Castle Defense"-type maps, here you can also build towers (i suppose they should be made vital for survival somehow), so you always have to decide, whether spend money on tower or on items.

Unlike other "Tower Wars"-type maps, here each player has a hero, that takes part in the siege/defence and creeps don't ignore towers - they have to first defeat the defenders before they can go further.

![green_envy_xmas_defense_cover](https://user-images.githubusercontent.com/30558426/31322188-d567d23c-ac9b-11e7-8161-ced532485982.png)

__________________________

#### Description in Workshop

Story: the Dire was too sad about all their christmas trees being ashened, so they decided to burn all the beautiful green christmas trees belonging to the Radiant.

Game rules: Radiant have to defend their Christmas Tree (aka Castle) from the Dire. Radiant heroes can build towers, Dire heroes can build barracks.

The game is currently in a sketch state (basic waves powering up over time and few towers).

https://github.com/klesun-misc/green-envy-xmas-defense