// Reduced motion, as the site decides it: the toggle under the navbar (Base.astro), else the device's
// preference. Base.astro writes it to <html data-motion="reduce|full"> before the first paint and announces
// every change with a "seismic:motion" event, so a demo can read it live instead of once at load.

export const MOTION_EVENT = "seismic:motion";

/** Whether motion is reduced right now. */
export function reducedMotion(): boolean {
  return document.documentElement.dataset.motion === "reduce";
}

/** Calls `onChange` whenever reduced motion is turned on or off. */
export function onMotionChange(onChange: (reduced: boolean) => void): void {
  document.addEventListener(MOTION_EVENT, () => onChange(reducedMotion()));
}
