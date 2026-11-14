// Draws a cubic Bézier link with an explicit, filled arrowhead (no SVG <marker>).
// The head is a triangle built from the curve's end tangent, and the line stops at the
// head's base, so the stroke never pokes past the tip and nothing is clipped or rescaled.
export function linkWithHead(
  x1: number, y1: number, c1x: number, c1y: number,
  c2x: number, c2y: number, tipX: number, tipY: number,
  len = 9, half = 4.5,
): { d: string; head: string } {
  let ux = tipX - c2x, uy = tipY - c2y;
  const m = Math.hypot(ux, uy) || 1;
  ux /= m; uy /= m;
  const bx = tipX - ux * len, by = tipY - uy * len;
  const nx = -uy, ny = ux;
  // End the line slightly inside the head so there is no hairline gap.
  const ex = bx + ux * 1.5, ey = by + uy * 1.5;
  const f = (n: number) => n.toFixed(2);
  return {
    d: `M${f(x1)},${f(y1)} C${f(c1x)},${f(c1y)} ${f(c2x)},${f(c2y)} ${f(ex)},${f(ey)}`,
    head: `M${f(tipX)},${f(tipY)}L${f(bx + nx * half)},${f(by + ny * half)}L${f(bx - nx * half)},${f(by - ny * half)}Z`,
  };
}
