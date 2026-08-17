(() => {
  const currentPath = window.location.pathname.replace(/\/+$/, "") || "/";
  document.querySelectorAll(".site-nav a[href]").forEach((link) => {
    const target = new URL(link.href, window.location.origin);
    const targetPath = target.pathname.replace(/\/+$/, "") || "/";
    if (target.origin === window.location.origin && targetPath === currentPath) {
      link.setAttribute("aria-current", "page");
    }
  });
})();
