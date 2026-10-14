# Alternate Generation Backend: ComfyUI

The primary route is generating clips through a video model directly from scene prompts. ComfyUI (credit: Comfy-Org/ComfyUI, 123k stars) is a documented alternate backend for the generation stage. It is node-based: you wire together a graph of operations (prompt input, model loader, sampler, upscaler, output) and run the scene through it. Same stage of the pipeline, different way of producing the clips.

## What a node-based backend gives you

**Reproducible workflow files checked into the project.** A ComfyUI workflow is a saved file that describes the whole generation graph: which model, which sampler, how many steps, which seed, what resolution. Check that file into the project and anyone (including future-you) can re-run the exact same scene months later and get the same result. That is version control for generation, not just for scripts.

**Local control.** Everything runs on your own hardware. No queue, no per-clip API cost, no provider-side changes to model behavior between runs. When a look needs fifty small iterations, local iteration is free.

**Composable steps.** Enhancement moves that live outside the model (upscaling, frame interpolation, denoising) can sit inside the same workflow as nodes instead of separate post-processing commands. One file can cover generation plus the enhancement recipe from the companion doc, so the full shot pipeline is a single reproducible unit.

## When to choose it over the primary route

**A model declined a prompt.** Bridge scenes (rebuilt as environment or energy shots when combat prompts are refused) sometimes land more cleanly when you can decompose the shot into explicit nodes rather than negotiating with a single prompt string.

**A specific look is easier to dial in as nodes.** Locked character designs and Style DNA constraints sometimes need precise control (seed sweeps, sampler tuning, resolution staging) that is awkward through a one-shot prompt API. A node graph exposes those dials directly.

**You want full local reproducibility.** If a project needs every clip re-generatable from checked-in files with no external dependency, the node backend is the answer. This matters most for series work where characters must match across dozens of episodes.

## What stays the same regardless of backend

The backend changes how clips are produced, not what the series standards are. These do not move:

- **The prompt formula.** Same scene description structure, same directing language, same shot discipline.
- **Character locks.** Locked designs from the character library apply identically. A node workflow does not get to invent a new look for a locked character.
- **Style DNA byte-identical rule.** The visual identity constraints are absolute: same palette, same lighting language, same compositional rules, frame after frame, episode after episode.
- **Directing principles.** Cinematic pacing, tension, dramatic narration beats, no hallucination. The no-hallucination rule binds every backend: no invented events, names, techniques, or outcomes, ever.

## Checklist: porting a scene prompt into a node workflow

1. Start from the scene prompt written for the primary route. Do not rewrite the creative content; port it.
2. Lock the character design first: reference the design-lock entry (or the locked image path) in the workflow notes so the graph cannot drift from it.
3. Set the sampler, step count, and seed explicitly. Fixed seed until the look is approved; only then vary it for alternates.
4. Match output resolution to the assembly target. Upscale inside the workflow only if your enhancement recipe calls for it; otherwise keep the clip native and upscale in the enhancement stage.
5. Run one scene end to end and QC it against the same checklist used for primary-route clips (character match, no artifacts, motion quality).
6. Save the workflow file into the project with the episode and scene name in the filename. An unsaved workflow is not reproducible.

ComfyUI is the documented example because it is the most widely adopted node system. The principles above (reproducible files, local control, composable steps, identical series standards) apply to any node-based backend you choose.
