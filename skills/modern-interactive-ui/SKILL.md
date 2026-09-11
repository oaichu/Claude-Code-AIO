---
name: modern-interactive-ui
description: Patterns for high-end interactive modern UI (21st.dev, Magic UI, Aceternity UI). Use when building modern landing pages, SaaS dashboards, bento grids, animated borders, shimmer buttons, particle backgrounds, card hover physics, and slick micro-interactions. Pair with frontend-design (for direction) and ui-styling (for structure).
argument-hint: "[bento|shimmer|beam|physics|card]"
license: MIT
---

# Modern Interactive UI Patterns (21st.dev / Magic UI / Aceternity)

Guidelines for adding high-impact visual polish and interactive micro-interactions to web applications without degrading performance or accessibility.

## Core Rule: The 10% Constraint

Apply high-impact interactive effects to at most **10% of the screen** (the "Signature Element" or primary focal point). Never apply heavy animations across entire pages.

- **DO:** Add a subtle Border Beam or Shimmer to the single primary CTA or Hero card.
- **DO:** Use a Bento Grid for the core feature showcase with gentle hover tilts.
- **DON'T:** Animate every card, background, header, and button simultaneously.

## 1. Bento Grid Architecture

A Bento Grid organizes asymmetric features into a clean, modern mosaic:

```tsx
// Standard 3-column / 2-row Bento Layout
<div className="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-6xl mx-auto">
  {/* Large Hero Card (spans 2 cols) */}
  <div className="md:col-span-2 rounded-2xl border border-border/50 bg-card/60 p-6 backdrop-blur-sm relative overflow-hidden group hover:border-border transition-colors">
    {/* Content */}
  </div>
  {/* Tall Side Card (spans 1 col) */}
  <div className="rounded-2xl border border-border/50 bg-card/60 p-6 backdrop-blur-sm relative overflow-hidden group hover:border-border transition-colors">
    {/* Content */}
  </div>
</div>
```

## 2. Border Beam / Animated Glow Effect

Creates a moving beam of light tracing the border of a card or button:

```css
/* Clean CSS-only Border Beam */
@keyframes border-beam {
  0% { offset-distance: 0%; }
  100% { offset-distance: 100%; }
}
```

```tsx
export function BorderBeam({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "pointer-events-none absolute inset-0 rounded-[inherit] [border:1px_solid_transparent]",
        "![mask-clip:padding-box,border-box] ![mask-composite:intersect] [mask:linear-gradient(transparent,transparent),linear-gradient(white,white)]",
        "after:absolute after:aspect-square after:w-[200px] after:animate-[border-beam_8s_infinite_linear]",
        "after:[animation-delay:0s] after:[background:linear-gradient(to_left,var(--primary),transparent)] after:[offset-anchor:100%_50%] after:[offset-path:rect(0_auto_auto_0_round_inherit)]",
        className
      )}
    />
  );
}
```

## 3. Shimmer Button & Text Shimmer

Subtle animated gradient sweep across text or button:

```tsx
export function ShimmerButton({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <button
      className={cn(
        "relative inline-flex h-11 overflow-hidden rounded-xl p-[1px] focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2",
        className
      )}
    >
      <span className="absolute inset-[-1000%] animate-[spin_3s_linear_infinite] bg-[conic-gradient(from_90deg_at_50%_50%,var(--primary)_0%,transparent_50%,var(--primary)_100%)]" />
      <span className="inline-flex h-full w-full cursor-pointer items-center justify-center rounded-xl bg-background px-6 py-2 text-sm font-medium text-foreground backdrop-blur-3xl">
        {children}
      </span>
    </button>
  );
}
```

## 4. Spring Physics & Card Hover (Framer Motion)

Use natural springs (`stiffness: 400`, `damping: 30`), never sluggish linear transitions:

```tsx
import { motion } from "framer-motion";

<motion.div
  whileHover={{ y: -4, scale: 1.01 }}
  transition={{ type: "spring", stiffness: 400, damping: 25 }}
  className="rounded-2xl border bg-card p-6 shadow-sm hover:shadow-md"
>
  {/* Content */}
</motion.div>
```

## 5. Background Accents (Subtle Grid & Radial Gradients)

Never use high-contrast checkered patterns; keep opacity below 5–10%:

```tsx
<div className="absolute inset-0 -z-10 h-full w-full bg-background bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:24px_24px]">
  <div className="absolute inset-0 bg-[radial-gradient(circle_500px_at_50%_200px,var(--primary-subtle),transparent)]" />
</div>
```

## Checklist for Implementation

1. **Accessibility first:** Respect `prefers-reduced-motion`. Wrap CSS animations in `@media (prefers-reduced-motion: no-preference)`.
2. **Performance:** Animate only `transform` and `opacity`. Never animate `width`, `height`, `margin`, or `padding`.
3. **Contrast:** Ensure all text passes WCAG AA contrast against animated or gradient backgrounds.
