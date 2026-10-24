const root = document.documentElement;
const calm = matchMedia("(prefers-reduced-motion: reduce)").matches;

const store = (key, value) => {
  try {
    if (value === undefined) return localStorage.getItem(key);
    localStorage.setItem(key, value);
  } catch {
    return null;
  }
  return value;
};

{
  const saved = store("sli-vault-lang") || store("streak-lang");
  if ((saved === "en" || saved === "ta") && !root.dataset.fixed) {
    root.dataset.lang = saved;
    root.lang = saved;
  }
}
document.getElementById("lang").addEventListener("click", () => {
  const next = root.dataset.lang === "ta" ? "en" : "ta";
  store("sli-vault-lang", next);
  store("streak-lang", next);
  const alt = document.querySelector("a[data-alt]");
  if (alt && root.dataset.fixed) {
    location.href = alt.href;
    return;
  }
  root.dataset.lang = next;
  root.lang = next;
});

const bar = document.querySelector(".bar");
const onScroll = () => bar && bar.classList.toggle("is-down", scrollY > 8);
addEventListener("scroll", onScroll, { passive: true });
onScroll();

// Mobile navigation drawer controller
const mobToggle = document.getElementById("mob-toggle");
const mobMenu = document.getElementById("mob-menu");
const mobClose = document.getElementById("mob-close");
const mobBackdrop = document.getElementById("mob-backdrop");

if (mobToggle && mobMenu) {
  const setMobOpen = (open) => {
    mobMenu.classList.toggle("is-open", open);
    mobToggle.classList.toggle("is-active", open);
    mobToggle.setAttribute("aria-expanded", String(open));
    mobMenu.setAttribute("aria-hidden", String(!open));
    document.body.classList.toggle("has-mob-menu", open);
  };

  mobToggle.addEventListener("click", () => {
    const isOpen = mobMenu.classList.contains("is-open");
    setMobOpen(!isOpen);
  });

  if (mobClose) mobClose.addEventListener("click", () => setMobOpen(false));
  if (mobBackdrop) mobBackdrop.addEventListener("click", () => setMobOpen(false));

  mobMenu.querySelectorAll(".mob-menu__link").forEach((link) => {
    link.addEventListener("click", () => setMobOpen(false));
  });

  addEventListener("keydown", (e) => {
    if (e.key === "Escape" && mobMenu.classList.contains("is-open")) {
      setMobOpen(false);
    }
  });
}

