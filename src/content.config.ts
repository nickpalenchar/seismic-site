import { defineCollection } from "astro:content";
import { docsLoader } from "@astrojs/starlight/loaders";
import { docsSchema } from "@astrojs/starlight/schema";

// Starlight's docs. Pages live in src/content/docs/docs/ so they are served under /docs/.
export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
};
