#!/usr/bin/env node
// ───────────────────────────────────────────────────────────────────
//  Bakes the collaborations map's geometry from _data/network.yml into
//  _data/network_geometry.yml, which the map template then renders.
//
//  WHY THIS EXISTS. The map needs two real cartographic projections —
//  Natural Earth for the world, Mercator for the Europe enlargement —
//  and Liquid cannot do that arithmetic. Doing it in the browser would
//  mean shipping d3, topojson and a world-atlas download, and the
//  project's rules forbid third-party requests; CI also installs only
//  Ruby gems, so it cannot run this. So it is computed once, here, and
//  the result is committed.
//
//  WHEN TO RUN IT. Only when a location is added, removed, or its
//  lat/lon changes. Editing a label, subtitle or member list needs
//  nothing — those are read straight from network.yml at build time.
//
//  HOW TO RUN IT (from the repository root):
//
//    mkdir -p /tmp/mapbake && cd /tmp/mapbake
//    nix shell github:NixOS/nixpkgs/nixos-24.11#nodejs_20 --command bash -c '
//      npm init -y >/dev/null
//      npm install d3-geo@3 topojson-client@3 world-atlas@2.0.2 yaml@2
//      NODE_PATH=$PWD/node_modules node <repo>/bin/bake-map.mjs <repo>'
//
//  Geometry: Natural Earth 110m via world-atlas 2.0.2 (public domain).
//  The world uses the land outline; the Europe enlargement uses country
//  outlines, because which country an institution sits in is legible at
//  that scale and is the thing the enlargement exists to show.
// ───────────────────────────────────────────────────────────────────

import * as d3 from "d3-geo";
import * as topojson from "topojson-client";
import YAML from "yaml";
import { readFileSync, writeFileSync } from "fs";
import { createRequire } from "module";
import { join } from "path";

const repo = process.argv[2] || process.cwd();
const require = createRequire(import.meta.url);

// ── layout constants, from the delivered design ───────────────────
// The delivered renderer used h: 430 to leave room for an all-caps key line
// inside the SVG; that line is a <figcaption> here, in the page's own type and
// sentence case, so the box is trimmed to the artwork. The world's fitExtent
// keeps its original numbers — the world is width-constrained, so changing the
// box height does not move or resize it.
const DESKTOP = {
  w: 960, h: 356, mw: 612,
  world: [[8, 18], [604, 412]],
  inset: { x: 630, y: 28, w: 322, h: 300 },
  insetFit: [[656, 44], [936, 312]],
  rWorld: 4.2, rInset: 4.4, hubR: 5, hubRing: 13, hubSize: 16,
};
const PHONE = {
  w: 400, h: 512, th: 232, gap: 14, bh: 266,
  world: [[6, 10], [394, 224]],
  inset: { x: 0, y: 246, w: 400, h: 266 },
  insetFit: [[26, 260], [386, 498]],
  rWorld: 3.8, rInset: 4.2, hubR: 4, hubRing: 11, hubSize: 13,
};

// The world is cropped to 58°S–80°N: Antarctica and the empty far north
// carry no points. The fit target is a MultiPoint sampled along three
// parallels, not a polygon — a ring spanning all 360° of longitude has an
// ambiguous interior and d3 falls back to the whole sphere when taking its
// bounds. The equator has to be in the sample because it is the widest
// line in Natural Earth; the two outer parallels alone fit too narrow.
const WORLD_SAMPLE = (() => {
  const c = [];
  for (let lon = -180; lon <= 180; lon += 5) {
    c.push([lon, -58], [lon, 0], [lon, 80]);
  }
  return { type: "MultiPoint", coordinates: c };
})();

const EUROPE_BBOX = { w: -30, e: 50, s: 30, n: 75 };
const inEurope = (s) => s.lon > -12 && s.lon < 32 && s.lat > 35;

// ── read the data ─────────────────────────────────────────────────
const net = YAML.parse(readFileSync(join(repo, "_data/network.yml"), "utf8"));
const hub = net.center;
const sites = net.locations;
for (const s of [hub, ...sites]) {
  if (!s.id || typeof s.lat !== "number" || typeof s.lon !== "number") {
    throw new Error(`network.yml: ${s.label || "?"} needs id, lat and lon`);
  }
}
const eu = sites.filter(inEurope);

