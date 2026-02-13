# Current State Journal

## Snapshot

Date: 2026-02-13

This project already has the core scaffolding for:

1. Three band-driven googly-eye sources (`LowBandEye`, `MidBandEye`, `HighBandEye`) rendered via `SubViewport`.
2. Band signal cycling logic in the main scene.
3. A sprite-spawning spiral system intended to reuse those viewport textures.

This aligns with the goal of synchronized behavior per size class. The use of one source eye per band/size is a strong architectural fit for “all same-size eyes shake identically.”

## What Is Working

1. Main scene wiring exists for three band eyes and three sprite collections.
2. Band signal object and per-eye `apply_band_signal()` behavior are implemented.
3. Spiral motion logic exists in `EyeSprite` and updates position/rotation/scale over time.
4. Global tuning variables for inward speed, rotation speed, and base eye diameter exist.

## What Is Partially Implemented

1. Music reactivity is simulated with timer-based random impulse direction, not real audio bands yet.
2. Spawn areas/packing intent is present, but packing math and overlap constraints are not fully enforced yet.
3. Center static eye with controlled non-physics pupil is not implemented yet.

## Current Issues Affecting Behavior

1. Newly spawned sprite instances are created but not returned to caller in collection handoff logic.
2. Reparent ordering in collection handoff is fragile (add/remove order can cause node-parent issues).
3. Scene export values for ring settings are currently `null` in the scene file, which is risky and can invalidate tuning assumptions.
4. Local default texture in `eye_sprite.tscn` points to a specific viewport path and may be invalid outside the main scene context.

## Why Existing Choices Make Sense

Your described intent fully explains the existing architecture:

1. `SubViewport` per size/band is the right move for perfect same-size synchronization.
2. Band-specific source eyes map directly to future low/mid/high music inputs.
3. Separate spiral sprite collections by size supports clean scaling and controlled density.

So yes, your explanation provides strong context for why these choices were made.

## Next Focus

1. Fix sprite collection handoff/spawn return path first (unblocks visible spiral population).
2. Harden node reparent flow for pooling reuse.
3. Replace timer-based fake band triggers with audio-band signal source.
4. Add center eye scene and script with explicit non-physics pupil look-at behavior.
