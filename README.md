# maple's retro extravaganza

it's a minecraft shader pack with some palettes to emulate retro console graphics. isn't it great?

## screenshots

![Sage Minor System](screenshots/sms.png)
_Sage Minor System_

![Captain 64 palette with 6x3 pixels](screenshots/c64.png)
_Captain 64 palette with 6x3 pixels_

![For Workgroups](screenshots/wfw.png)
_For Workgroups (day)_

![Gremlin Boy](screenshots/gb.png)
_Gremlin Boy (night)_

## usage

get optifine installed in your java minecraft version of choice and download this repository as a zip into your shaderpacks folder

you can also unpack it into its own folder inside shaderpacks

## modding

if you're feeling adventurous, making a color look-up image for a custom palette is simple, just take the identity LUT in `shaders/textures/clut_identity.png` and modify it to fit your palette. there are also some additional palettes not enabled in the shader that you can play around with. look at `shaders/shaders.properties` to find where to change the path for LUT textures.