// ── geometry ──────────────────────────────────────────────────────
const atlas = (f) => JSON.parse(readFileSync(require.resolve(`world-atlas/${f}.json`), "utf8"));
const landTopo = atlas("land-110m");
const land = topojson.feature(landTopo, landTopo.objects.land);
const ctryTopo = atlas("countries-110m");
const countries = topojson.feature(ctryTopo, ctryTopo.objects.countries);
const europeLand = {
  type: "FeatureCollection",
  features: countries.features.filter((f) => {
    const [[w, s], [e, n]] = d3.geoBounds(f);
    return e >= EUROPE_BBOX.w && w <= EUROPE_BBOX.e && n >= EUROPE_BBOX.s && s <= EUROPE_BBOX.n;
  }),
};

// Integer pixel precision. At 960 px wide the 110m coastline is already
// coarser than a pixel, and it cuts the committed path data by a third.
const r0 = (s) => s.replace(/-?\d+\.?\d*/g, (m) => Math.round(+m).toString());
const r2 = (n) => +(+n).toFixed(2);

// Both views use the same two projections at different scales, so each
// view is an affine transform of the other. The geometry is emitted once,
// in desktop coordinates, and the phone <use>s it through that transform.
function affine(from, to) {
  const k = to.scale() / from.scale();
  const [fx, fy] = from.translate(), [tx, ty] = to.translate();
  return { k: +k.toFixed(6), x: +(tx - k * fx).toFixed(3), y: +(ty - k * fy).toFixed(3) };
}
const applyAffine = (a, [x, y]) => [a.k * x + a.x, a.k * y + a.y];

