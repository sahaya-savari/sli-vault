import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  Outlet,
  RouterProvider,
  createMemoryHistory,
  createRootRouteWithContext,
  createRoute,
  createRouter,
} from "@tanstack/react-router";
import { render, type RenderResult } from "@testing-library/react";

import { Route as IndexFileRoute } from "@/routes/index";
import { Route as ResourcesFileRoute } from "@/routes/resources";

const IndexComponent = IndexFileRoute.options.component!;
const ResourcesComponent = ResourcesFileRoute.options.component!;

function buildRouter(path: string) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  const rootRoute = createRootRouteWithContext<{ queryClient: QueryClient }>()({
    component: () => {
      const { queryClient: client } = rootRoute.useRouteContext();
      return (
        <QueryClientProvider client={client}>
          <Outlet />
        </QueryClientProvider>
      );
    },
  });

  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: IndexComponent,
  });

  const resourcesRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/resources",
    component: ResourcesComponent,
  });

  const routeTree = rootRoute.addChildren([indexRoute, resourcesRoute]);

  return createRouter({
    routeTree,
    context: { queryClient },
    history: createMemoryHistory({ initialEntries: [path] }),
  });
}

/**
 * Renders a route inside a real TanStack Router provider so components that use
 * <Link> resolve correctly (the site nav links to the first-party /resources page).
 */
export async function renderWithRouter(
  path = "/",
): Promise<RenderResult & { router: ReturnType<typeof buildRouter> }> {
  const router = buildRouter(path);
  await router.load();
  const result = render(<RouterProvider router={router} />);
  return { router, ...result };
}
