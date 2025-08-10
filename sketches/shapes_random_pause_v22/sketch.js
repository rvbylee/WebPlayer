// https://editor.p5js.org/jht9629-nyu/sketches/n0LYuXRmX
// shapes random pause v22
let my = {};
let n, i, arr;
function setup() {
  my.nshapes = 5;
  createCanvas(windowWidth, windowHeight);
  init_page();
  // frameRate(2);
  npause = getTargetFrameRate() * 5;
//  ipause = 0;
  setup_fullScreenButton()
}
function draw() {
  if (ipause > 0) {
    ipause = ipause - 1;
    if (ipause <= 0) {
      init_page();
    }
    return;
  }
  if (i >= arr.length) {
    ipause = npause;
    return;
  }
  let [x, y] = arr[i];
  draw_bullseye(w + x, h + y, w, h);
  i = i + 1;
}
function init_vars() {
  ipause = 0;
  let p = my.nshapes;
  w = Math.floor(width / p);
  // w = Math.round(width / p);
  h = w;
  // h = Math.round(height / p);
  let mr = 1;
  mwidth = width - w * mr;
  mheight = height - h * mr;
  i = 0;
  arr = [];
  for (let y = 0; y < mheight; y += h) {
    for (let x = 0; x < mwidth; x += w) {
      arr.push([x, y]);
    }
  }
  shuffle(arr, true);
}
function draw_bullseye(x, y, w, h) {
  fill(random(255), random(255), random(255));
  ellipse(x, y, w, h);
  fill(random(255), random(255), random(255));
  ellipse(x, y, w * 0.75, h * 0.75);
  fill(random(255), random(255), random(255));
  ellipse(x, y, w * 0.5, h * 0.5);
  fill(random(255), random(255), random(255));
  ellipse(x, y, w * 0.25, h * 0.25);
}
function init_page() {
  init_vars();
  background(random(255), random(255), random(255));
}
function mousePressed() {
  init_page();
}
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  init_page();
}

function plusAction() {
  my.nshapes += 1;
  init_page()
}

function minusAction() {
  my.nshapes -= 1;
  init_page()
}

// --
function setup_fullScreenButton() {
  my.fullScreenButton = createButton("?=v22 Full Screen");
  my.fullScreenButton.mousePressed(fullScreen_action);
  my.fullScreenButton.style("font-size:42px");
}

function fullScreen_action() {
  my.fullScreenButton.remove();
  fullscreen(1);
  let delay = 3000;
  setTimeout(ui_present_window, delay);
}

function ui_present_window() {
  resizeCanvas(windowWidth, windowHeight);
  init_vars()
  // init_dim();
}

// Respond to window resizing event
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
}

// https://editor.p5js.org/jht9629-nyu/sketches/KpCniSa1w
// shapes random frameRate v15

// https://editor.p5js.org/jht9629-nyu/sketches/GzlO70dCj
// shapes random array v17

// https://editor.p5js.org/jht9629-nyu/sketches/pW2RT5UHy
// shapes random array circle v20

// https://editor.p5js.org/jht9629-nyu/sketches/Iru8nBTSf
// shapes random pause v21
