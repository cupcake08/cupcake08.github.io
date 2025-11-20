{{flutter_js}}
{{flutter_build_config}}

// 1. Create the Loader HTML Structure dynamically
const loaderDiv = document.createElement('div');
loaderDiv.className = "boot-loader";
loaderDiv.innerHTML = `
  <div class="boot-text" id="console-output">
    > BIOS CHECK... OK<br>
    > ALLOCATING MEMORY...<br>
  </div>
  <div class="progress-container">
    <div class="progress-bar" id="progress-bar"></div>
  </div>
`;
document.body.appendChild(loaderDiv);

// Helper to append logs
function log(message) {
  const consoleDiv = document.getElementById('console-output');
  if (consoleDiv) {
    consoleDiv.innerHTML += `> ${message}<br>`;
  }
}

// 2. Flutter Loader Hook
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      log("ENTRYPOINT LOADED.");
      log("INITIALIZING GRAPHICS ENGINE...");

      // Initialize the Flutter Engine
      const appRunner = await engineInitializer.initializeEngine();

      log("ENGINE ONLINE.");
      log("MOUNTING ROOT WIDGET...");

      // Update progress bar to full just before launch
      const bar = document.getElementById('progress-bar');
      if (bar) bar.style.width = "100%";

      // ----------------------------------------------------------
      // CRITICAL: This line waits for Flutter to start.
      // When it finishes, the app is ready to be shown.
      // ----------------------------------------------------------
      await appRunner.runApp();

    } finally {
      // 3. Cleanup Animation (Runs even if errors occur)
      // We use a small delay to let the user read the final "ONLINE" log
      // before fading out seamlessly.
      setTimeout(() => {
        loaderDiv.style.transition = 'opacity 0.1s';
        loaderDiv.style.opacity = '0';

        // Actually remove the DOM element after the fade
        setTimeout(() => {
          if (document.body.contains(loaderDiv)) {
            loaderDiv.remove();
          }
        }, 50);
      }, 10);
    }
  }
});