function countUp(node, to) {
  if (calm) {
    node.textContent = to.toLocaleString();
    return;
  }
  const start = performance.now();
  const step = (now) => {
    const t = Math.min(1, (now - start) / 1600);
    node.textContent = Math.round(to * (1 - (1 - t) ** 4)).toLocaleString();
    if (t < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

function whenSeen(node, run) {
  const seen = new IntersectionObserver((entries) => {
    if (!entries[0].isIntersecting) return;
    seen.disconnect();
    run();
  });
  seen.observe(node);
}

function counter(name) {
  const nodes = [...document.querySelectorAll(`[data-count="${name}"]`)];
  const saved = Number(store(`streak-${name}`)) || 0;
  let value = saved;
  const shown = new Set();
  const show = (node) => {
    if (!value || shown.has(node)) return;
    shown.add(node);
    countUp(node, value);
  };
  nodes.forEach((node) => {
    node.textContent = "0";
    whenSeen(node, () => {
      node.dataset.seen = "1";
      show(node);
    });
  });
  return (fresh) => {
    if (typeof fresh !== "number" || !nodes.length) return;
    store(`streak-${name}`, fresh);
    value = fresh;
    nodes.forEach((node) => {
      if (!node.dataset.seen) return;
      if (shown.has(node)) node.textContent = fresh.toLocaleString();
      else show(node);
    });
  };
}

const setStars = counter("stars");
fetch("https://api.github.com/repos/sahaya-savari/sli-vault")
  .then((res) => (res.ok ? res.json() : null))
  .then((repo) => {
    if (repo && typeof repo.stargazers_count === "number" && repo.stargazers_count > 0) {
      setStars(repo.stargazers_count);
    }
  })
  .catch(() => {});

if (document.querySelector('[data-count="downloads"]')) {
  const setDownloads = counter("downloads");
  fetch("https://api.github.com/repos/sahaya-savari/sli-vault/releases?per_page=100")
    .then((res) => (res.ok ? res.json() : null))
    .then((releases) => {
      if (!Array.isArray(releases)) return;
      let total = 0;
      releases.forEach((release) => {
        (release.assets || []).forEach((asset) => {
          total += asset.download_count || 0;
        });
      });
      if (total > 0) {
        setDownloads(total);
      }
    })
    .catch(() => {});
}

const heat = document.getElementById("heat");
if (heat) {
  const cells = [];
  for (let i = 0; i < 30 * 22; i += 1) {
    const cell = document.createElement("i");
    heat.appendChild(cell);
    cells.push(cell);
  }
  const paint = (cell) => {
    const on = Math.random() > 0.42;
    const level = 0.22 + Math.random() * 0.5;
    cell.style.background = on ? `rgba(255,87,34,${level.toFixed(2)})` : "rgba(255,255,255,.05)";
    cell.style.boxShadow = on && level > 0.6 ? "0 0 10px rgba(255,87,34,.45)" : "none";
  };
  cells.forEach(paint);
  if (!calm) {
    setInterval(() => {
      for (let i = 0; i < 4; i += 1) paint(cells[Math.floor(Math.random() * cells.length)]);
    }, 700);
  }
}

const shelf = document.getElementById("shelf");
if (shelf) {
  const [back, next] = document.querySelectorAll("[data-shelf]");
  const step = () => shelf.querySelector(".shot").offsetWidth + 26;
  const sync = () => {
    back.disabled = shelf.scrollLeft < 8;
    next.disabled = shelf.scrollLeft + shelf.clientWidth > shelf.scrollWidth - 8;
  };
  document.querySelectorAll("[data-shelf]").forEach((button) => {
    button.addEventListener("click", () => {
      shelf.scrollBy({ left: Number(button.dataset.shelf) * step() * 2 });
    });
  });
  shelf.addEventListener("scroll", sync, { passive: true });
  addEventListener("resize", sync);
  sync();
}

const lb = document.getElementById("lb");
const lbStage = lb.querySelector(".lb__stage");
const lbCap = lb.querySelector(".lb__cap");
let lbList = [];
let lbAt = 0;

const captionOf = (el) => {
  if (el.closest(".prose")) return el.querySelector("img").alt;
  const item = el.closest(".item, .shot");
  if (!item) return "";
  const label = item.querySelector("h3, figcaption");
  if (!label) return "";
  const shown = [...label.querySelectorAll(".en, .ta")].find((span) => span.offsetParent !== null);
  return (shown || label).textContent.trim();
};

const showAt = (index) => {
  lbAt = (index + lbList.length) % lbList.length;
  const el = lbList[lbAt];
  lbStage.innerHTML = "";
  let media;
  if (el.dataset.type === "video") {
    media = document.createElement("video");
    media.src = el.dataset.src;
    media.poster = el.querySelector("video").poster;
    media.controls = true;
    media.autoplay = true;
    media.loop = true;
    media.muted = true;
    media.playsInline = true;
  } else {
    media = document.createElement("img");
    const thumb = el.querySelector("img");
    media.src = el.dataset.src || thumb.currentSrc || thumb.src;
    media.alt = thumb ? thumb.alt : "";
    if (!el.dataset.src) media.className = "is-phone";
  }
  lbStage.classList.remove("is-pan");
  if (el.closest(".prose")) {
    media.addEventListener("load", () => {
      lbStage.classList.toggle("is-pan", media.naturalWidth > media.naturalHeight);
    });
  }
  lbStage.appendChild(media);
  lbCap.textContent = captionOf(el);
  lb.querySelectorAll(".lb__nav").forEach((nav) => {
    nav.hidden = lbList.length < 2;
  });
};

document.querySelectorAll(".prose img").forEach((img) => {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "zoom";
  button.dataset.group = "post";
  button.dataset.src = img.getAttribute("src");
  button.setAttribute("aria-label", img.alt);
  img.replaceWith(button);
  button.appendChild(img);
});

document.querySelectorAll(".zoom").forEach((el) => {
  el.addEventListener("click", () => {
    lbList = [...document.querySelectorAll(`.zoom[data-group="${el.dataset.group}"]`)].filter(
      (other) => !other.closest("[hidden]"),
    );
    lb.showModal();
    showAt(lbList.indexOf(el));
  });
});

lb.addEventListener("click", (event) => {
  const action = event.target.closest("[data-lb]");
  if (action) {
    if (action.dataset.lb === "close") lb.close();
    else showAt(lbAt + Number(action.dataset.lb));
    return;
  }
  if (event.target === lb || event.target === lbStage) lb.close();
});

lb.addEventListener("close", () => {
  lbStage.innerHTML = "";
});

addEventListener("keydown", (event) => {
  if (!lb.open) return;
  if (event.key === "ArrowRight") showAt(lbAt + 1);
  if (event.key === "ArrowLeft") showAt(lbAt - 1);
});

const filters = document.querySelectorAll(".filters button");
filters.forEach((button) => {
  button.addEventListener("click", () => {
    filters.forEach((other) => other.classList.toggle("is-on", other === button));
    const kind = button.dataset.filter;
    document.querySelectorAll(".item").forEach((item) => {
      item.hidden = kind !== "all" && item.dataset.kind !== kind;
    });
  });
});

document.querySelectorAll(".item--scene").forEach((item) => {
  const video = item.querySelector("video");
  const play = () => {
    video.play().catch(() => {});
  };
  const stop = () => {
    video.pause();
  };
  item.addEventListener("mouseenter", play);
  item.addEventListener("mouseleave", stop);
});

const save = (blob, name) => {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = name;
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 4000);
};

document.querySelectorAll(".get").forEach((button) => {
  button.addEventListener("click", async (event) => {
    if (!window.fetch || !window.ReadableStream) return;
    event.preventDefault();
    button.classList.remove("is-done");
    button.classList.add("is-busy");
    button.style.setProperty("--p", 0);
    try {
      const res = await fetch(button.href);
      if (!res.ok || !res.body) throw new Error(res.status);
      const total = Number(res.headers.get("content-length")) || 0;
      const reader = res.body.getReader();
      const parts = [];
      let got = 0;
      for (;;) {
        const { done, value } = await reader.read();
        if (done) break;
        parts.push(value);
        got += value.length;
        if (total) button.style.setProperty("--p", (got / total).toFixed(3));
      }
      button.style.setProperty("--p", 1);
      save(new Blob(parts), button.getAttribute("download"));
      button.classList.remove("is-busy");
      button.classList.add("is-done");
    } catch {
      button.classList.remove("is-busy");
      location.href = button.href;
    }
  });
});

const audio = new Audio();
let current = null;

const bars = (item) => [...item.querySelectorAll(".wave i")];

const release = () => {
  if (!current) return;
  current.classList.remove("is-playing");
  bars(current).forEach((bar) => bar.classList.remove("on"));
  current = null;
};

audio.addEventListener("timeupdate", () => {
  if (!current || !audio.duration) return;
  const list = bars(current);
  const lit = Math.round((audio.currentTime / audio.duration) * list.length);
  list.forEach((bar, i) => bar.classList.toggle("on", i < lit));
});
audio.addEventListener("ended", release);

document.querySelectorAll(".play").forEach((button) => {
  button.addEventListener("click", () => {
    const item = button.closest(".item");
    if (current === item) {
      audio.pause();
      release();
      return;
    }
    release();
    audio.src = button.dataset.src;
    audio.play().catch(() => {});
    current = item;
    item.classList.add("is-playing");
  });
});

document.querySelectorAll("[data-share]").forEach((button) => {
  button.addEventListener("click", async () => {
    const url = button.dataset.share;
    if (navigator.share) {
      try {
        await navigator.share({ title: "SLI Vault", text: document.title, url });
        return;
      } catch (error) {
        if (error && error.name === "AbortError") return;
      }
    }
    try {
      await navigator.clipboard.writeText(url);
    } catch {
      return;
    }
    button.classList.add("is-copied");
    setTimeout(() => button.classList.remove("is-copied"), 2600);
  });
});

// Clean hash / hashtag url slug (e.g. #support, #download) from address bar
const cleanHashSlug = () => {
  if (window.location.hash) {
    const target = document.querySelector(window.location.hash);
    if (target) {
      setTimeout(() => {
        target.scrollIntoView({ behavior: calm ? "auto" : "smooth" });
      }, 50);
    }
    if (window.history && window.history.replaceState) {
      window.history.replaceState(null, "", window.location.pathname + window.location.search);
    }
  }
};

document.querySelectorAll('a[href^="#"]').forEach((link) => {
  link.addEventListener("click", (e) => {
    const hash = link.getAttribute("href");
    if (!hash || hash === "#") return;
    const target = document.querySelector(hash);
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: calm ? "auto" : "smooth" });
      if (window.history && window.history.replaceState) {
        window.history.replaceState(null, "", window.location.pathname + window.location.search);
      }
    }
  });
});

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", cleanHashSlug);
} else {
  cleanHashSlug();
}

