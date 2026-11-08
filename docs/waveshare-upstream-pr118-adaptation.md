# Hardware updates adapted from upstream PR #118

Source: https://github.com/SundayMoments/DS5_Bridge/pull/118
Commit reviewed: `e205121a07cf1f451cc2e094faf2cb7850716160`

The original PR targets an older DS5 Bridge architecture, while current
main has heavily rewritten USB, BTstack and persona management. Applying
all six files from PR #118 verbatim would regress the newer implementation.

## Changes retained
- Waveshare RP2350B-Plus-W: `PICO_FLASH_SIZE_BYTES` is declared using
  `pico_board_cmake_set_default` for the actual 16 MiB flash part.
- LED2 on the RP2350B is exposed as default GPIO23; LED1 is still CYW43 GPIO0.
- Bluetooth TLV storage uses hardware-tested low-flash bank offset
  `0x003FD000` on Waveshare only; Pico 2 W remains unchanged.

## Current-main features that supersede the older PR
- `src/bt.cpp` now has fixed-size `std::array<feature_cache_entry>`
  with `ds5::InlineBytes`, and `bt_copy_feature_data()`.
- `src/main.cpp` uses `bt_copy_feature_data()` in USB HID GET_REPORT
  rather than dynamically allocating a vector in the callback.
- Bluetooth input is transferred through bounded receive batches and
  USB/BT callbacks already avoid the old in-callback teardown patterns.
- `src/usb.cpp` implements companion bridge-only USB topology plus
  intentional reconnect transitions and persona switching; replacing
  this function with the older keep-attached shortcut would bypass
  this logic.

The older PR's additional SET_REPORT queue is not imported in this
first adaptation, because the current output path has changed and a
parallel queue needs performance/correctness validation in all host
personas, particularly Edge native haptics and Xbox emulation.

## Flash compatibility warning
The bank offset moves **paired controller keys** from the upper 16 MiB
region to the lower 4 MiB region. Previously paired controllers may
need to be paired again. On the current firmware, the two sectors
immediately below the TLV bank are reserved for other persistent data:
`PICO_FLASH_BANK_STORAGE_OFFSET - FLASH_SECTOR_SIZE` is bootloader
authorization; the two preceding sectors are Wake-on-LAN storage.
The relative layout remains unchanged when the bank offset moves.

## Hardware validation
Upstream author reported physical Waveshare tests; this adapted branch
has not yet been tested on the user's board. Check Bluetooth pairing,
re-pairing, normal reboot, USB identity, Edge feature reports, sound,
adaptive triggers, OLED if enabled, and keys surviving a cold restart.
