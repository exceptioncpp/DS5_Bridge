# Optional SH1107 OLED display

This is the first, deliberately read-only OLED integration for DS5 Bridge. It does not change Bluetooth reports, USB descriptors, host persona switching, or Companion commands. Without `ENABLE_OLED`, the OLED driver is not compiled or linked.

## Supported display and wiring

- **Display:** Waveshare Pico-OLED-1.3, SPI SH1107, 128 x 64 (not the I2C SSD1306 variant).
- **MCU:** Waveshare RP2350B-Plus-W with the display connected to the mapped GPIO pins. It also builds with Pico 2 W when the same pins are available.
- **Pins:** DC GP8, CS GP9, SPI1 SCK GP10, SPI1 MOSI GP11, RST GP12, KEY0 GP15, KEY1 GP17. Logic is **3.3 V**; match the display's documented supply voltage.
- The Pico-OLED-1.3 pinout was taken from [MarcelineVPQ/DS5Dongle-OLED-Edition](https://github.com/MarcelineVPQ/DS5Dongle-OLED-Edition); confirm physical wiring before powering a different carrier board. The default SPI0 pins in the Waveshare board header are unrelated; this display uses SPI1 explicitly.

## Build

Set `PICO_SDK_PATH` to Pico SDK **2.3.0** and add ARM GNU Toolchain
**15.2.Rel1** plus Ninja to `PATH`. Use the same TinyUSB revision as CI:
`2d56dc533e45e4e91b15e93fdab5e22e964f328d`.

From the repository root (Bash or PowerShell):

```sh
cmake --preset waveshare-rp2350b-plus-w-oled-release
cmake --build --preset waveshare-rp2350b-plus-w-oled-release --parallel 2
```

This preset enables `WAVESHARE_RP2350B_PLUS_W_BUILD=ON`,
`ENABLE_OLED=ON`, `ENABLE_COMPANION=ON`, `CMAKE_BUILD_TYPE=Release`,
and `DS5_DIAGNOSTICS_PRESET=off`. It uses its own build directory so
cached Pico 2 W or non-OLED settings cannot select the wrong board.

Local firmware: `build/waveshare-rp2350b-plus-w-oled-release/ds5-bridge.uf2`.

For a downloadable build, open **Actions → Build firmware → Run workflow**,
select branch `feature/optional-sh1107-oled` (or the branch containing this
change), and run it. The three independent CI jobs verify Pico 2 W,
Waveshare without OLED, and Waveshare with OLED. Download
**`ds5-bridge-companion-waveshare-oled.uf2`** from the successful run.
The other two files do not enable the display. This is an optimized
Release build for hardware testing, not a published stable release.

## Behavior

- **Screen 1:** connected controller type (DualSense/Edge), battery percentage, Bluetooth RSSI, host persona (DS5/Edge/DS4/Xbox), USB mount state.
- **Screen 2:** board target, Bluetooth connection, pairing state, USB state, firmware version.
- KEY0 / KEY1 switch screens (no settings or host persona changes). A keypress wakes the display before it changes screens.
- Refresh rate is limited to 10 Hz; unchanged frames produce no SPI output. Screen dims after 2 minutes and shuts off after 15 minutes of inactivity; connection/mount changes or a keypress wake it.
- This first iteration does **not** include changing the polling rate, mirroring the OLED to the Companion app, or the full OLED Edition menus.

## Provenance

The SH1107 initialization, Waveshare pin mapping, tested framebuffer transfer in `src/oled_flush.h`, and public-domain 5x7 font in `src/oled_font.h` are adapted from [MarcelineVPQ/DS5Dongle-OLED-Edition](https://github.com/MarcelineVPQ/DS5Dongle-OLED-Edition) (AGPL-3.0 project). The OLED status integration and Bridge data bindings are specific to DS5 Bridge.