// ==========================================================================
// Magic UI Native Interactions (ScrollProgress, SmoothCursor, Terminal, Grid)
// ==========================================================================

// 1. Reading Scroll Progress Indicator
const scrollProgressEl = document.getElementById("magic-scroll-progress");
if (scrollProgressEl) {
  const updateScrollProgress = () => {
    const totalHeight = document.documentElement.scrollHeight - window.innerHeight;
    const progress = totalHeight > 0 ? (window.scrollY / totalHeight) * 100 : 0;
    scrollProgressEl.style.width = Math.min(100, Math.max(0, progress)) + "%";
  };
  window.addEventListener("scroll", updateScrollProgress, { passive: true });
  updateScrollProgress();
}

// 2. Flickering Grid Background Canvas
const flickerCanvas = document.getElementById("magic-flicker-grid");
if (flickerCanvas && !calm) {
  const ctx = flickerCanvas.getContext("2d");
  let gridAnimId;
  const squareSize = 4;
  const gridGap = 8;
  const squareTotal = squareSize + gridGap;

  const resizeGrid = () => {
    flickerCanvas.width = flickerCanvas.offsetWidth;
    flickerCanvas.height = flickerCanvas.offsetHeight;
  };
  window.addEventListener("resize", resizeGrid, { passive: true });
  resizeGrid();

  const drawGrid = () => {
    if (!ctx) return;
    ctx.clearRect(0, 0, flickerCanvas.width, flickerCanvas.height);
    const cols = Math.floor(flickerCanvas.width / squareTotal);
    const rows = Math.floor(flickerCanvas.height / squareTotal);

    for (let c = 0; c < cols; c++) {
      for (let r = 0; r < rows; r++) {
        if (Math.random() < 0.08) {
          const alpha = 0.05 + Math.random() * 0.35;
          ctx.fillStyle = `rgba(255, 87, 34, ${alpha.toFixed(2)})`;
          ctx.fillRect(c * squareTotal, r * squareTotal, squareSize, squareSize);
        }
      }
    }
    gridAnimId = setTimeout(() => requestAnimationFrame(drawGrid), 180);
  };
  drawGrid();
}

// 4. Interactive Terminal Typing & Preflight Checks
const termEl = document.getElementById("magic-terminal");
if (termEl) {
  const typedEl = document.getElementById("term-typed");
  const fullCmd = "sli-vault verify --sandbox --network-audit";
  let hasRun = false;

  const runTerminal = () => {
    if (hasRun || !typedEl) return;
    hasRun = true;
    let charIdx = 0;

    const typeChar = () => {
      if (charIdx < fullCmd.length) {
        typedEl.textContent += fullCmd.charAt(charIdx);
        charIdx++;
        setTimeout(typeChar, calm ? 5 : 32);
      } else {
        // Step-by-step logs reveal
        const logIds = [
          "term-log-1",
          "term-log-2",
          "term-log-3",
          "term-log-4",
          "term-log-5",
          "term-log-6",
          "term-log-7",
        ];
        logIds.forEach((id, idx) => {
          setTimeout(
            () => {
              const row = document.getElementById(id);
              if (row) row.classList.remove("term-hidden");
            },
            calm ? 100 * idx : 500 + idx * 550,
          );
        });
      }
    };
    setTimeout(typeChar, 300);
  };

  whenSeen(termEl, runTerminal);
}
