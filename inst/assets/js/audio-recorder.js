"use strict";
(() => {
  // srcts/videoClipper.ts
  var VideoClipperElement = class extends HTMLElement {
    constructor() {
      super();
      this.chunks = [];
      this.attachShadow({ mode: "open" });
      this.shadowRoot.innerHTML = `
        <style>
          :host {
            display: grid;
            grid-template-rows: 1fr;
            grid-template-columns: 1fr;
            width: 100%;
            height: min-content;
          }
          video {
            grid-column: 1 / 2;
            grid-row: 1 / 2;
            width: 100%;
            object-fit: cover;
            background-color: var(--video-clip-bg, black);
            aspect-ratio: auto 16 / 9;
            border-radius: var(--video-clip-border-radius, var(--bs-border-radius-lg));
          }
          video.mirrored {
            transform: scaleX(-1);
          }
          .panel-settings {
            grid-column: 1 / 2;
            grid-row: 1 / 2;
            justify-self: end;
            margin: 0.5em;
          }
          .panel-buttons {
            grid-column: 1 / 2;
            grid-row: 1 / 2;
            justify-self: end;
            align-self: end;
            margin: 0.5em;
          }
        </style>
        <video part="video" muted playsinline></video>
        <div class="panel-settings">
          <slot name="settings"></slot>
        </div>
        <div class="panel-buttons">
          <slot name="recording-controls"></slot>
        </div>
    `;
      this.video = this.shadowRoot.querySelector("video");
    }
    connectedCallback() {
      (async () => {
        const slotSettings = this.shadowRoot.querySelector(
          "slot[name=settings]"
        );
        slotSettings.addEventListener("slotchange", async () => {
          this.avSettingsMenu = slotSettings.assignedElements()[0];
          await this.#initializeMediaInput();
          if (this.buttonRecord) {
            this.#setEnabledButton(this.buttonRecord);
          }
        });
        const slotControls = this.shadowRoot.querySelector(
          "slot[name=recording-controls]"
        );
        slotControls.addEventListener("slotchange", () => {
          const findButton = (selector) => {
            for (const el of slotControls.assignedElements()) {
              if (el.matches(selector)) {
                return el;
              }
              const sub = el.querySelector(selector);
              if (sub) {
                return sub;
              }
            }
            return null;
          };
          this.buttonRecord = findButton(".record-button");
          this.buttonStop = findButton(".stop-button");
          this.#setEnabledButton();
          this.buttonRecord.addEventListener("click", () => {
            this.dispatchEvent(new CustomEvent("recordstart"));
            this.#setEnabledButton(this.buttonStop);
            this._beginRecord();
          });
          this.buttonStop.addEventListener("click", () => {
            this._endRecord();
            this.#setEnabledButton(this.buttonRecord);
          });
        });
      })().catch((err) => {
        console.error(err);
      });
    }
    disconnectedCallback() {
    }
    #setEnabledButton(btn) {
      this.buttonRecord.style.display = btn === this.buttonRecord ? "inline-block" : "none";
      this.buttonStop.style.display = btn === this.buttonStop ? "inline-block" : "none";
    }
    async setMediaDevices(cameraId, micId) {
      if (this.cameraStream) {
        this.cameraStream.getTracks().forEach((track) => track.stop());
      }
      this.cameraStream = await navigator.mediaDevices.getUserMedia({
        video: {
          deviceId: cameraId || void 0,
          // If cameraId is not specified, default to the selfie cam
          facingMode: cameraId ? void 0 : "user"
        },
        audio: {
          deviceId: micId || void 0
        }
      });
      const label = this.cameraStream.getVideoTracks()[0].label;
      const isSelfieCam = hasConstraint(
        this.cameraStream.getVideoTracks()[0].getCapabilities().facingMode,
        "user"
      ) || /facetime|isight|front/i.test(label);
      this.video.classList.toggle("mirrored", isSelfieCam);
      const aspectRatio = this.cameraStream.getVideoTracks()[0].getSettings().aspectRatio;
      if (aspectRatio) {
        this.video.style.aspectRatio = `${aspectRatio}`;
      } else {
        this.video.style.aspectRatio = "";
      }
      this.video.srcObject = this.cameraStream;
      try {
        await this.video.play();
        this.video.style.aspectRatio = "";
      } catch (err) {
        console.error("Error playing video: ", err);
      }
      return {
        cameraId: this.cameraStream.getVideoTracks()[0].getSettings().deviceId,
        micId: this.cameraStream.getAudioTracks()[0].getSettings().deviceId
      };
    }
    async #initializeMediaInput() {
      const savedCamera = window.localStorage.getItem("multimodal-camera");
      const savedMic = window.localStorage.getItem("multimodal-mic");
      const { cameraId, micId } = await this.setMediaDevices(
        savedCamera,
        savedMic
      );
      const devices = await navigator.mediaDevices.enumerateDevices();
      this.avSettingsMenu.setCameras(
        devices.filter((dev) => dev.kind === "videoinput")
      );
      this.avSettingsMenu.setMics(
        devices.filter((dev) => dev.kind === "audioinput")
      );
      this.avSettingsMenu.cameraId = cameraId;
      this.avSettingsMenu.micId = micId;
      const handleDeviceChange = async (deviceType, deviceId) => {
        if (!deviceId) return;
        window.localStorage.setItem(`multimodal-${deviceType}`, deviceId);
        await this.setMediaDevices(
          this.avSettingsMenu.cameraId,
          this.avSettingsMenu.micId
        );
      };
      this.avSettingsMenu.addEventListener("camera-change", (e) => {
        handleDeviceChange("camera", this.avSettingsMenu.cameraId);
      });
      this.avSettingsMenu.addEventListener("mic-change", (e) => {
        handleDeviceChange("mic", this.avSettingsMenu.micId);
      });
    }
    _beginRecord() {
      this.recorder = new MediaRecorder(this.cameraStream, {
        mimeType: this.dataset.mimeType,
        videoBitsPerSecond: safeFloat(this.dataset.videoBitsPerSecond),
        audioBitsPerSecond: safeFloat(this.dataset.audioBitsPerSecond)
      });
      this.recorder.addEventListener("error", (e) => {
        console.error("MediaRecorder error:", e.error);
      });
      this.recorder.addEventListener("dataavailable", (e) => {
        this.chunks.push(e.data);
      });
      this.recorder.addEventListener("start", () => {
      });
      this.recorder.addEventListener("stop", () => {
        if (this.chunks.length === 0) {
          console.warn("No data recorded");
          return;
        }
        const blob = new Blob(this.chunks, { type: this.chunks[0].type });
        const event = new BlobEvent("data", {
          data: blob
        });
        try {
          this.dispatchEvent(event);
        } finally {
          this.chunks = [];
        }
      });
      this.recorder.start();
    }
    _endRecord(emit = true) {
      this.recorder.stop();
    }
  };
  customElements.define("video-clipper", VideoClipperElement);
  function safeFloat(value) {
    if (value === void 0) {
      return void 0;
    }
    const floatVal = parseFloat(value);
    if (isNaN(floatVal)) {
      return void 0;
    }
    return floatVal;
  }
  function hasConstraint(constraint, value) {
    if (constraint === void 0) {
      return false;
    }
    if (Array.isArray(constraint)) {
      return constraint.includes(value);
    }
    if (typeof constraint === "string") {
      return constraint === value;
    }
    if (constraint instanceof Object) {
      if (constraint.exact) {
        if (hasConstraint(constraint.exact, value)) {
          return true;
        }
      }
      if (constraint.ideal) {
        if (hasConstraint(constraint.ideal, value)) {
          return true;
        }
      }
    }
    return false;
  }

  // srcts/avSettingsMenu.ts
  var DeviceChangeEvent = class extends CustomEvent {
    constructor(type, detail) {
      super(type, { detail });
    }
  };
  var AVSettingsMenuElement = class extends HTMLElement {
    constructor() {
      super();
      this.addEventListener("click", (e) => {
        if (e.target instanceof HTMLAnchorElement) {
          const a = e.target;
          if (a.classList.contains("camera-device-item")) {
            this.cameraId = a.dataset.deviceId;
          } else if (a.classList.contains("mic-device-item")) {
            this.micId = a.dataset.deviceId;
          }
        }
      });
    }
    #setDevices(deviceType, devices) {
      const deviceEls = devices.map(
        (dev) => this.#createDeviceElement(dev, `${deviceType}-device-item`)
      );
      const header = this.querySelector(`.${deviceType}-header`);
      header.after(...deviceEls);
    }
    setCameras(cameras) {
      this.#setDevices("camera", cameras);
    }
    setMics(mics) {
      this.#setDevices("mic", mics);
    }
    setMicsOnly(mics) {
      this.#setDevices("mic", mics);
    }
    get cameraId() {
      return this.#getSelectedDevice("camera");
    }
    set cameraId(id) {
      this.#setSelectedDevice("camera", id);
    }
    get micId() {
      return this.#getSelectedDevice("mic");
    }
    set micId(id) {
      this.#setSelectedDevice("mic", id);
    }
    #createDeviceElement(dev, className) {
      const li = this.ownerDocument.createElement("li");
      const a = li.appendChild(this.ownerDocument.createElement("a"));
      a.onclick = (e) => e.preventDefault();
      a.href = "#";
      a.textContent = dev.label;
      a.dataset.deviceId = dev.deviceId;
      a.className = className;
      a.classList.add("dropdown-item");
      return li;
    }
    #getSelectedDevice(device) {
      return this.querySelector(
        `a.${device}-device-item.active`
      )?.dataset.deviceId ?? null;
    }
    #setSelectedDevice(device, id) {
      this.querySelectorAll(`a.${device}-device-item.active`).forEach(
        (a) => a.classList.remove("active")
      );
      if (id) {
        this.querySelector(
          `a.${device}-device-item[data-device-id="${id}"]`
        ).classList.add("active");
      }
      this.dispatchEvent(
        new DeviceChangeEvent(`${device}-change`, {
          deviceId: id
        })
      );
    }
  };
  customElements.define("av-settings-menu", AVSettingsMenuElement);

  // srcts/audioSpinner.ts
  var AudioSpinnerElement = class extends HTMLElement {
    #audio;
    #canvas;
    #ctx2d;
    #analyzer;
    #dataArray;
    #smoother;
    #secondsOffset = 0;
    #tooltip;
    constructor() {
      super();
      this.attachShadow({ mode: "open" });
      this.shadowRoot.innerHTML = `
        <style>
          :host {
            display: block;
            position: relative;
          }
          ::slotted(canvas) {
            position: absolute;
            top: 0;
            left: 0;
            cursor: pointer;
          }
          ::slotted(audio) {
            display: none;
          }
        </style>
        <slot name="audio"></slot>
        <slot name="canvas"></slot>
        `;
    }
    connectedCallback() {
      const audioSlot = this.shadowRoot.querySelector(
        "slot[name=audio]"
      );
      this.#audio = this.ownerDocument.createElement("audio");
      this.#audio.controls = false;
      this.#audio.src = this.getAttribute("src");
      this.#audio.slot = "audio";
      audioSlot.assign(this.#audio);
      this.#audio.addEventListener("play", () => {
        this.#draw();
      });
      this.#audio.addEventListener("ended", () => {
        if (typeof this.dataset.autodismiss !== "undefined") {
          this.style.transition = "opacity 0.5s 1s";
          this.classList.add("fade");
          this.addEventListener("transitionend", () => {
            this.remove();
          });
        } else {
          this.#secondsOffset += this.#audio.currentTime;
          this.#audio.pause();
          this.#audio.currentTime = 0;
        }
      });
      const canvasSlot = this.shadowRoot.querySelector(
        "slot[name=canvas]"
      );
      this.#canvas = this.ownerDocument.createElement("canvas");
      this.#canvas.slot = "canvas";
      this.#canvas.width = this.clientWidth * window.devicePixelRatio;
      this.#canvas.height = this.clientHeight * window.devicePixelRatio;
      this.#canvas.style.width = this.clientWidth + "px";
      this.#canvas.style.height = this.clientHeight + "px";
      this.#canvas.onclick = () => {
        if (this.#audio.paused) {
          this.#audio.play();
        } else {
          this.#audio.pause();
        }
      };
      this.appendChild(this.#canvas);
      canvasSlot.assign(this.#canvas);
      this.#ctx2d = this.#canvas.getContext("2d");
      new ResizeObserver(() => {
        this.#canvas.width = this.clientWidth * 2;
        this.#canvas.height = this.clientHeight * 2;
        this.#canvas.style.width = this.clientWidth + "px";
        this.#canvas.style.height = this.clientHeight + "px";
      }).observe(this);
      const audioCtx = new AudioContext();
      const source = audioCtx.createMediaElementSource(this.#audio);
      this.#analyzer = new AnalyserNode(audioCtx, {
        fftSize: 2048
      });
      this.#dataArray = new Float32Array(this.#analyzer.frequencyBinCount);
      source.connect(this.#analyzer);
      this.#analyzer.connect(audioCtx.destination);
      const dataArray2 = new Float32Array(this.#analyzer.frequencyBinCount);
      this.#smoother = new Smoother(5, (samples) => {
        for (let i = 0; i < dataArray2.length; i++) {
          dataArray2[i] = 0;
          for (let j = 0; j < samples.length; j++) {
            dataArray2[i] += samples[j][i];
          }
          dataArray2[i] /= samples.length;
        }
        return dataArray2;
      });
      this.#draw();
      if (typeof this.dataset.autoplay !== "undefined") {
        this.#audio.play().catch((err) => {
          this.#showTooltip();
        });
      }
    }
    disconnectedCallback() {
      if (this.#tooltip) {
        this.#tooltip.dispose();
        this.#tooltip = void 0;
      }
      if (!this.#audio.paused) {
        this.#audio.pause();
      }
    }
    #showTooltip() {
      const isMobile = /Mobi/.test(navigator.userAgent);
      const gesture = isMobile ? "Tap" : "Click";
      this.#tooltip = new window.bootstrap.Tooltip(this, {
        title: `${gesture} to play`,
        trigger: "manual",
        placement: "right"
      });
      this.#audio.addEventListener(
        "play",
        () => {
          if (this.#tooltip) {
            this.#tooltip.dispose();
            this.#tooltip = void 0;
          }
        },
        { once: true }
      );
      this.#tooltip.show();
    }
    #draw() {
      if (!this.isConnected) {
        return;
      }
      requestAnimationFrame(() => this.#draw());
      const pixelRatio = window.devicePixelRatio;
      const physicalWidth = this.#canvas.width;
      const physicalHeight = this.#canvas.height;
      const width = physicalWidth / pixelRatio;
      const height = physicalHeight / pixelRatio;
      this.#ctx2d.reset();
      this.#ctx2d.clearRect(0, 0, physicalWidth, physicalHeight);
      this.#ctx2d.scale(pixelRatio, pixelRatio);
      this.#ctx2d.translate(width / 2, height / 2);
      this.#analyzer.getFloatTimeDomainData(this.#dataArray);
      const smoothed = this.#smoother.add(new Float32Array(this.#dataArray));
      let {
        rpm,
        gap,
        stroke,
        minRadius,
        radiusCompression,
        radiusOverscan,
        steps,
        blades
      } = this.#getSettings(width, height);
      if (blades === 0) {
        blades = 1;
        gap = 0;
      }
      stroke = Math.max(0, stroke);
      minRadius = Math.max(0, minRadius);
      steps = Math.max(0, steps);
      const scalarVal = Math.max(0, ...smoothed.map(Math.abs));
      const compressedScalarVal = Math.pow(scalarVal, radiusCompression);
      const maxRadius = Math.min(width, height) / 2 * radiusOverscan;
      const radius = minRadius + compressedScalarVal * (maxRadius - minRadius);
      const sweep = Math.PI * 2 / blades - gap;
      const staticAngle = Math.PI / -2 + // rotate -90 degrees to start at the top
      sweep / -2;
      for (let step = 0; step < steps + 1; step++) {
        const this_radius = radius - step * (radius / (steps + 2));
        if (step === steps) {
          this.#drawPie(0, Math.PI * 2, this_radius, stroke);
        } else {
          const seconds = (this.#audio.currentTime || 0) + this.#secondsOffset;
          const spinVelocity = rpm / 60 * Math.PI * 2;
          const startAngle = staticAngle + seconds * spinVelocity % (Math.PI * 2);
          for (let blade = 0; blade < blades; blade++) {
            const angleOffset = Math.PI * 2 / blades * blade;
            this.#drawPie(startAngle + angleOffset, sweep, this_radius, stroke);
          }
        }
      }
    }
    #drawPie(startAngle, sweep, radius, stroke) {
      this.#ctx2d.beginPath();
      this.#ctx2d.fillStyle = window.getComputedStyle(this.#canvas).color;
      if (!stroke) {
        this.#ctx2d.moveTo(0, 0);
      }
      this.#ctx2d.arc(0, 0, radius, startAngle, startAngle + sweep);
      if (!stroke) {
        this.#ctx2d.lineTo(0, 0);
      } else {
        this.#ctx2d.arc(
          0,
          0,
          radius - stroke,
          startAngle + sweep,
          startAngle,
          true
        );
      }
      this.#ctx2d.fill();
    }
    #getSettings(width, height) {
      const settings = {
        rpm: 10,
        gap: Math.PI / 5,
        stroke: 2.5,
        minRadius: Math.min(width, height) / 6,
        radiusCompression: 0.5,
        radiusOverscan: 1,
        steps: 2,
        blades: 3
      };
      for (const key in settings) {
        const value = tryParseFloat(this.dataset[key]);
        if (typeof value !== "undefined") {
          Object.assign(settings, { [key]: value });
        }
      }
      return settings;
    }
  };
  window.customElements.define("audio-spinner", AudioSpinnerElement);
  var Smoother = class {
    #samples = [];
    #smooth;
    #size;
    #pos;
    constructor(size, smooth) {
      this.#size = size;
      this.#pos = 0;
      this.#smooth = smooth;
    }
    add(sample) {
      this.#samples[this.#pos] = sample;
      this.#pos = (this.#pos + 1) % this.#size;
      return this.smoothed();
    }
    smoothed() {
      return this.#smooth(this.#samples);
    }
  };
  function tryParseFloat(str) {
    if (typeof str === "undefined") {
      return void 0;
    }
    const parsed = parseFloat(str);
    return isNaN(parsed) ? void 0 : parsed;
  }

  // New AudioClipperElement
  class AudioClipperElement extends HTMLElement {
  constructor() {
    super();
    this.chunks = [];
    this.attachShadow({ mode: "open" });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          width: 100%;
          height: min-content;
        }
        .panel-settings {
          margin: 0.5em;
        }
        .panel-buttons {
          margin: 0.5em;
          display: block !important;  /* Force display */
        }
      </style>
      <div class="panel-settings">
        <slot name="settings"></slot>
      </div>
      <div class="panel-buttons">
        <slot name="recording-controls"></slot>
      </div>
    `;
  }

    connectedCallback() {
      (async () => {
        const slotSettings = this.shadowRoot.querySelector(
          "slot[name=settings]"
        );
        slotSettings.addEventListener("slotchange", async () => {
          this.avSettingsMenu = slotSettings.assignedElements()[0];
          await this.#initializeMediaInput();
          if (this.buttonRecord) {
            this.#setEnabledButton(this.buttonRecord);
          }
        });
        const slotControls = this.shadowRoot.querySelector(
          "slot[name=recording-controls]"
        );
        slotControls.addEventListener("slotchange", () => {
          const findButton = (selector) => {
            for (const el of slotControls.assignedElements()) {
              if (el.matches(selector)) {
                return el;
              }
              const sub = el.querySelector(selector);
              if (sub) {
                return sub;
              }
            }
            return null;
          };
          this.buttonRecord = findButton(".record-button");
          this.buttonStop = findButton(".stop-button");
          this.#setEnabledButton();
          this.buttonRecord.addEventListener("click", () => {
            this.dispatchEvent(new CustomEvent("recordstart"));
            this.#setEnabledButton(this.buttonStop);
            this._beginRecord();
          });
          this.buttonStop.addEventListener("click", () => {
            this._endRecord();
            this.#setEnabledButton(this.buttonRecord);
          });
        });
      })().catch((err) => {
        console.error(err);
      });
    }

    #setEnabledButton(btn) {
      this.buttonRecord.style.display = btn === this.buttonRecord ? "inline-block" : "none";
      this.buttonStop.style.display = btn === this.buttonStop ? "inline-block" : "none";
    }

    async setMediaDevices(micId) {
      if (this.audioStream) {
        this.audioStream.getTracks().forEach((track) => track.stop());
      }
      this.audioStream = await navigator.mediaDevices.getUserMedia({
        audio: {
          deviceId: micId || undefined,
        },
      });
      return {
        micId: this.audioStream.getAudioTracks()[0].getSettings().deviceId,
      };
    }

    async #initializeMediaInput() {
      const savedMic = window.localStorage.getItem("multimodal-mic");
      const { micId } = await this.setMediaDevices(savedMic);
      const devices = await navigator.mediaDevices.enumerateDevices();
      this.avSettingsMenu.setMicsOnly(
        devices.filter((dev) => dev.kind === "audioinput")
      );
      this.avSettingsMenu.micId = micId;
      const handleDeviceChange = async (deviceType, deviceId) => {
        if (!deviceId) return;
        window.localStorage.setItem(`multimodal-${deviceType}`, deviceId);
        await this.setMediaDevices(this.avSettingsMenu.micId);
      };
      this.avSettingsMenu.addEventListener("mic-change", (e) => {
        handleDeviceChange("mic", this.avSettingsMenu.micId);
      });
    }

    _beginRecord() {
      this.recorder = new MediaRecorder(this.audioStream, {
        mimeType: this.dataset.mimeType,
        audioBitsPerSecond: safeFloat(this.dataset.audioBitsPerSecond)
      });
      this.recorder.addEventListener("error", (e) => {
        console.error("MediaRecorder error:", e.error);
      });
      this.recorder.addEventListener("dataavailable", (e) => {
        this.chunks.push(e.data);
      });
      this.recorder.addEventListener("start", () => {
      });
      this.recorder.addEventListener("stop", () => {
        if (this.chunks.length === 0) {
          console.warn("No data recorded");
          return;
        }
        const blob = new Blob(this.chunks, { type: this.chunks[0].type });
        const event = new BlobEvent("data", {
          data: blob
        });
        try {
          this.dispatchEvent(event);
        } finally {
          this.chunks = [];
        }
      });
      this.recorder.start();
    }

    _endRecord() {
      this.recorder.stop();
    }
  }

  customElements.define("audio-clipper", AudioClipperElement);

  // srcts/index.ts
  if (window.Shiny) {
    let bustAutoPlaySuppression = function() {
      const audioContext = new AudioContext();
      const buffer = audioContext.createBuffer(
        1,
        audioContext.sampleRate * 105,
        audioContext.sampleRate
      );
      const destination = audioContext.createMediaStreamDestination();
      const source = audioContext.createBufferSource();
      source.buffer = buffer;
      source.connect(destination);
      source.start();
      const audioElement = document.createElement("audio");
      audioElement.controls = true;
      audioElement.autoplay = true;
      audioElement.style.display = "none";
      audioElement.addEventListener("play", () => {
        audioElement.remove();
      });
      audioElement.srcObject = destination.stream;
      document.body.appendChild(audioElement);
      document.body.addEventListener(
        "click",
        () => {
          audioElement.play();
        },
        { capture: true, once: true }
      );
    };
    bustAutoPlaySuppression2 = bustAutoPlaySuppression;
    class VideoClipperBinding extends Shiny.InputBinding {
      #lastKnownValue = /* @__PURE__ */ new WeakMap();
      #handlers = /* @__PURE__ */ new WeakMap();
      find(scope) {
        return $(scope).find("video-clipper.shiny-video-clip");
      }
      getValue(el) {
        return this.#lastKnownValue.get(el);
      }
      subscribe(el, callback) {
        const handler = async (ev) => {
          const blob = ev.data;
          console.log(
            `Recorded video of type ${blob.type} and size ${blob.size} bytes`
          );
          const encoded = `data:${blob.type};base64,${await base64(blob)}`;
          this.#lastKnownValue.set(el, encoded);
          callback(true);
        };
        el.addEventListener("data", handler);
        const handler2 = (ev) => {
          if (typeof el.dataset.resetOnRecord !== "undefined") {
            this.#lastKnownValue.set(el, null);
            callback(true);
          }
        };
        el.addEventListener("recordstart", handler2);
        this.#handlers.set(el, [handler, handler2]);
      }
      unsubscribe(el) {
        const handlers = this.#handlers.get(el);
        el.removeEventListener("data", handlers[0]);
        el.removeEventListener("recordstart", handlers[1]);
        this.#handlers.delete(el);
      }
    }
    window.Shiny.inputBindings.register(
      new VideoClipperBinding(),
      "video-clipper"
    );

    // New AudioClipperBinding
    class AudioClipperBinding extends Shiny.InputBinding {
      #lastKnownValue = new WeakMap();
      #handlers = new WeakMap();

      find(scope) {
        return $(scope).find("audio-clipper.shiny-audio-clip");
      }

      getValue(el) {
        return this.#lastKnownValue.get(el);
      }

      subscribe(el, callback) {
        const handler = async (ev) => {
          const blob = ev.data;
          console.log(`Recorded audio of type ${blob.type} and size ${blob.size} bytes`);
          const encoded = `data:${blob.type};base64,${await base64(blob)}`;
          this.#lastKnownValue.set(el, encoded);
          callback(true);
        };
        el.addEventListener("data", handler);

        const handler2 = (ev) => {
          if (typeof el.dataset.resetOnRecord !== "undefined") {
            this.#lastKnownValue.set(el, null);
            callback(true);
          }
        };
        el.addEventListener("recordstart", handler2);

        this.#handlers.set(el, [handler, handler2]);
      }

      unsubscribe(el) {
        const handlers = this.#handlers.get(el);
        el.removeEventListener("data", handlers[0]);
        el.removeEventListener("recordstart", handlers[1]);
        this.#handlers.delete(el);
      }
    }

    window.Shiny.inputBindings.register(
      new AudioClipperBinding(),
      "audio-clipper"
    );

    async function base64(blob) {
      const buf = await blob.arrayBuffer();
      const results = [];
      const CHUNKSIZE = 1024;
      for (let i = 0; i < buf.byteLength; i += CHUNKSIZE) {
        const chunk = buf.slice(i, i + CHUNKSIZE);
        results.push(String.fromCharCode(...new Uint8Array(chunk)));
      }
      return btoa(results.join(""));
    }

    document.addEventListener("DOMContentLoaded", bustAutoPlaySuppression);
  }
  var bustAutoPlaySuppression2;
})();