function build() {
  const dWorld = d3.geoNaturalEarth1().fitExtent(DESKTOP.world, WORLD_SAMPLE);
  const pWorld = d3.geoNaturalEarth1().fitExtent(PHONE.world, WORLD_SAMPLE);
  const euSample = { type: "MultiPoint", coordinates: [[hub.lon, hub.lat], ...eu.map((s) => [s.lon, s.lat])] };
  const dEu = d3.geoMercator().fitExtent(DESKTOP.insetFit, euSample);
  const pEu = d3.geoMercator().fitExtent(PHONE.insetFit, euSample);

  const worldAff0 = affine(dWorld, pWorld);
  const euAff0 = affine(dEu, pEu);

  // Clip the geometry to what is actually visible, in desktop space, before
  // it is written out: without this the file carries Antarctica and half of
  // Russia as path data that only the SVG clipPath hides. The clip is the
  // union of the two views' frames — the phone's frame mapped back through
  // its transform — because both views share this one copy of the geometry.
  const unclip = (aff, [x0, y0, x1, y1]) =>
    [(x0 - aff.x) / aff.k, (y0 - aff.y) / aff.k, (x1 - aff.x) / aff.k, (y1 - aff.y) / aff.k];
  const union = (a, b) => [Math.min(a[0], b[0]) - 2, Math.min(a[1], b[1]) - 2,
                           Math.max(a[2], b[2]) + 2, Math.max(a[3], b[3]) + 2];

  // Both views clip the world to the same region — the phone's world clip is
  // this rect under world_transform — so the crop is just the fitted bounds.
  // That is what drops Antarctica, which the 58°S crop excludes anyway.
  const wb0 = d3.geoPath(dWorld).bounds(WORLD_SAMPLE);
  const worldRect = [wb0[0][0] - 2, wb0[0][1] - 2, wb0[1][0] + 2, wb0[1][1] + 2];
  const euRect = union(
    [DESKTOP.inset.x, DESKTOP.inset.y, DESKTOP.inset.x + DESKTOP.inset.w, DESKTOP.inset.y + DESKTOP.inset.h],
    unclip(euAff0, [PHONE.inset.x, PHONE.inset.y, PHONE.inset.x + PHONE.inset.w, PHONE.inset.y + PHONE.inset.h]));

  const dWorldPath = d3.geoPath(d3.geoNaturalEarth1()
    .scale(dWorld.scale()).translate(dWorld.translate())
    .postclip(d3.geoClipRectangle(...worldRect)));
  const dEuPath = d3.geoPath(d3.geoMercator()
    .scale(dEu.scale()).translate(dEu.translate())
    .postclip(d3.geoClipRectangle(...euRect)));

  // Clip rects come from the projected bounds, never hand-guessed.
  const wb = d3.geoPath(dWorld).bounds(WORLD_SAMPLE);
  const worldClip = {
    x: Math.round(wb[0][0] - 2), y: Math.round(wb[0][1] - 2),
    w: Math.round(wb[1][0] - wb[0][0] + 4), h: Math.round(wb[1][1] - wb[0][1] + 4),
  };

  const arc = (path, s) => r0(path({ type: "LineString", coordinates: [[hub.lon, hub.lat], [s.lon, s.lat]] }));

  const worldAff = worldAff0;
  const euAff = euAff0;

  // The affine must reproduce every projected point exactly, or the phone
  // markers would sit off their own coastline.
  for (const s of [hub, ...sites]) {
    const direct = pWorld([s.lon, s.lat]);
    const viaAff = applyAffine(worldAff, dWorld([s.lon, s.lat]));
    const err = Math.max(Math.abs(direct[0] - viaAff[0]), Math.abs(direct[1] - viaAff[1]));
    if (err > 0.01) throw new Error(`world affine off by ${err} at ${s.id}`);
  }
  for (const s of [hub, ...eu]) {
    const direct = pEu([s.lon, s.lat]);
    const viaAff = applyAffine(euAff, dEu([s.lon, s.lat]));
    const err = Math.max(Math.abs(direct[0] - viaAff[0]), Math.abs(direct[1] - viaAff[1]));
    if (err > 0.01) throw new Error(`europe affine off by ${err} at ${s.id}`);
  }

  const pt = (proj, s) => { const [x, y] = proj([s.lon, s.lat]); return { x: r2(x), y: r2(y) }; };

  const view = (cfg, wProj, eProj) => ({
    width: cfg.w,
    height: cfg.h,
    r_world: cfg.rWorld,
    r_inset: cfg.rInset,
    hub_r: cfg.hubR,
    hub_ring: cfg.hubRing,
    hub_size: cfg.hubSize,
    world_clip: cfg === DESKTOP ? worldClip : {
      x: Math.round(applyAffine(worldAff, [worldClip.x, worldClip.y])[0]),
      y: Math.round(applyAffine(worldAff, [worldClip.x, worldClip.y])[1]),
      w: Math.round(worldClip.w * worldAff.k), h: Math.round(worldClip.h * worldAff.k),
    },
    inset_frame: cfg.inset,
    hub_world: pt(wProj, hub),
    hub_inset: pt(eProj, hub),
    sites: Object.fromEntries(sites.map((s) => [s.id, {
      world: pt(wProj, s),
      inset: inEurope(s) ? pt(eProj, s) : null,
    }])),
  });

  return {
    world_transform: worldAff,
    europe_transform: euAff,
    world_land: r0(dWorldPath(land)),
    world_graticule: r0(dWorldPath(d3.geoGraticule().extent([[-180, -58], [180, 80]])())),
    world_arcs: Object.fromEntries(sites.map((s) => [s.id, arc(dWorldPath, s)])),
    europe_land: r0(dEuPath(europeLand)),
    europe_arcs: Object.fromEntries(eu.map((s) => [s.id, arc(dEuPath, s)])),
    europe_ids: eu.map((s) => s.id),
    desktop: view(DESKTOP, dWorld, dEu),
    phone: view(PHONE, pWorld, pEu),
  };
}

const geo = build();
const header = `# ───────────────────────────────────────────────────────────────────
#  GENERATED FILE — DO NOT EDIT BY HAND.
#
#  Produced by bin/bake-map.mjs from _data/network.yml. Every number here
#  is derived; editing one moves a coastline or a point away from where
#  the projection puts it. To change the map, edit network.yml and run
#  the script again — its header says how.
#
#  Coastlines: Natural Earth 110m via world-atlas 2.0.2 (public domain).
#  Projections: Natural Earth for the world, Mercator for the enlargement.
#  Coordinates are in the desktop layout's pixel space; the phone view is
#  the same geometry under world_transform / europe_transform.
# ───────────────────────────────────────────────────────────────────
`;
const out = join(repo, "_data/network_geometry.yml");
writeFileSync(out, header + YAML.stringify(geo, { lineWidth: 0 }));

const size = readFileSync(out).length;
console.log(`wrote _data/network_geometry.yml — ${(size / 1024).toFixed(1)} KB`);
console.log(`  world land ${(geo.world_land.length / 1024).toFixed(1)} KB, ` +
  `graticule ${(geo.world_graticule.length / 1024).toFixed(1)} KB, ` +
  `europe ${(geo.europe_land.length / 1024).toFixed(1)} KB`);
console.log(`  ${sites.length} locations, ${geo.europe_ids.length} of them drawn twice`);
