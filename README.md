# Ultima Loca

This generator enables (mixed !) narrow & wide rivers and well-defined mountain ranges with very flat areas inbetween.

It is still WIP but functional and safe to use.

The reason I made this was because I found the vanilla generator and other modded generators didn't create very scenic and practical maps because the transitions between highland and lowland was too gradual & 'bumpy' for my taste. Also, I wanted to have more control over rivers; especially their widths.

## Mountains
- Higher mountains (upto about 1500m) with a more distinct transition between flatland and cliffs.
- If you enable snow tops in the mod settings (on by default) mountain tops will be covered in snow above ~750m.
- NOTE: Mountain density is a fickle setting which seems to depend (internally) on the map seed. Esp. if you set the maximum mountain height to maximum. (I'm still finetuning this).

## Rivers
- Rivers can be much narrower and wider than in vanilla. (Keep in mind that ships cannot navigate very narrow rivers.)
- Wider rivers are also deeper (still experimenting with this).
- Lake generation in rivers can be disabled.
- More rivers.
- Curved rivers.
- Random river widths (still experimenting with this).
- Option to make rivers 'zig-zag' more (since v1.2).

## Rocks
- Option to disable scattered rocks on the map; completely or keep them along rivers.

## Trees & Forests
- Amount of scattered forests can be set (tree density).
- Tree density also affects the density of forests along mountain ridges.
- The treeline (height) on mountains can be changed.

### TODO:
- Option to add a coastline? (help needed)
- Scattered lakes (outside rivers)? (help needed)
- Translations
- Finetuning (mountain height-density ratio, river depth & width randomness)
- Known Issue: Rocks do not render when trees are set to 0.

### Important
If you enable the snow caps option, they will also appear in the (temperate) vanilla generator and any other modded generator that uses the temperate climate.
