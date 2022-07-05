# Ultima Loca

A temperate terrain generator with some extra features.
It is still WIP but functional and safe to use.

## Mountains
- Higher mountains with a more distinct transition between flatland and mountain ranges.
- You can set the amount of mountains (density) and peak-height separately.
- There is a threshold where density goes down again when you set the height over a certain value. I have done this because of how the game calculates the terrain and this prevents maps from having 100% mountains only.

## Rivers
- Rivers can be much narrower and wider than in vanilla.
- Lake generation in rivers can be disabled.
- More rivers.
- Random river widths.
- Keep in mind that ships cannot navigate very narrow rivers.

## Rocks
- Option to disable scattered rocks on the map, they still generate along rivers.

## Trees & Forests
- Amount of scattered forests can be set (tree density).
- Tree density  affects the density of forests along mountain ridges in a limited way only. Except when set to 0 (then no trees will generate at all).
- The treeline (height) on mountains can be changed.
