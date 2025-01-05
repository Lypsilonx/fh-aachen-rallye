#import "@preview/tiaoma:0.2.1"
#import "@preview/suiji:0.3.0"

#set page(margin: 0pt)

#let fharCode(id, scale) = {
  box(
    stroke: (thickness: 1em * scale, paint: orange),
    radius: 2em * scale,
    inset: 2em * scale,
  )[
    #tiaoma.qrcode(
      "FHAR-" + id,
      options: (
        scale: 8.0,
        fg-color: blue,
        output-options: (
          barcode-dotty-mode: true
        ),
        dot-size: 1.2,
      )
    )

    #place(
      bottom + center,
      dy: 2.8em * scale,
    )[
    #box(
      fill: white,
      width: 90%,
      inset: 0.25em * scale,
    )[
        #text(
          font: "Futura",
          weight: 700,
          size: 1.5em * scale,
        )[
          FHAR-#id
        ]
      ]
    ]
  ]
}

#let random_code(seed) = {
  // random 8 digit code (numbers and letters)
  let code = ""
  let rng = suiji.gen-rng-f(seed)
  let a = ()
  (rng, a) = suiji.integers-f(rng, high: 35, size: 8)
  for r in a {
    if (r < 10) {
      r = str(r)
    } else {
      r = str.from-unicode(r + 55)
    }
    code = code + r
  }

  return code
}

#let random_codes(n, seed) = {
  let codes = ()
  for i in range(n) {
    codes = codes + (random_code(seed + i),)
  }
  return codes
}

#let codes = random_codes(9, 123)

#grid(
  columns: 3,
  inset: 1em,
  ..codes.map(id => fharCode(id, 0.7))
)