import {
  constructRoutes,
  constructApplications,
  constructLayoutEngine,
} from "single-spa-layout";
import { registerApplication, start } from "single-spa";

const routes = constructRoutes(document.querySelector("#single-spa-layout"));
const applications = constructApplications({
  routes,
  loadApp: ({ name }) => System.import(name),
});
// Delay starting the layout engine until the styleguide CSS is loaded
const layoutEngine = constructLayoutEngine({
  routes,
  applications,
  active: false,
});

applications.forEach(registerApplication);

// registerApplication({
//   name: "@react-mf/navigation",
//   app: () => System.import("@react-mf/navigation"),
//   activeWhen: "/",
// });

layoutEngine.activate();
start();

// const application = {
//   bootstrap: () => Promise.resolve(), //bootstrap function
//   mount: () => Promise.resolve(), //mount function
//   unmount: () => Promise.resolve(), //unmount function
// }
// registerApplication('@react-mf/navigation', application);

// registerApplication({
//   name: "@react-mf/apicurio-studio",
//   app: () => System.import("@react-mf/apicurio-studio"),
//   activeWhen: "/apicuriostudio",
// });

// registerApplication({
//   name: "@react-mf/syndesis",
//   app: () => loadWithoutAmd("@react-mf/syndesis"),
//   activeWhen: "/syndesis",
// });

// function loadingFn() {
//   return System.import('@react-mf/navigation');
// }

// System.import("@react-mf/navigation");
// System.import("@react-mf/apicurio-studio");
// // System.import('@react-mf/syndesis');

// const routes = constructRoutes(document.querySelector("#single-spa-layout"));
// const applications = constructApplications({
//   routes,
//   loadApp: ({ name }) => System.import(name),
// });

// // Delay starting the layout engine until the styleguide CSS is loaded
// const layoutEngine = constructLayoutEngine({
//   routes,
//   applications,
//   active: false,
// });

// // applications.forEach(registerApplication);

// layoutEngine.activate();
// start();

// System.import("@react-mf/styleguide").then(() => {
//   // Activate the layout engine once the styleguide CSS is loaded
//   layoutEngine.activate();
//   start();
// });
