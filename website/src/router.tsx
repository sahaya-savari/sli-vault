import { QueryClient } from "@tanstack/react-query";
import { createRouter } from "@tanstack/react-router";
import { routeTree } from "./routeTree.gen";

function routerBasepath(): string | undefined {
  const base = import.meta.env.BASE_URL;
  if (base === "/" || base === "./") return undefined;
  return base.endsWith("/") ? base.slice(0, -1) : base;
}

export const getRouter = () => {
  const queryClient = new QueryClient();

  const router = createRouter({
    routeTree,
    context: { queryClient },
    basepath: routerBasepath(),
    scrollRestoration: true,
    defaultPreloadStaleTime: 0,
  });

  return router;
};
