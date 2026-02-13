# Googly Eye Spiral Goals

## Vision

Create a dense field of googly eyes that spiral inward toward the center, with a hypnotic, coherent look and synchronized behavior by size class.

## Primary Goals

1. Display many googly-eye sprites moving inward along a spiral path.
2. Use exactly three size classes (small, medium, large).
3. Keep each size class visually identical:
   - If one eye in a size class jiggles, all eyes in that class reflect the same pupil motion/state.
   - No per-instance drift for pupil behavior within the same class.
4. Drive pupil jiggling from music bands (planned integration):
   - Low band -> one size class
   - Mid band -> one size class
   - High band -> one size class
5. Add a center hero eye (planned):
   - Static in position at the center.
   - Pupil is **not** physics/gravity affected.
   - Pupil performs an intentional “look at viewer” behavior.

## Design Constraints

1. Visual parity within each size class is non-negotiable.
2. Animation should feel smooth and continuous while sprites spawn/pack inward.
3. Music-reactive behavior must be deterministic enough to look intentional, not noisy.
4. Center eye behavior should read as deliberate and distinct from the spiraling physics-driven eyes.

## Milestone Order

1. Stabilize spiral spawning/packing and pooling logic.
2. Guarantee per-band texture/viewport consistency for all spawned eyes.
3. Integrate music-band input for pupil impulses.
4. Implement and tune center static eye look-at behavior.
